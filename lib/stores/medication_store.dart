import 'package:flutter/foundation.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/services/medication_service.dart';
import 'package:pet_circle/services/reminder_service.dart';
import 'package:pet_circle/stores/user_store.dart';

final medicationStore = MedicationStore();

class MedicationStore extends ChangeNotifier {
  /// Medications grouped by pet id for the UI. Source of truth is the current
  /// user's private collection; entries are private per user.
  Map<String, List<Medication>> _medications = {};
  String? _currentUid;
  bool _pendingWrite = false;

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
    _pendingWrite = true;
    notifyListeners();

    final uid = userStore.currentUserUid;
    if (kEnableFirebase && uid != null && uid.isNotEmpty) {
      try {
        await MedicationService.add(uid, medication);
      } catch (e) {
        _medications[petId]?.remove(medication);
        notifyListeners();
        rethrow;
      } finally {
        _pendingWrite = false;
      }
    } else {
      _pendingWrite = false;
    }
  }

  Future<void> removeMedication(String petId, String medicationId) async {
    final list = _medications[petId];
    final idx = list?.indexWhere((m) => m.id == medicationId) ?? -1;
    final removed = (list != null && idx != -1) ? list.removeAt(idx) : null;
    if (removed != null) {
      _pendingWrite = true;
      notifyListeners();
    }

    if (!kIsWeb) {
      ReminderService.instance.cancelMedicationReminder(medicationId);
    }

    final uid = userStore.currentUserUid;
    if (kEnableFirebase && uid != null && uid.isNotEmpty) {
      try {
        await MedicationService.delete(uid, medicationId);
      } catch (e) {
        if (removed != null && list != null) {
          list.insert(idx.clamp(0, list.length), removed);
          notifyListeners();
        }
        rethrow;
      } finally {
        _pendingWrite = false;
      }
    } else {
      _pendingWrite = false;
    }
  }

  Future<void> updateMedication(
      String petId, String medicationId, Medication updated) async {
    final list = _medications[petId];
    if (list == null) return;
    final idx = list.indexWhere((m) => m.id == medicationId);
    if (idx == -1) return;
    final previous = list[idx];
    list[idx] = updated;
    _pendingWrite = true;
    notifyListeners();

    final uid = userStore.currentUserUid;
    if (kEnableFirebase && uid != null && uid.isNotEmpty) {
      try {
        await MedicationService.update(uid, medicationId, updated.toFirestore());
      } catch (e) {
        list[idx] = previous;
        notifyListeners();
        rethrow;
      } finally {
        _pendingWrite = false;
      }
    } else {
      _pendingWrite = false;
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
    _pendingWrite = true;
    notifyListeners();

    if (!kIsWeb && !toggled.isActive) {
      ReminderService.instance.cancelMedicationReminder(medicationId);
    }

    final uid = userStore.currentUserUid;
    if (kEnableFirebase && uid != null && uid.isNotEmpty) {
      try {
        await MedicationService.update(
            uid, medicationId, {'isActive': toggled.isActive});
      } catch (e) {
        list[idx] = previous;
        notifyListeners();
        rethrow;
      } finally {
        _pendingWrite = false;
      }
    } else {
      _pendingWrite = false;
    }
  }

  /// All medications across all pets, regardless of active state.
  List<Medication> get allMedications => List.unmodifiable(
        _medications.values.expand((meds) => meds).toList(),
      );

  /// Active medications (across all pets) that have an end-date reminder.
  List<Medication> getMedicationsWithEndReminder() {
    final result = <Medication>[];
    for (final meds in _medications.values) {
      for (final med in meds) {
        if (med.hasEndReminder) result.add(med);
      }
    }
    return List.unmodifiable(result);
  }

  /// Fetch the current user's medications from Firestore, grouped by pet id.
  Future<void> fetchForUser(String uid) async {
    _currentUid = uid;
    if (_pendingWrite) return;
    try {
      final meds = await MedicationService.fetchForUser(uid);
      final grouped = <String, List<Medication>>{};
      for (final med in meds) {
        grouped.putIfAbsent(med.petId, () => []).add(med);
      }
      _medications = grouped;
    } catch (e) {
      debugPrint('[MedicationStore] Failed to fetch for user $uid: $e');
    }
    notifyListeners();
  }

  /// Re-fetch all medications for the current user (pull-to-refresh).
  Future<void> refresh() async {
    final uid = _currentUid;
    if (uid == null) return;
    await fetchForUser(uid);
  }

  void clearData() {
    _medications.clear();
    _currentUid = null;
    notifyListeners();
  }
}
