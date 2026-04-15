import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/services/abstract_reminder_service.dart';

@pragma('vm:entry-point')
void _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse response) {
  // Background handler runs in a separate isolate on Android — static fields
  // written here are NOT visible to the main isolate.  The main isolate uses
  // getNotificationAppLaunchDetails() instead to recover the tap payload.
}

class ReminderService implements AbstractReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Stream that emits route strings when the user taps a local notification
  /// while the app is in the foreground.
  /// Process-scoped: intentionally never closed (singleton lifetime).
  static final StreamController<String> onNotificationTap =
      StreamController<String>.broadcast();

  /// Check if the app was launched by tapping a local notification (cold start).
  /// Returns the route from the notification payload, or `null`.
  /// Uses flutter_local_notifications' getNotificationAppLaunchDetails(),
  /// which works correctly across isolate boundaries (unlike static fields).
  static Future<String?> consumePendingRoute() async {
    try {
      final details = await FlutterLocalNotificationsPlugin()
          .getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      final payload = details.notificationResponse?.payload;
      if (payload == null || payload.isEmpty) return null;
      return _extractRoute(payload);
    } catch (_) {
      return null;
    }
  }

  static String? _extractRoute(String payload) {
    try {
      final data = json.decode(payload) as Map<String, dynamic>;
      return data['route'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final local = tz.local;
    tz.setLocalLocation(local);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onForegroundNotificationTap,
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );

    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    return false;
  }

  /// Handle a notification tap while the app is in the foreground.
  static void _onForegroundNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    final route = _extractRoute(payload);
    if (route != null && route.isNotEmpty) {
      onNotificationTap.add(route);
    }
  }

  /// Stable FNV-1a hash for a string — deterministic across Dart runtimes,
  /// unlike String.hashCode which may be randomised per isolate.
  static int _stableHash(String s) {
    var hash = 0x811c9dc5;
    for (var i = 0; i < s.length; i++) {
      hash ^= s.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash & 0x3FFFFFFF; // 30 bits — leaves room for stride
  }

  /// Stable numeric IDs for medication reminders.
  /// Uses a stride of 2 per medication to avoid collisions between
  /// morning (baseId) and evening (baseId + 1) slots.
  int _medMorningId(String medId) => _stableHash(medId) * 2;
  int _medEveningId(String medId) => _stableHash(medId) * 2 + 1;

  @override
  Future<void> scheduleMedicationReminder(
    Medication med, {
    int morningHour = 9,
    int morningMinute = 0,
    int eveningHour = 21,
    int eveningMinute = 0,
  }) async {
    if (!_initialized) await init();

    final permitted = await requestPermission();
    if (!permitted) return;

    await cancelMedicationReminder(med.id);

    if (med.endDate != null && med.endDate!.isBefore(DateTime.now())) return;

    final morningId = _medMorningId(med.id);
    final eveningId = _medEveningId(med.id);

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders for scheduled pet medications',
      importance: Importance.high,
      priority: Priority.high,
      groupKey: 'medication',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final title = 'Medication Due: ${med.name}';
    final body = '${med.dosage} — ${med.frequency}';
    final payload = json.encode({
      'type': 'medication',
      'route': '/shell?tab=4',
      'medicationId': med.id,
    });

    if (med.frequency == 'Once daily') {
      await _plugin.zonedSchedule(
        morningId,
        title,
        body,
        _nextInstanceOfTime(morningHour, morningMinute),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } else if (med.frequency == 'Twice daily') {
      await _plugin.zonedSchedule(
        morningId,
        title,
        body,
        _nextInstanceOfTime(morningHour, morningMinute),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      await _plugin.zonedSchedule(
        eveningId,
        title,
        body,
        _nextInstanceOfTime(eveningHour, eveningMinute),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    }
    // 'As needed' -- no automatic schedule
  }

  @override
  Future<void> cancelMedicationReminder(String medicationId) async {
    await _plugin.cancel(_medMorningId(medicationId));
    await _plugin.cancel(_medEveningId(medicationId));
  }

  // ── Measurement reminders ───────────────────────────────────────

  /// Base notification ID for measurement reminders (900000 + dayOfWeek).
  static const _measurementBaseId = 900000;

  @override
  Future<void> scheduleMeasurementReminder({
    required List<int> days,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await init();

    final permitted = await requestPermission();
    if (!permitted) return;

    await cancelMeasurementReminder();

    const androidDetails = AndroidNotificationDetails(
      'measurement_reminders',
      'Measurement Reminders',
      channelDescription: 'Reminders to measure your pet\'s respiratory rate',
      importance: Importance.high,
      priority: Priority.high,
      groupKey: 'measurement',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    const title = 'Time to Measure';
    const body = 'It\'s time to check your pet\'s respiratory rate';
    final payload = json.encode({
      'type': 'measurement',
      'route': '/shell?tab=3',
    });

    for (final day in days) {
      final notifId = _measurementBaseId + day;
      final scheduledDate = _nextInstanceOfDayAndTime(day, hour, minute);
      await _plugin.zonedSchedule(
        notifId,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
    }
  }

  @override
  Future<void> cancelMeasurementReminder() async {
    // Cancel all 7 possible day slots.
    for (var day = 1; day <= 7; day++) {
      await _plugin.cancel(_measurementBaseId + day);
    }
  }

  @override
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  @override
  Future<void> showImmediateNotification(
    int id,
    String title,
    String body,
    String? payload,
  ) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'push_notifications',
      'Push Notifications',
      channelDescription: 'Notifications from Pet Circle',
      importance: Importance.high,
      priority: Priority.high,
      groupKey: 'social',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Next occurrence of a specific weekday and time.
  /// [weekday] uses ISO 8601: 1=Monday..7=Sunday.
  tz.TZDateTime _nextInstanceOfDayAndTime(
    int weekday,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    // Advance to the target weekday.
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    // If the target time has already passed this week, jump ahead 7 days.
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return scheduled;
  }
}
