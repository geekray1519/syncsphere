import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/sync_job.dart';
import '../models/sync_result.dart';

enum SyncState { idle, running, paused, completed, error }

class SyncProvider extends ChangeNotifier {
  final List<SyncJob> _jobs = <SyncJob>[];
  final List<SyncResult> _history = <SyncResult>[];

  SyncState _syncState = SyncState.idle;
  double _progress = 0.0;
  SyncJob? _currentJob;

  UnmodifiableListView<SyncJob> get jobs => UnmodifiableListView<SyncJob>(_jobs);

  UnmodifiableListView<SyncJob> get syncJobs => jobs;

  UnmodifiableListView<SyncResult> get history =>
      UnmodifiableListView<SyncResult>(_history);

  SyncState get syncState => _syncState;
  double get progress => _progress;
  SyncJob? get currentJob => _currentJob;

  bool isComparing(String jobId) => false; // TODO: implement comparison state

  SyncJob? getJobById(String id) {
    for (final SyncJob job in _jobs) {
      if (job.id == id) {
        return job;
      }
    }
    return null;
  }

  void addJob(SyncJob job) {
    if (getJobById(job.id) != null) {
      updateJob(job);
      return;
    }
    _jobs.add(job);
    notifyListeners();
  }

  void updateJob(SyncJob updatedJob) {
    final int index = _jobs.indexWhere((SyncJob job) => job.id == updatedJob.id);
    if (index == -1) {
      return;
    }
    _jobs[index] = updatedJob;
    if (_currentJob?.id == updatedJob.id) {
      _currentJob = updatedJob;
    }
    notifyListeners();
  }

  void removeJob(String id) {
    _jobs.removeWhere((SyncJob job) => job.id == id);
    if (_currentJob?.id == id) {
      _currentJob = null;
      _syncState = SyncState.idle;
      _progress = 0.0;
    }
    notifyListeners();
  }

  void setJobActive(String id, bool isActive) {
    final SyncJob? job = getJobById(id);
    if (job == null) {
      return;
    }
    updateJob(job.copyWith(isActive: isActive));
  }

  void startSync(String jobId) {
    final int jobIndex = _jobs.indexWhere((SyncJob job) => job.id == jobId);
    if (jobIndex == -1) {
      return;
    }

    final SyncJob selectedJob = _jobs[jobIndex];
    final SyncJob runningJob = selectedJob.copyWith(isActive: true);
    _jobs[jobIndex] = runningJob;

    _currentJob = runningJob;
    _syncState = SyncState.running;
    _progress = 0.0;
    notifyListeners();
  }

  void stopSync(String jobId) {
    final int jobIndex = _jobs.indexWhere((SyncJob job) => job.id == jobId);
    if (jobIndex != -1) {
      _jobs[jobIndex] = _jobs[jobIndex].copyWith(isActive: false);
    }

    if (_currentJob?.id == jobId) {
      _currentJob = jobIndex == -1 ? null : _jobs[jobIndex];
    }

    _syncState = SyncState.idle;
    _progress = 0.0;
    notifyListeners();
  }

  void pauseSync() {
    if (_syncState != SyncState.running) {
      return;
    }
    _syncState = SyncState.paused;
    notifyListeners();
  }

  void resumeSync() {
    if (_syncState != SyncState.paused) {
      return;
    }
    _syncState = SyncState.running;
    notifyListeners();
  }

  void updateProgress(double value) {
    _progress = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void completeSync(SyncResult result) {
    _history.insert(0, result);
    _syncState = result.errors > 0 ? SyncState.error : SyncState.completed;
    _progress = 1.0;

    final int jobIndex = _jobs.indexWhere((SyncJob job) => job.id == result.jobId);
    if (jobIndex != -1) {
      final SyncJob job = _jobs[jobIndex];
      final SyncJob updatedJob = job.copyWith(
        lastSync: result.endTime,
        isActive: false,
      );
      _jobs[jobIndex] = updatedJob;
      _currentJob = updatedJob;
    }

    notifyListeners();
  }

  void failCurrentSync() {
    _syncState = SyncState.error;
    notifyListeners();
  }

  void resetSyncState() {
    _syncState = SyncState.idle;
    _progress = 0.0;
    _currentJob = null;
    notifyListeners();
  }
}
