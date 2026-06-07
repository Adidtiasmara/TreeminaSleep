import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const int sleepSessionNotificationId = 1001;
  static const int sleepStatusNotificationId = 1002;
  static const int sleepPlanReminderNotificationId = 1003;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

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

  static Future<void> scheduleSleepPlanReminder(String targetSleepTime) async {
    await cancelSleepPlanReminder();
    await requestPermission();

    final reminderTime = _nextReminderTime(targetSleepTime);
    const androidDetails = AndroidNotificationDetails(
      'sleep_plan_reminder_channel',
      'Sleep Plan Reminder',
      channelDescription: 'Pengingat sebelum jadwal tidur dimulai',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
    );
    const iosDetails = DarwinNotificationDetails();
    const linuxDetails = LinuxNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );

    await _plugin.zonedSchedule(
      sleepPlanReminderNotificationId,
      'Pengingat Tidur',
      'Waktu tidur anda telah diatur di jam $targetSleepTime',
      reminderTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'sleep_plan_reminder',
    );
  }

  static Future<void> cancelSleepPlanReminder() async {
    await _plugin.cancel(sleepPlanReminderNotificationId);
  }

  static tz.TZDateTime _nextReminderTime(String targetSleepTime) {
    final parts = targetSleepTime.split(':');
    final hour = int.tryParse(parts.first) ?? 22;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).subtract(const Duration(minutes: 5));

    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target;
  }

  static Future<void> showSleepSessionNotification(DateTime sleepStart) async {
    final androidDetails = AndroidNotificationDetails(
      'active_sleep_session_channel',
      'Active Sleep Session',
      channelDescription: 'Notifikasi saat sesi tidur sedang berjalan',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
      when: sleepStart.millisecondsSinceEpoch,
      usesChronometer: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.alarm,
      playSound: false,
      enableVibration: false,
      actions: [
        const AndroidNotificationAction(
          'open_sleep_session',
          'Buka',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: false,
    );
    const linuxDetails = LinuxNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );

    await _plugin.show(
      sleepSessionNotificationId,
      'Sedang Tidur',
      'Sesi tidur berjalan. Ketuk untuk membuka Treemina Sleep.',
      details,
      payload: 'sleep_session',
    );
  }

  static Future<void> cancelSleepSessionNotification() async {
    await _plugin.cancel(sleepSessionNotificationId);
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

    await _plugin.show(sleepStatusNotificationId, title, body, details);
  }
}
