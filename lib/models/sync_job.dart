import 'package:syncsphere/models/sync_enums.dart';

export 'package:syncsphere/models/sync_enums.dart'
    show SyncMode, CompareMode, ConnectionType, VersioningType, SyncAction;

enum ScheduleType { manual, interval, daily, weekly, monthly, realtime }

class SyncJob {
  const SyncJob({
    required this.id,
    required this.name,
    required this.sourcePath,
    required this.targetPath,
    this.syncMode = SyncMode.mirror,
    this.compareMode = CompareMode.timeAndSize,
    this.connectionType = ConnectionType.local,
    this.scheduleType = ScheduleType.manual,
    this.filterInclude = const <String>[],
    this.filterExclude = const <String>[],
    this.customRules = const <String, bool>{},
    this.versioningType = VersioningType.none,
    this.retentionDays = 30,
    this.lastSync,
    this.isActive = true,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String sourcePath;
  final String targetPath;
  final SyncMode syncMode;
  final CompareMode compareMode;
  final ConnectionType connectionType;
  final ScheduleType scheduleType;
  final List<String> filterInclude;
  final List<String> filterExclude;
  final Map<String, bool> customRules;
  final VersioningType versioningType;
  final int retentionDays;
  final DateTime? lastSync;
  final bool isActive;
  final DateTime createdAt;

  SyncJob copyWith({
    String? id,
    String? name,
    String? sourcePath,
    String? targetPath,
    SyncMode? syncMode,
    CompareMode? compareMode,
    ConnectionType? connectionType,
    ScheduleType? scheduleType,
    List<String>? filterInclude,
    List<String>? filterExclude,
    Map<String, bool>? customRules,
    VersioningType? versioningType,
    int? retentionDays,
    DateTime? lastSync,
    bool clearLastSync = false,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return SyncJob(
      id: id ?? this.id,
      name: name ?? this.name,
      sourcePath: sourcePath ?? this.sourcePath,
      targetPath: targetPath ?? this.targetPath,
      syncMode: syncMode ?? this.syncMode,
      compareMode: compareMode ?? this.compareMode,
      connectionType: connectionType ?? this.connectionType,
      scheduleType: scheduleType ?? this.scheduleType,
      filterInclude: filterInclude ?? this.filterInclude,
      filterExclude: filterExclude ?? this.filterExclude,
      customRules: customRules ?? this.customRules,
      versioningType: versioningType ?? this.versioningType,
      retentionDays: retentionDays ?? this.retentionDays,
      lastSync: clearLastSync ? null : (lastSync ?? this.lastSync),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'sourcePath': sourcePath,
      'targetPath': targetPath,
      'syncMode': syncMode.name,
      'compareMode': compareMode.name,
      'connectionType': connectionType.name,
      'scheduleType': scheduleType.name,
      'filterInclude': filterInclude,
      'filterExclude': filterExclude,
      'customRules': customRules,
      'versioningType': versioningType.name,
      'retentionDays': retentionDays,
      'lastSync': lastSync?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SyncJob.fromMap(Map<String, Object?> map) {
    return SyncJob(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Untitled Job',
      sourcePath: map['sourcePath'] as String? ?? '',
      targetPath: map['targetPath'] as String? ?? '',
      syncMode: _enumFromName(
        SyncMode.values,
        map['syncMode'],
        SyncMode.mirror,
      ),
      compareMode: _enumFromName(
        CompareMode.values,
        map['compareMode'],
        CompareMode.timeAndSize,
      ),
      connectionType: _enumFromName(
        ConnectionType.values,
        map['connectionType'],
        ConnectionType.local,
      ),
      scheduleType: _enumFromName(
        ScheduleType.values,
        map['scheduleType'],
        ScheduleType.manual,
      ),
      filterInclude: List<String>.from(
        (map['filterInclude'] as List<Object?>?) ?? const <Object?>[],
      ),
      filterExclude: List<String>.from(
        (map['filterExclude'] as List<Object?>?) ?? const <Object?>[],
      ),
      customRules: _mapToBoolMap(map['customRules']),
      versioningType: _enumFromName(
        VersioningType.values,
        map['versioningType'],
        VersioningType.none,
      ),
      retentionDays: map['retentionDays'] as int? ?? 30,
      lastSync: _parseDateTime(map['lastSync']),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
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

  static Map<String, bool> _mapToBoolMap(Object? value) {
    if (value is Map) {
      final Map<String, bool> result = <String, bool>{};
      for (final MapEntry<dynamic, dynamic> entry in value.entries) {
        result[entry.key.toString()] = entry.value == true;
      }
      return result;
    }
    return const <String, bool>{};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncJob && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SyncJob(id: $id, name: $name)';
}
