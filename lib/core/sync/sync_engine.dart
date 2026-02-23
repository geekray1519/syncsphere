import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:syncsphere/core/sync/conflict_resolver.dart';
import 'package:syncsphere/core/sync/file_comparator.dart';
import 'package:syncsphere/core/sync/filter_engine.dart';
import 'package:syncsphere/core/sync/versioning_service.dart';
import 'package:syncsphere/models/file_item.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/models/sync_result.dart';

class CancellationToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

class SyncProgress {
  const SyncProgress({
    required this.progress,
    required this.currentFile,
    required this.processedItems,
    required this.totalItems,
  });

  final double progress;
  final String currentFile;
  final int processedItems;
  final int totalItems;
}

class SyncEngine {
  SyncEngine({
    this.onProgress,
    FileComparator? comparator,
    FilterEngine? filterEngine,
    VersioningService? versioningService,
    ConflictResolver? conflictResolver,
  }) : _comparator = comparator ?? FileComparator(),
       _filterEngine = filterEngine ?? FilterEngine(),
       _versioningService = versioningService ?? VersioningService(),
       _conflictResolver = conflictResolver ?? ConflictResolver();

  final void Function(double progress, String currentFile)? onProgress;

  final FileComparator _comparator;
  final FilterEngine _filterEngine;
  final VersioningService _versioningService;
  final ConflictResolver _conflictResolver;

  final StreamController<SyncProgress> _progressController =
      StreamController<SyncProgress>.broadcast();

  Stream<SyncProgress> get progressStream => _progressController.stream;

  Future<SyncResult> runSync(
    SyncJob job, {
    CancellationToken? cancellationToken,
  }) async {
    final CancellationToken token = cancellationToken ?? CancellationToken();
    final DateTime startTime = DateTime.now();
    final _Counters counters = _Counters();

    try {
      final Directory sourceRoot = Directory(job.sourcePath);
      if (!await sourceRoot.exists()) {
        counters.errors++;
        return _buildResult(job.id, startTime, counters);
      }

      final Directory targetRoot = Directory(job.targetPath);
      if (!await targetRoot.exists()) {
        await targetRoot.create(recursive: true);
      }

      final List<FileItem> differences = await _comparator.compare(
        job.sourcePath,
        job.targetPath,
        job.compareMode,
      );

      final List<FileItem> candidates = differences.where((FileItem item) {
        return _filterEngine.shouldInclude(
          item.path,
          job.filterInclude,
          job.filterExclude,
        );
      }).toList(growable: false);

      if (candidates.isEmpty) {
        onProgress?.call(1.0, '');
        return _buildResult(job.id, startTime, counters);
      }

      int processed = 0;
      for (final FileItem item in candidates) {
        if (token.isCancelled) {
          return SyncResult(
            jobId: job.id,
            startTime: startTime,
            endTime: DateTime.now(),
            filesCopied: counters.filesCopied,
            filesDeleted: counters.filesDeleted,
            filesSkipped: counters.filesSkipped,
            conflicts: counters.conflicts,
            errors: counters.errors,
            status: SyncResultStatus.cancelled,
          );
        }

        try {
          final _Plan plan = await _planOperation(job, item);
          final _Applied applied = await _applyOperation(job, plan);

          counters.filesCopied += applied.filesCopied;
          counters.filesDeleted += applied.filesDeleted;
          counters.filesSkipped += applied.filesSkipped;
          counters.conflicts += applied.conflicts;
          counters.errors += applied.errors;
          counters.totalBytes += applied.totalBytes;
        } catch (error) {
          debugPrint('[SyncEngine] File operation failed: $error');
          counters.errors++;
          counters.filesSkipped++;
        }

        processed++;
        onProgress?.call(processed / candidates.length, item.path);
        _progressController.add(
          SyncProgress(
            progress: processed / candidates.length,
            currentFile: item.path,
            processedItems: processed,
            totalItems: candidates.length,
          ),
        );
      }
    } catch (error) {
      debugPrint('[SyncEngine] Sync run error: $error');
      counters.errors++;
    }

    return _buildResult(job.id, startTime, counters);
  }

