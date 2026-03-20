import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/services/pet_service.dart';
import 'package:pet_circle/services/reminder_service.dart';

final medicationStore = MedicationStore();

class MedicationStore extends ChangeNotifier {
  Map<String, List<Medication>> _medications = {};
  final Map<String, StreamSubscription<List<Medication>>> _subscriptions = {};

  void seed(Map<String, List<Medication>> initial) {
    _medications = {
      for (final entry in initial.entries) entry.key: List.of(entry.value),
    };
    notifyListeners();
  }

  List<Medication> getMedications(String petId) {
    return List.unmodifiable(_medications[petId] ?? []);
  }

  List<Medication> getActiveMedications(String petId) {
    return List.unmodifiable(
      (_medications[petId] ?? []).where((m) => m.isActive).toList(),
    );
  }

  Future<void> addMedication(String petId, Medication medication) async {
    if (kEnableFirebase) {
      await PetService.addMedication(petId, medication);
    } else {
      _medications.putIfAbsent(petId, () => []);
      _medications[petId]!.add(medication);
      notifyListeners();
    }
  }

  Future<void> removeMedication(String petId, String medicationId) async {
    await ReminderService.instance.cancelMedicationReminder(medicationId);
    if (kEnableFirebase) {
      await PetService.deleteMedication(petId, medicationId);
    } else {
      _medications[petId]?.removeWhere((m) => m.id == medicationId);
      notifyListeners();
    }
  }

  Future<void> updateMedication(String petId, String medicationId, Medication updated) async {
    if (kEnableFirebase) {
      await PetService.updateMedication(petId, medicationId, updated.toFirestore());
    } else {
      final list = _medications[petId];
      if (list == null) return;
      final idx = list.indexWhere((m) => m.id == medicationId);
      if (idx == -1) return;
      list[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> toggleMedication(String petId, String medicationId) async {
    final list = _medications[petId];
    if (list == null) return;
    final idx = list.indexWhere((m) => m.id == medicationId);
    if (idx == -1) return;
    final toggled = list[idx].copyWith(isActive: !list[idx].isActive);

    if (!toggled.isActive) {
      await ReminderService.instance.cancelMedicationReminder(medicationId);
    }

    if (kEnableFirebase) {
      await PetService.updateMedication(petId, medicationId, {'isActive': toggled.isActive});
    } else {
      list[idx] = toggled;
      notifyListeners();
    }
  }

  void subscribeForPets(List<String> petIds) {
    final currentIds = _subscriptions.keys.toSet();
    final newIds = petIds.toSet();

    for (final id in currentIds.difference(newIds)) {
      _subscriptions[id]?.cancel();
      _subscriptions.remove(id);
      _medications.remove(id);
    }

    for (final id in newIds.difference(currentIds)) {
      _subscriptions[id] = PetService.streamMedications(id).listen((list) {
        _medications[id] = list;
        notifyListeners();
      });
    }
  }

  void cancelSubscriptions() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }
}
