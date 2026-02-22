import 'dart:io';

import 'package:flutter/services.dart';

import 'package:syncsphere/models/run_conditions.dart';

class RunConditionsService {
  static const MethodChannel _channel = MethodChannel('syncsphere/run_conditions');

  Future<bool> isOnWifi() async {
    try {
      final List<NetworkInterface> interfaces = await NetworkInterface.list(
        includeLoopback: false,
        includeLinkLocal: true,
      );

      final RegExp wifiLikePattern = RegExp(
        r'(wifi|wi-fi|wlan|wl\d*|en0|en1)',
        caseSensitive: false,
      );

      for (final NetworkInterface interface in interfaces) {
        if (wifiLikePattern.hasMatch(interface.name)) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isCharging() async {
    try {
      final bool? value = await _channel.invokeMethod<bool>('isCharging');
      return value ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isBatterySaverEnabled() async {
    try {
      final bool? value = await _channel.invokeMethod<bool>('isBatterySaverEnabled');
      return value ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<String?> getCurrentWifiSsid() async {
    try {
      final String? ssid = await _channel.invokeMethod<String>('getCurrentWifiSsid');
      return ssid;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<bool> shouldSync(RunConditions conditions) async {
    if (conditions.syncOnWifiOnly) {
      final bool onWifi = await isOnWifi();
      if (!onWifi) {
        return false;
      }
    }

    if (conditions.syncOnChargingOnly) {
      final bool charging = await isCharging();
      if (!charging) {
        return false;
      }
    }

    if (conditions.syncOnBatterySaverOff) {
      final bool batterySaverEnabled = await isBatterySaverEnabled();
      if (batterySaverEnabled) {
        return false;
      }
    }

    if (conditions.allowedSsids.isNotEmpty) {
      final String? currentSsid = await getCurrentWifiSsid();
      if (currentSsid == null) {
        return false;
      }

      final String normalizedCurrent = _normalizeSsid(currentSsid);
      final Set<String> allowed = conditions.allowedSsids
          .map(_normalizeSsid)
          .where((String ssid) => ssid.isNotEmpty)
          .toSet();
      if (!allowed.contains(normalizedCurrent)) {
        return false;
      }
    }

    return true;
  }

  String _normalizeSsid(String ssid) {
    return ssid.replaceAll('"', '').trim();
  }
}