  Future<_Plan> _planOperation(SyncJob job, FileItem item) async {
    if (item.syncAction == SyncAction.copyToTarget) {
      return _Plan.copyToTarget(item.path, item.path);
    }

    if (item.syncAction == SyncAction.copyToSource) {
      switch (job.syncMode) {
        case SyncMode.mirror:
          return _Plan.deleteTarget(item.path);
        case SyncMode.twoWay:
        case SyncMode.custom:
          return _Plan.copyToSource(item.path, item.path);
        case SyncMode.update:
          return _Plan.skip(item.path);
      }
    }

    if (item.syncAction == SyncAction.deleteTarget) {
      switch (job.syncMode) {
        case SyncMode.mirror:
          return _Plan.deleteTarget(item.path);
        case SyncMode.twoWay:
          return _Plan.copyToSource(item.path, item.path);
        case SyncMode.update:
          return _Plan.skip(item.path);
        case SyncMode.custom:
          final bool allowBidirectional =
              job.customRules['allowBidirectional'] ?? false;
          final bool allowDelete = job.customRules['allowDelete'] ?? false;
          if (allowBidirectional) {
            return _Plan.copyToSource(item.path, item.path);
          }
          if (allowDelete) {
            return _Plan.deleteTarget(item.path);
          }
          return _Plan.skip(item.path);
      }
    }

    if (item.syncAction != SyncAction.conflict) {
      return _Plan.skip(item.path);
    }

    final FileItem? targetFile = await _readFileItem(job.targetPath, item.path);
    if (targetFile == null) {
      return _Plan.copyToTarget(item.path, item.path);
    }

    switch (job.syncMode) {
      case SyncMode.mirror:
        final FileItem resolved = _conflictResolver.resolve(
          item,
          targetFile,
          ConflictStrategy.keepSource,
        );
        return _Plan.copyToTarget(item.path, resolved.path, conflicts: 1);
      case SyncMode.twoWay:
        final FileItem resolved = _conflictResolver.resolve(
          item,
          targetFile,
          ConflictStrategy.keepNewer,
        );
        if (resolved.syncAction == SyncAction.copyToSource) {
          return _Plan.copyToSource(item.path, item.path, conflicts: 1);
        }
        return _Plan.copyToTarget(item.path, item.path, conflicts: 1);
      case SyncMode.update:
        final bool sourceNewer =
            item.modifiedAt.millisecondsSinceEpoch >=
            targetFile.modifiedAt.millisecondsSinceEpoch;
        return sourceNewer
            ? _Plan.copyToTarget(item.path, item.path, conflicts: 1)
            : _Plan.skip(item.path, conflicts: 1);
      case SyncMode.custom:
        final FileItem resolved = _conflictResolver.resolve(
          item,
          targetFile,
          ConflictStrategy.keepBoth,
        );
        return _Plan.copyToTarget(item.path, resolved.path, conflicts: 1);
    }
  }

