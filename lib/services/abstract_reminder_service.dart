import 'package:pet_circle/models/medication.dart';

abstract class AbstractReminderService {
  Future<void> init();
  Future<bool> requestPermission();
  /// Schedule a one-shot reminder on the morning of [med]'s end date.
  Future<void> scheduleMedicationReminder(
    Medication med, {
    required String title,
    required String body,
    int hour = 9,
    int minute = 0,
  });
  Future<void> cancelMedicationReminder(String medicationId);

  Future<void> cancelAllReminders();

  /// Schedule recurring measurement reminders on specific weekdays.
  Future<void> scheduleMeasurementReminder({
    required List<int> days,
    required int hour,
    required int minute,
  });

  /// Cancel all scheduled measurement reminders.
  Future<void> cancelMeasurementReminder();

  /// Schedule a recurring weekly re-engagement nudge on [weekday] at
  /// [hour]:[minute] (ISO 8601 weekday: 1=Monday..7=Sunday).
  Future<void> scheduleWeeklySummary({
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
  });

  /// Cancel the scheduled weekly summary nudge.
  Future<void> cancelWeeklySummary();

  /// Display an immediate (non-scheduled) notification.
  /// Used by [PushNotificationService] to show foreground FCM messages.
  Future<void> showImmediateNotification(
    int id,
    String title,
    String body,
    String? payload,
  );
}
