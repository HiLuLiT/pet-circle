import 'package:pet_circle/models/medication.dart';

abstract class AbstractReminderService {
  Future<void> init();
  Future<bool> requestPermission();
  Future<void> scheduleMedicationReminder(
    Medication med, {
    int morningHour = 9,
    int morningMinute = 0,
    int eveningHour = 21,
    int eveningMinute = 0,
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

  /// Display an immediate (non-scheduled) notification.
  /// Used by [PushNotificationService] to show foreground FCM messages.
  Future<void> showImmediateNotification(
    int id,
    String title,
    String body,
    String? payload,
  );
}
