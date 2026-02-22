import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:syncsphere/models/device_info.dart';

class LanDiscoveryService {
  static const int discoveryPort = 21089;

  final StreamController<DeviceInfo> _deviceStream =
      StreamController<DeviceInfo>.broadcast();
  final Map<String, DeviceInfo> _cache = <String, DeviceInfo>{};

  RawDatagramSocket? _socket;
  DeviceInfo? _self;

  Stream<DeviceInfo> get discoveredDevices => _deviceStream.stream;

  List<DeviceInfo> get devices => _cache.values.toList(growable: false);

  Future<void> start(DeviceInfo self) async {
    _self = self;
    if (_socket != null) {
      return;
    }

    final RawDatagramSocket socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      discoveryPort,
      reuseAddress: true,
      reusePort: true,
    );
    socket.broadcastEnabled = true;
    socket.listen(_onSocketEvent, onError: _deviceStream.addError);
    _socket = socket;
  }

  Future<void> broadcastDiscovery() async {
    final RawDatagramSocket? socket = _socket;
    final DeviceInfo? self = _self;
    if (socket == null || self == null) {
      return;
    }

    final Map<String, Object?> payload = _payload('discovery', self);
    socket.send(
      utf8.encode(jsonEncode(payload)),
      InternetAddress('255.255.255.255'),
      discoveryPort,
    );
  }

  Future<void> stop() async {
    _socket?.close();
    _socket = null;
    _cache.clear();
  }

  Future<void> dispose() async {
    await stop();
    await _deviceStream.close();
  }

  void _onSocketEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) {
      return;
    }

    Datagram? datagram = _socket?.receive();
    while (datagram != null) {
      _onDatagram(datagram);
      datagram = _socket?.receive();
    }
  }

  void _onDatagram(Datagram datagram) {
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(datagram.data));
    } on FormatException {
      return;
    }
    if (decoded is! Map) {
      return;
    }

    final Map<String, Object?> map = Map<String, Object?>.from(decoded);
    final String? type = map['type'] as String?;
    final Object? deviceRaw = map['device'];
    if (type == null || deviceRaw is! Map) {
      return;
    }

    final DeviceInfo? remote = _deviceFrom(
      Map<String, Object?>.from(deviceRaw),
      datagram.address.address,
    );
    if (remote == null) {
      return;
    }

    final DeviceInfo? self = _self;
    if (self != null && remote.id == self.id) {
      return;
    }

    _cache[remote.id] = remote;
    _deviceStream.add(remote);

    if (type == 'discovery' && self != null) {
      final Map<String, Object?> response = _payload('response', self);
      _socket?.send(
        utf8.encode(jsonEncode(response)),
        datagram.address,
        datagram.port,
      );
    }
  }

  Map<String, Object?> _payload(String type, DeviceInfo device) {
    return <String, Object?>{
      'type': type,
      'device': <String, Object?>{
        'id': device.id,
        'name': device.name,
        'address': device.address,
        'port': device.port,
        'platform': device.platform,
        'isOnline': true,
        'lastSeen': DateTime.now().toIso8601String(),
      },
    };
  }

  DeviceInfo? _deviceFrom(Map<String, Object?> map, String senderAddress) {
    final String? id = map['id'] as String?;
    final String? name = map['name'] as String?;
    final String? platform = map['platform'] as String?;
    if (id == null || name == null || platform == null) {
      return null;
    }

    return DeviceInfo(
      id: id,
      name: name,
      address: (map['address'] as String?) ?? senderAddress,
      port: map['port'] as int? ?? discoveryPort,
      isOnline: map['isOnline'] as bool? ?? true,
      lastSeen: DateTime.tryParse((map['lastSeen'] as String?) ?? '') ?? DateTime.now(),
      platform: platform,
    );
  }
}
