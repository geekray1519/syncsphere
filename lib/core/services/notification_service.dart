import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();

  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'syncsphere_sync',
      'Sync Notifications',
      description: 'Notifications for sync status updates',
      importance: Importance.defaultImportance,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<void> showSyncComplete(String jobName, Object? result) async {
    if (!_initialized) {
      debugPrint('[Notification] Not initialized, skipping sync complete notification');
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'syncsphere_sync',
        'Sync Notifications',
        channelDescription: 'Notifications for sync status updates',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Sync Complete',
      '$jobName synced successfully',
      details,
    );
  }

  Future<void> showError(String message) async {
    if (!_initialized) {
      debugPrint('[Notification] Not initialized, skipping error notification');
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'syncsphere_sync',
        'Sync Notifications',
        channelDescription: 'Notifications for sync status updates',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Sync Error',
      message,
      details,
    );
  }

  Future<void> showNewDevice(String deviceName) async {
    if (!_initialized) {
      debugPrint('[Notification] Not initialized, skipping new device notification');
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'syncsphere_sync',
        'Sync Notifications',
        channelDescription: 'Notifications for sync status updates',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'New Device Detected',
      '$deviceName connected',
      details,
    );
  }
}
