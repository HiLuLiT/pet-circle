import 'package:flutter/foundation.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/services/medication_service.dart';
import 'package:pet_circle/services/reminder_service.dart';

final medicationStore = MedicationStore();

class MedicationStore extends ChangeNotifier {
  Map<String, List<Medication>> _medications = {};
  List<String> _currentPetIds = [];
  final Set<String> _pendingWritePetIds = {};

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
    _pendingWritePetIds.add(petId);
    notifyListeners();

    if (kEnableFirebase) {
      try {
        await MedicationService.add(petId, medication);
      } catch (e) {
        _medications[petId]?.remove(medication);
        notifyListeners();
        rethrow;
      } finally {
        _pendingWritePetIds.remove(petId);
      }
    } else {
      _pendingWritePetIds.remove(petId);
    }
  }

  Future<void> removeMedication(String petId, String medicationId) async {
    final list = _medications[petId];
    final idx = list?.indexWhere((m) => m.id == medicationId) ?? -1;
    final removed = (list != null && idx != -1) ? list.removeAt(idx) : null;
    if (removed != null) {
      _pendingWritePetIds.add(petId);
      notifyListeners();
    }

    if (!kIsWeb) {
      ReminderService.instance.cancelMedicationReminder(medicationId);
    }

    if (kEnableFirebase) {
      try {
        await MedicationService.delete(petId, medicationId);
      } catch (e) {
        if (removed != null && list != null) {
          list.insert(idx.clamp(0, list.length), removed);
          notifyListeners();
        }
        rethrow;
      } finally {
        _pendingWritePetIds.remove(petId);
      }
    } else {
      _pendingWritePetIds.remove(petId);
    }
  }

  Future<void> updateMedication(String petId, String medicationId, Medication updated) async {
    final list = _medications[petId];
    if (list == null) return;
    final idx = list.indexWhere((m) => m.id == medicationId);
    if (idx == -1) return;
    final previous = list[idx];
    list[idx] = updated;
    _pendingWritePetIds.add(petId);
    notifyListeners();

    if (kEnableFirebase) {
      try {
        await MedicationService.update(petId, medicationId, updated.toFirestore());
      } catch (e) {
        list[idx] = previous;
        notifyListeners();
        rethrow;
      } finally {
        _pendingWritePetIds.remove(petId);
      }
    } else {
      _pendingWritePetIds.remove(petId);
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
    _pendingWritePetIds.add(petId);
    notifyListeners();

    if (!kIsWeb && !toggled.isActive) {
      ReminderService.instance.cancelMedicationReminder(medicationId);
    }

    if (kEnableFirebase) {
      try {
        await MedicationService.update(petId, medicationId, {'isActive': toggled.isActive});
      } catch (e) {
        list[idx] = previous;
        notifyListeners();
        rethrow;
      } finally {
        _pendingWritePetIds.remove(petId);
      }
    } else {
      _pendingWritePetIds.remove(petId);
    }
  }

  /// Fetch medications for the given pet IDs from Firestore.
  Future<void> fetchForPets(List<String> petIds) async {
    final newIds = petIds.toSet();
    _medications.removeWhere((id, _) => !newIds.contains(id));
    _currentPetIds = List.of(petIds);

    final futures = <Future<void>>[];
    for (final id in petIds) {
      if (_pendingWritePetIds.contains(id)) continue;
      futures.add(
        MedicationService.fetch(id).then((list) {
          _medications[id] = list;
        }).catchError((Object e) {
          debugPrint('[MedicationStore] Failed to fetch for pet $id: $e');
        }),
      );
    }
    await Future.wait(futures);
    notifyListeners();
  }

  /// Re-fetch all medications for the current pet IDs (pull-to-refresh).
  Future<void> refresh() async {
    if (_currentPetIds.isEmpty) return;
    await fetchForPets(_currentPetIds);
  }

  void clearData() {
    _medications.clear();
    _currentPetIds = [];
    notifyListeners();
  }
}
