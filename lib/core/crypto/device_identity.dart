import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

class DeviceIdentity {
  static String generateDeviceId() {
    final String seed = _buildSeed();
    final Digest hash = sha256.convert(utf8.encode(seed));
    final String compact = hash.toString().toUpperCase().substring(0, 20);

    final List<String> groups = <String>[];
    for (int i = 0; i < compact.length; i += 5) {
      groups.add(compact.substring(i, i + 5));
    }
    return groups.join('-');
  }

  static String _buildSeed() {
    final String host = Platform.localHostname;
    final String os = Platform.operatingSystem;
    final String osVersion = Platform.operatingSystemVersion;
    final String runtime = Platform.version;
    final String cpu = Platform.numberOfProcessors.toString();
    final String user =
        Platform.environment['USERNAME'] ?? Platform.environment['USER'] ?? '';

    return <String>[host, os, osVersion, runtime, cpu, user].join('|');
  }
}