  Future<_Applied> _applyOperation(SyncJob job, _Plan plan) async {
    switch (plan.type) {
      case _PlanType.copyToTarget:
        final _CopyResult copy = await _copyEntity(
          fromRoot: job.sourcePath,
          toRoot: job.targetPath,
          sourceRelative: plan.sourceRelativePath,
          destinationRelative: plan.destinationRelativePath,
          versioningType: job.versioningType,
        );
        return _Applied(
          filesCopied: copy.success ? 1 : 0,
          filesDeleted: 0,
          filesSkipped: copy.success ? 0 : 1,
          conflicts: plan.conflicts,
          errors: 0,
          totalBytes: copy.bytes,
        );
      case _PlanType.copyToSource:
        final _CopyResult copy = await _copyEntity(
          fromRoot: job.targetPath,
          toRoot: job.sourcePath,
          sourceRelative: plan.sourceRelativePath,
          destinationRelative: plan.destinationRelativePath,
          versioningType: job.versioningType,
        );
        return _Applied(
          filesCopied: copy.success ? 1 : 0,
          filesDeleted: 0,
          filesSkipped: copy.success ? 0 : 1,
          conflicts: plan.conflicts,
          errors: 0,
          totalBytes: copy.bytes,
        );
      case _PlanType.deleteTarget:
        final bool deleted = await _deleteEntity(
          rootPath: job.targetPath,
          relativePath: plan.sourceRelativePath,
          versioningType: job.versioningType,
        );
        return _Applied(
          filesCopied: 0,
          filesDeleted: deleted ? 1 : 0,
          filesSkipped: deleted ? 0 : 1,
          conflicts: plan.conflicts,
          errors: 0,
          totalBytes: 0,
        );
      case _PlanType.skip:
        return _Applied(
          filesCopied: 0,
          filesDeleted: 0,
          filesSkipped: 1,
          conflicts: plan.conflicts,
          errors: 0,
          totalBytes: 0,
        );
    }
  }

  Future<_CopyResult> _copyEntity({
    required String fromRoot,
    required String toRoot,
    required String sourceRelative,
    required String destinationRelative,
    required VersioningType versioningType,
  }) async {
    final String sourcePath = p.join(fromRoot, sourceRelative);
    final String destinationPath = p.join(toRoot, destinationRelative);

    final FileSystemEntityType sourceType = await FileSystemEntity.type(
      sourcePath,
      followLinks: false,
    );
    if (sourceType == FileSystemEntityType.notFound) {
      return const _CopyResult(success: false, bytes: 0);
    }

    if (sourceType == FileSystemEntityType.directory) {
      final Directory targetDirectory = Directory(destinationPath);
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }
      return const _CopyResult(success: true, bytes: 0);
    }

    final File destinationFile = File(destinationPath);
    if (!await destinationFile.parent.exists()) {
      await destinationFile.parent.create(recursive: true);
    }

    final FileSystemEntityType destinationType = await FileSystemEntity.type(
      destinationPath,
      followLinks: false,
    );
    if (destinationType != FileSystemEntityType.notFound) {
      await _versioningService.archiveFile(
        originalPath: destinationPath,
        rootPath: toRoot,
        relativePath: destinationRelative,
        versioningType: versioningType,
      );
      final FileSystemEntityType stillExists = await FileSystemEntity.type(
        destinationPath,
        followLinks: false,
      );
      if (stillExists == FileSystemEntityType.file) {
        await File(destinationPath).delete();
      } else if (stillExists == FileSystemEntityType.directory) {
        await Directory(destinationPath).delete(recursive: true);
      }
    }

    final File sourceFile = File(sourcePath);
    final int sourceLength = await sourceFile.length();

    final File tempFile = File(
      p.join(
        destinationFile.parent.path,
        '.syncsphere_tmp_${DateTime.now().microsecondsSinceEpoch}',
      ),
    );

