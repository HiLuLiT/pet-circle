import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';

enum PetAccessSource {
  ownerId,
  careCircleUid,
  careCircleEmailFallback,
  legacyNameFallback,
  unknown,
}

class PetAccess {
  const PetAccess({
    required this.pet,
    required this.role,
    required this.source,
    this.isOwner = false,
  });

  final Pet? pet;
  final CareCircleRole role;
  final PetAccessSource source;
  final bool isOwner;

  bool get hasPet => pet != null;
  bool get canMeasure => role.canMeasure;
  bool get canEditPet => role.canEditPet;
  bool get canManageCircle => role.canManageCircle;
  bool get canDeletePet => role.canDeletePet;
  bool get canAddNotes => role.canAddNotes;
  bool get canManageMedication => true;
  bool get canDeleteMeasurements => true;

  factory PetAccess.unknown([Pet? pet]) {
    return PetAccess(
      pet: pet,
      role: CareCircleRole.member,
      source: PetAccessSource.unknown,
    );
  }
}
