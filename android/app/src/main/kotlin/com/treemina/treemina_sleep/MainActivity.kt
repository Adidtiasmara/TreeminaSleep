package com.treemina.treemina_sleep

import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.AlarmClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val notificationChannel = "treemina_sleep/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, notificationChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "clearScheduledNotificationCache") {
                    getSharedPreferences("scheduled_notifications", MODE_PRIVATE)
                        .edit()
                        .clear()
                        .apply()
                    result.success(null)
                } else if (call.method == "setWakeAlarm") {
                    val hour = call.argument<Int>("hour")
                    val minute = call.argument<Int>("minute")
                    if (hour == null || minute == null) {
                        result.error("INVALID_TIME", "Jam alarm tidak valid.", null)
                        return@setMethodCallHandler
                    }
                    setWakeAlarm(hour, minute, result)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun setWakeAlarm(hour: Int, minute: Int, result: MethodChannel.Result) {
        val intent = Intent(AlarmClock.ACTION_SET_ALARM).apply {
            putExtra(AlarmClock.EXTRA_HOUR, hour)
            putExtra(AlarmClock.EXTRA_MINUTES, minute)
            putExtra(AlarmClock.EXTRA_MESSAGE, "Treemina Sleep")
            putExtra(AlarmClock.EXTRA_SKIP_UI, true)
        }

        try {
            startActivity(intent)
            result.success(null)
        } catch (error: ActivityNotFoundException) {
            result.error("NO_ALARM_APP", "Aplikasi alarm tidak ditemukan.", null)
        }
    }
}
