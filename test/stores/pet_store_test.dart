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
  });
}
