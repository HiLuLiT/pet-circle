import 'package:flutter/foundation.dart';
import 'package:pet_circle/models/medication.dart';

final medicationStore = MedicationStore();

class MedicationStore extends ChangeNotifier {
  Map<String, List<Medication>> _medications = {};

  void seed(Map<String, List<Medication>> initial) {
    _medications = {
      for (final entry in initial.entries) entry.key: List.of(entry.value),
    };
    notifyListeners();
  }

  List<Medication> getMedications(String petName) {
    return List.unmodifiable(_medications[petName] ?? []);
  }

  List<Medication> getActiveMedications(String petName) {
    return List.unmodifiable(
      (_medications[petName] ?? []).where((m) => m.isActive).toList(),
    );
  }

  void addMedication(String petName, Medication medication) {
    _medications.putIfAbsent(petName, () => []);
    _medications[petName]!.add(medication);
    notifyListeners();
  }

  void removeMedication(String petName, String medicationId) {
    _medications[petName]?.removeWhere((m) => m.id == medicationId);
    notifyListeners();
  }

  void toggleMedication(String petName, String medicationId) {
    final list = _medications[petName];
    if (list == null) return;
    final idx = list.indexWhere((m) => m.id == medicationId);
    if (idx == -1) return;
    list[idx] = list[idx].copyWith(isActive: !list[idx].isActive);
    notifyListeners();
  }
}
