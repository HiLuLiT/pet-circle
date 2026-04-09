import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/models/pet_access.dart';
import 'package:pet_circle/models/user.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';

/// Build a minimal pet for access-control testing.
Pet _makePet({
  String name = 'TestPet',
  String? id,
  String? ownerId,
  List<CareCircleMember> careCircle = const [],
}) {
  return Pet(
    id: id ?? 'pet-1',
    name: name,
    breedAndAge: 'Breed - 3 years',
    imageUrl: 'https://example.com/$name.png',
    statusLabel: 'Normal',
    statusColorHex: 0xFF75ACFF,
    latestMeasurement: Measurement(
      bpm: 22,
      recordedAt: DateTime(2025, 1, 1),
    ),
    careCircle: careCircle,
    ownerId: ownerId,
  );
}

void main() {
  setUp(() {
    // Seed userStore with a known owner user for each test.
    userStore.seed(User(
      id: 'uid-owner',
      name: 'Hila',
      email: 'hila@example.com',
      role: UserRole.owner,
      avatarUrl: 'https://example.com/avatar.png',
    ));
  });

  tearDown(() {
    petStore.seed(ownerPets: [], clinicPets: []);
  });

  group('accessForPet — owner via ownerId', () {
    test('returns owner role when user is the pet ownerId', () {
      final pet = _makePet(ownerId: 'uid-owner');

      final access = petStore.accessForPet(pet);

      expect(access.role, CareCircleRole.owner);
      expect(access.source, PetAccessSource.ownerId);
    });

    test('owner access has isOwner = true', () {
      final pet = _makePet(ownerId: 'uid-owner');

      final access = petStore.accessForPet(pet);

      expect(access.isOwner, isTrue);
    });

    test('owner access has canManageCircle = true', () {
      final pet = _makePet(ownerId: 'uid-owner');

      final access = petStore.accessForPet(pet);

      expect(access.canManageCircle, isTrue);
    });
  });

  group('accessForPet — care circle UID match', () {
    test('returns member role from careCircle when matched by UID', () {
      final pet = _makePet(
        ownerId: 'someone-else',
        careCircle: [
          const CareCircleMember(
            uid: 'uid-owner',
            name: 'Hila',
            avatarUrl: 'https://example.com/avatar.png',
            role: CareCircleRole.member,
          ),
        ],
      );

      final access = petStore.accessForPet(pet);

      expect(access.role, CareCircleRole.member);
      expect(access.source, PetAccessSource.careCircleUid);
    });

    test('non-owner UID match has isOwner = false', () {
      final pet = _makePet(
        ownerId: 'someone-else',
        careCircle: [
          const CareCircleMember(
            uid: 'uid-owner',
            name: 'Hila',
            avatarUrl: 'https://example.com/avatar.png',
            role: CareCircleRole.member,
          ),
        ],
      );

      final access = petStore.accessForPet(pet);

      expect(access.isOwner, isFalse);
    });

    test('non-owner member access has canManageCircle = false', () {
      final pet = _makePet(
        ownerId: 'someone-else',
        careCircle: [
          const CareCircleMember(
            uid: 'uid-owner',
            name: 'Hila',
            avatarUrl: 'https://example.com/avatar.png',
            role: CareCircleRole.member,
          ),
        ],
      );

      final access = petStore.accessForPet(pet);

      expect(access.canManageCircle, isFalse);
    });
  });

  group('accessForPet — email fallback', () {
    test('returns member role via email fallback when UID not in circle', () {
      final pet = _makePet(
        ownerId: 'someone-else',
        careCircle: [
          const CareCircleMember(
            uid: 'different-uid',
            name: 'hila@example.com',
            avatarUrl: 'https://example.com/avatar.png',
            role: CareCircleRole.member,
          ),
        ],
      );

      final access = petStore.accessForPet(pet);

      expect(access.role, CareCircleRole.member);
      expect(access.source, PetAccessSource.careCircleEmailFallback);
    });
  });

  group('accessForPet — unknown user', () {
    test('returns member role with unknown source for unrecognised user', () {
      final pet = _makePet(
        ownerId: 'someone-else',
        careCircle: [
          const CareCircleMember(
            uid: 'other-uid',
            name: 'Other Person',
            avatarUrl: 'https://example.com/other.png',
            role: CareCircleRole.owner,
          ),
        ],
      );

      final access = petStore.accessForPet(pet);

      expect(access.role, CareCircleRole.member);
      expect(access.source, PetAccessSource.unknown);
    });

    test('returns unknown access when pet is null', () {
      final access = petStore.accessForPet(null);

      expect(access.role, CareCircleRole.member);
      expect(access.source, PetAccessSource.unknown);
      expect(access.hasPet, isFalse);
    });
  });

  group('accessForActivePet', () {
    test('delegates to accessForPet with the active pet', () {
      final pet = _makePet(ownerId: 'uid-owner');
      petStore.seed(ownerPets: [pet], clinicPets: []);

      final access = petStore.accessForActivePet();

      expect(access.role, CareCircleRole.owner);
      expect(access.source, PetAccessSource.ownerId);
      expect(access.isOwner, isTrue);
    });

    test('returns unknown when no active pet exists', () {
      petStore.seed(ownerPets: [], clinicPets: []);

      final access = petStore.accessForActivePet();

      expect(access.source, PetAccessSource.unknown);
      expect(access.hasPet, isFalse);
    });
  });

  group('accessForPetId', () {
    test('returns unknown access when petId is null', () {
      final access = petStore.accessForPetId(null);

      expect(access.role, CareCircleRole.member);
      expect(access.source, PetAccessSource.unknown);
      expect(access.hasPet, isFalse);
    });

    test('returns unknown access when petId not found in store', () {
      petStore.seed(ownerPets: [], clinicPets: []);

      final access = petStore.accessForPetId('nonexistent-id');

      expect(access.role, CareCircleRole.member);
      expect(access.source, PetAccessSource.unknown);
      expect(access.hasPet, isFalse);
    });

    test('returns correct access when petId is found', () {
      final pet = _makePet(id: 'pet-lookup', ownerId: 'uid-owner');
      petStore.seed(ownerPets: [pet], clinicPets: []);

      final access = petStore.accessForPetId('pet-lookup');

      expect(access.role, CareCircleRole.owner);
      expect(access.source, PetAccessSource.ownerId);
      expect(access.hasPet, isTrue);
    });
  });

  group('accessForPet — multiple members in careCircle', () {
    test('correct member is found by UID among multiple', () {
      final pet = _makePet(
        ownerId: 'someone-else',
        careCircle: [
          const CareCircleMember(
            uid: 'other-1',
            name: 'Alice',
            avatarUrl: '',
            role: CareCircleRole.owner,
          ),
          const CareCircleMember(
            uid: 'uid-owner',
            name: 'Hila',
            avatarUrl: '',
            role: CareCircleRole.member,
          ),
          const CareCircleMember(
            uid: 'other-2',
            name: 'Bob',
            avatarUrl: '',
            role: CareCircleRole.member,
          ),
        ],
      );

      final access = petStore.accessForPet(pet);

      expect(access.role, CareCircleRole.member);
      expect(access.source, PetAccessSource.careCircleUid);
    });

    test('UID match takes priority over email match', () {
      // Both UID and email match exist — UID should win
      final pet = _makePet(
        ownerId: 'someone-else',
        careCircle: [
          const CareCircleMember(
            uid: 'uid-owner',
            name: 'Hila (UID)',
            avatarUrl: '',
            role: CareCircleRole.owner,
          ),
          const CareCircleMember(
            uid: 'different-uid',
            name: 'hila@example.com',
            avatarUrl: '',
            role: CareCircleRole.member,
          ),
        ],
      );

      final access = petStore.accessForPet(pet);

      // Should match by UID (owner role), not email (member role)
      expect(access.role, CareCircleRole.owner);
      expect(access.source, PetAccessSource.careCircleUid);
    });
  });

  group('accessForPet — display name fallback', () {
    test('matches by display name when UID and email do not match', () {
      final pet = _makePet(
        ownerId: 'someone-else',
        careCircle: [
          const CareCircleMember(
            uid: 'different-uid',
            name: 'Hila',
            avatarUrl: '',
            role: CareCircleRole.owner,
          ),
        ],
      );

      final access = petStore.accessForPet(pet);

      expect(access.role, CareCircleRole.owner);
      expect(access.source, PetAccessSource.legacyNameFallback);
    });
  });

  group('currentUserRoleFor', () {
    test('returns owner role for pet the user owns', () {
      final pet = _makePet(name: 'Buddy', ownerId: 'uid-owner');
      petStore.seed(ownerPets: [pet], clinicPets: []);

      final role = petStore.currentUserRoleFor('Buddy');

      expect(role, CareCircleRole.owner);
    });

    test('returns member role for pet user is member of', () {
      final pet = _makePet(
        name: 'Rex',
        ownerId: 'someone-else',
        careCircle: [
          const CareCircleMember(
            uid: 'uid-owner',
            name: 'Hila',
            avatarUrl: '',
            role: CareCircleRole.member,
          ),
        ],
      );
      petStore.seed(ownerPets: [pet], clinicPets: []);

      final role = petStore.currentUserRoleFor('Rex');

      expect(role, CareCircleRole.member);
    });

    test('returns null for unknown pet name', () {
      petStore.seed(ownerPets: [], clinicPets: []);

      final role = petStore.currentUserRoleFor('NonexistentPet');

      expect(role, isNull);
    });
  });
}
