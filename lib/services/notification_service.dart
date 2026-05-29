import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool debugLogsEnabled = false;

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final locationName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(locationName));
    } catch (e) {
      debugPrint('⚠️ Could not detect timezone: $e');
      final offset = DateTime.now().timeZoneOffset;
      tz.setLocalLocation(tz.getLocation(
        'Etc/GMT${offset.isNegative ? '+' : '-'}${(offset.inHours).abs()}'
      ));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Notification tapped: ${response.payload}');
      },
    );
  }

  Future<bool> requestPermissions() async {
    final bool? notificationGranted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return notificationGranted ?? false;
  }

  Future<void> scheduleDailyNotifications(UserProfile profile) async {
    if (!profile.notificationsEnabled) {
      await cancelAll();
      debugPrint('🔕 Notifications disabled.');
      return;
    }

    await requestPermissions();
    await cancelAll();

    if (debugLogsEnabled) debugPrint('📅 Scheduling Daily Meals...');

    await _scheduleNotification(
      id: 1,
      title: 'Breakfast Time! 🍳',
      body: 'Don\'t forget to log your breakfast.',
      minutesFromMidnight: profile.breakfastTime,
    );

    await _scheduleNotification(
      id: 2,
      title: 'Lunch Time! 🥗',
      body: 'Time to log your lunch.',
      minutesFromMidnight: profile.lunchTime,
    );

    await _scheduleNotification(
      id: 3,
      title: 'Dinner Time! 🥩',
      body: 'Remember to log your dinner.',
      minutesFromMidnight: profile.dinnerTime,
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int minutesFromMidnight,
  }) async {
    if (minutesFromMidnight < 0 || minutesFromMidnight > 1439) {
      debugPrint('❌ Invalid minutesFromMidnight: $minutesFromMidnight');
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = _computeScheduledDate(now, minutesFromMidnight);

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders_v2',
            'Meal Reminders',
            channelDescription: 'Reminders to log your meals',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      if (debugLogsEnabled) debugPrint('✅ Scheduled [$title] for $scheduledDate');
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        debugPrint('⚠️ Exact alarm not permitted, falling back to inexact for [$title]');
        try {
          await _notificationsPlugin.zonedSchedule(
            id, title, body, scheduledDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'meal_reminders_v2',
                'Meal Reminders',
                channelDescription: 'Reminders to log your meals',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/launcher_icon',
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          if (debugLogsEnabled) debugPrint('✅ Scheduled (inexact) [$title] for $scheduledDate');
        } catch (e2) {
          debugPrint('❌ Fallback scheduling also failed for [$title]: $e2');
        }
      } else {
        debugPrint('❌ Error scheduling notification $id: $e');
      }
    }
  }

  tz.TZDateTime _computeScheduledDate(tz.TZDateTime now, int minutesFromMidnight) {
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutesFromMidnight ~/ 60,
      minutesFromMidnight % 60,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleTestNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(seconds: 5));

    try {
      await _notificationsPlugin.zonedSchedule(
        999,
        'Test Notification 🔔',
        'This is a test notification from Calorize.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Test notifications for debugging',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ Test notification scheduled for $scheduledDate');
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        debugPrint('⚠️ Exact alarm not permitted for test notification, falling back to inexact');
        await _notificationsPlugin.zonedSchedule(
          999,
          'Test Notification 🔔',
          'This is a test notification from Calorize.',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'test_channel',
              'Test Notifications',
              channelDescription: 'Test notifications for debugging',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('✅ Test notification scheduled (inexact) for $scheduledDate');
      } else {
        debugPrint('❌ Error scheduling test notification: $e');
        rethrow;
      }
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('⚠️ Error cancelling notifications (stale cache): $e');
    }
  }
}
