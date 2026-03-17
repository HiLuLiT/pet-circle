import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet_access.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/services/pet_service.dart';
import 'package:pet_circle/services/user_service.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/note_store.dart';
import 'package:pet_circle/stores/user_store.dart';

final petStore = PetStore();

class PetStore extends ChangeNotifier {
  List<Pet> _ownerPets = [];
  List<Pet> _clinicPets = [];
  int _activePetIndex = 0;
  StreamSubscription<List<Pet>>? _petsSubscription;
  bool _isLoading = false;

  List<Pet> get ownerPets => List.unmodifiable(_ownerPets);
  List<Pet> get allClinicPets => List.unmodifiable(_clinicPets);
  bool get isLoading => _isLoading;
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

  /// Subscribe to Firestore streams for a given user.
  /// Pets where the user is in the careCircle appear in ownerPets.
  void subscribeForUser(String uid) {
    _petsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _petsSubscription = PetService.streamPetsForUser(uid).listen((pets) {
      final previousActivePetId = activePet?.id;
      _ownerPets = pets;
      _clinicPets = pets;
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
      measurementStore.subscribeForPets(petIds);
      noteStore.subscribeForPets(petIds);
      medicationStore.subscribeForPets(petIds);
      _isLoading = false;
      notifyListeners();
    });
  }

  void cancelSubscription() {
    _petsSubscription?.cancel();
    _petsSubscription = null;
    measurementStore.cancelSubscriptions();
    noteStore.cancelSubscriptions();
    medicationStore.cancelSubscriptions();
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
        await UserService.addPetToUser(uid, created.id!);
      }
      return created;
    } else {
      addPet(pet);
      return pet;
    }
  }

  Future<void> updatePetWithFirestore(Pet updated) async {
    if (kEnableFirebase && updated.id != null) {
      await PetService.updatePet(updated.id!, {
        'name': updated.name,
        'breedAndAge': updated.breedAndAge,
        'imageUrl': updated.imageUrl,
      });
      return;
    }
    _replacePetLocal(updated);
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

  /// Remove a pet from Firestore (stream updates local state) or locally in mock mode.
  Future<void> removePetWithFirestore(String name) async {
    if (kEnableFirebase) {
      final pet = getPetByName(name);
      if (pet?.id != null) {
        final uid = userStore.currentUserUid;
        await PetService.deletePet(pet!.id!);
        if (uid != null) {
          await UserService.removePetFromUser(uid, pet.id!);
        }
      }
    } else {
      _ownerPets.removeWhere((p) => p.name == name);
      _clinicPets.removeWhere((p) => p.name == name);
      notifyListeners();
    }
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
        role: CareCircleRole.admin,
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

  /// Remove a care circle member from Firestore (stream updates local state) or locally in mock mode.
  Future<void> removeCareCircleMemberWithFirestore(String petName, String memberName) async {
    if (kEnableFirebase) {
      final pet = getPetByName(petName);
      if (pet?.id != null) {
        final member = pet!.careCircle.firstWhere(
          (m) => m.name == memberName,
          orElse: () => CareCircleMember(name: '', avatarUrl: '', role: CareCircleRole.viewer),
        );
        if (member.uid != null) {
          await PetService.removeCareCircleMember(pet.id!, member.uid!);
        }
      }
    } else {
      _removeCareCircleMemberLocal(petName, memberName);
    }
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
