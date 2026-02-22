class RunConditions {
  const RunConditions({
    this.syncOnWifiOnly = false,
    this.syncOnChargingOnly = false,
    this.syncOnBatterySaverOff = true,
    this.allowedSsids = const <String>[],
  });

  final bool syncOnWifiOnly;
  final bool syncOnChargingOnly;
  final bool syncOnBatterySaverOff;
  final List<String> allowedSsids;

  RunConditions copyWith({
    bool? syncOnWifiOnly,
    bool? syncOnChargingOnly,
    bool? syncOnBatterySaverOff,
    List<String>? allowedSsids,
  }) {
    return RunConditions(
      syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
      syncOnChargingOnly: syncOnChargingOnly ?? this.syncOnChargingOnly,
      syncOnBatterySaverOff:
          syncOnBatterySaverOff ?? this.syncOnBatterySaverOff,
      allowedSsids: allowedSsids ?? this.allowedSsids,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'syncOnWifiOnly': syncOnWifiOnly,
      'syncOnChargingOnly': syncOnChargingOnly,
      'syncOnBatterySaverOff': syncOnBatterySaverOff,
      'allowedSsids': allowedSsids,
    };
  }

  factory RunConditions.fromMap(Map<String, dynamic> map) {
    return RunConditions(
      syncOnWifiOnly: map['syncOnWifiOnly'] as bool? ?? false,
      syncOnChargingOnly: map['syncOnChargingOnly'] as bool? ?? false,
      syncOnBatterySaverOff: map['syncOnBatterySaverOff'] as bool? ?? true,
      allowedSsids: List<String>.from(
        (map['allowedSsids'] as List<dynamic>?) ?? const <dynamic>[],
      ),
    );
  }

  factory RunConditions.defaults() {
    return const RunConditions();
  }
}
