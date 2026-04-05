import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/models/pet_access.dart';

Pet _makePet() {
  return Pet(
    id: 'p-1',
    name: 'Princess',
    breedAndAge: 'Cavalier - 5 years',
    imageUrl: 'https://example.com/pet.png',
    statusLabel: 'Normal',
    statusColorHex: 0xFF75ACFF,
    latestMeasurement: Measurement(bpm: 22, recordedAt: DateTime(2025, 1, 1)),
    careCircle: [],
    ownerId: 'owner-1',
  );
}

void main() {
  group('PetAccess construction', () {
    test('creates with all required fields', () {
      final access = PetAccess(
        pet: _makePet(),
        role: CareCircleRole.owner,
        source: PetAccessSource.ownerId,
        isOwner: true,
      );

      expect(access.pet, isNotNull);
      expect(access.role, CareCircleRole.owner);
      expect(access.source, PetAccessSource.ownerId);
      expect(access.isOwner, isTrue);
    });

    test('isOwner defaults to false', () {
      final access = PetAccess(
        pet: _makePet(),
        role: CareCircleRole.member,
        source: PetAccessSource.careCircleUid,
      );

      expect(access.isOwner, isFalse);
    });

    test('pet can be null', () {
      final access = PetAccess(
        pet: null,
        role: CareCircleRole.member,
        source: PetAccessSource.unknown,
      );

      expect(access.pet, isNull);
    });
  });

  group('PetAccess.unknown factory', () {
    test('creates with member role and unknown source', () {
      final access = PetAccess.unknown();

      expect(access.pet, isNull);
      expect(access.role, CareCircleRole.member);
      expect(access.source, PetAccessSource.unknown);
      expect(access.isOwner, isFalse);
    });

    test('unknown factory accepts optional pet', () {
      final pet = _makePet();
      final access = PetAccess.unknown(pet);

      expect(access.pet, isNotNull);
      expect(access.pet!.name, 'Princess');
      expect(access.role, CareCircleRole.member);
      expect(access.source, PetAccessSource.unknown);
    });
  });

  group('PetAccess computed properties', () {
    test('hasPet returns true when pet is not null', () {
      final access = PetAccess(
        pet: _makePet(),
        role: CareCircleRole.owner,
        source: PetAccessSource.ownerId,
      );

      expect(access.hasPet, isTrue);
    });

    test('hasPet returns false when pet is null', () {
      final access = PetAccess.unknown();

      expect(access.hasPet, isFalse);
    });
  });

  group('PetAccess permission delegation', () {
    test('owner can measure, edit, manage circle, delete, add notes', () {
      final access = PetAccess(
        pet: _makePet(),
        role: CareCircleRole.owner,
        source: PetAccessSource.ownerId,
      );

      expect(access.canMeasure, isTrue);
      expect(access.canEditPet, isTrue);
      expect(access.canManageCircle, isTrue);
      expect(access.canDeletePet, isTrue);
      expect(access.canAddNotes, isTrue);
      expect(access.canManageMedication, isTrue);
      expect(access.canDeleteMeasurements, isTrue);
    });

    test('member can measure, add notes, manage meds, delete measurements', () {
      final access = PetAccess(
        pet: _makePet(),
        role: CareCircleRole.member,
        source: PetAccessSource.careCircleUid,
      );

      expect(access.canMeasure, isTrue);
      expect(access.canEditPet, isFalse);
      expect(access.canManageCircle, isFalse);
      expect(access.canDeletePet, isFalse);
      expect(access.canAddNotes, isTrue);
      expect(access.canManageMedication, isTrue);
      expect(access.canDeleteMeasurements, isTrue);
    });
  });

  group('PetAccessSource', () {
    test('all source values are distinct', () {
      final sources = PetAccessSource.values;
      expect(sources.length, 5);
      expect(sources.toSet().length, 5);
    });
  });
}
