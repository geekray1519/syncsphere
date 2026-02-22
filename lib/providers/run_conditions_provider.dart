import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:syncsphere/core/services/run_conditions_service.dart';
import 'package:syncsphere/models/run_conditions.dart';

class RunConditionsProvider extends ChangeNotifier {
  RunConditionsProvider(
    this._preferences, {
    RunConditionsService? service,
  }) : _service = service ?? RunConditionsService() {
    _loadFromPreferences();
    unawaited(refreshCanSync());
  }

  static const String _storageKey = 'run_conditions';

  final SharedPreferences _preferences;
  final RunConditionsService _service;

  RunConditions _conditions = RunConditions.defaults();
  bool _canSync = true;

  RunConditions get conditions => _conditions;
  bool get canSync => _canSync;

  Future<void> setSyncOnWifiOnly(bool enabled) async {
    await _updateConditions(_conditions.copyWith(syncOnWifiOnly: enabled));
  }

  Future<void> setSyncOnChargingOnly(bool enabled) async {
    await _updateConditions(_conditions.copyWith(syncOnChargingOnly: enabled));
  }

  Future<void> setSyncOnBatterySaverOff(bool enabled) async {
    await _updateConditions(
      _conditions.copyWith(syncOnBatterySaverOff: enabled),
    );
  }

  Future<void> addAllowedSsid(String ssid) async {
    final String value = ssid.trim();
    if (value.isEmpty) {
      return;
    }

    final bool exists = _conditions.allowedSsids
        .any((String item) => item.toLowerCase() == value.toLowerCase());
    if (exists) {
      return;
    }

    await _updateConditions(
      _conditions.copyWith(
        allowedSsids: <String>[..._conditions.allowedSsids, value],
      ),
    );
  }

  Future<void> removeAllowedSsid(String ssid) async {
    final String value = ssid.trim();
    final List<String> next = _conditions.allowedSsids
        .where((String item) => item.toLowerCase() != value.toLowerCase())
        .toList();
    if (next.length == _conditions.allowedSsids.length) {
      return;
    }

    await _updateConditions(_conditions.copyWith(allowedSsids: next));
  }

  Future<void> refreshCanSync() async {
    final bool next = await _service.shouldSync(_conditions);
    if (_canSync == next) {
      return;
    }
    _canSync = next;
    notifyListeners();
  }

  void _loadFromPreferences() {
    final String? raw = _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      _conditions = RunConditions.defaults();
      return;
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map) {
        _conditions = RunConditions.fromMap(
          Map<String, dynamic>.from(decoded),
        );
        return;
      }
    } catch (_) {
      // Fall through to defaults when malformed.
    }

    _conditions = RunConditions.defaults();
  }

  Future<void> _updateConditions(RunConditions next) async {
    if (_isSame(next, _conditions)) {
      return;
    }

    _conditions = next;
    await _preferences.setString(_storageKey, jsonEncode(_conditions.toMap()));
    _canSync = await _service.shouldSync(_conditions);
    notifyListeners();
  }

  bool _isSame(RunConditions a, RunConditions b) {
    if (a.syncOnWifiOnly != b.syncOnWifiOnly ||
        a.syncOnChargingOnly != b.syncOnChargingOnly ||
        a.syncOnBatterySaverOff != b.syncOnBatterySaverOff ||
        a.allowedSsids.length != b.allowedSsids.length) {
      return false;
    }
    for (int i = 0; i < a.allowedSsids.length; i++) {
      if (a.allowedSsids[i] != b.allowedSsids[i]) {
        return false;
      }
    }
    return true;
  }
}
