import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SyncthingConfig {
  Future<String> getConfigPath() async {
    if (Platform.isWindows) {
      final String? localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null && localAppData.isNotEmpty) {
        return '$localAppData${Platform.pathSeparator}Syncthing${Platform.pathSeparator}config.xml';
      }

      final String? userProfile = Platform.environment['USERPROFILE'];
      if (userProfile == null || userProfile.isEmpty) {
        throw FileSystemException('Unable to resolve LOCALAPPDATA or USERPROFILE.');
      }
      return '$userProfile${Platform.pathSeparator}AppData${Platform.pathSeparator}Local${Platform.pathSeparator}Syncthing${Platform.pathSeparator}config.xml';
    }

    if (Platform.isAndroid) {
      final Directory directory = await getApplicationSupportDirectory();
      return '${directory.path}${Platform.pathSeparator}config.xml';
    }

    final Directory directory = await getApplicationSupportDirectory();
    return '${directory.path}${Platform.pathSeparator}config.xml';
  }

  Future<Map<String, dynamic>> readConfig() async {
    final String configPath = await getConfigPath();
    final File configFile = File(configPath);
    if (!await configFile.exists()) {
      return _defaultConfig();
    }

    final String xml = await configFile.readAsString();
    if (xml.trim().isEmpty) {
      return _defaultConfig();
    }

    return _normalizeConfig(_parseConfigXml(xml));
  }

  Future<void> writeConfig(Map<String, dynamic> config) async {
    final String configPath = await getConfigPath();
    final File configFile = File(configPath);
    await configFile.parent.create(recursive: true);

    final String xml = _buildConfigXml(_normalizeConfig(config));
    await configFile.writeAsString(xml, flush: true);
  }

  Future<String> getApiKey() async {
    final Map<String, dynamic> config = await readConfig();
    return config['apiKey'] as String? ?? '';
  }

  Future<String> getDeviceId() async {
    final Map<String, dynamic> config = await readConfig();
    return config['deviceId'] as String? ?? '';
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    final Map<String, dynamic> config = await readConfig();
    return _toMapList(config['folders']);
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    final Map<String, dynamic> config = await readConfig();
    return _toMapList(config['devices']);
  }

  Future<void> addFolder({
    required String id,
    required String label,
    required String path,
    List<String> deviceIds = const <String>[],
  }) async {
    final Map<String, dynamic> config = await readConfig();
    final List<Map<String, dynamic>> folders = _toMapList(config['folders']);

    folders.removeWhere((Map<String, dynamic> folder) => folder['id'] == id);
    folders.add(<String, dynamic>{
      'id': id,
      'label': label,
      'path': path,
      'devices': List<String>.from(deviceIds),
    });

    config['folders'] = folders;
    await writeConfig(config);
  }

  Future<void> addDevice({
    required String deviceId,
    required String name,
    List<String> addresses = const <String>['dynamic'],
  }) async {
    final Map<String, dynamic> config = await readConfig();
    final List<Map<String, dynamic>> devices = _toMapList(config['devices']);

    devices.removeWhere((Map<String, dynamic> device) => device['deviceId'] == deviceId);
    devices.add(<String, dynamic>{
      'deviceId': deviceId,
      'name': name,
      'addresses': List<String>.from(addresses),
    });

    config['devices'] = devices;
    await writeConfig(config);
  }

  Future<void> removeFolder(String folderId) async {
    final Map<String, dynamic> config = await readConfig();
    final List<Map<String, dynamic>> folders = _toMapList(config['folders']);
    folders.removeWhere((Map<String, dynamic> folder) => folder['id'] == folderId);
    config['folders'] = folders;
    await writeConfig(config);
  }

  Future<void> removeDevice(String deviceId) async {
    final Map<String, dynamic> config = await readConfig();
    final List<Map<String, dynamic>> devices = _toMapList(config['devices']);
    devices.removeWhere((Map<String, dynamic> device) => device['deviceId'] == deviceId);
    config['devices'] = devices;

    final List<Map<String, dynamic>> folders = _toMapList(config['folders']);
    final List<Map<String, dynamic>> updatedFolders = folders
        .map((Map<String, dynamic> folder) {
          final List<String> folderDevices = _toStringList(folder['devices'])
            ..removeWhere((String id) => id == deviceId);
          return <String, dynamic>{
            ...folder,
            'devices': folderDevices,
          };
        })
        .toList(growable: false);
    config['folders'] = updatedFolders;

    await writeConfig(config);
  }

  Map<String, dynamic> _defaultConfig() {
    return <String, dynamic>{
      'apiKey': '',
      'deviceId': '',
      'folders': <Map<String, dynamic>>[],
      'devices': <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> _parseConfigXml(String xml) {
    final String? apiKey = _matchTag(xml, 'apikey');

    final List<Map<String, dynamic>> devices = <Map<String, dynamic>>[];
    final RegExp deviceRegex = RegExp(
      r'<device\b([^>]*)>([\s\S]*?)</device>',
      caseSensitive: false,
    );
    for (final RegExpMatch match in deviceRegex.allMatches(xml)) {
      final String attrs = match.group(1) ?? '';
      final String body = match.group(2) ?? '';
      final Map<String, String> attributes = _parseAttributes(attrs);
      final String? id = attributes['id'];
      if (id == null || id.isEmpty) {
        continue;
      }

      final String name = _matchTag(body, 'name') ?? '';
      final List<String> addresses = _matchTags(body, 'address');
      devices.add(<String, dynamic>{
        'deviceId': id,
        'name': name,
        'addresses': addresses.isEmpty ? <String>['dynamic'] : addresses,
      });
    }

    final List<Map<String, dynamic>> folders = <Map<String, dynamic>>[];
    final RegExp folderRegex = RegExp(
      r'<folder\b([^>]*)>([\s\S]*?)</folder>',
      caseSensitive: false,
    );
    for (final RegExpMatch match in folderRegex.allMatches(xml)) {
      final String attrs = match.group(1) ?? '';
      final String body = match.group(2) ?? '';
      final Map<String, String> attributes = _parseAttributes(attrs);
      final String id = attributes['id'] ?? '';
      if (id.isEmpty) {
        continue;
      }

      final List<String> folderDevices = <String>[];
      final RegExp folderDeviceRegex = RegExp(
        r'<device\b([^>]*)/?>',
        caseSensitive: false,
      );
      for (final RegExpMatch folderMatch in folderDeviceRegex.allMatches(body)) {
        final String folderDeviceAttrs = folderMatch.group(1) ?? '';
        final Map<String, String> parsed = _parseAttributes(folderDeviceAttrs);
        final String? folderDeviceId = parsed['id'];
        if (folderDeviceId != null && folderDeviceId.isNotEmpty) {
          folderDevices.add(folderDeviceId);
        }
      }

      folders.add(<String, dynamic>{
        'id': id,
        'label': attributes['label'] ?? id,
        'path': attributes['path'] ?? '',
        'devices': folderDevices,
      });
    }

    return <String, dynamic>{
      'apiKey': apiKey ?? '',
      'deviceId': devices.isNotEmpty ? devices.first['deviceId'] as String : '',
      'devices': devices,
      'folders': folders,
    };
  }

  String _buildConfigXml(Map<String, dynamic> config) {
    final String apiKey = config['apiKey'] as String? ?? '';
    final String deviceId = config['deviceId'] as String? ?? '';
    final List<Map<String, dynamic>> devices = _toMapList(config['devices']);
    final List<Map<String, dynamic>> folders = _toMapList(config['folders']);

    Map<String, dynamic>? selfDevice;
    if (deviceId.isNotEmpty) {
      for (final Map<String, dynamic> device in devices) {
        if (device['deviceId'] == deviceId) {
          selfDevice = device;
          break;
        }
      }
    }

    final StringBuffer xml = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<configuration version="37">')
      ..writeln('  <gui enabled="true">')
      ..writeln('    <address>127.0.0.1:8384</address>')
      ..writeln('    <apikey>${_escapeXml(apiKey)}</apikey>')
      ..writeln('  </gui>');

    if (selfDevice != null) {
      final List<String> selfAddresses = _toStringList(selfDevice['addresses']);
      xml.writeln('  <device id="${_escapeXml(deviceId)}">');
      xml.writeln('    <name>${_escapeXml(selfDevice['name'] as String? ?? 'SyncSphere')}</name>');
      for (final String address in selfAddresses) {
        xml.writeln('    <address>${_escapeXml(address)}</address>');
      }
      xml.writeln('  </device>');
    }

    for (final Map<String, dynamic> device in devices) {
      final String id = device['deviceId'] as String? ?? '';
      if (id.isEmpty || id == deviceId) {
        continue;
      }
      final String name = device['name'] as String? ?? id;
      final List<String> addresses = _toStringList(device['addresses']);
      xml.writeln('  <device id="${_escapeXml(id)}">');
      xml.writeln('    <name>${_escapeXml(name)}</name>');
      for (final String address in addresses) {
        xml.writeln('    <address>${_escapeXml(address)}</address>');
      }
      xml.writeln('  </device>');
    }

    for (final Map<String, dynamic> folder in folders) {
      final String id = folder['id'] as String? ?? '';
      if (id.isEmpty) {
        continue;
      }
      final String label = folder['label'] as String? ?? id;
      final String path = folder['path'] as String? ?? '';
      final List<String> folderDevices = _toStringList(folder['devices']);
      xml.writeln(
        '  <folder id="${_escapeXml(id)}" label="${_escapeXml(label)}" path="${_escapeXml(path)}" type="sendreceive">',
      );
      for (final String folderDevice in folderDevices) {
        xml.writeln('    <device id="${_escapeXml(folderDevice)}"/>');
      }
      xml.writeln('  </folder>');
    }

    xml
      ..writeln('  <options>')
      ..writeln('    <listenAddress>default</listenAddress>')
      ..writeln('  </options>')
      ..writeln('</configuration>');

    return xml.toString();
  }

  String? _matchTag(String source, String tag) {
    final RegExp regex = RegExp(
      '<$tag>([^<]*)</$tag>',
      caseSensitive: false,
    );
    final RegExpMatch? match = regex.firstMatch(source);
    if (match == null) {
      return null;
    }
    return _unescapeXml(match.group(1) ?? '');
  }

  List<String> _matchTags(String source, String tag) {
    final RegExp regex = RegExp(
      '<$tag>([^<]*)</$tag>',
      caseSensitive: false,
    );
    return regex
        .allMatches(source)
        .map((RegExpMatch match) => _unescapeXml(match.group(1) ?? ''))
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
  }

  Map<String, String> _parseAttributes(String attributes) {
    final RegExp attrRegex = RegExp(r'([A-Za-z0-9_:\-]+)="([^"]*)"');
    final Map<String, String> map = <String, String>{};
    for (final RegExpMatch match in attrRegex.allMatches(attributes)) {
      final String key = match.group(1) ?? '';
      final String value = _unescapeXml(match.group(2) ?? '');
      if (key.isEmpty) {
        continue;
      }
      map[key] = value;
    }
    return map;
  }

  List<Map<String, dynamic>> _toMapList(Object? value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((Map item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  List<String> _toStringList(Object? value) {
    if (value is! List) {
      return <String>[];
    }
    return value.map((Object? item) => item?.toString() ?? '').where((
      String item,
    ) {
      return item.isNotEmpty;
    }).toList(growable: false);
  }

  String _escapeXml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  String _unescapeXml(String value) {
    return value
        .replaceAll('&apos;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<')
        .replaceAll('&amp;', '&');
  }

  Map<String, dynamic> _normalizeConfig(Map<String, dynamic> config) {
    return Map<String, dynamic>.from(
      jsonDecode(jsonEncode(config)) as Map<String, dynamic>,
    );
  }
}
