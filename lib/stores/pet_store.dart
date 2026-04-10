import 'package:flutter/foundation.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet_access.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/services/pet_service.dart';
import 'package:pet_circle/repositories/user_repository.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/note_store.dart';
import 'package:pet_circle/stores/user_store.dart';

final petStore = PetStore();

class PetStore extends ChangeNotifier {
  List<Pet> _ownerPets = [];
  List<Pet> _clinicPets = [];
  int _activePetIndex = 0;
  String? _subscribedUid;
  bool _isLoading = false;
  final Set<String> _pendingDeletes = {};

  List<Pet> get ownerPets => List.unmodifiable(_ownerPets);
  List<Pet> get allClinicPets => List.unmodifiable(_clinicPets);
  bool get isLoading => _isLoading;
  /// The UID currently subscribed to, or null if no subscription is active.
  String? get currentSubscribedUid => _subscribedUid;
  int get activePetIndex => _activePetIndex.clamp(0, _ownerPets.isEmpty ? 0 : _ownerPets.length - 1);

  Pet? get activePet => _ownerPets.isEmpty ? null : _ownerPets[activePetIndex];

  void setActivePetIndex(int index) {
    _activePetIndex = index;
    notifyListeners();
  }

  void setActivePet(Pet pet) {
    final index = _ownerPets.indexWhere((candidate) =>
        (candidate.id != null && candidate.id == pet.id) ||
        candidate.name == pet.name);
    if (index == -1) return;
    _activePetIndex = index;
    notifyListeners();
  }

  /// Seed from mock data (when kEnableFirebase == false).
  void seed({
    required List<Pet> ownerPets,
    required List<Pet> clinicPets,
  }) {
    _ownerPets = ownerPets.map(_withFallbackId).toList();
    _clinicPets = clinicPets.map(_withFallbackId).toList();
    _activePetIndex = activePetIndex;
    notifyListeners();
  }

