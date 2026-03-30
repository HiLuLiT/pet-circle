import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/services/abstract_reminder_service.dart';

@pragma('vm:entry-point')
void _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse response) {
  // Background tap handler -- no-op for now; can deep-link later.
}

class ReminderService implements AbstractReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

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
      onDidReceiveNotificationResponse: (_) {},
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

  /// Stable numeric id derived from the medication string id.
  int _notifIdFromMedId(String medId) => medId.hashCode & 0x7FFFFFFF;

  @override
  Future<void> scheduleMedicationReminder(Medication med) async {
    if (!_initialized) await init();

    final permitted = await requestPermission();
    if (!permitted) return;

    await cancelMedicationReminder(med.id);

    if (med.endDate != null && med.endDate!.isBefore(DateTime.now())) return;

    final baseId = _notifIdFromMedId(med.id);

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders for scheduled pet medications',
      importance: Importance.high,
      priority: Priority.high,
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

    if (med.frequency == 'Once daily') {
      await _plugin.zonedSchedule(
        baseId,
        title,
        body,
        _nextInstanceOfTime(9, 0),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else if (med.frequency == 'Twice daily') {
      await _plugin.zonedSchedule(
        baseId,
        title,
        body,
        _nextInstanceOfTime(9, 0),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      await _plugin.zonedSchedule(
        baseId + 1,
        title,
        body,
        _nextInstanceOfTime(21, 0),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    // 'As needed' -- no automatic schedule
  }

  @override
  Future<void> cancelMedicationReminder(String medicationId) async {
    final baseId = _notifIdFromMedId(medicationId);
    await _plugin.cancel(baseId);
    await _plugin.cancel(baseId + 1);
  }

  @override
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
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
}
