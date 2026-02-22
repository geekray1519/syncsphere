import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

class SyncProtocol {
  static const int chunkSize = 1024 * 1024;

  final Map<WebSocket, _UploadState> _uploads = <WebSocket, _UploadState>{};
  final Map<WebSocket, _PendingChunk> _pendingChunks =
      <WebSocket, _PendingChunk>{};

  Future<void> handleMessage(
    WebSocket ws,
    dynamic data,
    String syncDir,
  ) async {
    if (data is String) {
      await _handleJsonMessage(ws, data, syncDir);
      return;
    }

    if (data is List<int>) {
      await _handleBinaryMessage(ws, data, syncDir);
      return;
    }

    await _sendError(ws, 'Unsupported message type received.');
  }

  Future<void> sendFileList(WebSocket ws, String syncDir) async {
    final List<Map<String, Object?>> files = await _scanFiles(syncDir);
    final Map<String, Object?> payload = <String, Object?>{
      'type': 'file_list',
      'files': files,
    };
    ws.add(jsonEncode(payload));
  }

  Future<void> sendFile(
    WebSocket ws,
    String syncDir,
    String relativePath,
  ) async {
    final String? safePath = _safeRelativePath(relativePath);
    if (safePath == null) {
      await _sendError(ws, 'Invalid file path requested: $relativePath');
      return;
    }

    final File file = File(p.join(syncDir, safePath));
    if (!await file.exists()) {
      await _sendError(ws, 'Requested file does not exist: $safePath');
      return;
    }

    final int totalBytes = await file.length();
    final int totalChunks = (totalBytes / chunkSize).ceil();
    final _DigestCollector digestCollector = _DigestCollector();
    final ByteConversionSink hashSink =
        sha256.startChunkedConversion(digestCollector);

    ws.add(
      jsonEncode(
        <String, Object?>{
          'type': 'download_start',
          'path': safePath,
          'size': totalBytes,
          'totalChunks': totalChunks,
        },
      ),
    );

    int transferredBytes = 0;
    final RandomAccessFile randomAccessFile = await file.open(mode: FileMode.read);
    try {
      List<int> chunk = await randomAccessFile.read(chunkSize);
      while (chunk.isNotEmpty) {
        ws.add(chunk);
        hashSink.add(chunk);
        transferredBytes += chunk.length;

        ws.add(
          jsonEncode(
            <String, Object?>{
              'type': 'sync_progress',
              'status': 'syncing',
              'filesProcessed': 0,
              'totalFiles': 1,
              'bytesTransferred': transferredBytes,
              'totalBytes': totalBytes,
            },
          ),
        );

        chunk = await randomAccessFile.read(chunkSize);
      }
    } finally {
      await randomAccessFile.close();
      hashSink.close();
    }

    ws.add(
      jsonEncode(
        <String, Object?>{
          'type': 'download_complete',
          'path': safePath,
          'hash': digestCollector.value?.toString() ?? '',
        },
      ),
    );

    ws.add(
      jsonEncode(
        <String, Object?>{
          'type': 'sync_progress',
          'status': 'complete',
          'filesProcessed': 1,
          'totalFiles': 1,
          'bytesTransferred': totalBytes,
          'totalBytes': totalBytes,
        },
      ),
    );
  }

  Future<void> receiveFile(
    String syncDir,
    String relativePath,
    List<int> data,
  ) async {
    final String? safePath = _safeRelativePath(relativePath);
    if (safePath == null) {
      throw const FormatException('Invalid file path for upload.');
    }

    final String absolutePath = p.join(syncDir, safePath);
    final File file = File(absolutePath);
    final Directory parentDirectory = file.parent;
    if (!await parentDirectory.exists()) {
      await parentDirectory.create(recursive: true);
    }

    await file.writeAsBytes(data, mode: FileMode.append);
  }

