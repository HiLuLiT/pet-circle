import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/stores/pet_store.dart';

Pet _makePet(String name, {String? id}) {
  return Pet(
    id: id,
    name: name,
    breedAndAge: 'Breed - 3 years',
    imageUrl: 'https://example.com/$name.png',
    statusLabel: 'Normal',
    statusColorHex: 0xFF75ACFF,
    latestMeasurement: Measurement(
      bpm: 22,
      recordedAt: DateTime(2025, 1, 1),
    ),
    careCircle: const [],
  );
}

void main() {
  late PetStore store;

  setUp(() {
    store = PetStore();
  });

  group('PetStore seed', () {
    test('seed() populates ownerPets list', () {
      final pets = [_makePet('Buddy', id: 'p1'), _makePet('Rex', id: 'p2')];

      store.seed(ownerPets: pets, clinicPets: []);

      expect(store.ownerPets.length, 2);
      expect(store.ownerPets[0].name, 'Buddy');
      expect(store.ownerPets[1].name, 'Rex');
    });

    test('seed() assigns fallback ids to pets without an id', () {
      final pet = _makePet('Buddy');
      store.seed(ownerPets: [pet], clinicPets: []);

      expect(store.ownerPets.first.id, isNotNull);
      expect(store.ownerPets.first.id, startsWith('mock-'));
    });

    test('seed() populates clinicPets list', () {
      final clinics = [_makePet('Luna', id: 'c1')];
      store.seed(ownerPets: [], clinicPets: clinics);

      expect(store.allClinicPets.length, 1);
      expect(store.allClinicPets.first.name, 'Luna');
    });
  });

  group('PetStore add / remove', () {
    test('addPet increases ownerPets length', () {
      store.seed(ownerPets: [_makePet('A', id: 'a1')], clinicPets: []);
      expect(store.ownerPets.length, 1);

      store.addPet(_makePet('B', id: 'b1'));
      expect(store.ownerPets.length, 2);
    });

    test('removePet decreases ownerPets length', () {
      store.seed(
        ownerPets: [_makePet('A', id: 'a1'), _makePet('B', id: 'b1')],
        clinicPets: [],
      );
      expect(store.ownerPets.length, 2);

      store.removePet('A');
      expect(store.ownerPets.length, 1);
      expect(store.ownerPets.first.name, 'B');
    });

    test('removePet with non-existent name does nothing', () {
      store.seed(ownerPets: [_makePet('A', id: 'a1')], clinicPets: []);

      store.removePet('DoesNotExist');
      expect(store.ownerPets.length, 1);
    });
  });

  group('PetStore setActivePet', () {
    test('setActivePet updates activePet', () {
      final petA = _makePet('A', id: 'a1');
      final petB = _makePet('B', id: 'b1');
      store.seed(ownerPets: [petA, petB], clinicPets: []);

      expect(store.activePet?.name, 'A');

      store.setActivePet(petB);
      expect(store.activePet?.name, 'B');
      expect(store.activePetIndex, 1);
    });

    test('setActivePetIndex updates activePet', () {
      store.seed(
        ownerPets: [_makePet('A', id: 'a1'), _makePet('B', id: 'b1')],
        clinicPets: [],
      );

      store.setActivePetIndex(1);
      expect(store.activePet?.name, 'B');
    });

    test('activePet returns null when ownerPets is empty', () {
      store.seed(ownerPets: [], clinicPets: []);
      expect(store.activePet, isNull);
    });
  });

  group('PetStore notifyListeners', () {
    test('notifyListeners is called on seed', () {
      int callCount = 0;
      store.addListener(() => callCount++);

      store.seed(ownerPets: [_makePet('X', id: 'x1')], clinicPets: []);
      expect(callCount, 1);
    });

    test('notifyListeners is called on addPet', () {
      store.seed(ownerPets: [], clinicPets: []);

      int callCount = 0;
      store.addListener(() => callCount++);

      store.addPet(_makePet('Y', id: 'y1'));
      expect(callCount, 1);
    });

    test('notifyListeners is called on removePet', () {
      store.seed(ownerPets: [_makePet('Z', id: 'z1')], clinicPets: []);

      int callCount = 0;
      store.addListener(() => callCount++);

      store.removePet('Z');
      expect(callCount, 1);
    });

    test('notifyListeners is called on setActivePet', () {
      final petA = _makePet('A', id: 'a1');
      final petB = _makePet('B', id: 'b1');
      store.seed(ownerPets: [petA, petB], clinicPets: []);

      int callCount = 0;
      store.addListener(() => callCount++);

      store.setActivePet(petB);
      expect(callCount, 1);
    });
  });

  group('PetStore lookup', () {
    test('getPetByName returns correct pet', () {
      store.seed(
        ownerPets: [_makePet('Buddy', id: 'b1')],
        clinicPets: [_makePet('Luna', id: 'l1')],
      );

      expect(store.getPetByName('Buddy')?.name, 'Buddy');
      expect(store.getPetByName('Luna')?.name, 'Luna');
      expect(store.getPetByName('NonExistent'), isNull);
    });

    test('getPetById returns correct pet', () {
      store.seed(
        ownerPets: [_makePet('Buddy', id: 'b1')],
        clinicPets: [],
      );

      expect(store.getPetById('b1')?.name, 'Buddy');
      expect(store.getPetById('nonexistent'), isNull);
    });
  });

  group('PetStore updatePet', () {
    test('updatePet replaces pet by name', () {
      store.seed(
        ownerPets: [_makePet('Buddy', id: 'b1')],
        clinicPets: [],
      );

      final updated = _makePet('Buddy', id: 'b1').copyWith(
        breedAndAge: 'New Breed - 5 years',
      );
      store.updatePet('Buddy', updated);

      expect(store.ownerPets.first.breedAndAge, 'New Breed - 5 years');
    });

    test('updatePet with non-existent name does nothing', () {
      store.seed(
        ownerPets: [_makePet('Buddy', id: 'b1')],
        clinicPets: [],
      );

      store.updatePet('NonExistent', _makePet('NonExistent'));
      expect(store.ownerPets.first.name, 'Buddy');
    });

    test('updatePet updates both ownerPets and clinicPets when both contain the pet', () {
      store.seed(
        ownerPets: [_makePet('Shared', id: 's1')],
        clinicPets: [_makePet('Shared', id: 's1')],
      );

      final updated = _makePet('Shared', id: 's1').copyWith(breedAndAge: 'New Breed');
      store.updatePet('Shared', updated);

      expect(store.ownerPets.first.breedAndAge, 'New Breed');
      expect(store.allClinicPets.first.breedAndAge, 'New Breed');
    });

    test('updatePet notifies listeners', () {
      store.seed(ownerPets: [_makePet('Buddy', id: 'b1')], clinicPets: []);

      int callCount = 0;
      store.addListener(() => callCount++);

      store.updatePet('Buddy', _makePet('Buddy', id: 'b1').copyWith(breedAndAge: 'Updated'));
      expect(callCount, 1);
    });
  });

  group('PetStore addPet', () {
    test('addPet assigns fallback id when pet has no id', () {
      store.seed(ownerPets: [], clinicPets: []);

      store.addPet(_makePet('Fido'));

      expect(store.ownerPets.first.id, isNotNull);
      expect(store.ownerPets.first.id, startsWith('mock-'));
    });

    test('addPet adds to clinicPets when not already present', () {
      store.seed(ownerPets: [], clinicPets: []);

      store.addPet(_makePet('Rover', id: 'r1'));

      expect(store.allClinicPets.any((p) => p.name == 'Rover'), isTrue);
    });

    test('addPet does not duplicate in clinicPets when name already present', () {
      store.seed(
        ownerPets: [],
        clinicPets: [_makePet('Rover', id: 'r1')],
      );

      store.addPet(_makePet('Rover', id: 'r2'));

      // Still 1 clinic pet — duplicate by name is skipped.
      expect(store.allClinicPets.length, 1);
    });
  });

  group('PetStore removePet', () {
    test('removePet removes from both ownerPets and clinicPets', () {
      store.seed(
        ownerPets: [_makePet('Rex', id: 'r1')],
        clinicPets: [_makePet('Rex', id: 'r1')],
      );

      store.removePet('Rex');

      expect(store.ownerPets, isEmpty);
      expect(store.allClinicPets, isEmpty);
    });
  });

  group('PetStore activePetIndex clamping', () {
    test('activePetIndex is clamped to valid range when list shrinks', () {
      store.seed(
        ownerPets: [_makePet('A', id: 'a1'), _makePet('B', id: 'b1')],
        clinicPets: [],
      );
      store.setActivePetIndex(1);
      expect(store.activePetIndex, 1);

      store.removePet('B');
      // Index was 1, but list now has only 1 element — clamped to 0.
      expect(store.activePetIndex, 0);
    });

    test('activePetIndex is 0 when ownerPets is empty', () {
      store.seed(ownerPets: [], clinicPets: []);
      expect(store.activePetIndex, 0);
    });
  });

  group('PetStore setActivePet', () {
    test('setActivePet with pet not in list does nothing', () {
      store.seed(ownerPets: [_makePet('Only', id: 'o1')], clinicPets: []);

      store.setActivePet(_makePet('NotInList', id: 'z1'));

      expect(store.activePetIndex, 0);
      expect(store.activePet?.name, 'Only');
    });

    test('setActivePet matches by name when id is null', () {
      store.seed(ownerPets: [_makePet('Alpha', id: 'a1'), _makePet('Beta', id: 'b1')], clinicPets: []);

      // Pet without id — should match by name.
      store.setActivePet(_makePet('Beta'));

      expect(store.activePetIndex, 1);
      expect(store.activePet?.name, 'Beta');
    });
  });

  // Note: createPetWithFirestore / removePetWithFirestore call Firebase when
  // kEnableFirebase=true. The non-Firebase branches are exercised by addPet /
  // removePet (tested above). These groups verify equivalent local outcomes via
  // seed() and the synchronous path tests.

  group('PetStore createPetWithFirestore (local equivalent via addPet)', () {
    test('addPet simulates non-Firebase createPet — pet appears in ownerPets', () {
      store.seed(ownerPets: [], clinicPets: []);

      final pet = _makePet('NewPet', id: 'np1');
      store.addPet(pet);

      expect(store.ownerPets.any((p) => p.name == 'NewPet'), isTrue);
    });

    test('created pet retains its name', () {
      store.seed(ownerPets: [], clinicPets: []);

      final pet = _makePet('MyNewPet', id: 'mnp1');
      store.addPet(pet);

      expect(store.ownerPets.first.name, 'MyNewPet');
    });
  });

  group('PetStore removePetWithFirestore (local equivalent via removePet)', () {
    test('removePet simulates non-Firebase removePet — pet absent from ownerPets', () {
      store.seed(
        ownerPets: [_makePet('Buddy', id: 'b1')],
        clinicPets: [_makePet('Buddy', id: 'b1')],
      );

      store.removePet('Buddy');

      expect(store.ownerPets, isEmpty);
      expect(store.allClinicPets, isEmpty);
    });

    test('removePetWithFirestore with non-existent name does nothing', () async {
      store.seed(ownerPets: [_makePet('Buddy', id: 'b1')], clinicPets: []);

      // No Firebase is triggered when pet is not found (getPetByName returns null
      // → petId is null → kEnableFirebase block is skipped).
      await store.removePetWithFirestore('NoSuchPet');

      expect(store.ownerPets.length, 1);
    });
  });

  group('PetStore getPetByName', () {
    test('getPetByName searches both ownerPets and clinicPets', () {
      store.seed(
        ownerPets: [_makePet('Owner Pet', id: 'op1')],
        clinicPets: [_makePet('Clinic Pet', id: 'cp1')],
      );

      expect(store.getPetByName('Owner Pet')?.name, 'Owner Pet');
      expect(store.getPetByName('Clinic Pet')?.name, 'Clinic Pet');
    });
  });

  group('PetStore getPetById', () {
    test('getPetById returns null for unknown id', () {
      store.seed(ownerPets: [_makePet('Buddy', id: 'b1')], clinicPets: []);

      expect(store.getPetById('nonexistent'), isNull);
    });

    test('getPetById searches clinicPets as well', () {
      store.seed(
        ownerPets: [],
        clinicPets: [_makePet('Luna', id: 'luna-id')],
      );

      expect(store.getPetById('luna-id')?.name, 'Luna');
    });
  });

  group('PetStore isLoading', () {
    test('isLoading is false after seed', () {
      store.seed(ownerPets: [_makePet('A', id: 'a1')], clinicPets: []);
      expect(store.isLoading, isFalse);
    });
  });

  group('PetStore cancelSubscription', () {
    test('cancelSubscription clears subscribedUid', () {
      store.cancelSubscription();
      expect(store.currentSubscribedUid, isNull);
    });
  });

  group('PetStore removeCareCircleMember (local mock mode)', () {
    test('removeCareCircleMember removes member by name', () {
      const member = CareCircleMember(
        uid: 'uid-alice',
        name: 'Alice',
        avatarUrl: '',
        role: CareCircleRole.member,
      );
      final pet = Pet(
        id: 'pet-rc',
        name: 'Circle Pet',
        breedAndAge: 'Breed',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(bpm: 22, recordedAt: DateTime(2025, 1, 1)),
        careCircle: [member],
      );
      store.seed(ownerPets: [pet], clinicPets: []);

      store.removeCareCircleMember('Circle Pet', 'Alice');

      expect(store.ownerPets.first.careCircle, isEmpty);
    });

    test('removeCareCircleMember with unknown member name does not modify careCircle', () {
      const member = CareCircleMember(
        uid: 'uid-alice',
        name: 'Alice',
        avatarUrl: '',
        role: CareCircleRole.member,
      );
      final pet = Pet(
        id: 'pet-rc2',
        name: 'Circle Pet 2',
        breedAndAge: 'Breed',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(bpm: 22, recordedAt: DateTime(2025, 1, 1)),
        careCircle: [member],
      );
      store.seed(ownerPets: [pet], clinicPets: []);

      store.removeCareCircleMember('Circle Pet 2', 'NonExistentMember');

      expect(store.ownerPets.first.careCircle.length, 1);
    });
  });

  group('PetStore removeCareCircleMemberByUid (local mock mode)', () {
    test('removeCareCircleMemberByUid falls back to local removal when uid is null', () async {
      const member = CareCircleMember(
        uid: 'member-uid',
        name: 'Alice',
        avatarUrl: '',
        role: CareCircleRole.member,
      );
      final pet = Pet(
        id: 'pet-rc3',
        name: 'Circle Pet 3',
        breedAndAge: 'Breed',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(bpm: 22, recordedAt: DateTime(2025, 1, 1)),
        careCircle: [member],
      );
      store.seed(ownerPets: [pet], clinicPets: []);

      // uid=null triggers local removal path even when kEnableFirebase=true.
      await store.removeCareCircleMemberByUid('Circle Pet 3', null, 'Alice');

      expect(store.ownerPets.first.careCircle, isEmpty);
    });
  });
}
