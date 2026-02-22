import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  factory NotificationService() {
    return _instance;
  }

  void showSyncComplete(String jobName, Object? result) {
    debugPrint('[Notification] Sync complete for "$jobName": $result');
    // TODO: Integrate flutter_local_notifications for sync complete notification.
  }

  void showError(String message) {
    debugPrint('[Notification] Error: $message');
    // TODO: Integrate flutter_local_notifications for error notification.
  }

  void showNewDevice(String deviceName) {
    debugPrint('[Notification] New device detected: $deviceName');
    // TODO: Integrate flutter_local_notifications for new device notification.
  }
}
