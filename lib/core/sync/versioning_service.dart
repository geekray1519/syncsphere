import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:syncsphere/models/sync_enums.dart';

class VersioningService {
  const VersioningService();

  Future<String?> archiveFile({
    required String originalPath,
    required String rootPath,
    required String relativePath,
    required VersioningType versioningType,
  }) async {
    if (versioningType == VersioningType.none) {
      return null;
    }

    final File source = File(originalPath);
    if (!await source.exists()) {
      return null;
    }

    switch (versioningType) {
      case VersioningType.none:
        return null;
      case VersioningType.trashCan:
        return _moveToTrashByRelative(source, rootPath, relativePath);
      case VersioningType.timestamped:
        return _copyTimestamped(source);
    }
  }

  Future<int> cleanupOldVersions({
    required String rootPath,
    required int retentionDays,
  }) async {
    final Directory versionsDir =
        Directory(p.join(rootPath, '.syncsphere_versions'));
    if (!await versionsDir.exists()) {
      return 0;
    }

    final DateTime cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    int deleted = 0;

    await for (final FileSystemEntity entity
        in versionsDir.list(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }
      final FileStat stat = await entity.stat();
      if (stat.modified.isBefore(cutoff)) {
        await entity.delete();
        deleted++;
      }
    }

    return deleted;
  }

  Future<String?> preserve(String path, VersioningType type) async {
    if (type == VersioningType.none) {
      return null;
    }

    final FileSystemEntityType entityType = await FileSystemEntity.type(
      path,
      followLinks: false,
    );
    if (entityType == FileSystemEntityType.notFound) {
      return null;
    }

    final String mode = type.name;
    if (mode == 'recycleBin' || mode == 'trashCan') {
      return _moveToTrash(path, entityType);
    }
    if (mode == 'versions' || mode == 'timestamped') {
      return _createVersion(path, entityType);
    }
    return null;
  }

  Future<String> _moveToTrash(String path, FileSystemEntityType type) async {
    final Directory trash = Directory(
      p.join(p.dirname(path), '.syncsphere_trash'),
    );
    if (!await trash.exists()) {
      await trash.create(recursive: true);
    }

    final String destination = await _uniquePath(
      p.join(trash.path, p.basename(path)),
    );

    if (type == FileSystemEntityType.directory) {
      await _moveDirectory(path, destination);
    } else {
      await _moveFile(path, destination);
    }

    return destination;
  }

  Future<String> _moveToTrashByRelative(
    File source,
    String rootPath,
    String relativePath,
  ) async {
    final Directory versionsDir =
        Directory(p.join(rootPath, '.syncsphere_versions'));
    await versionsDir.create(recursive: true);

    final String destination = p.join(
      versionsDir.path,
      relativePath.replaceAll('/', p.separator),
    );
    final String uniqueDestination = await _uniquePath(destination);
    await Directory(p.dirname(uniqueDestination)).create(recursive: true);
    final File moved = await source.rename(uniqueDestination);
    return moved.path;
  }

  Future<String> _copyTimestamped(File source) async {
    final String timestamp = _timestamp(DateTime.now());
    final String destination = await _uniquePath('${source.path}.$timestamp');
    final File copied = await source.copy(destination);
    return copied.path;
  }

  Future<String> _createVersion(String path, FileSystemEntityType type) async {
    final String stamp = _timestamp(DateTime.now());
    final String base = type == FileSystemEntityType.directory
        ? '${path}_$stamp'
        : '$path.$stamp';
    final String destination = await _uniquePath(base);

    if (type == FileSystemEntityType.directory) {
      await _copyDirectory(path, destination);
    } else {
      await File(path).copy(destination);
    }

    return destination;
  }

  Future<void> _moveFile(String src, String dst) async {
    final File source = File(src);
    try {
      await source.rename(dst);
    } on FileSystemException {
      await source.copy(dst);
      await source.delete();
    }
  }

  Future<void> _moveDirectory(String src, String dst) async {
    final Directory source = Directory(src);
    try {
      await source.rename(dst);
    } on FileSystemException {
      await _copyDirectory(src, dst);
      await source.delete(recursive: true);
    }
  }

  Future<void> _copyDirectory(String src, String dst) async {
    final Directory destination = Directory(dst);
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    await for (final FileSystemEntity entity in Directory(src).list(
      recursive: true,
      followLinks: false,
    )) {
      final String relative = p.relative(entity.path, from: src);
      final String targetPath = p.join(dst, relative);

      if (entity is Directory) {
        final Directory dir = Directory(targetPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } else if (entity is File) {
        final File target = File(targetPath);
        if (!await target.parent.exists()) {
          await target.parent.create(recursive: true);
        }
        await entity.copy(target.path);
      }
    }
  }

  Future<String> _uniquePath(String basePath) async {
    if (!await _exists(basePath)) {
      return basePath;
    }

    int suffix = 1;
    while (true) {
      final String candidate = '${basePath}_$suffix';
      if (!await _exists(candidate)) {
        return candidate;
      }
      suffix++;
    }
  }

  Future<bool> _exists(String path) async {
    final FileSystemEntityType type = await FileSystemEntity.type(
      path,
      followLinks: false,
    );
    return type != FileSystemEntityType.notFound;
  }

  String _timestamp(DateTime time) {
    final String y = time.year.toString().padLeft(4, '0');
    final String m = time.month.toString().padLeft(2, '0');
    final String d = time.day.toString().padLeft(2, '0');
    final String h = time.hour.toString().padLeft(2, '0');
    final String min = time.minute.toString().padLeft(2, '0');
    final String s = time.second.toString().padLeft(2, '0');
    return '$y-$m-${d}_$h$min$s';
  }
}
