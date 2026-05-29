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
import com.calorize.app.R

class CalorizeAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra("notification_id", 0)
        val title = intent.getStringExtra("title") ?: return
        val body = intent.getStringExtra("body") ?: ""
        val channelId = intent.getStringExtra("channel_id") ?: "meal_reminders_v2"
        val channelName = intent.getStringExtra("channel_name") ?: "Meal Reminders"
        val nextEpochMillis = intent.getLongExtra("next_epoch_millis", 0L)
        val scheduledEpochMillis = intent.getLongExtra("epoch_millis", 0L)

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

        val launchIntent =
            context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

        val pendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        try {
            NotificationManagerCompat.from(context).notify(notificationId, notification)
            Log.d("CalorizeAlarm", "Notification $notificationId shown: $title")
        } catch (e: SecurityException) {
            Log.w("CalorizeAlarm", "Permission denied: ${e.message}")
        }

        if (nextEpochMillis > 0L) {
            val nextIntent = Intent(context, CalorizeAlarmReceiver::class.java).apply {
                putExtra("notification_id", notificationId)
                putExtra("title", title)
                putExtra("body", body)
                putExtra("channel_id", channelId)
                putExtra("channel_name", channelName)
                putExtra("next_epoch_millis", nextEpochMillis)
                putExtra("epoch_millis", nextEpochMillis)
            }
            val nextPendingIntent = PendingIntent.getBroadcast(
                context, notificationId, nextIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            try {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, nextEpochMillis, nextPendingIntent)
                Log.d("CalorizeAlarm", "Rescheduled $notificationId for $nextEpochMillis")
            } catch (e: SecurityException) {
                alarmManager.setExactAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, nextEpochMillis, nextPendingIntent
                )
                Log.d("CalorizeAlarm", "Rescheduled $notificationId (allowWhileIdle) for $nextEpochMillis")
            }
        }
    }
}
