import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._preferences) {
    _loadFromPreferences();
  }

  static const String _themeModeKey = 'settings.themeMode';
  static const String _localeLanguageCodeKey = 'settings.localeLanguageCode';
  static const String _bandwidthLimitKey = 'settings.bandwidthLimit';
  static const String _notificationsEnabledKey = 'settings.notificationsEnabled';
  static const String _defaultSyncModeKey = 'settings.defaultSyncMode';
  static const String _downloadBandwidthLimitKey =
      'settings.downloadBandwidthLimit';
  static const String _wifiOnlySyncKey = 'settings.wifiOnlySync';
  static const String _chargingOnlySyncKey = 'settings.chargingOnlySync';
  static const String _powerSaveOffOnlyKey = 'settings.powerSaveOffOnly';
  static const String _allowedSsidsKey = 'settings.allowedSsids';
  static const String _backgroundSyncKey = 'settings.backgroundSync';
  static const String _autoStartOnBootKey = 'settings.autoStartOnBoot';
  static const String _errorNotificationsKey = 'settings.errorNotifications';
  static const String _newDeviceNotificationsKey =
      'settings.newDeviceNotifications';

  final SharedPreferences _preferences;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ja');
  double _bandwidthLimit = 0.0;
  bool _notificationsEnabled = true;
  String _defaultSyncMode = 'mirror';
  double _downloadBandwidthLimit = 0.0;
  bool _wifiOnlySync = true;
  bool _chargingOnlySync = false;
  bool _powerSaveOffOnly = true;
  List<String> _allowedSsids = <String>['MyHomeNetwork', 'Office_5G'];
  bool _backgroundSync = true;
  bool _autoStartOnBoot = false;
  bool _errorNotifications = true;
  bool _newDeviceNotifications = true;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  double get bandwidthLimit => _bandwidthLimit;
  bool get notificationsEnabled => _notificationsEnabled;
  String get defaultSyncMode => _defaultSyncMode;
  double get downloadBandwidthLimit => _downloadBandwidthLimit;
  bool get wifiOnlySync => _wifiOnlySync;
  bool get chargingOnlySync => _chargingOnlySync;
  bool get powerSaveOffOnly => _powerSaveOffOnly;
  List<String> get allowedSsids => List<String>.unmodifiable(_allowedSsids);
  bool get backgroundSync => _backgroundSync;
  bool get autoStartOnBoot => _autoStartOnBoot;
  bool get errorNotifications => _errorNotifications;
  bool get newDeviceNotifications => _newDeviceNotifications;

  void _loadFromPreferences() {
    _themeMode = _themeModeFromString(
      _preferences.getString(_themeModeKey),
      fallback: ThemeMode.system,
    );

    final String languageCode =
        _preferences.getString(_localeLanguageCodeKey) ?? 'ja';
    _locale = Locale(languageCode);
    _bandwidthLimit = _preferences.getDouble(_bandwidthLimitKey) ?? 0.0;
    _notificationsEnabled =
        _preferences.getBool(_notificationsEnabledKey) ?? true;
    _defaultSyncMode = _preferences.getString(_defaultSyncModeKey) ?? 'mirror';
    _downloadBandwidthLimit =
        _preferences.getDouble(_downloadBandwidthLimitKey) ?? 0.0;
    _wifiOnlySync = _preferences.getBool(_wifiOnlySyncKey) ?? true;
    _chargingOnlySync = _preferences.getBool(_chargingOnlySyncKey) ?? false;
    _powerSaveOffOnly = _preferences.getBool(_powerSaveOffOnlyKey) ?? true;
    _allowedSsids = _preferences.getStringList(_allowedSsidsKey) ??
        <String>['MyHomeNetwork', 'Office_5G'];
    _backgroundSync = _preferences.getBool(_backgroundSyncKey) ?? true;
    _autoStartOnBoot = _preferences.getBool(_autoStartOnBootKey) ?? false;
    _errorNotifications = _preferences.getBool(_errorNotificationsKey) ?? true;
    _newDeviceNotifications =
        _preferences.getBool(_newDeviceNotificationsKey) ?? true;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();
    await _preferences.setString(_themeModeKey, mode.name);
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) {
      return;
    }

    _locale = locale;
    notifyListeners();
    await _preferences.setString(_localeLanguageCodeKey, locale.languageCode);
  }

  Future<void> setBandwidthLimit(double limit) async {
    if (limit < 0 || _bandwidthLimit == limit) {
      return;
    }

    _bandwidthLimit = limit;
    notifyListeners();
    await _preferences.setDouble(_bandwidthLimitKey, limit);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) {
      return;
    }

    _notificationsEnabled = enabled;
    notifyListeners();
    await _preferences.setBool(_notificationsEnabledKey, enabled);
  }

  Future<void> setDefaultSyncMode(String mode) async {
    if (_defaultSyncMode == mode) {
      return;
    }

    _defaultSyncMode = mode;
    notifyListeners();
    await _preferences.setString(_defaultSyncModeKey, mode);
  }

  Future<void> setDownloadBandwidthLimit(double limit) async {
    if (limit < 0 || _downloadBandwidthLimit == limit) {
      return;
    }

    _downloadBandwidthLimit = limit;
    notifyListeners();
    await _preferences.setDouble(_downloadBandwidthLimitKey, limit);
  }

  Future<void> setWifiOnlySync(bool enabled) async {
    if (_wifiOnlySync == enabled) {
      return;
    }

    _wifiOnlySync = enabled;
    notifyListeners();
    await _preferences.setBool(_wifiOnlySyncKey, enabled);
  }

  Future<void> setChargingOnlySync(bool enabled) async {
    if (_chargingOnlySync == enabled) {
      return;
    }

    _chargingOnlySync = enabled;
    notifyListeners();
    await _preferences.setBool(_chargingOnlySyncKey, enabled);
  }

  Future<void> setPowerSaveOffOnly(bool enabled) async {
    if (_powerSaveOffOnly == enabled) {
      return;
    }

    _powerSaveOffOnly = enabled;
    notifyListeners();
    await _preferences.setBool(_powerSaveOffOnlyKey, enabled);
  }

  Future<void> setAllowedSsids(List<String> ssids) async {
    if (_areStringListsEqual(_allowedSsids, ssids)) {
      return;
    }

    _allowedSsids = List<String>.from(ssids);
    notifyListeners();
    await _preferences.setStringList(_allowedSsidsKey, _allowedSsids);
  }

  Future<void> addSsid(String ssid) async {
    final String trimmed = ssid.trim();
    if (trimmed.isEmpty || _allowedSsids.contains(trimmed)) {
      return;
    }

    final List<String> nextSsids = List<String>.from(_allowedSsids)
      ..add(trimmed);
    await setAllowedSsids(nextSsids);
  }

  Future<void> removeSsid(String ssid) async {
    if (!_allowedSsids.contains(ssid)) {
      return;
    }

    final List<String> nextSsids = List<String>.from(_allowedSsids)
      ..remove(ssid);
    await setAllowedSsids(nextSsids);
  }

  Future<void> setBackgroundSync(bool enabled) async {
    if (_backgroundSync == enabled) {
      return;
    }

    _backgroundSync = enabled;
    notifyListeners();
    await _preferences.setBool(_backgroundSyncKey, enabled);
  }

  Future<void> setAutoStartOnBoot(bool enabled) async {
    if (_autoStartOnBoot == enabled) {
      return;
    }

    _autoStartOnBoot = enabled;
    notifyListeners();
    await _preferences.setBool(_autoStartOnBootKey, enabled);
  }

  Future<void> setErrorNotifications(bool enabled) async {
    if (_errorNotifications == enabled) {
      return;
    }

    _errorNotifications = enabled;
    notifyListeners();
    await _preferences.setBool(_errorNotificationsKey, enabled);
  }

  Future<void> setNewDeviceNotifications(bool enabled) async {
    if (_newDeviceNotifications == enabled) {
      return;
    }

    _newDeviceNotifications = enabled;
    notifyListeners();
    await _preferences.setBool(_newDeviceNotificationsKey, enabled);
  }

  Map<String, dynamic> exportConfigToJson() {
    return toJson();
  }

  Future<void> importConfigFromJson(Map<String, dynamic> json) async {
    await importFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': _themeMode.index,
      'locale': _locale.languageCode,
      'bandwidthLimit': _bandwidthLimit,
      'notificationsEnabled': _notificationsEnabled,
      'defaultSyncMode': _defaultSyncMode,
      'downloadBandwidthLimit': _downloadBandwidthLimit,
      'wifiOnlySync': _wifiOnlySync,
      'chargingOnlySync': _chargingOnlySync,
      'powerSaveOffOnly': _powerSaveOffOnly,
      'allowedSsids': _allowedSsids,
      'backgroundSync': _backgroundSync,
      'autoStartOnBoot': _autoStartOnBoot,
      'errorNotifications': _errorNotifications,
      'newDeviceNotifications': _newDeviceNotifications,
    };
  }

  Future<void> importFromJson(Map<String, dynamic> json) async {
    final dynamic themeModeValue = json['themeMode'];
    if (themeModeValue is int &&
        themeModeValue >= 0 &&
        themeModeValue < ThemeMode.values.length) {
      await setThemeMode(ThemeMode.values[themeModeValue]);
    }

    final dynamic localeValue = json['locale'];
    if (localeValue is String && localeValue.isNotEmpty) {
      await setLocale(Locale(localeValue));
    }

    final dynamic bandwidthLimitValue = json['bandwidthLimit'];
    if (bandwidthLimitValue is num) {
      await setBandwidthLimit(bandwidthLimitValue.toDouble());
    }

    final dynamic notificationsEnabledValue = json['notificationsEnabled'];
    if (notificationsEnabledValue is bool) {
      await setNotificationsEnabled(notificationsEnabledValue);
    }

    final dynamic defaultSyncModeValue = json['defaultSyncMode'];
    if (defaultSyncModeValue is String) {
      await setDefaultSyncMode(defaultSyncModeValue);
    }

    final dynamic downloadBandwidthLimitValue = json['downloadBandwidthLimit'];
    if (downloadBandwidthLimitValue is num) {
      await setDownloadBandwidthLimit(downloadBandwidthLimitValue.toDouble());
    }

    final dynamic wifiOnlySyncValue = json['wifiOnlySync'];
    if (wifiOnlySyncValue is bool) {
      await setWifiOnlySync(wifiOnlySyncValue);
    }

    final dynamic chargingOnlySyncValue = json['chargingOnlySync'];
    if (chargingOnlySyncValue is bool) {
      await setChargingOnlySync(chargingOnlySyncValue);
    }

    final dynamic powerSaveOffOnlyValue = json['powerSaveOffOnly'];
    if (powerSaveOffOnlyValue is bool) {
      await setPowerSaveOffOnly(powerSaveOffOnlyValue);
    }

    final dynamic allowedSsidsValue = json['allowedSsids'];
    if (allowedSsidsValue is List<dynamic>) {
      final List<String> ssids = allowedSsidsValue.whereType<String>().toList();
      _allowedSsids = ssids;
      await _preferences.setStringList(_allowedSsidsKey, ssids);
      notifyListeners();
    }

    final dynamic backgroundSyncValue = json['backgroundSync'];
    if (backgroundSyncValue is bool) {
      await setBackgroundSync(backgroundSyncValue);
    }

    final dynamic autoStartOnBootValue = json['autoStartOnBoot'];
    if (autoStartOnBootValue is bool) {
      await setAutoStartOnBoot(autoStartOnBootValue);
    }

    final dynamic errorNotificationsValue = json['errorNotifications'];
    if (errorNotificationsValue is bool) {
      await setErrorNotifications(errorNotificationsValue);
    }

    final dynamic newDeviceNotificationsValue = json['newDeviceNotifications'];
    if (newDeviceNotificationsValue is bool) {
      await setNewDeviceNotifications(newDeviceNotificationsValue);
    }
  }

  ThemeMode _themeModeFromString(String? rawValue, {required ThemeMode fallback}) {
    if (rawValue == null) {
      return fallback;
    }
    for (final ThemeMode mode in ThemeMode.values) {
      if (mode.name == rawValue) {
        return mode;
      }
    }
    return fallback;
  }

  bool _areStringListsEqual(List<String> first, List<String> second) {
    if (identical(first, second)) {
      return true;
    }
    if (first.length != second.length) {
      return false;
    }
    for (int index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }
    return true;
  }
}
