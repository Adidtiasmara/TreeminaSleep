import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/sleep_record_model.dart';
import '../utils/sleep_calculator.dart';
import 'alarm_service.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

const String _wakeUpActionId = 'wake_up_from_notification';
const String _setWakeAlarmActionId = 'set_wake_alarm_from_notification';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  unawaited(NotificationService.handleNotificationResponse(response));
}

class NotificationService {
  static const int sleepSessionNotificationId = 1001;
  static const int sleepStatusNotificationId = 1002;
  static const int sleepPlanReminderNotificationId = 1003;
  static const MethodChannel _nativeChannel =
      MethodChannel('treemina_sleep/notifications');

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

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  static Future<void> handleNotificationResponse(
    NotificationResponse response,
  ) async {
    if (response.actionId == _wakeUpActionId) {
      try {
        await _wakeUpFromNotification();
      } catch (_) {
        // Action callbacks can run while the app is waking up in the background.
      }
    } else if (response.actionId == _setWakeAlarmActionId) {
      final wakeTime = _wakeTimeFromPayload(response.payload);
      if (wakeTime == null) return;
      try {
        await AlarmService.setWakeAlarmFromString(wakeTime);
      } catch (_) {
        // The alarm app may be unavailable, or Android may reject background use.
      }
    }
  }

  static Future<void> scheduleSleepPlanReminder(
    String targetSleepTime,
    String targetWakeTime,
  ) async {
    await _safeCancel(
      sleepPlanReminderNotificationId,
      clearCacheOnFailure: true,
    );
    await requestPermission();

    final reminderTime = _nextReminderTime(targetSleepTime);
    final androidDetails = AndroidNotificationDetails(
      'sleep_plan_reminder_channel_v3',
      'Pengingat Waktu Tidur',
      channelDescription: 'Pengingat sebelum jadwal tidur dimulai',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
      enableVibration: true,
      actions: [
        AndroidNotificationAction(
          _setWakeAlarmActionId,
          'Buat Alarm ${_formatReminderTime(targetWakeTime)}',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );
    const iosDetails = DarwinNotificationDetails();
    const linuxDetails = LinuxNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );

    try {
      await _schedulePlanReminder(
        targetSleepTime,
        targetWakeTime,
        reminderTime,
        details,
      );
    } catch (_) {
      await clearScheduledNotificationCache();
      await _schedulePlanReminder(
        targetSleepTime,
        targetWakeTime,
        reminderTime,
        details,
      );
    }
  }

  static Future<void> cancelSleepPlanReminder() async {
    await _safeCancel(sleepPlanReminderNotificationId);
  }

  static Future<void> _safeCancel(
    int id, {
    bool clearCacheOnFailure = false,
  }) async {
    try {
      await _plugin.cancel(id);
    } catch (_) {
      if (clearCacheOnFailure) await clearScheduledNotificationCache();
      // Older cached scheduled notifications can fail to deserialize on Android.
    }
  }

  static Future<void> clearScheduledNotificationCache() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _nativeChannel.invokeMethod<void>(
        'clearScheduledNotificationCache',
      );
    } catch (_) {
      // The app can still continue without scheduled notification cleanup.
    }
  }

  static Future<void> _schedulePlanReminder(
    String targetSleepTime,
    String targetWakeTime,
    tz.TZDateTime reminderTime,
    NotificationDetails details,
  ) {
    return _plugin.zonedSchedule(
      sleepPlanReminderNotificationId,
      'Pengingat Waktu Tidur',
      'Tidur ${_formatReminderTime(targetSleepTime)}. Alarm bangun ${_formatReminderTime(targetWakeTime)}.',
      reminderTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'sleep_plan_reminder|wake=$targetWakeTime',
    );
  }

  static String? _wakeTimeFromPayload(String? payload) {
    if (payload == null) return null;
    const marker = 'wake=';
    final start = payload.indexOf(marker);
    if (start == -1) return null;
    return payload.substring(start + marker.length).trim();
  }

  static String _formatReminderTime(String targetSleepTime) {
    final parts = targetSleepTime.split(':');
    final hour = int.tryParse(parts.first) ?? 22;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final displayHour = hour.toString().padLeft(2, '0');
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute';
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
          _wakeUpActionId,
          'Wake Up',
          showsUserInterface: false,
          cancelNotification: true,
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
      'Sesi tidur berjalan. Tekan Wake Up saat kamu bangun.',
      details,
      payload: 'sleep_session',
    );
  }

  static Future<void> _wakeUpFromNotification() async {
    await StorageService.init();
    await SupabaseService.init();

    final useSupabase = SupabaseService.isReady && SupabaseService.isLoggedIn;
    final sleepStart = useSupabase
        ? await SupabaseService.getSleepStart()
        : StorageService.getSleepStart();

    if (sleepStart == null) return;

    final now = DateTime.now();
    final duration = SleepCalculator.calculateDurationMinutes(sleepStart, now);
    final status = SleepCalculator.getSleepStatus(duration);
    final record = SleepRecord(
      id: now.millisecondsSinceEpoch.toString(),
      date: now,
      sleepStart: sleepStart,
      wakeUp: now,
      durationMinutes: duration,
      status: status,
    );

    if (useSupabase) {
      await SupabaseService.addSleepRecord(record);
      await SupabaseService.clearSleepSession();
    } else {
      await StorageService.addSleepRecord(record);
      await StorageService.clearSleepSession();
    }

    await cancelSleepSessionNotification();
    await showSleepStatusNotification(status);
  }

  static Future<void> cancelSleepSessionNotification() async {
    await _safeCancel(sleepSessionNotificationId);
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
