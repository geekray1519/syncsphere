import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:syncsphere/models/device_info.dart';

class DeviceConnectionService {
  static const int defaultPort = 21090;

  final StreamController<DeviceInfo> _pairedStream =
      StreamController<DeviceInfo>.broadcast();
  final Set<Socket> _sockets = <Socket>{};

  ServerSocket? _server;

  Stream<DeviceInfo> get pairedDevices => _pairedStream.stream;

  Future<void> startServer(DeviceInfo self, {int port = defaultPort}) async {
    await stopServer();
    final ServerSocket server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );

    _server = server;
    server.listen(
      (Socket socket) {
        _sockets.add(socket);
        _handleIncoming(socket, self);
      },
      onError: _pairedStream.addError,
    );
  }

  Future<DeviceInfo?> pairWithDevice({
    required String host,
    required DeviceInfo self,
    int port = defaultPort,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    Socket? socket;
    try {
      socket = await Socket.connect(host, port, timeout: timeout);
      final Map<String, Object?> pairMessage = <String, Object?>{
        'type': 'pair',
        'device': <String, Object?>{
          'id': self.id,
          'name': self.name,
          'platform': self.platform,
        },
      };
      socket.write('${jsonEncode(pairMessage)}\n');

      final String line = await _readLine(socket, timeout);
      final DeviceInfo? ack = _parseAck(line, socket.remoteAddress.address);
      if (ack != null) {
        _pairedStream.add(ack);
      }
      return ack;
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    } on FormatException {
      return null;
    } finally {
      await socket?.close();
      if (socket != null) {
        _sockets.remove(socket);
      }
    }
  }

  Future<void> stopServer() async {
    final ServerSocket? server = _server;
    _server = null;
    await server?.close();

    for (final Socket socket in _sockets.toList(growable: false)) {
      await socket.close();
      _sockets.remove(socket);
    }
  }

  Future<void> dispose() async {
    await stopServer();
    await _pairedStream.close();
  }

  Future<void> _handleIncoming(Socket socket, DeviceInfo self) async {
    try {
      final String line = await _readLine(socket, const Duration(seconds: 10));
      final DeviceInfo? remote = _parsePair(line, socket.remoteAddress.address);
      if (remote == null) {
        return;
      }

      _pairedStream.add(remote);

      final Map<String, Object?> ack = <String, Object?>{
        'type': 'ack',
        'device': <String, Object?>{
          'id': self.id,
          'name': self.name,
          'platform': self.platform,
          'address': self.address,
          'lastSeen': DateTime.now().toIso8601String(),
        },
      };
      socket.write('${jsonEncode(ack)}\n');
    } on TimeoutException {
      // Ignore handshake timeouts.
    } on FormatException {
      // Ignore malformed payloads.
    } finally {
      await socket.close();
      _sockets.remove(socket);
    }
  }

  DeviceInfo? _parsePair(String line, String address) {
    final Object? decoded = jsonDecode(line);
    if (decoded is! Map) {
      return null;
    }

    final Map<String, Object?> map = Map<String, Object?>.from(decoded);
    if (map['type'] != 'pair') {
      return null;
    }

    final Object? deviceRaw = map['device'];
    if (deviceRaw is! Map) {
      return null;
    }
    final Map<String, Object?> device = Map<String, Object?>.from(deviceRaw);

    final String? id = device['id'] as String?;
    final String? name = device['name'] as String?;
    final String? platform = device['platform'] as String?;
    if (id == null || name == null || platform == null) {
      return null;
    }

    return DeviceInfo(
      id: id,
      name: name,
      address: address,
      port: defaultPort,
      isOnline: true,
      lastSeen: DateTime.now(),
      platform: platform,
    );
  }

  DeviceInfo? _parseAck(String line, String defaultAddress) {
    final Object? decoded = jsonDecode(line);
    if (decoded is! Map) {
      return null;
    }

    final Map<String, Object?> map = Map<String, Object?>.from(decoded);
    if (map['type'] != 'ack') {
      return null;
    }

    final Object? deviceRaw = map['device'];
    if (deviceRaw is! Map) {
      return null;
    }
    final Map<String, Object?> device = Map<String, Object?>.from(deviceRaw);

    final String? id = device['id'] as String?;
    final String? name = device['name'] as String?;
    final String? platform = device['platform'] as String?;
    if (id == null || name == null || platform == null) {
      return null;
    }

    return DeviceInfo(
      id: id,
      name: name,
      address: (device['address'] as String?) ?? defaultAddress,
      port: device['port'] as int? ?? defaultPort,
      isOnline: true,
      lastSeen:
          DateTime.tryParse((device['lastSeen'] as String?) ?? '') ?? DateTime.now(),
      platform: platform,
    );
  }

  Future<String> _readLine(Socket socket, Duration timeout) {
    final Completer<String> completer = Completer<String>();
    final StringBuffer buffer = StringBuffer();
    late StreamSubscription<List<int>> subscription;
    Timer? timer;

    void completeWithError(Object error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    timer = Timer(timeout, () {
      completeWithError(TimeoutException('Timed out waiting for peer data.', timeout));
    });

    subscription = socket.listen(
      (List<int> data) {
        final String chunk = utf8.decode(data);
        final int newline = chunk.indexOf('\n');
        if (newline == -1) {
          buffer.write(chunk);
          return;
        }

        buffer.write(chunk.substring(0, newline));
        if (!completer.isCompleted) {
          completer.complete(buffer.toString().trim());
        }
      },
      onError: completeWithError,
      onDone: () {
        if (!completer.isCompleted) {
          completeWithError(StateError('Socket closed before newline payload.'));
        }
      },
      cancelOnError: true,
    );

    return completer.future.whenComplete(() async {
      timer?.cancel();
      await subscription.cancel();
    });
  }
}
