import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(initSettings);
  }

  static Future<void> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  static Future<void> showSleepStatusNotification(String status) async {
    String title;
    String body;

    switch (status) {
      case 'Excellent Sleep':
        title = 'Excellent Sleep 😊';
        body = 'Tidurmu cukup. Pertahankan pola tidur yang baik.';
        break;
      case 'Bad Sleep':
        title = 'Bad Sleep 😟';
        body =
            'Kamu kurang tidur hari ini. Cobalah tidur lebih awal malam ini.';
        break;
      case 'Over Sleep':
        title = 'Over Sleep 😴';
        body = 'Kamu tidur lebih lama dari kebutuhan normal.';
        break;
      default:
        return;
    }

    const androidDetails = AndroidNotificationDetails(
      'sleep_status_channel',
      'Sleep Status',
      channelDescription: 'Notifikasi status kualitas tidur',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const linuxDetails = LinuxNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );

    await _plugin.show(0, title, body, details);
  }
}
