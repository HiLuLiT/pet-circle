import 'package:pet_circle/models/medication.dart';

abstract class AbstractReminderService {
  Future<void> init();
  Future<bool> requestPermission();
  Future<void> scheduleMedicationReminder(Medication med);
  Future<void> cancelMedicationReminder(String medicationId);
  Future<void> cancelAllReminders();
}
