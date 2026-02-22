import 'package:syncsphere/models/sync_enums.dart';

class FileItem {
  FileItem({
    String? path,
    String? name,
    int? size,
    DateTime? modifiedAt,
    this.isDirectory = false,
    SyncAction? syncAction,
    String? relativePath,
    this.sourcePath,
    this.targetPath,
    this.sourceExists = false,
    this.targetExists = false,
    this.sourceSize,
    this.targetSize,
    this.sourceModified,
    this.targetModified,
    this.sourceHash,
    this.targetHash,
    SyncAction? action,
  })  : path = path ?? relativePath ?? '',
        name = name ?? _extractName(path ?? relativePath ?? ''),
        size = size ?? sourceSize ?? targetSize ?? 0,
        modifiedAt = modifiedAt ??
            sourceModified ??
            targetModified ??
            DateTime.fromMillisecondsSinceEpoch(0),
        syncAction = syncAction ?? action ?? SyncAction.skip,
        relativePath = relativePath ?? path ?? '',
        action = action ?? syncAction ?? SyncAction.skip;

  final String path;
  final String name;
  final int size;
  final DateTime modifiedAt;
  final bool isDirectory;
  final SyncAction syncAction;

  final String relativePath;
  final String? sourcePath;
  final String? targetPath;
  final bool sourceExists;
  final bool targetExists;
  final int? sourceSize;
  final int? targetSize;
  final DateTime? sourceModified;
  final DateTime? targetModified;
  final String? sourceHash;
  final String? targetHash;
  final SyncAction action;

  bool get hasSource => sourceExists && sourcePath != null;
  bool get hasTarget => targetExists && targetPath != null;

  FileItem copyWith({
    String? path,
    String? name,
    int? size,
    DateTime? modifiedAt,
    bool? isDirectory,
    SyncAction? syncAction,
    String? relativePath,
    String? sourcePath,
    String? targetPath,
    bool? sourceExists,
    bool? targetExists,
    int? sourceSize,
    int? targetSize,
    DateTime? sourceModified,
    DateTime? targetModified,
    String? sourceHash,
    String? targetHash,
    SyncAction? action,
  }) {
    return FileItem(
      path: path ?? this.path,
      name: name ?? this.name,
      size: size ?? this.size,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      isDirectory: isDirectory ?? this.isDirectory,
      syncAction: syncAction ?? this.syncAction,
      relativePath: relativePath ?? this.relativePath,
      sourcePath: sourcePath ?? this.sourcePath,
      targetPath: targetPath ?? this.targetPath,
      sourceExists: sourceExists ?? this.sourceExists,
      targetExists: targetExists ?? this.targetExists,
      sourceSize: sourceSize ?? this.sourceSize,
      targetSize: targetSize ?? this.targetSize,
      sourceModified: sourceModified ?? this.sourceModified,
      targetModified: targetModified ?? this.targetModified,
      sourceHash: sourceHash ?? this.sourceHash,
      targetHash: targetHash ?? this.targetHash,
      action: action ?? this.action,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'path': path,
      'name': name,
      'size': size,
      'modifiedAt': modifiedAt.millisecondsSinceEpoch,
      'isDirectory': isDirectory,
      'syncAction': syncAction.name,
      'relativePath': relativePath,
      'sourcePath': sourcePath,
      'targetPath': targetPath,
      'sourceExists': sourceExists,
      'targetExists': targetExists,
      'sourceSize': sourceSize,
      'targetSize': targetSize,
      'sourceModified': sourceModified?.millisecondsSinceEpoch,
      'targetModified': targetModified?.millisecondsSinceEpoch,
      'sourceHash': sourceHash,
      'targetHash': targetHash,
      'action': action.name,
    };
  }

  factory FileItem.fromMap(Map<String, Object?> map) {
    final String path =
        map['path'] as String? ?? map['relativePath'] as String? ?? '';
    final SyncAction parsedAction = _enumFromName(
      SyncAction.values,
      map['syncAction'] ?? map['action'],
      SyncAction.skip,
    );

    return FileItem(
      path: path,
      name: map['name'] as String? ?? _extractName(path),
      size: map['size'] as int? ?? (map['sourceSize'] as int?) ?? 0,
      modifiedAt: _fromEpochMs(map['modifiedAt']) ??
          _fromEpochMs(map['sourceModified']) ??
          _fromEpochMs(map['targetModified']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isDirectory: map['isDirectory'] as bool? ?? false,
      syncAction: parsedAction,
      relativePath: map['relativePath'] as String? ?? path,
      sourcePath: map['sourcePath'] as String?,
      targetPath: map['targetPath'] as String?,
      sourceExists: map['sourceExists'] as bool? ?? false,
      targetExists: map['targetExists'] as bool? ?? false,
      sourceSize: map['sourceSize'] as int?,
      targetSize: map['targetSize'] as int?,
      sourceModified: _fromEpochMs(map['sourceModified']),
      targetModified: _fromEpochMs(map['targetModified']),
      sourceHash: map['sourceHash'] as String?,
      targetHash: map['targetHash'] as String?,
      action: parsedAction,
    );
  }

  static DateTime? _fromEpochMs(Object? value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  static T _enumFromName<T extends Enum>(
    List<T> values,
    Object? raw,
    T fallback,
  ) {
    final String? name = raw as String?;
    if (name == null) {
      return fallback;
    }
    for (final T value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }

  static String _extractName(String value) {
    if (value.isEmpty) {
      return '';
    }
    final String normalized = value.replaceAll('\\', '/');
    final int index = normalized.lastIndexOf('/');
    if (index == -1 || index == normalized.length - 1) {
      return normalized;
    }
    return normalized.substring(index + 1);
  }
}
