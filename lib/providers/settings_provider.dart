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

  final SharedPreferences _preferences;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ja');
  double _bandwidthLimit = 0.0;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  double get bandwidthLimit => _bandwidthLimit;
  bool get notificationsEnabled => _notificationsEnabled;

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
}
