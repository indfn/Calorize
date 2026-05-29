package com.calorize.app

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class CalorizeAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra("notification_id", 0)
        val title = intent.getStringExtra("title")
        val body = intent.getStringExtra("body") ?: ""
        val channelId = intent.getStringExtra("channel_id") ?: "meal_reminders_v2"
        val channelName = intent.getStringExtra("channel_name") ?: "Meal Reminders"
        val nextEpochMillis = intent.getLongExtra("next_epoch_millis", 0L)

        Log.d("CalorizeAlarm", "onReceive: id=$notificationId title=$title body=$body")

        if (title == null) {
            Log.w("CalorizeAlarm", "No title in intent extras, aborting")
            return
        }

        val enabled = NotificationManagerCompat.from(context).areNotificationsEnabled()
        Log.d("CalorizeAlarm", "Notifications enabled: $enabled")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId, channelName, NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Reminders to log your meals"
            }
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val launchIntent =
            context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

        val pendingIntent = PendingIntent.getActivity(
            context, notificationId, launchIntent, flags
        )

        try {
            val iconRes = context.resources.getIdentifier("launcher_icon", "mipmap", context.packageName)
            val notifIcon = if (iconRes != 0) iconRes else android.R.drawable.ic_dialog_info

            val notification = NotificationCompat.Builder(context, channelId)
                .setSmallIcon(notifIcon)
                .setContentTitle(title)
                .setContentText(body)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
                .build()

            NotificationManagerCompat.from(context).notify(notificationId, notification)
            Log.d("CalorizeAlarm", "Notification $notificationId shown: $title")
        } catch (e: Exception) {
            Log.e("CalorizeAlarm", "Failed to show notification: ${e.message}", e)
        }

        if (nextEpochMillis > 0L) {
            val nextIntent = Intent(context, CalorizeAlarmReceiver::class.java).apply {
                putExtra("notification_id", notificationId)
                putExtra("title", title)
                putExtra("body", body)
                putExtra("channel_id", channelId)
                putExtra("channel_name", channelName)
                putExtra("next_epoch_millis", nextEpochMillis)
            }
            val nextPendingIntent = PendingIntent.getBroadcast(
                context, notificationId, nextIntent, flags
            )
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            try {
                alarmManager.setAlarmClock(
                    AlarmManager.AlarmClockInfo(nextEpochMillis, null),
                    nextPendingIntent
                )
                Log.d("CalorizeAlarm", "Rescheduled $notificationId at $nextEpochMillis")
            } catch (e: Exception) {
                Log.w("CalorizeAlarm", "Reschedule with setAlarmClock failed: ${e.message}")
                try {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP, nextEpochMillis, nextPendingIntent
                    )
                    Log.d("CalorizeAlarm", "Rescheduled $notificationId via allowWhileIdle")
                } catch (e2: Exception) {
                    Log.e("CalorizeAlarm", "All reschedule methods failed: ${e2.message}")
                }
            }
        }
    }
}
