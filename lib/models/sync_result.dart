enum SyncResultStatus { success, partialSuccess, failed, cancelled }

class SyncResult {
  SyncResult({
    required this.jobId,
    required this.startTime,
    required this.endTime,
    int? totalItems,
    int? processedItems,
    int? copiedToTarget,
    int? copiedToSource,
    int? deletedFromTarget,
    int? deletedFromSource,
    int? filesSkipped,
    int? conflicts,
    int? errors,
    this.status = SyncResultStatus.success,
    this.errorMessage,
    int? filesCopied,
    int? filesDeleted,
  })  : copiedToTarget = copiedToTarget ?? filesCopied ?? 0,
        copiedToSource = copiedToSource ?? 0,
        deletedFromTarget = deletedFromTarget ?? filesDeleted ?? 0,
        deletedFromSource = deletedFromSource ?? 0,
        filesSkipped = filesSkipped ?? 0,
        conflicts = conflicts ?? 0,
        errors = errors ?? 0,
        totalItems = totalItems ??
            _deriveTotal(
              copiedToTarget ?? filesCopied ?? 0,
              copiedToSource ?? 0,
              deletedFromTarget ?? filesDeleted ?? 0,
              deletedFromSource ?? 0,
              filesSkipped ?? 0,
              conflicts ?? 0,
            ),
        processedItems = processedItems ??
            (totalItems ??
                _deriveTotal(
                  copiedToTarget ?? filesCopied ?? 0,
                  copiedToSource ?? 0,
                  deletedFromTarget ?? filesDeleted ?? 0,
                  deletedFromSource ?? 0,
                  filesSkipped ?? 0,
                  conflicts ?? 0,
                ));

  final String jobId;
  final DateTime startTime;
  final DateTime endTime;
  final int totalItems;
  final int processedItems;
  final int copiedToTarget;
  final int copiedToSource;
  final int deletedFromTarget;
  final int deletedFromSource;
  final int filesSkipped;
  final int conflicts;
  final int errors;
  final SyncResultStatus status;
  final String? errorMessage;

  int get filesCopied => copiedToTarget + copiedToSource;
  int get filesDeleted => deletedFromTarget + deletedFromSource;
  int get totalBytes => 0;

  Duration get duration => endTime.difference(startTime);

  SyncResult copyWith({
    String? jobId,
    DateTime? startTime,
    DateTime? endTime,
    int? totalItems,
    int? processedItems,
    int? copiedToTarget,
    int? copiedToSource,
    int? deletedFromTarget,
    int? deletedFromSource,
    int? filesSkipped,
    int? conflicts,
    int? errors,
    SyncResultStatus? status,
    String? errorMessage,
  }) {
    return SyncResult(
      jobId: jobId ?? this.jobId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalItems: totalItems ?? this.totalItems,
      processedItems: processedItems ?? this.processedItems,
      copiedToTarget: copiedToTarget ?? this.copiedToTarget,
      copiedToSource: copiedToSource ?? this.copiedToSource,
      deletedFromTarget: deletedFromTarget ?? this.deletedFromTarget,
      deletedFromSource: deletedFromSource ?? this.deletedFromSource,
      filesSkipped: filesSkipped ?? this.filesSkipped,
      conflicts: conflicts ?? this.conflicts,
      errors: errors ?? this.errors,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'jobId': jobId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalItems': totalItems,
      'processedItems': processedItems,
      'copiedToTarget': copiedToTarget,
      'copiedToSource': copiedToSource,
      'deletedFromTarget': deletedFromTarget,
      'deletedFromSource': deletedFromSource,
      'filesSkipped': filesSkipped,
      'conflicts': conflicts,
      'errors': errors,
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  factory SyncResult.fromMap(Map<String, Object?> map) {
    return SyncResult(
      jobId: map['jobId'] as String? ?? '',
      startTime:
          DateTime.tryParse(map['startTime'] as String? ?? '') ?? DateTime.now(),
      endTime:
          DateTime.tryParse(map['endTime'] as String? ?? '') ?? DateTime.now(),
      totalItems: map['totalItems'] as int?,
      processedItems: map['processedItems'] as int?,
      copiedToTarget:
          (map['copiedToTarget'] as int?) ?? (map['filesCopied'] as int?),
      copiedToSource: map['copiedToSource'] as int?,
      deletedFromTarget:
          (map['deletedFromTarget'] as int?) ?? (map['filesDeleted'] as int?),
      deletedFromSource: map['deletedFromSource'] as int?,
      filesSkipped: map['filesSkipped'] as int?,
      conflicts: map['conflicts'] as int?,
      errors: map['errors'] as int?,
      status: _enumFromName(
        SyncResultStatus.values,
        map['status'],
        SyncResultStatus.success,
      ),
      errorMessage: map['errorMessage'] as String?,
    );
  }

  static int _deriveTotal(
    int copiedToTarget,
    int copiedToSource,
    int deletedFromTarget,
    int deletedFromSource,
    int filesSkipped,
    int conflicts,
  ) {
    return copiedToTarget +
        copiedToSource +
        deletedFromTarget +
        deletedFromSource +
        filesSkipped +
        conflicts;
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
}
