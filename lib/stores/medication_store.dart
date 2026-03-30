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
    _medications.putIfAbsent(petId, () => []);
    _medications[petId]!.add(medication);
    notifyListeners();

    if (kEnableFirebase) {
      try {
        await PetService.addMedication(petId, medication);
      } catch (e) {
        _medications[petId]?.remove(medication);
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> removeMedication(String petId, String medicationId) async {
    final list = _medications[petId];
    final idx = list?.indexWhere((m) => m.id == medicationId) ?? -1;
    final removed = (list != null && idx != -1) ? list.removeAt(idx) : null;
    if (removed != null) notifyListeners();

    if (!kIsWeb) {
      ReminderService.instance.cancelMedicationReminder(medicationId);
    }

    if (kEnableFirebase) {
      try {
        await PetService.deleteMedication(petId, medicationId);
      } catch (e) {
        if (removed != null && list != null) {
          list.insert(idx.clamp(0, list.length), removed);
          notifyListeners();
        }
        rethrow;
      }
    }
  }

  Future<void> updateMedication(String petId, String medicationId, Medication updated) async {
    final list = _medications[petId];
    if (list == null) return;
    final idx = list.indexWhere((m) => m.id == medicationId);
    if (idx == -1) return;
    final previous = list[idx];
    list[idx] = updated;
    notifyListeners();

    if (kEnableFirebase) {
      try {
        await PetService.updateMedication(petId, medicationId, updated.toFirestore());
      } catch (e) {
        list[idx] = previous;
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> toggleMedication(String petId, String medicationId) async {
    final list = _medications[petId];
    if (list == null) return;
    final idx = list.indexWhere((m) => m.id == medicationId);
    if (idx == -1) return;
    final previous = list[idx];
    final toggled = previous.copyWith(isActive: !previous.isActive);
    list[idx] = toggled;
    notifyListeners();

    if (!kIsWeb && !toggled.isActive) {
      ReminderService.instance.cancelMedicationReminder(medicationId);
    }

    if (kEnableFirebase) {
      try {
        await PetService.updateMedication(petId, medicationId, {'isActive': toggled.isActive});
      } catch (e) {
        list[idx] = previous;
        notifyListeners();
        rethrow;
      }
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
