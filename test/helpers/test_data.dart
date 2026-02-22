import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/models/sync_result.dart';
import 'package:syncsphere/models/device_info.dart';

/// Creates a [SyncJob] with sensible defaults that can be overridden.
SyncJob createTestSyncJob({
  String id = 'test-job-1',
  String name = 'テスト同期ジョブ',
  String sourcePath = '/storage/emulated/0/Documents',
  String targetPath = '/storage/emulated/0/Backup',
  SyncMode syncMode = SyncMode.mirror,
  CompareMode compareMode = CompareMode.timeAndSize,
  ConnectionType connectionType = ConnectionType.local,
  ScheduleType scheduleType = ScheduleType.manual,
  VersioningType versioningType = VersioningType.none,
  bool isActive = true,
  DateTime? lastSync,
  DateTime? createdAt,
  List<String> filterInclude = const <String>[],
  List<String> filterExclude = const <String>[],
}) {
  return SyncJob(
    id: id,
    name: name,
    sourcePath: sourcePath,
    targetPath: targetPath,
    syncMode: syncMode,
    compareMode: compareMode,
    connectionType: connectionType,
    scheduleType: scheduleType,
    versioningType: versioningType,
    isActive: isActive,
    lastSync: lastSync,
    createdAt: createdAt ?? DateTime(2025, 1, 1),
    filterInclude: filterInclude,
    filterExclude: filterExclude,
  );
}

/// Creates a [DeviceInfo] with sensible defaults.
DeviceInfo createTestDeviceInfo({
  String id = 'device-1',
  String name = 'テスト PC',
  String address = '192.168.1.100',
  int port = 8384,
  ConnectionType connectionType = ConnectionType.lan,
  bool isOnline = true,
  String platform = 'windows',
  DateTime? lastSeen,
  bool isPaired = false,
}) {
  return DeviceInfo(
    id: id,
    name: name,
    address: address,
    port: port,
    connectionType: connectionType,
    isOnline: isOnline,
    lastSeen: lastSeen ?? DateTime(2025, 6, 15, 14, 30),
    platform: platform,
    isPaired: isPaired,
  );
}

/// Creates a [SyncResult] with sensible defaults.
SyncResult createTestSyncResult({
  String jobId = 'test-job-1',
  DateTime? startTime,
  DateTime? endTime,
  int filesCopied = 10,
  int filesDeleted = 2,
  int filesSkipped = 1,
  int conflicts = 0,
  int errors = 0,
  SyncResultStatus status = SyncResultStatus.success,
  String? errorMessage,
}) {
  final DateTime start =
      startTime ?? DateTime(2025, 6, 15, 14, 0);
  final DateTime end =
      endTime ?? DateTime(2025, 6, 15, 14, 5);

  return SyncResult(
    jobId: jobId,
    startTime: start,
    endTime: end,
    filesCopied: filesCopied,
    filesDeleted: filesDeleted,
    filesSkipped: filesSkipped,
    conflicts: conflicts,
    errors: errors,
    status: status,
    errorMessage: errorMessage,
  );
}

/// Convenience: creates a list of N distinct [SyncJob]s.
List<SyncJob> createTestSyncJobs(int count) {
  return List<SyncJob>.generate(count, (int i) {
    return createTestSyncJob(
      id: 'job-$i',
      name: 'ジョブ $i',
      isActive: i == 0,
      lastSync: i.isEven ? DateTime(2025, 6, 15) : null,
    );
  });
}

/// Convenience: creates a list with both online and offline devices.
List<DeviceInfo> createTestDeviceList() {
  return <DeviceInfo>[
    createTestDeviceInfo(
      id: 'online-1',
      name: 'オフィス PC',
      isOnline: true,
      platform: 'windows',
    ),
    createTestDeviceInfo(
      id: 'online-2',
      name: 'MacBook Pro',
      isOnline: true,
      platform: 'macos',
      address: '192.168.1.101',
    ),
    createTestDeviceInfo(
      id: 'offline-1',
      name: '自宅 PC',
      isOnline: false,
      platform: 'linux',
      address: '192.168.1.200',
    ),
  ];
}
