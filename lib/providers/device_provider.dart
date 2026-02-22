import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/device_info.dart';

class DeviceProvider extends ChangeNotifier {
  final List<DeviceInfo> _devices = <DeviceInfo>[];

  UnmodifiableListView<DeviceInfo> get devices =>
      UnmodifiableListView<DeviceInfo>(_devices);

  List<DeviceInfo> get connectedDevices {
    return _devices
        .where((DeviceInfo device) => device.isOnline)
        .toList(growable: false);
  }

  DeviceInfo? getDeviceById(String id) {
    for (final DeviceInfo device in _devices) {
      if (device.id == id) {
        return device;
      }
    }
    return null;
  }

  void setDevices(List<DeviceInfo> devices) {
    _devices
      ..clear()
      ..addAll(devices);
    notifyListeners();
  }

  void addOrUpdateDevice(DeviceInfo device) {
    final int index = _devices.indexWhere((DeviceInfo item) => item.id == device.id);
    if (index == -1) {
      _devices.add(device);
    } else {
      _devices[index] = device;
    }
    notifyListeners();
  }

  void removeDevice(String id) {
    _devices.removeWhere((DeviceInfo device) => device.id == id);
    notifyListeners();
  }

  void markDeviceOnline(
    String id, {
    required bool isOnline,
    DateTime? seenAt,
  }) {
    final int index = _devices.indexWhere((DeviceInfo device) => device.id == id);
    if (index == -1) {
      return;
    }

    final DeviceInfo current = _devices[index];
    _devices[index] = current.copyWith(
      isOnline: isOnline,
      lastSeen: seenAt ?? DateTime.now(),
    );
    notifyListeners();
  }

  void clearDevices() {
    _devices.clear();
    notifyListeners();
  }
}
