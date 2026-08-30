import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/services/abstract_reminder_service.dart';

@pragma('vm:entry-point')
void _onDidReceiveBackgroundNotificationResponse(
  NotificationResponse response,
) {
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

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

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
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
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
    // 28 bits: morning/evening IDs (hash*2 / *2+1) max out at 0x1FFFFFFF,
    // staying clear of the 0x40000000 dose-reminder namespace below.
    return hash & 0x0FFFFFFF;
  }

  /// Stable numeric ID for a medication's end-date reminder.
  /// (Even slot of the per-medication stride; the odd slot is a legacy
  /// evening slot kept only so [cancelMedicationReminder] can clear it.)
  int _medReminderId(String medId) => _stableHash(medId) * 2;
  int _legacyMedEveningId(String medId) => _stableHash(medId) * 2 + 1;

  @override
  Future<void> scheduleMedicationReminder(
    Medication med, {
    required String title,
    required String body,
    int hour = 9,
    int minute = 0,
  }) async {
    if (!_initialized) await init();

    final permitted = await requestPermission();
    if (!permitted) return;

    await cancelMedicationReminder(med.id);

    // One-shot reminder on the morning of the medication's end date.
    if (!med.hasEndReminder) return;
    final when = tz.TZDateTime(
      tz.local,
      med.endDate!.year,
      med.endDate!.month,
      med.endDate!.day,
      hour,
      minute,
    );
    if (!when.isAfter(tz.TZDateTime.now(tz.local))) return;

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

    final payload = json.encode({
      'type': 'medication',
      'route': AppRoutes.shell(tab: AppRoutes.tabMedication),
      'medicationId': med.id,
    });

    await _plugin.zonedSchedule(
      _medReminderId(med.id),
      title,
      body,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  @override
  Future<void> cancelMedicationReminder(String medicationId) async {
    await _plugin.cancel(_medReminderId(medicationId));
    // Clear the legacy evening slot from the previous daily-reminder version.
    await _plugin.cancel(_legacyMedEveningId(medicationId));
  }

  // ── Medication dose reminders ────────────────────────────────────

  /// Notification-ID namespace for recurring per-dose medication reminders.
  ///
  /// Every other allocation in this file lives below 0x20000000:
  /// medication-end uses `_stableHash(id) * 2` (+1 for the legacy slot) over a
  /// 28-bit hash, so it tops out at 0x1FFFFFFF, and the fixed measurement
  /// (900000 + weekday) and weekly-summary (800000) IDs sit inside that same
  /// low band. Dose IDs therefore start at 0x40000000 and are laid out as
  ///
  ///     0x40000000 + _stableHash(medId) * _maxDoseSlots + slotIndex
  ///
  /// which is deterministic across runs, unique per (medication, slot), and
  /// bounded by 0x40000000 + 0x0FFFFFFF * 4 + 3 == 0x7FFFFFFF — the largest
  /// signed 32-bit int, so it never wraps into another namespace.
  static const int _doseBaseId = 0x40000000;

  /// Number of reserved dose slots per medication (the ID stride).
  /// "Twice daily" needs 2; the extra headroom keeps IDs stable if a future
  /// frequency adds a third or fourth dose.
  static const int _maxDoseSlots = 4;

  int _doseReminderId(String medId, int slot) =>
      _doseBaseId + _stableHash(medId) * _maxDoseSlots + slot;

  /// Parse a canonical `"HH:mm"` string. Returns `null` when malformed or
  /// out of range, so one bad entry cannot break the whole schedule.
  static ({int hour, int minute})? _parseTimeOfDay(String raw) {
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return (hour: hour, minute: minute);
  }

  @override
  Future<void> scheduleMedicationDoseReminders(
    Medication med, {
    required List<String> times,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    final permitted = await requestPermission();
    if (!permitted) return;

    await cancelMedicationDoseReminders(med.id);

    if (!med.isActive || !med.remindersEnabled || times.isEmpty) return;

    const androidDetails = AndroidNotificationDetails(
      'medication_dose_reminders',
      'Medication Dose Reminders',
      channelDescription: 'Daily reminders to give your pet its medication',
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

    final payload = json.encode({
      'type': 'medicationDose',
      'route': AppRoutes.shell(tab: AppRoutes.tabMedication),
      'medicationId': med.id,
    });

    final slots = times.length < _maxDoseSlots ? times.length : _maxDoseSlots;
    for (var slot = 0; slot < slots; slot++) {
      final parsed = _parseTimeOfDay(times[slot]);
      if (parsed == null) continue;
      await _plugin.zonedSchedule(
        _doseReminderId(med.id, slot),
        title,
        body,
        _nextInstanceOfTime(parsed.hour, parsed.minute),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // Recurs every day at the same wall-clock time.
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    }
  }

  @override
  Future<void> cancelMedicationDoseReminders(String medicationId) async {
    for (var slot = 0; slot < _maxDoseSlots; slot++) {
      await _plugin.cancel(_doseReminderId(medicationId, slot));
    }
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
      'route': AppRoutes.shell(tab: AppRoutes.tabMeasure),
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

  // ── Weekly summary nudge ─────────────────────────────────────────

  /// Fixed notification ID for the weekly summary nudge (single recurring slot).
  static const _weeklySummaryId = 800000;

  @override
  Future<void> scheduleWeeklySummary({
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    final permitted = await requestPermission();
    if (!permitted) return;

    await cancelWeeklySummary();

    const androidDetails = AndroidNotificationDetails(
      'weekly_summary',
      'Weekly Summary',
      channelDescription: "A weekly recap nudge for your pet's health trends",
      importance: Importance.high,
      priority: Priority.high,
      groupKey: 'weekly_summary',
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

    final payload = json.encode({
      'type': 'weeklySummary',
      'route': AppRoutes.shell(tab: AppRoutes.tabTrends),
    });

    await _plugin.zonedSchedule(
      _weeklySummaryId,
      title,
      body,
      _nextInstanceOfDayAndTime(weekday, hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  @override
  Future<void> cancelWeeklySummary() async {
    await _plugin.cancel(_weeklySummaryId);
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

  /// Next occurrence of a time of day — today if it is still ahead,
  /// otherwise tomorrow.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Next occurrence of a specific weekday and time.
  /// [weekday] uses ISO 8601: 1=Monday..7=Sunday.
  tz.TZDateTime _nextInstanceOfDayAndTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
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
