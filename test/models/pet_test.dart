import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';

Pet _makePet() {
  return Pet(
    id: 'p-1',
    name: 'Princess',
    breedAndAge: 'Cavalier King Charles - 5 years old',
    imageUrl: 'https://example.com/pet.png',
    statusLabel: 'Normal',
    statusColorHex: 0xFF75ACFF,
    latestMeasurement: Measurement(
      bpm: 22,
      recordedAt: DateTime(2025, 1, 1),
    ),
    careCircle: [
      CareCircleMember(
        name: 'Hila',
        avatarUrl: 'https://example.com/hila.png',
        role: CareCircleRole.admin,
      ),
    ],
    diagnosis: 'MVD Stage B1',
    ownerId: 'owner-1',
  );
}

void main() {
  group('Pet copyWith', () {
    test('copyWith creates a new instance', () {
      final original = _makePet();
      final copy = original.copyWith(name: 'Buddy');

      expect(identical(original, copy), isFalse);
      expect(copy.name, 'Buddy');
      expect(original.name, 'Princess');
    });

    test('all fields preserved when no args to copyWith', () {
      final original = _makePet();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.breedAndAge, original.breedAndAge);
      expect(copy.imageUrl, original.imageUrl);
      expect(copy.statusLabel, original.statusLabel);
      expect(copy.statusColorHex, original.statusColorHex);
      expect(copy.latestMeasurement.bpm, original.latestMeasurement.bpm);
      expect(copy.careCircle.length, original.careCircle.length);
      expect(copy.diagnosis, original.diagnosis);
      expect(copy.ownerId, original.ownerId);
    });

    test('original is unchanged after copyWith', () {
      final original = _makePet();

      original.copyWith(
        name: 'NewName',
        breedAndAge: 'NewBreed',
        statusLabel: 'Critical',
        diagnosis: 'NewDiagnosis',
      );

      expect(original.name, 'Princess');
      expect(original.breedAndAge, 'Cavalier King Charles - 5 years old');
      expect(original.statusLabel, 'Normal');
      expect(original.diagnosis, 'MVD Stage B1');
    });

    test('copyWith can update each field independently', () {
      final original = _makePet();

      expect(original.copyWith(id: 'new-id').id, 'new-id');
      expect(original.copyWith(name: 'Rex').name, 'Rex');
      expect(
        original.copyWith(breedAndAge: 'Poodle - 2 years').breedAndAge,
        'Poodle - 2 years',
      );
      expect(
        original.copyWith(imageUrl: 'new.png').imageUrl,
        'new.png',
      );
      expect(
        original.copyWith(statusLabel: 'Elevated').statusLabel,
        'Elevated',
      );
      expect(
        original.copyWith(statusColorHex: 0xFF000000).statusColorHex,
        0xFF000000,
      );
      expect(
        original.copyWith(ownerId: 'new-owner').ownerId,
        'new-owner',
      );
    });

    test('copyWith can replace careCircle', () {
      final original = _makePet();
      final newCircle = [
        CareCircleMember(
          name: 'Bob',
          avatarUrl: 'https://example.com/bob.png',
          role: CareCircleRole.viewer,
        ),
      ];

      final copy = original.copyWith(careCircle: newCircle);

      expect(copy.careCircle.length, 1);
      expect(copy.careCircle.first.name, 'Bob');
      expect(original.careCircle.first.name, 'Hila');
    });
  });

  group('Pet construction', () {
    test('Pet with null id is valid', () {
      final pet = Pet(
        name: 'NoPet',
        breedAndAge: 'Unknown',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFFFFFFFF,
        latestMeasurement: Measurement(bpm: 0, recordedAt: DateTime(2025, 1, 1)),
        careCircle: [],
      );

      expect(pet.id, isNull);
      expect(pet.ownerId, isNull);
      expect(pet.diagnosis, isNull);
    });
  });
}
