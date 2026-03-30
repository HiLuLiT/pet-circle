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
  Future<void> scheduleMedicationReminder(Medication med) async {}

  @override
  Future<void> cancelMedicationReminder(String medicationId) async {}

  @override
  Future<void> cancelAllReminders() async {}
}
