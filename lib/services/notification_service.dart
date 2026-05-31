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

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin =>
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final locationName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(locationName));
    } catch (e) {
      debugPrint('⚠️ Could not detect timezone: $e');
      final offset = DateTime.now().timeZoneOffset;
      final hours = offset.inHours;
      if (hours == 0) {
        tz.setLocalLocation(tz.getLocation('Etc/UTC'));
      } else {
        final sign = hours.isNegative ? '+' : '-';
        tz.setLocalLocation(tz.getLocation('Etc/GMT$sign${hours.abs()}'));
      }
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_meal');

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

    try {
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('🔔 Notification tapped: ${response.payload}');
        },
      );
    } catch (e) {
      debugPrint('⚠️ Notif plugin init failed: $e');
    }
  }

  Future<bool> requestPermissions() async {
    final plugin = _androidPlugin;
    if (plugin == null) return false;
    final bool? granted = await plugin.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<bool> areNotificationsEnabled() async {
    final plugin = _androidPlugin;
    if (plugin == null) return false;
    return await plugin.areNotificationsEnabled() ?? false;
  }

  Future<bool> canScheduleExactAlarms() async {
    final plugin = _androidPlugin;
    if (plugin == null) return false;
    return await plugin.canScheduleExactNotifications() ?? false;
  }

  Future<bool> requestExactAlarmPermission() async {
    final plugin = _androidPlugin;
    if (plugin == null) return false;
    return await plugin.requestExactAlarmsPermission() ?? false;
  }

  Future<void> scheduleDailyNotifications(UserProfile profile) async {
    if (!profile.notificationsEnabled) {
      await cancelAll();
      debugPrint('🔕 Notifications disabled.');
      return;
    }

    final granted = await requestPermissions();
    final enabled = await areNotificationsEnabled();
    debugPrint('📋 Notif permission granted=$granted, system enabled=$enabled');

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

    const androidDetails = AndroidNotificationDetails(
      'meal_reminders_v2',
      'Meal Reminders',
      channelDescription: 'Reminders to log your meals',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_meal',
    );
    const details = NotificationDetails(android: androidDetails);

    for (final mode in [
      AndroidScheduleMode.inexactAllowWhileIdle,
      AndroidScheduleMode.inexact,
    ]) {
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: mode,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        if (debugLogsEnabled) {
          debugPrint('✅ Scheduled [$title] for $scheduledDate using $mode');
        }
        return;
      } on PlatformException catch (e) {
        debugPrint('⚠️ $mode failed: ${e.code} — ${e.message}');
        continue;
      } catch (e) {
        debugPrint('❌ Error scheduling notification $id: $e');
        return;
      }
    }
    debugPrint('❌ All schedule modes failed for notification $id');
  }

  Future<void> scheduleTestNotification() async {
    debugPrint('🔍 Checking notification permissions...');
    bool granted;
    try {
      granted = await requestPermissions().timeout(const Duration(seconds: 10));
      debugPrint('📋 Permission request result: $granted');
    } catch (e) {
      debugPrint('❌ Permission request timed out or failed: $e');
      granted = false;
    }

    bool enabled;
    try {
      enabled = await areNotificationsEnabled().timeout(const Duration(seconds: 5));
      debugPrint('📋 System enabled check: $enabled');
    } catch (e) {
      debugPrint('❌ System enabled check failed: $e');
      enabled = false;
    }

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications from Calorize',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_meal',
    );
    const details = NotificationDetails(android: androidDetails);

    try {
      debugPrint('🔔 Attempting to show notification via show()...');
      await _notificationsPlugin.show(
        999,
        'Test Notification 🔔',
        'This is a test notification from Calorize.',
        details,
      ).timeout(const Duration(seconds: 10));
      debugPrint('✅ Test notification shown successfully');
    } catch (e) {
      debugPrint('❌ Error showing test notification: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('⚠️ Error cancelling notifications: $e');
    }
  }
}
