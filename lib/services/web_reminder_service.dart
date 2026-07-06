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
    required String title,
    required String body,
    int hour = 9,
    int minute = 0,
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
  Future<void> scheduleWeeklySummary({
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelWeeklySummary() async {}

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
