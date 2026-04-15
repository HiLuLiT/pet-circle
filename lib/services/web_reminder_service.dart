import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/services/abstract_reminder_service.dart';

/// No-op reminder service for web platform.
/// flutter_local_notifications does not support web, so all methods are stubs.
class WebReminderService implements AbstractReminderService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleMedicationReminder(
    Medication med, {
    int morningHour = 9,
    int morningMinute = 0,
    int eveningHour = 21,
    int eveningMinute = 0,
  }) async {}

  @override
  Future<void> cancelMedicationReminder(String medicationId) async {}

  @override
  Future<void> scheduleMeasurementReminder({
    required List<int> days,
    required int hour,
    required int minute,
  }) async {}

  @override
  Future<void> cancelMeasurementReminder() async {}

  @override
  Future<void> cancelAllReminders() async {}

  @override
  Future<void> showImmediateNotification(
    int id,
    String title,
    String body,
    String? payload,
  ) async {}
}
