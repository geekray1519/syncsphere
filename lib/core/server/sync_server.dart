import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'sync_protocol.dart';

class SyncServer {
  SyncServer({
    required this.webRoot,
    required this.syncDir,
    this.port = 8384,
    SyncProtocol? protocol,
    this.onClientCountChanged,
  }) : _protocol = protocol ?? SyncProtocol();

  final String webRoot;
  final String syncDir;
  final int port;
  final void Function(int clientCount)? onClientCountChanged;

  final SyncProtocol _protocol;
  final Set<WebSocket> _clients = <WebSocket>{};

  HttpServer? _server;

  bool get isRunning => _server != null;

  int get connectedClients => _clients.length;

  Future<void> start() async {
    if (_server != null) {
      return;
    }

    final Directory rootDirectory = Directory(webRoot);
    if (!await rootDirectory.exists()) {
      throw FileSystemException('Web root does not exist.', webRoot);
    }

    final HttpServer server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      port,
    );

    _server = server;
    server.listen(
      _handleRequest,
      onError: (Object error, StackTrace stackTrace) {
        stderr.writeln('SyncServer request error: $error');
      },
      cancelOnError: false,
    );
  }

  Future<void> stop() async {
    final HttpServer? server = _server;
    if (server == null) {
      return;
    }

    _server = null;

    final List<WebSocket> sockets = _clients.toList(growable: false);
    _clients.clear();
    onClientCountChanged?.call(0);

    for (final WebSocket socket in sockets) {
      try {
        await socket.close(WebSocketStatus.goingAway, 'Server stopping');
      } on WebSocketException catch (error) {
        stderr.writeln('WebSocket close error: $error');
      }
      _protocol.handleClientDisconnected(socket);
    }

    await server.close(force: true);
  }

  Future<String> getLocalIpAddress() async {
    try {
      final List<NetworkInterface> interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );

      InternetAddress? fallbackAddress;

      for (final NetworkInterface networkInterface in interfaces) {
        for (final InternetAddress address in networkInterface.addresses) {
          if (!_isPrivateIpv4(address.address)) {
            continue;
          }

          fallbackAddress ??= address;
          if (_looksLikeLanInterface(networkInterface.name)) {
            return address.address;
          }
        }
      }

      return fallbackAddress?.address ?? InternetAddress.loopbackIPv4.address;
    } on SocketException {
      return InternetAddress.loopbackIPv4.address;
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    // Add CORS headers for local network access
    request.response.headers
      ..add('Access-Control-Allow-Origin', '*')
      ..add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
      ..add('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    try {
      final String requestPath = request.uri.path;

      if (requestPath == '/ws') {
        await _handleWebSocketUpgrade(request);
        return;
      }

      // File upload endpoint (Quick Transfer)
      if (requestPath == '/upload' && request.method == 'POST') {
        await _handleFileUpload(request);
        return;
      }

      // File download endpoint
      if (requestPath.startsWith('/files/') && request.method == 'GET') {
        await _handleFileDownload(request);
        return;
      }

      await _serveStaticAsset(request);
    } on Object catch (error) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Internal server error: $error');
      await request.response.close();
    }
  }

  Future<void> _handleWebSocketUpgrade(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Expected WebSocket upgrade request.');
      await request.response.close();
      return;
    }

    final WebSocket socket = await WebSocketTransformer.upgrade(request);
    _clients.add(socket);
    onClientCountChanged?.call(_clients.length);

    socket.listen(
      (dynamic data) {
        unawaited(_protocol.handleMessage(socket, data, syncDir));
      },
      onError: (Object error, StackTrace stackTrace) {
        stderr.writeln('WebSocket error: $error');
        _removeClient(socket);
      },
      onDone: () {
        _removeClient(socket);
      },
      cancelOnError: true,
    );
  }

  Future<void> _handleFileUpload(HttpRequest request) async {
    try {
      final String? boundary =
          request.headers.contentType?.parameters['boundary'];
      if (boundary == null) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Missing multipart boundary.');
        await request.response.close();
        return;
      }

      // Collect all request bytes
      final List<int> allBytes = <int>[];
      await for (final List<int> chunk in request) {
        allBytes.addAll(chunk);
      }

      // Parse multipart boundaries manually
      final String bodyStr = String.fromCharCodes(allBytes);
      final String marker = '--$boundary';
      final List<String> parts = bodyStr.split(marker);

      for (final String part in parts) {
        final String trimmed = part.trim();
        if (trimmed.isEmpty || trimmed == '--') {
          continue;
        }

        final int headerEnd = trimmed.indexOf('\r\n\r\n');
        if (headerEnd == -1) {
          continue;
        }

        final String headerSection = trimmed.substring(0, headerEnd);
        String bodySection = trimmed.substring(headerEnd + 4);
        if (bodySection.endsWith('\r\n')) {
          bodySection = bodySection.substring(0, bodySection.length - 2);
        }

        final RegExp filenameRegex = RegExp(r'filename="([^"]*)"');
        final RegExpMatch? match = filenameRegex.firstMatch(headerSection);
        if (match == null) {
          continue;
        }

        final String filename = match.group(1)!;
        final String filePath = p.join(syncDir, filename);
        final File targetFile = File(filePath);
        final Directory parentDir = targetFile.parent;
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }
        await targetFile.writeAsBytes(bodySection.codeUnits, flush: true);
      }

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write('{"status":"ok"}');
      await request.response.close();
    } on Object catch (error) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Upload failed: $error');
      await request.response.close();
    }
  }

  Future<void> _handleFileDownload(HttpRequest request) async {
    final String relativePath =
        Uri.decodeFull(request.uri.path.substring('/files/'.length));

    final String? safePath = _safeAssetPath(relativePath);
    if (safePath == null) {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
      return;
    }

    final File file = File(p.join(syncDir, safePath));
    if (!await file.exists()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final int fileLength = await file.length();
    final ContentType contentType = _contentTypeFor(safePath);
    final String fileName = p.basename(file.path);

    request.response.headers
      ..contentType = contentType
      ..set('Content-Length', fileLength.toString())
      ..set(
        'Content-Disposition',
        'attachment; filename="${Uri.encodeComponent(fileName)}"',
      );

    await request.response.addStream(file.openRead());
    await request.response.close();
  }

  Future<void> _serveStaticAsset(HttpRequest request) async {
    final String normalizedPath = _normalizeAssetPath(request.uri.path);
    final String? safePath = _safeAssetPath(normalizedPath);
    if (safePath == null) {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
      return;
    }

    final File assetFile = File(p.join(webRoot, safePath));
    if (!await assetFile.exists()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final ContentType contentType = _contentTypeFor(safePath);
    request.response.headers.contentType = contentType;
    await request.response.addStream(assetFile.openRead());
    await request.response.close();
  }

  String _normalizeAssetPath(String rawPath) {
    if (rawPath == '/' || rawPath.isEmpty) {
      return 'index.html';
    }
    final String decoded = Uri.decodeComponent(rawPath);
    return decoded.startsWith('/') ? decoded.substring(1) : decoded;
  }

  String? _safeAssetPath(String rawPath) {
    final String normalized = p.normalize(rawPath).replaceAll('\\', '/');
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

  ContentType _contentTypeFor(String filePath) {
    final String extension = p.extension(filePath).toLowerCase();
    switch (extension) {
      case '.html':
        return ContentType('text', 'html', charset: 'utf-8');
      case '.css':
        return ContentType('text', 'css', charset: 'utf-8');
      case '.js':
        return ContentType('application', 'javascript', charset: 'utf-8');
      case '.png':
        return ContentType('image', 'png');
      case '.svg':
        return ContentType('image', 'svg+xml');
      case '.json':
        return ContentType('application', 'json', charset: 'utf-8');
      case '.woff2':
        return ContentType('font', 'woff2');
      default:
        return ContentType.binary;
    }
  }

  void _removeClient(WebSocket socket) {
    final bool removed = _clients.remove(socket);
    _protocol.handleClientDisconnected(socket);
    if (removed) {
      onClientCountChanged?.call(_clients.length);
    }
  }

  bool _looksLikeLanInterface(String interfaceName) {
    final String name = interfaceName.toLowerCase();
    return name.contains('wlan') ||
        name.contains('wi-fi') ||
        name.contains('wifi') ||
        name.contains('eth') ||
        name.contains('en');
  }

  bool _isPrivateIpv4(String address) {
    if (address.startsWith('10.')) {
      return true;
    }
    if (address.startsWith('192.168.')) {
      return true;
    }
    final List<String> parts = address.split('.');
    if (parts.length != 4) {
      return false;
    }
    final int? secondOctet = int.tryParse(parts[1]);
    if (parts[0] == '172' && secondOctet != null) {
      return secondOctet >= 16 && secondOctet <= 31;
    }
    return false;
  }
}
