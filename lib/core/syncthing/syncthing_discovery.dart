import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SyncthingDevice {
  SyncthingDevice({
    required this.deviceId,
    required this.name,
    required this.addresses,
    required this.isConnected,
  });

  final String deviceId;
  final String name;
  final List<String> addresses;
  final bool isConnected;

  SyncthingDevice copyWith({
    String? deviceId,
    String? name,
    List<String>? addresses,
    bool? isConnected,
  }) {
    return SyncthingDevice(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      addresses: addresses ?? this.addresses,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class SyncthingDiscovery {
  static const int discoveryPort = 21027;
  static const Duration _discoveryTimeout = Duration(seconds: 5);

  Future<List<SyncthingDevice>> discoverLocalDevices() async {
    final RawDatagramSocket socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
      reuseAddress: true,
      reusePort: true,
    );
    socket.broadcastEnabled = true;

    final Map<String, SyncthingDevice> discovered = <String, SyncthingDevice>{};
    final Completer<void> completer = Completer<void>();

    late final StreamSubscription<RawSocketEvent> subscription;
    subscription = socket.listen(
      (RawSocketEvent event) {
        if (event != RawSocketEvent.read) {
          return;
        }

        Datagram? datagram = socket.receive();
        while (datagram != null) {
          final SyncthingDevice? device = _parseDiscoveryDatagram(datagram);
          if (device != null) {
            discovered[device.deviceId] = device;
          }
          datagram = socket.receive();
        }
      },
      onError: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    try {
      _sendDiscoveryProbe(socket);
      Timer(_discoveryTimeout, () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
      await completer.future;

      final List<SyncthingDevice> devices = discovered.values.toList(growable: false);
      final List<SyncthingDevice> enriched = <SyncthingDevice>[];
      for (final SyncthingDevice device in devices) {
        final InternetAddress? host = _extractHost(device.addresses);
        final bool isReachable = host == null
            ? false
            : await isDeviceReachable(host.address, 22000);
        enriched.add(device.copyWith(isConnected: isReachable));
      }

      return enriched;
    } finally {
      await subscription.cancel();
      socket.close();
    }
  }

  Future<bool> isDeviceReachable(String address, int port) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        address,
        port,
        timeout: const Duration(seconds: 3),
      );
      return true;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } finally {
      await socket?.close();
    }
  }

  void _sendDiscoveryProbe(RawDatagramSocket socket) {
    final List<int> payload = utf8.encode(
      jsonEncode(<String, Object>{
        'type': 'syncthing-discovery',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      }),
    );

    socket.send(payload, InternetAddress('255.255.255.255'), discoveryPort);
  }

  SyncthingDevice? _parseDiscoveryDatagram(Datagram datagram) {
    final String senderAddress = datagram.address.address;

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(datagram.data, allowMalformed: true));
    } on FormatException {
      return SyncthingDevice(
        deviceId: senderAddress,
        name: 'Syncthing Device',
        addresses: <String>['$senderAddress:22000'],
        isConnected: false,
      );
    }

    if (decoded is! Map) {
      return SyncthingDevice(
        deviceId: senderAddress,
        name: 'Syncthing Device',
        addresses: <String>['$senderAddress:22000'],
        isConnected: false,
      );
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
    final String deviceId = _readString(
      map,
      <String>['deviceId', 'id'],
      fallback: senderAddress,
    );
    final String name = _readString(
      map,
      <String>['name', 'deviceName'],
      fallback: 'Syncthing Device',
    );
    final List<String> addresses = _readAddresses(map, senderAddress);

    return SyncthingDevice(
      deviceId: deviceId,
      name: name,
      addresses: addresses,
      isConnected: map['isConnected'] as bool? ?? false,
    );
  }

  String _readString(
    Map<String, dynamic> map,
    List<String> keys, {
    required String fallback,
  }) {
    for (final String key in keys) {
      final Object? value = map[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    final Object? nestedDevice = map['device'];
    if (nestedDevice is Map) {
      final Map<String, dynamic> nested = Map<String, dynamic>.from(nestedDevice);
      for (final String key in keys) {
        final Object? value = nested[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return fallback;
  }

  List<String> _readAddresses(Map<String, dynamic> map, String fallbackAddress) {
    final List<String> addresses = <String>[];

    void collect(Object? value) {
      if (value is String && value.isNotEmpty) {
        addresses.add(value);
        return;
      }
      if (value is List) {
        for (final Object? item in value) {
          if (item is String && item.isNotEmpty) {
            addresses.add(item);
          }
        }
      }
    }

    collect(map['addresses']);
    collect(map['address']);

    final Object? nestedDevice = map['device'];
    if (nestedDevice is Map) {
      final Map<String, dynamic> nested = Map<String, dynamic>.from(nestedDevice);
      collect(nested['addresses']);
      collect(nested['address']);
    }

    if (addresses.isEmpty) {
      addresses.add('$fallbackAddress:22000');
    }

    return addresses.toSet().toList(growable: false);
  }

  InternetAddress? _extractHost(List<String> addresses) {
    for (final String address in addresses) {
      final String host = address.contains(':')
          ? address.substring(0, address.lastIndexOf(':'))
          : address;
      if (host.isEmpty || host == 'dynamic' || host == 'tcp://') {
        continue;
      }

      try {
        return InternetAddress(host);
      } on ArgumentError {
        continue;
      }
    }
    return null;
  }
}
