package com.calorize.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.calorize.app/widget"
    private val THEME_CHANNEL = "com.calorize.app/theme"
    private val ALARM_CHANNEL = "com.calorize.app/custom_alarm"
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        val sharedPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val themeMode = sharedPrefs.getString("flutter.themeMode", "")
        if (themeMode == "ThemeMode.light" || themeMode == "light" || themeMode == "VGhlbWVNb2RlLmxpZ2h0") {
            setTheme(R.style.LaunchThemeLight)
        } else if (themeMode == "ThemeMode.dark" || themeMode == "dark" || themeMode == "VGhlbWVNb2RlLmRhcms=") {
            setTheme(R.style.LaunchThemeDark)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val uiManager = getSystemService(Context.UI_MODE_SERVICE) as android.app.UiModeManager
            if (themeMode == "ThemeMode.light" || themeMode == "light" || themeMode == "VGhlbWVNb2RlLmxpZ2h0") {
                uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_NO)
            } else if (themeMode == "ThemeMode.dark" || themeMode == "dark" || themeMode == "VGhlbWVNb2RlLmRhcms=") {
                uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_YES)
            } else {
                uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_AUTO)
            }
        }
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent?.data?.toString()?.let { action ->
            methodChannel?.invokeMethod("onWidgetClick", action)
        }
    }

    private fun cancelPluginPendingIntents() {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val cleanupIntent = Intent(this, com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver::class.java)
        val flags = PendingIntent.FLAG_NO_CREATE or
            (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        val knownIds = listOf(1, 2, 3, 999)
        for (id in knownIds) {
            val pi = PendingIntent.getBroadcast(this, id, cleanupIntent, flags)
            if (pi != null) {
                alarmManager.cancel(pi)
                pi.cancel()
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        cancelPluginPendingIntents()

        getSharedPreferences("scheduled_notifications", Context.MODE_PRIVATE).edit().clear().apply()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    val args = call.arguments as? Map<*, *>
                    if (args == null) {
                        result.error("INVALID_ARGS", "Expected Map arguments", null)
                        return@setMethodCallHandler
                    }
                    val id = (args["id"] as? Number)?.toInt() ?: 0
                    val title = args["title"] as? String ?: ""
                    val body = args["body"] as? String ?: ""
                    val channelId = args["channelId"] as? String ?: "meal_reminders_v2"
                    val channelName = args["channelName"] as? String ?: "Meal Reminders"
                    val epochMillis = (args["epochMillis"] as? Number)?.toLong() ?: 0L
                    val nextEpochMillis = (args["nextEpochMillis"] as? Number)?.toLong() ?: 0L

                    Log.d("CalorizeAlarm", "scheduleAlarm id=$id epoch=$epochMillis next=$nextEpochMillis")

                    val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    } else {
                        PendingIntent.FLAG_UPDATE_CURRENT
                    }

                    val intent = Intent(this, CalorizeAlarmReceiver::class.java).apply {
                        putExtra("notification_id", id)
                        putExtra("title", title)
                        putExtra("body", body)
                        putExtra("channel_id", channelId)
                        putExtra("channel_name", channelName)
                        putExtra("epoch_millis", epochMillis)
                        putExtra("next_epoch_millis", nextEpochMillis)
                    }

                    val pendingIntent = PendingIntent.getBroadcast(
                        this, id, intent, flags
                    )

                    val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            alarmManager.setAlarmClock(
                                AlarmManager.AlarmClockInfo(epochMillis, null),
                                pendingIntent
                            )
                        } else {
                            alarmManager.setExact(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                        }
                        Log.d("CalorizeAlarm", "Alarm set for id=$id at $epochMillis")
                        result.success(null)
                    } catch (e: Exception) {
                        Log.e("CalorizeAlarm", "setAlarmClock failed: ${e.message}")
                        try {
                            alarmManager.setExactAndAllowWhileIdle(
                                AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent
                            )
                            Log.d("CalorizeAlarm", "Fallback: alarm set via allowWhileIdle")
                            result.success(null)
                        } catch (e2: Exception) {
                            Log.e("CalorizeAlarm", "All alarm methods failed: ${e2.message}")
                            result.error("ALARM_FAILED", "Could not schedule alarm: ${e2.message}", null)
                        }
                    }
                }
                "cancelScheduledAlarm" -> {
                    val id = when (val raw = call.arguments<Any>()) {
                        is Int -> raw
                        is Long -> raw.toInt()
                        is Double -> raw.toInt()
                        is String -> raw.toIntOrNull() ?: 0
                        else -> 0
                    }
                    val cancelIntent = Intent(this, CalorizeAlarmReceiver::class.java)
                    val cancelFlags = PendingIntent.FLAG_NO_CREATE or
                        (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
                    val pi = PendingIntent.getBroadcast(
                        this, id, cancelIntent, cancelFlags
                    )
                    if (pi != null) {
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        alarmManager.cancel(pi)
                        pi.cancel()
                    }
                    result.success(null)
                }
                "cancelAllScheduledAlarms" -> {
                    val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    val cancelIntent = Intent(this, CalorizeAlarmReceiver::class.java)
                    val cancelFlags = PendingIntent.FLAG_NO_CREATE or
                        (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
                    for (id in listOf(1, 2, 3, 999)) {
                        val pi = PendingIntent.getBroadcast(this, id, cancelIntent, cancelFlags)
                        if (pi != null) {
                            alarmManager.cancel(pi)
                            pi.cancel()
                        }
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, THEME_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setThemeMode") {
                val themeMode = call.argument<String>("themeMode")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val uiManager = getSystemService(Context.UI_MODE_SERVICE) as android.app.UiModeManager
                    when (themeMode) {
                        "light" -> uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_NO)
                        "dark" -> uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_YES)
                        else -> uiManager.setApplicationNightMode(android.app.UiModeManager.MODE_NIGHT_AUTO)
                    }
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        methodChannel = null
        super.onDestroy()
    }
}
