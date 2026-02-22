import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncsphere/models/sync_job.dart';

class StorageService {
  static const String _jobsKey = 'sync_jobs';

  Future<List<SyncJob>> loadJobs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_jobsKey);
    if (raw == null || raw.isEmpty) {
      return <SyncJob>[];
    }

    final Object? decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <SyncJob>[];
    }

    final List<SyncJob> jobs = <SyncJob>[];
    for (final Object? item in decoded) {
      if (item is! Map) {
        continue;
      }
      jobs.add(SyncJob.fromMap(Map<String, Object?>.from(item)));
    }

    return jobs;
  }

  Future<void> saveJobs(List<SyncJob> jobs) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, Object?>> payload =
        jobs.map((SyncJob job) => job.toMap()).toList(growable: false);
    await prefs.setString(_jobsKey, jsonEncode(payload));
  }
}
