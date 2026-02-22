import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncsphere/models/device_info.dart';
import 'package:syncsphere/models/sync_job.dart';

class StorageService {
  static const String _jobsKey = 'sync_jobs';
  static const String _devicesKey = 'saved_devices';

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
    final List<Map<String, Object?>> payload = jobs
        .map((SyncJob job) => job.toMap())
        .toList(growable: false);
    await prefs.setString(_jobsKey, jsonEncode(payload));
  }

  Future<List<DeviceInfo>> loadDevices() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_devicesKey);
    if (raw == null || raw.isEmpty) {
      return <DeviceInfo>[];
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <DeviceInfo>[];
    }
    final List<DeviceInfo> devices = <DeviceInfo>[];
    for (final Object? item in decoded) {
      if (item is! Map) continue;
      devices.add(DeviceInfo.fromMap(Map<String, Object?>.from(item)));
    }
    return devices;
  }

  Future<void> saveDevices(List<DeviceInfo> devices) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, Object?>> payload = devices
        .map((DeviceInfo device) => device.toMap())
        .toList(growable: false);
    await prefs.setString(_devicesKey, jsonEncode(payload));
  }
}