  Map<String, List<Map<String, Object?>>> computeSyncPlan(
    List<Map<String, Object?>> files1,
    List<Map<String, Object?>> files2,
  ) {
    final Map<String, Map<String, Object?>> map1 =
        <String, Map<String, Object?>>{};
    final Map<String, Map<String, Object?>> map2 =
        <String, Map<String, Object?>>{};

    for (final Map<String, Object?> file in files1) {
      final String? path = file['path'] as String?;
      final bool isDir = file['isDir'] as bool? ?? false;
      if (path != null && !isDir) {
        map1[path] = file;
      }
    }

    for (final Map<String, Object?> file in files2) {
      final String? path = file['path'] as String?;
      final bool isDir = file['isDir'] as bool? ?? false;
      if (path != null && !isDir) {
        map2[path] = file;
      }
    }

    final List<Map<String, Object?>> toUpload = <Map<String, Object?>>[];
    final List<Map<String, Object?>> toDownload = <Map<String, Object?>>[];
    final List<Map<String, Object?>> conflicts = <Map<String, Object?>>[];

    for (final String path in map1.keys) {
      final Map<String, Object?> file1 = map1[path]!;
      final Map<String, Object?>? file2 = map2[path];

      if (file2 == null) {
        toUpload.add(file1);
        continue;
      }

      final int size1 = file1['size'] as int? ?? 0;
      final int size2 = file2['size'] as int? ?? 0;
      final int modified1 = file1['modified'] as int? ?? 0;
      final int modified2 = file2['modified'] as int? ?? 0;

      if (size1 == size2 && modified1 == modified2) {
        continue;
      }

      if (modified1 > modified2) {
        toUpload.add(file1);
        continue;
      }
      if (modified2 > modified1) {
        toDownload.add(file2);
        continue;
      }

      conflicts.add(
        <String, Object?>{
          'path': path,
          'local': file2,
          'remote': file1,
        },
      );
    }

    for (final String path in map2.keys) {
      if (!map1.containsKey(path)) {
        toDownload.add(map2[path]!);
      }
    }

    return <String, List<Map<String, Object?>>>{
      'toUpload': toUpload,
      'toDownload': toDownload,
      'conflicts': conflicts,
    };
  }

  void handleClientDisconnected(WebSocket ws) {
    _uploads.remove(ws);
    _pendingChunks.remove(ws);
  }

  Future<void> _handleJsonMessage(
    WebSocket ws,
    String payload,
    String syncDir,
  ) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException {
      await _sendError(ws, 'Invalid JSON message.');
      return;
    }

    if (decoded is! Map) {
      await _sendError(ws, 'JSON payload must be an object.');
      return;
    }

    final Map<String, Object?> message = Map<String, Object?>.from(decoded);
    final String? type = message['type'] as String?;

    if (type == null) {
      await _sendError(ws, 'Message type is required.');
      return;
    }

