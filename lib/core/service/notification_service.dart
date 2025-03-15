import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;
    try {
      const initSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettingsIos = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: initSettingsAndroid,
        iOS: initSettingsIos,
      );

      await notificationPlugin.initialize(initSettings);
      _isInitialized = true;
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  NotificationDetails notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  Future<void> showNotification(
      {int id = 0, String? title, String? body}) async {
    try {
      await notificationPlugin.show(id, title, body, notificationDetails());
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}