  /// Fetch pets for a given user from Firestore (one-time read).
  /// Then fetches child store data (measurements, notes, medications) in parallel.
  Future<void> fetchForUser(String uid) async {
    _subscribedUid = uid;
    _isLoading = true;
    notifyListeners();

    try {
      final pets = await PetService.fetchPetsForUser(uid);

      // Filter out pets that are pending deletion to avoid race conditions.
      final filtered = _pendingDeletes.isEmpty
          ? pets
          : pets.where((p) => p.id == null || !_pendingDeletes.contains(p.id)).toList();
      final previousActivePetId = activePet?.id;
      _ownerPets = List.of(filtered);
      _clinicPets = List.of(filtered);
      if (previousActivePetId != null) {
        final newIndex =
            _ownerPets.indexWhere((pet) => pet.id == previousActivePetId);
        _activePetIndex = newIndex == -1 ? 0 : newIndex;
      } else {
        _activePetIndex = activePetIndex;
      }

      final petIds = _ownerPets
          .map((pet) => pet.id)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();

      // Fetch child store data in parallel
      await Future.wait([
        measurementStore.fetchForPets(petIds),
        noteStore.fetchForPets(petIds),
        medicationStore.fetchForPets(petIds),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Re-fetch all data for the current user (pull-to-refresh).
  Future<void> refresh() async {
    if (_subscribedUid == null) return;
    await fetchForUser(_subscribedUid!);
  }

  void clearData() {
    _subscribedUid = null;
    _ownerPets = [];
    _clinicPets = [];
    measurementStore.clearData();
    noteStore.clearData();
    medicationStore.clearData();
    notifyListeners();
  }

  Pet? getPetByName(String name) {
    final all = {..._ownerPets, ..._clinicPets};
    for (final pet in all) {
      if (pet.name == name) return pet;
    }
    return null;
  }

  Pet? getPetById(String id) {
    for (final pet in [..._ownerPets, ..._clinicPets]) {
      if (pet.id == id) return pet;
    }
    return null;
  }

  void addPet(Pet pet) {
    final normalizedPet = _withFallbackId(pet);
    _ownerPets.add(normalizedPet);
    if (!_clinicPets.any((p) => p.name == normalizedPet.name)) {
      _clinicPets.add(normalizedPet);
    }
    notifyListeners();
  }

  Pet _withFallbackId(Pet pet) {
    if (pet.id != null && pet.id!.isNotEmpty) return pet;
    return pet.copyWith(id: 'mock-${pet.name.toLowerCase().replaceAll(' ', '-')}');
  }

  /// Create a pet and persist to Firestore when Firebase is enabled.
  Future<Pet> createPetWithFirestore(Pet pet) async {
    if (kEnableFirebase) {
      final uid = userStore.currentUserUid;
      final petWithOwner = pet.copyWith(ownerId: uid);
      final created = await PetService.createPet(petWithOwner);
      if (uid != null && created.id != null) {
        await userRepository.addPetToUser(uid, created.id!);
      }
      return created;
    } else {
      addPet(pet);
      return pet;
    }
  }

  Future<void> updatePetWithFirestore(Pet updated) async {
    final previousOwner = updated.id != null
        ? _ownerPets.where((p) => p.id == updated.id).firstOrNull
        : _ownerPets.where((p) => p.name == updated.name).firstOrNull;
    final previousClinic = updated.id != null
        ? _clinicPets.where((p) => p.id == updated.id).firstOrNull
        : _clinicPets.where((p) => p.name == updated.name).firstOrNull;

    _replacePetLocal(updated);

    if (kEnableFirebase && updated.id != null) {
      try {
        await PetService.updatePet(updated.id!, {
          'name': updated.name,
          'breedAndAge': updated.breedAndAge,
          'imageUrl': updated.imageUrl,
        });
      } catch (e) {
        if (previousOwner != null) _replacePetLocal(previousOwner);
        if (previousClinic != null && previousOwner == null) {
          _replacePetLocal(previousClinic);
        }
        rethrow;
      }
    }
  }

  void updatePet(String name, Pet updated) {
    final ownerIdx = _ownerPets.indexWhere((p) => p.name == name);
    if (ownerIdx != -1) _ownerPets[ownerIdx] = updated;

    final clinicIdx = _clinicPets.indexWhere((p) => p.name == name);
    if (clinicIdx != -1) _clinicPets[clinicIdx] = updated;

    notifyListeners();
  }

  void _replacePetLocal(Pet updated) {
    for (final list in [_ownerPets, _clinicPets]) {
      final idx = list.indexWhere((pet) =>
          (updated.id != null && pet.id == updated.id) ||
          pet.name == updated.name);
      if (idx != -1) {
        list[idx] = updated;
      }
    }
    notifyListeners();
  }

  Future<void> removePetWithFirestore(String name) async {
    final pet = getPetByName(name);
    final petId = pet?.id;
    final ownerIdx = _ownerPets.indexWhere((p) => p.name == name);
    final clinicIdx = _clinicPets.indexWhere((p) => p.name == name);

    // Mark as pending delete so the stream listener filters it out.
    if (petId != null) _pendingDeletes.add(petId);

    final removedOwner = ownerIdx != -1 ? _ownerPets.removeAt(ownerIdx) : null;
    final removedClinic = clinicIdx != -1 ? _clinicPets.removeAt(clinicIdx) : null;
    if (removedOwner != null || removedClinic != null) notifyListeners();

    if (kEnableFirebase && petId != null) {
      try {
        final uid = userStore.currentUserUid;
        await PetService.deletePet(petId);
        if (uid != null) {
          await userRepository.removePetFromUser(uid, petId);
        }
      } catch (e) {
        _pendingDeletes.remove(petId);
        if (removedOwner != null) {
          _ownerPets.insert(ownerIdx.clamp(0, _ownerPets.length), removedOwner);
        }
        if (removedClinic != null) {
          _clinicPets.insert(clinicIdx.clamp(0, _clinicPets.length), removedClinic);
        }
        notifyListeners();
        rethrow;
      }
    }
    // Clear pending delete after Firestore has processed it.
    if (petId != null) _pendingDeletes.remove(petId);
  }

  void removePet(String name) {
    _ownerPets.removeWhere((p) => p.name == name);
    _clinicPets.removeWhere((p) => p.name == name);
    notifyListeners();
  }

  PetAccess accessForActivePet() => accessForPet(activePet);

  PetAccess accessForPetId(String? petId) {
    if (petId == null) return PetAccess.unknown();
    return accessForPet(getPetById(petId));
  }

  PetAccess accessForPet(Pet? pet) {
    if (pet == null) return PetAccess.unknown();

    final uid = userStore.currentUserUid;
    final email = userStore.currentUserEmail?.toLowerCase();
    final displayName = userStore.currentUserDisplayName;

    if (uid != null && pet.ownerId == uid) {
      return PetAccess(
        pet: pet,
        role: CareCircleRole.owner,
        source: PetAccessSource.ownerId,
        isOwner: true,
      );
    }

    if (uid != null) {
      final uidMatch = pet.careCircle
          .where((member) => member.uid == uid)
          .firstOrNull;
      if (uidMatch != null) {
        return PetAccess(
          pet: pet,
          role: uidMatch.role,
          source: PetAccessSource.careCircleUid,
        );
      }
    }

    if (email != null && email.isNotEmpty) {
      final emailMatch = pet.careCircle
          .where((member) => member.name.toLowerCase() == email)
          .firstOrNull;
      if (emailMatch != null) {
        return PetAccess(
          pet: pet,
          role: emailMatch.role,
          source: PetAccessSource.careCircleEmailFallback,
        );
      }
    }

    if (displayName != null && displayName.isNotEmpty) {
      final nameMatch = pet.careCircle
          .where((member) => member.name == displayName)
          .firstOrNull;
      if (nameMatch != null) {
        return PetAccess(
          pet: pet,
          role: nameMatch.role,
          source: PetAccessSource.legacyNameFallback,
        );
      }
    }

    return PetAccess.unknown(pet);
  }

  CareCircleRole? currentUserRoleFor(String petName) {
    final pet = getPetByName(petName);
    if (pet == null) return null;
    return accessForPet(pet).role;
  }

  /// Remove a care circle member. Updates local state immediately (optimistic),
  /// then persists to Firestore. Rolls back on error.
  Future<void> removeCareCircleMemberByUid(String petName, String? uid, String memberName) async {
    final pet = getPetByName(petName);

    // Always update local state first for immediate UI feedback
    _removeCareCircleMemberLocal(petName, memberName);

    if (kEnableFirebase && pet?.id != null && uid != null) {
      try {
        await PetService.removeCareCircleMember(pet!.id!, uid);
      } catch (e) {
        // Rollback: re-fetch to restore the member in the local state
        await refresh();
        rethrow;
      }
    }
  }

  @Deprecated('Use removeCareCircleMemberByUid instead')
  Future<void> removeCareCircleMemberWithFirestore(String petName, String memberName) async {
    final pet = getPetByName(petName);
    if (kEnableFirebase && pet?.id != null) {
      final member = pet!.careCircle.where((m) => m.name == memberName).firstOrNull;
      if (member?.uid != null) {
        await PetService.removeCareCircleMember(pet.id!, member!.uid!);
        return;
      }
    }
    _removeCareCircleMemberLocal(petName, memberName);
  }

  void removeCareCircleMember(String petName, String memberName) {
    _removeCareCircleMemberLocal(petName, memberName);
  }

  void _removeCareCircleMemberLocal(String petName, String memberName) {
    for (final list in [_ownerPets, _clinicPets]) {
      final idx = list.indexWhere((p) => p.name == petName);
      if (idx != -1) {
        final pet = list[idx];
        list[idx] = pet.copyWith(
          careCircle: pet.careCircle.where((m) => m.name != memberName).toList(),
        );
      }
    }
    notifyListeners();
  }
}
