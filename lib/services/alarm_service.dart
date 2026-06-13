import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AlarmService {
  static const MethodChannel _channel =
      MethodChannel('treemina_sleep/notifications');

  static Future<void> setWakeAlarm({
    required int hour,
    required int minute,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError('Alarm sistem hanya didukung di Android.');
    }

    await _channel.invokeMethod<void>('setWakeAlarm', {
      'hour': hour,
      'minute': minute,
    });
  }

  static Future<void> setWakeAlarmFromString(String time) async {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first);
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : null;

    if (hour == null || minute == null) {
      throw ArgumentError('Format jam alarm tidak valid.');
    }

    await setWakeAlarm(hour: hour, minute: minute);
  }
}
