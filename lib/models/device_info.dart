import 'package:syncsphere/models/sync_enums.dart';

class DeviceInfo {
  const DeviceInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.port,
    this.connectionType = ConnectionType.lan,
    this.isOnline = true,
    this.lastSeen,
    this.platform = 'unknown',
    this.isPaired = false,
  });

  final String id;
  final String name;
  final String address;
  final int port;
  final ConnectionType connectionType;
  final bool isOnline;
  final DateTime? lastSeen;
  final String platform;
  final bool isPaired;

  DeviceInfo copyWith({
    String? id,
    String? name,
    String? address,
    int? port,
    ConnectionType? connectionType,
    bool? isOnline,
    DateTime? lastSeen,
    bool clearLastSeen = false,
    String? platform,
    bool? isPaired,
  }) {
    return DeviceInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      port: port ?? this.port,
      connectionType: connectionType ?? this.connectionType,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: clearLastSeen ? null : (lastSeen ?? this.lastSeen),
      platform: platform ?? this.platform,
      isPaired: isPaired ?? this.isPaired,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'address': address,
      'port': port,
      'connectionType': connectionType.name,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'platform': platform,
      'isPaired': isPaired,
    };
  }

  factory DeviceInfo.fromMap(Map<String, Object?> map) {
    return DeviceInfo(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      address: map['address'] as String? ?? '',
      port: map['port'] as int? ?? 0,
      connectionType: _enumFromName(
        ConnectionType.values,
        map['connectionType'],
        ConnectionType.lan,
      ),
      isOnline: map['isOnline'] as bool? ?? true,
      lastSeen: _parseDateTime(map['lastSeen']),
      platform: map['platform'] as String? ?? 'unknown',
      isPaired: map['isPaired'] as bool? ?? false,
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static T _enumFromName<T extends Enum>(
    List<T> values,
    Object? raw,
    T fallback,
  ) {
    final String? name = raw as String?;
    if (name == null) {
      return fallback;
    }
    for (final T value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DeviceInfo(id: $id, name: $name)';
}
