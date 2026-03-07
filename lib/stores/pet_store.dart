import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/services/pet_service.dart';
import 'package:pet_circle/services/user_service.dart';
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

  /// Seed from mock data (when kEnableFirebase == false).
  void seed({
    required List<Pet> ownerPets,
    required List<Pet> clinicPets,
  }) {
    _ownerPets = List.of(ownerPets);
    _clinicPets = List.of(clinicPets);
    notifyListeners();
  }

  /// Subscribe to Firestore streams for a given user.
  /// Pets where the user is in the careCircle appear in ownerPets.
  void subscribeForUser(String uid) {
    _petsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _petsSubscription = PetService.streamPetsForUser(uid).listen((pets) {
      _ownerPets = pets;
      _clinicPets = pets;
      _isLoading = false;
      notifyListeners();
    });
  }

  void cancelSubscription() {
    _petsSubscription?.cancel();
    _petsSubscription = null;
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
    _ownerPets.add(pet);
    if (!_clinicPets.any((p) => p.name == pet.name)) {
      _clinicPets.add(pet);
    }
    notifyListeners();
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

  void updatePet(String name, Pet updated) {
    final ownerIdx = _ownerPets.indexWhere((p) => p.name == name);
    if (ownerIdx != -1) _ownerPets[ownerIdx] = updated;

    final clinicIdx = _clinicPets.indexWhere((p) => p.name == name);
    if (clinicIdx != -1) _clinicPets[clinicIdx] = updated;

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

  CareCircleRole? currentUserRoleFor(String petName) {
    final uid = userStore.currentUserUid;
    final name = userStore.currentUser?.name;
    if (uid == null && name == null) return null;
    final pet = getPetByName(petName);
    if (pet == null) return null;

    // Owner of the pet is always admin, even if careCircle data is inconsistent
    if (uid != null && pet.ownerId == uid) return CareCircleRole.admin;

    final match = pet.careCircle
        .where((m) => (m.uid != null && m.uid == uid) || m.name == name)
        .firstOrNull;
    return match?.role;
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