    try {
      await sourceFile.copy(tempFile.path);
      if (await destinationFile.exists()) {
        await destinationFile.delete();
      }
      await tempFile.rename(destinationFile.path);
      return _CopyResult(success: true, bytes: sourceLength);
    } catch (error) {
      debugPrint('[SyncEngine] File copy failed: $error');
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      return const _CopyResult(success: false, bytes: 0);
    }
  }

  Future<bool> _deleteEntity({
    required String rootPath,
    required String relativePath,
    required VersioningType versioningType,
  }) async {
    final String absolutePath = p.join(rootPath, relativePath);
    final FileSystemEntityType type = await FileSystemEntity.type(
      absolutePath,
      followLinks: false,
    );
    if (type == FileSystemEntityType.notFound) {
      return false;
    }

    await _versioningService.archiveFile(
      originalPath: absolutePath,
      rootPath: rootPath,
      relativePath: relativePath,
      versioningType: versioningType,
    );
    final FileSystemEntityType stillExists = await FileSystemEntity.type(
      absolutePath,
      followLinks: false,
    );
    if (stillExists == FileSystemEntityType.file) {
      await File(absolutePath).delete();
    } else if (stillExists == FileSystemEntityType.directory) {
      await Directory(absolutePath).delete(recursive: true);
    }

    return true;
  }

  Future<FileItem?> _readFileItem(String rootPath, String relativePath) async {
    final String absolutePath = p.join(rootPath, relativePath);
    final FileSystemEntityType type = await FileSystemEntity.type(
      absolutePath,
      followLinks: false,
    );
    if (type == FileSystemEntityType.notFound) {
      return null;
    }

    final FileStat stat = await FileStat.stat(absolutePath);
    return FileItem(
      path: relativePath,
      name: p.basename(relativePath),
      size: type == FileSystemEntityType.file ? stat.size : 0,
      modifiedAt: stat.modified,
      isDirectory: type == FileSystemEntityType.directory,
      syncAction: SyncAction.equal,
    );
  }

  SyncResult _buildResult(String jobId, DateTime startTime, _Counters c) {
    final bool hasErrors = c.errors > 0;
    final bool hasChanges = c.filesCopied > 0 || c.filesDeleted > 0;

    final SyncResultStatus status;
    if (!hasErrors && c.conflicts == 0) {
      status = SyncResultStatus.success;
    } else if (hasErrors && !hasChanges) {
      status = SyncResultStatus.failed;
    } else {
      status = SyncResultStatus.partialSuccess;
    }

    return SyncResult(
      jobId: jobId,
      startTime: startTime,
      endTime: DateTime.now(),
      filesCopied: c.filesCopied,
      filesDeleted: c.filesDeleted,
      filesSkipped: c.filesSkipped,
      conflicts: c.conflicts,
      errors: c.errors,
      status: status,
    );
  }

  Future<void> dispose() async {
    await _progressController.close();
  }
}

enum _PlanType { copyToTarget, copyToSource, deleteTarget, skip }

class _Plan {
  const _Plan._({
    required this.type,
    required this.sourceRelativePath,
    required this.destinationRelativePath,
    this.conflicts = 0,
  });

  const _Plan.copyToTarget(
    String sourceRelativePath,
    String destinationRelativePath, {
    int conflicts = 0,
  }) : this._(
         type: _PlanType.copyToTarget,
         sourceRelativePath: sourceRelativePath,
         destinationRelativePath: destinationRelativePath,
         conflicts: conflicts,
       );

  const _Plan.copyToSource(
    String sourceRelativePath,
    String destinationRelativePath, {
    int conflicts = 0,
  }) : this._(
         type: _PlanType.copyToSource,
         sourceRelativePath: sourceRelativePath,
         destinationRelativePath: destinationRelativePath,
         conflicts: conflicts,
       );

  const _Plan.deleteTarget(String relativePath, {int conflicts = 0})
    : this._(
        type: _PlanType.deleteTarget,
        sourceRelativePath: relativePath,
        destinationRelativePath: relativePath,
        conflicts: conflicts,
      );

  const _Plan.skip(String relativePath, {int conflicts = 0})
    : this._(
        type: _PlanType.skip,
        sourceRelativePath: relativePath,
        destinationRelativePath: relativePath,
        conflicts: conflicts,
      );

  final _PlanType type;
  final String sourceRelativePath;
  final String destinationRelativePath;
  final int conflicts;
}

class _Applied {
  const _Applied({
    required this.filesCopied,
    required this.filesDeleted,
    required this.filesSkipped,
    required this.conflicts,
    required this.errors,
    required this.totalBytes,
  });

  final int filesCopied;
  final int filesDeleted;
  final int filesSkipped;
  final int conflicts;
  final int errors;
  final int totalBytes;
}

class _CopyResult {
  const _CopyResult({required this.success, required this.bytes});

  final bool success;
  final int bytes;
}

class _Counters {
  int filesCopied = 0;
  int filesDeleted = 0;
  int filesSkipped = 0;
  int conflicts = 0;
  int errors = 0;
  int totalBytes = 0;
}