    switch (type) {
      case 'hello':
        await _handleHello(ws, syncDir);
      case 'file_list':
        await _handleRemoteFileList(ws, message, syncDir);
      case 'upload_start':
        await _handleUploadStart(ws, message, syncDir);
      case 'upload_chunk':
        await _handleUploadChunk(ws, message);
      case 'upload_complete':
        await _handleUploadComplete(ws, message);
      case 'request_file':
        await _handleRequestFile(ws, message, syncDir);
      default:
        await _sendError(ws, 'Unsupported message type: $type');
    }
  }

  Future<void> _handleBinaryMessage(
    WebSocket ws,
    List<int> bytes,
    String syncDir,
  ) async {
    final _PendingChunk? pendingChunk = _pendingChunks.remove(ws);
    if (pendingChunk == null) {
      await _sendError(ws, 'Binary frame received without upload_chunk metadata.');
      return;
    }

    final _UploadState? uploadState = _uploads[ws];
    if (uploadState == null || uploadState.path != pendingChunk.path) {
      await _sendError(ws, 'No active upload session for incoming binary frame.');
      return;
    }

    await receiveFile(syncDir, pendingChunk.path, bytes);
    uploadState.receivedBytes += bytes.length;
    uploadState.hashSink.add(bytes);
  }

  Future<void> _handleHello(WebSocket ws, String syncDir) async {
    final int fileCount = await _countFiles(syncDir);
    ws.add(
      jsonEncode(
        <String, Object?>{
          'type': 'welcome',
          'device': Platform.localHostname,
          'syncDir': syncDir,
          'fileCount': fileCount,
        },
      ),
    );
  }

  Future<void> _handleRemoteFileList(
    WebSocket ws,
    Map<String, Object?> message,
    String syncDir,
  ) async {
    final Object? remoteFilesRaw = message['files'];
    if (remoteFilesRaw is! List) {
      await _sendError(ws, 'file_list message must include a files array.');
      return;
    }

    final List<Map<String, Object?>> remoteFiles =
        _normalizeFileList(remoteFilesRaw);
    final List<Map<String, Object?>> localFiles = await _scanFiles(syncDir);

    await sendFileList(ws, syncDir);
    final Map<String, List<Map<String, Object?>>> plan =
        computeSyncPlan(remoteFiles, localFiles);

    ws.add(
      jsonEncode(
        <String, Object?>{
          'type': 'sync_plan',
          'toUpload': plan['toUpload'] ?? <Map<String, Object?>>[],
          'toDownload': plan['toDownload'] ?? <Map<String, Object?>>[],
          'conflicts': plan['conflicts'] ?? <Map<String, Object?>>[],
        },
      ),
    );
  }

  Future<void> _handleUploadStart(
    WebSocket ws,
    Map<String, Object?> message,
    String syncDir,
  ) async {
    final String? relativePath = message['path'] as String?;
    final int? expectedSize = message['size'] as int?;
    if (relativePath == null || expectedSize == null) {
      await _sendError(ws, 'upload_start requires path and size.');
      return;
    }

    final String? safePath = _safeRelativePath(relativePath);
    if (safePath == null) {
      await _sendError(ws, 'Invalid upload path: $relativePath');
      return;
    }

    final File targetFile = File(p.join(syncDir, safePath));
    final Directory parent = targetFile.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    await targetFile.writeAsBytes(const <int>[]);
    _uploads[ws] = _UploadState(
      path: safePath,
      expectedSize: expectedSize,
      receivedBytes: 0,
      hashCollector: _DigestCollector(),
      hashSink: sha256.startChunkedConversion(_DigestCollector()),
    );

    final _UploadState uploadState = _uploads[ws]!;
    uploadState.hashSink.close();
    final _DigestCollector collector = _DigestCollector();
    uploadState.hashCollector.value = collector.value;
    uploadState.hashSink = sha256.startChunkedConversion(uploadState.hashCollector);
  }

  Future<void> _handleUploadChunk(
    WebSocket ws,
    Map<String, Object?> message,
  ) async {
    final String? relativePath = message['path'] as String?;
    final int? index = message['index'] as int?;
    if (relativePath == null || index == null) {
      await _sendError(ws, 'upload_chunk requires path and index.');
      return;
    }

    final String? safePath = _safeRelativePath(relativePath);
    if (safePath == null) {
      await _sendError(ws, 'Invalid upload path: $relativePath');
      return;
    }

    final _UploadState? uploadState = _uploads[ws];
    if (uploadState == null || uploadState.path != safePath) {
      await _sendError(ws, 'upload_chunk received without matching upload_start.');
      return;
    }

    _pendingChunks[ws] = _PendingChunk(path: safePath, index: index);
  }

  Future<void> _handleUploadComplete(
    WebSocket ws,
    Map<String, Object?> message,
  ) async {
    final String? relativePath = message['path'] as String?;
    if (relativePath == null) {
      await _sendError(ws, 'upload_complete requires path.');
      return;
    }

    final String? safePath = _safeRelativePath(relativePath);
    if (safePath == null) {
      await _sendError(ws, 'Invalid upload path: $relativePath');
      return;
    }

    final _UploadState? uploadState = _uploads.remove(ws);
    _pendingChunks.remove(ws);
    if (uploadState == null || uploadState.path != safePath) {
      await _sendError(ws, 'upload_complete received without active upload.');
      return;
    }

    uploadState.hashSink.close();
    final String calculatedHash = uploadState.hashCollector.value?.toString() ?? '';
    final String providedHash = message['hash'] as String? ?? '';

    if (providedHash.isNotEmpty && providedHash != calculatedHash) {
      await _sendError(ws, 'Hash mismatch for uploaded file: $safePath');
      return;
    }

    if (uploadState.receivedBytes != uploadState.expectedSize) {
      await _sendError(
        ws,
        'Size mismatch for $safePath (expected ${uploadState.expectedSize}, received ${uploadState.receivedBytes}).',
      );
      return;
    }

    ws.add(
      jsonEncode(
        <String, Object?>{
          'type': 'sync_progress',
          'status': 'complete',
          'filesProcessed': 1,
          'totalFiles': 1,
          'bytesTransferred': uploadState.receivedBytes,
          'totalBytes': uploadState.expectedSize,
        },
      ),
    );
  }

  Future<void> _handleRequestFile(
    WebSocket ws,
    Map<String, Object?> message,
    String syncDir,
  ) async {
    final String? relativePath = message['path'] as String?;
    if (relativePath == null) {
      await _sendError(ws, 'request_file requires path.');
      return;
    }

    await sendFile(ws, syncDir, relativePath);
  }

  Future<void> _sendError(WebSocket ws, String message) async {
    ws.add(
      jsonEncode(
        <String, Object?>{
          'type': 'error',
          'message': message,
        },
      ),
    );
  }

  Future<int> _countFiles(String syncDir) async {
    final List<Map<String, Object?>> files = await _scanFiles(syncDir);
    int count = 0;
    for (final Map<String, Object?> file in files) {
      final bool isDir = file['isDir'] as bool? ?? false;
      if (!isDir) {
        count += 1;
      }
    }
    return count;
  }

  Future<List<Map<String, Object?>>> _scanFiles(String syncDir) async {
    final Directory root = Directory(syncDir);
    if (!await root.exists()) {
      return <Map<String, Object?>>[];
    }

    final List<Map<String, Object?>> files = <Map<String, Object?>>[];
    await for (final FileSystemEntity entity
        in root.list(recursive: true, followLinks: false)) {
      final String relativePath =
          p.relative(entity.path, from: syncDir).replaceAll('\\', '/');

      if (entity is File) {
        final int size = await entity.length();
        final int modified = (await entity.lastModified()).millisecondsSinceEpoch;
        files.add(
          <String, Object?>{
            'path': relativePath,
            'size': size,
            'modified': modified,
            'isDir': false,
          },
        );
      } else if (entity is Directory) {
        final FileStat stat = await entity.stat();
        final int modified = stat.modified.millisecondsSinceEpoch;
        files.add(
          <String, Object?>{
            'path': relativePath,
            'size': 0,
            'modified': modified,
            'isDir': true,
          },
        );
      }
    }

    files.sort((Map<String, Object?> a, Map<String, Object?> b) {
      final String pathA = a['path'] as String? ?? '';
      final String pathB = b['path'] as String? ?? '';
      return pathA.compareTo(pathB);
    });

    return files;
  }

  List<Map<String, Object?>> _normalizeFileList(List rawFiles) {
    final List<Map<String, Object?>> normalized = <Map<String, Object?>>[];
    for (final Object? rawFile in rawFiles) {
      if (rawFile is! Map) {
        continue;
      }
      final Map<String, Object?> file = Map<String, Object?>.from(rawFile);
      final String? path = file['path'] as String?;
      if (path == null || path.isEmpty) {
        continue;
      }
      normalized.add(file);
    }
    return normalized;
  }

  String? _safeRelativePath(String rawPath) {
    String normalized = rawPath.replaceAll('\\', '/');
    if (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    normalized = p.normalize(normalized).replaceAll('\\', '/');

    if (normalized.isEmpty || normalized == '.') {
      return null;
    }
    if (normalized.startsWith('../') || normalized == '..') {
      return null;
    }
    if (p.isAbsolute(normalized)) {
      return null;
    }
    return normalized;
  }
}

class _UploadState {
  _UploadState({
    required this.path,
    required this.expectedSize,
    required this.receivedBytes,
    required this.hashCollector,
    required this.hashSink,
  });

  final String path;
  final int expectedSize;
  int receivedBytes;
  _DigestCollector hashCollector;
  ByteConversionSink hashSink;
}

class _PendingChunk {
  const _PendingChunk({required this.path, required this.index});

  final String path;
  final int index;
}

class _DigestCollector implements Sink<Digest> {
  Digest? value;

  @override
  void add(Digest data) {
    value = data;
  }

  @override
  void close() {}
}
