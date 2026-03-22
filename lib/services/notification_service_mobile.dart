import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit),
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    // Request POST_NOTIFICATIONS permission (Android 13+)
    await android.requestNotificationsPermission();

    // Request exact-alarm permission (Android 12+).
    // Result intentionally ignored – fallback is handled per-notification.
    try {
      await android.requestExactAlarmsPermission();
    } catch (_) {
      // Older plugin / OS versions may not expose this method.
    }
  }

  /// Schedules water-reminder notifications between [wakeTimeStr] and
  /// [sleepTimeStr] for the next 7 days, every [intervalHours] hours.
  ///
  /// Uses exact alarms when the permission is granted; silently falls back to
  /// inexact alarms so notifications always fire, even on restricted devices.
  Future<void> scheduleSleepAwareReminders({
    required int intervalHours,
    required String wakeTimeStr,
    required String sleepTimeStr,
    bool isSoundEnabled = true,
    bool isVibrationEnabled = true,
  }) async {
    if (kIsWeb) return;

    await cancelAll();

    // Unique channel per sound/vibration combo so Android 8+ honours changes
    // without requiring users to reinstall the app.
    final channelId =
        'water_reminders_s${isSoundEnabled ? 1 : 0}_v${isVibrationEnabled ? 1 : 0}';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Water Reminders',
      channelDescription: 'Reminds you to drink water',
      importance: Importance.max,
      priority: Priority.high,
      playSound: isSoundEnabled,
      enableVibration: isVibrationEnabled,
      sound: isSoundEnabled
          ? const RawResourceAndroidNotificationSound('notification')
          : null,
    );

    final details = NotificationDetails(android: androidDetails);

    try {
      final wakeParts = wakeTimeStr.split(':');
      final sleepParts = sleepTimeStr.split(':');
      final wakeHour = int.parse(wakeParts[0]);
      final wakeMin = int.parse(wakeParts[1]);
      final sleepHour = int.parse(sleepParts[0]);
      final sleepMin = int.parse(sleepParts[1]);

      int nid = 0;
      final now = tz.TZDateTime.now(tz.local);

      for (int d = 0; d < 7; d++) {
        var scheduled = tz.TZDateTime(
            tz.local, now.year, now.month, now.day + d, wakeHour, wakeMin);
        final sleepBoundary = tz.TZDateTime(
            tz.local, now.year, now.month, now.day + d, sleepHour, sleepMin);

        // Handle overnight schedule (sleep time < wake time → next day)
        final effectiveSleep = sleepBoundary.isBefore(scheduled)
            ? sleepBoundary.add(const Duration(days: 1))
            : sleepBoundary;

        // Skip times already passed today
        while (scheduled.isBefore(now)) {
          scheduled = scheduled.add(Duration(hours: intervalHours));
        }

        while (scheduled.isBefore(effectiveSleep)) {
          await _scheduleOne(id: nid++, scheduledDate: scheduled, details: details);
          scheduled = scheduled.add(Duration(hours: intervalHours));
        }
      }
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }

  /// Tries an exact alarm; falls back to inexact on [PlatformException].
  Future<void> _scheduleOne({
    required int id,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: 'Drink Water! 💧',
        body: "It's time to hydrate – stay healthy!",
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException catch (e) {
      debugPrint('Exact alarm denied – falling back to inexact: $e');
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: 'Drink Water! 💧',
          body: "It's time to hydrate – stay healthy!",
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (e2) {
        debugPrint('Inexact alarm also failed: $e2');
      }
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
