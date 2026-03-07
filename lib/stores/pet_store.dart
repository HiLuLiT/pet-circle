import 'package:flutter/foundation.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/stores/user_store.dart';

final petStore = PetStore();

class PetStore extends ChangeNotifier {
  List<Pet> _ownerPets = [];
  List<Pet> _clinicPets = [];
  int _activePetIndex = 0;

  List<Pet> get ownerPets => List.unmodifiable(_ownerPets);
  List<Pet> get allClinicPets => List.unmodifiable(_clinicPets);
  int get activePetIndex => _activePetIndex.clamp(0, _ownerPets.isEmpty ? 0 : _ownerPets.length - 1);

  Pet? get activePet => _ownerPets.isEmpty ? null : _ownerPets[activePetIndex];

  void setActivePetIndex(int index) {
    _activePetIndex = index;
    notifyListeners();
  }

  void seed({
    required List<Pet> ownerPets,
    required List<Pet> clinicPets,
  }) {
    _ownerPets = List.of(ownerPets);
    _clinicPets = List.of(clinicPets);
    notifyListeners();
  }

  Pet? getPetByName(String name) {
    final all = {..._ownerPets, ..._clinicPets};
    for (final pet in all) {
      if (pet.name == name) return pet;
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

  void updatePet(String name, Pet updated) {
    final ownerIdx = _ownerPets.indexWhere((p) => p.name == name);
    if (ownerIdx != -1) _ownerPets[ownerIdx] = updated;

    final clinicIdx = _clinicPets.indexWhere((p) => p.name == name);
    if (clinicIdx != -1) _clinicPets[clinicIdx] = updated;

    notifyListeners();
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
    final match = pet.careCircle
        .where((m) => (m.uid != null && m.uid == uid) || m.name == name)
        .firstOrNull;
    return match?.role;
  }

  void removeCareCircleMember(String petName, String memberName) {
    for (final list in [_ownerPets, _clinicPets]) {
      final idx = list.indexWhere((p) => p.name == petName);
      if (idx != -1) {
        final pet = list[idx];
        final updated = Pet(
          name: pet.name,
          breedAndAge: pet.breedAndAge,
          imageUrl: pet.imageUrl,
          statusLabel: pet.statusLabel,
          statusColorHex: pet.statusColorHex,
          latestMeasurement: pet.latestMeasurement,
          careCircle: pet.careCircle.where((m) => m.name != memberName).toList(),
          diagnosis: pet.diagnosis,
        );
        list[idx] = updated;
      }
    }
    notifyListeners();
  }
}
