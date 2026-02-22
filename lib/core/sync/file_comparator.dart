import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:syncsphere/core/sync/filter_engine.dart';
import 'package:syncsphere/models/file_item.dart';
import 'package:syncsphere/models/sync_job.dart';

class FileComparator {
  const FileComparator();

  Future<List<FileItem>> compareDirectories({
    required String sourceRoot,
    required String targetRoot,
    CompareMode mode = CompareMode.timeAndSize,
    FilterEngine? filterEngine,
    bool includeEqual = false,
  }) async {
    final Map<String, _SnapshotFile> sourceFiles =
        await _scanFiles(sourceRoot, filterEngine);
    final Map<String, _SnapshotFile> targetFiles =
        await _scanFiles(targetRoot, filterEngine);

    final List<String> allPaths = <String>{
      ...sourceFiles.keys,
      ...targetFiles.keys,
    }.toList()
      ..sort();

    final List<FileItem> differences = <FileItem>[];
    for (final String relativePath in allPaths) {
      final _SnapshotFile? sourceFile = sourceFiles[relativePath];
      final _SnapshotFile? targetFile = targetFiles[relativePath];

      if (sourceFile != null && targetFile == null) {
        differences.add(
          FileItem(
            relativePath: relativePath,
            sourcePath: sourceFile.absolutePath,
            targetPath: p.join(targetRoot, relativePath),
            sourceExists: true,
            sourceSize: sourceFile.size,
            sourceModified: sourceFile.modifiedAt,
            action: SyncAction.copyToTarget,
          ),
        );
        continue;
      }

      if (sourceFile == null && targetFile != null) {
        differences.add(
          FileItem(
            relativePath: relativePath,
            sourcePath: p.join(sourceRoot, relativePath),
            targetPath: targetFile.absolutePath,
            targetExists: true,
            targetSize: targetFile.size,
            targetModified: targetFile.modifiedAt,
            action: SyncAction.copyToSource,
          ),
        );
        continue;
      }

      if (sourceFile == null || targetFile == null) {
        continue;
      }

      final _PairResult compared =
          await _isDifferent(sourceFile, targetFile, mode);

      if (compared.equal && !includeEqual) {
        continue;
      }

      differences.add(
        FileItem(
          relativePath: relativePath,
          sourcePath: sourceFile.absolutePath,
          targetPath: targetFile.absolutePath,
          sourceExists: true,
          targetExists: true,
          sourceSize: sourceFile.size,
          targetSize: targetFile.size,
          sourceModified: sourceFile.modifiedAt,
          targetModified: targetFile.modifiedAt,
          sourceHash: compared.sourceHash,
          targetHash: compared.targetHash,
          action: compared.equal
              ? SyncAction.equal
              : _newerAction(sourceFile, targetFile),
        ),
      );
    }

    return differences;
  }

  Future<List<FileItem>> compare(
    String sourcePath,
    String targetPath,
    CompareMode mode,
  ) async {
    final CompareMode normalizedMode = _normalizeMode(mode);
    final List<FileItem> raw = await compareDirectories(
      sourceRoot: sourcePath,
      targetRoot: targetPath,
      mode: normalizedMode,
    );

    return raw.map(_normalizeAction).toList(growable: false);
  }

  CompareMode _normalizeMode(CompareMode mode) {
    if (mode.name == 'time') {
      return _findMode('timeAndSize', mode);
    }
    if (mode.name == 'size') {
      return _findMode('sizeOnly', mode);
    }
    return mode;
  }

  CompareMode _findMode(String name, CompareMode fallback) {
    for (final CompareMode item in CompareMode.values) {
      if (item.name == name) {
        return item;
      }
    }
    return fallback;
  }

  FileItem _normalizeAction(FileItem item) {
    if (!item.sourceExists && item.targetExists) {
      return item.copyWith(
        syncAction: SyncAction.deleteTarget,
        action: SyncAction.deleteTarget,
      );
    }

    if (item.sourceExists && item.targetExists && item.action != SyncAction.equal) {
      return item.copyWith(
        syncAction: SyncAction.conflict,
        action: SyncAction.conflict,
      );
    }

    return item.copyWith(syncAction: item.action, action: item.action);
  }

  Future<Map<String, _SnapshotFile>> _scanFiles(
    String rootPath,
    FilterEngine? filter,
  ) async {
    final Directory root = Directory(rootPath);
    if (!await root.exists()) {
      return <String, _SnapshotFile>{};
    }

    final Map<String, _SnapshotFile> files = <String, _SnapshotFile>{};
    await for (final FileSystemEntity entity
        in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }

      final String relativePath =
          p.relative(entity.path, from: rootPath).replaceAll('\\', '/');
      if (filter != null && !filter.shouldIncludePath(relativePath)) {
        continue;
      }

      final FileStat stat = await entity.stat();
      files[relativePath] = _SnapshotFile(
        absolutePath: entity.path,
        size: stat.size,
        modifiedAt: stat.modified,
      );
    }

    return files;
  }

  Future<_PairResult> _isDifferent(
    _SnapshotFile source,
    _SnapshotFile target,
    CompareMode mode,
  ) async {
    switch (mode) {
      case CompareMode.timeAndSize:
        return _PairResult(
          equal: source.size == target.size &&
              source.modifiedAt.millisecondsSinceEpoch ==
                  target.modifiedAt.millisecondsSinceEpoch,
        );
      case CompareMode.sizeOnly:
        return _PairResult(equal: source.size == target.size);
      case CompareMode.content:
        if (source.size != target.size) {
          return const _PairResult(equal: false);
        }
        final List<String> hashes = await Future.wait(<Future<String>>[
          Isolate.run<String>(() => _hashFileSync(source.absolutePath)),
          Isolate.run<String>(() => _hashFileSync(target.absolutePath)),
        ]);
        return _PairResult(
          equal: hashes[0] == hashes[1],
          sourceHash: hashes[0],
          targetHash: hashes[1],
        );
    }
  }

  SyncAction _newerAction(_SnapshotFile source, _SnapshotFile target) {
    if (source.modifiedAt.isAtSameMomentAs(target.modifiedAt)) {
      return SyncAction.conflict;
    }
    return source.modifiedAt.isAfter(target.modifiedAt)
        ? SyncAction.copyToTarget
        : SyncAction.copyToSource;
  }
}

class _SnapshotFile {
  const _SnapshotFile({
    required this.absolutePath,
    required this.size,
    required this.modifiedAt,
  });

  final String absolutePath;
  final int size;
  final DateTime modifiedAt;
}

class _PairResult {
  const _PairResult({
    required this.equal,
    this.sourceHash,
    this.targetHash,
  });

  final bool equal;
  final String? sourceHash;
  final String? targetHash;
}

String _hashFileSync(String path) {
  final List<int> bytes = File(path).readAsBytesSync();
  return sha256.convert(bytes).toString();
}
