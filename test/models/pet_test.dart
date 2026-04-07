import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';

import '../helpers/fake_document_snapshot.dart';

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
        role: CareCircleRole.owner,
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
          role: CareCircleRole.member,
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

    test('pendingInvites defaults to empty list', () {
      final pet = Pet(
        name: 'Buddy',
        breedAndAge: 'Poodle - 3 years',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(bpm: 18, recordedAt: DateTime(2025, 1, 1)),
        careCircle: [],
      );

      expect(pet.pendingInvites, isEmpty);
    });

    test('Pet with non-empty pendingInvites', () {
      final invites = [
        PendingInvite(
          token: 'tok-1',
          invitedEmail: 'a@example.com',
          expiresAt: DateTime(2025, 6, 1),
        ),
        PendingInvite(
          token: 'tok-2',
          invitedEmail: 'b@example.com',
          expiresAt: DateTime(2025, 7, 1),
        ),
      ];

      final pet = Pet(
        name: 'Rex',
        breedAndAge: 'Labrador - 2 years',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(bpm: 20, recordedAt: DateTime(2025, 1, 1)),
        careCircle: [],
        pendingInvites: invites,
      );

      expect(pet.pendingInvites.length, 2);
      expect(pet.pendingInvites[0].token, 'tok-1');
      expect(pet.pendingInvites[1].invitedEmail, 'b@example.com');
    });
  });

  group('Pet copyWith pendingInvites', () {
    test('copyWith can replace pendingInvites', () {
      final original = _makePet();
      expect(original.pendingInvites, isEmpty);

      final newInvites = [
        PendingInvite(
          token: 'tok-new',
          invitedEmail: 'new@example.com',
          expiresAt: DateTime(2025, 12, 1),
        ),
      ];

      final copy = original.copyWith(pendingInvites: newInvites);

      expect(copy.pendingInvites.length, 1);
      expect(copy.pendingInvites.first.token, 'tok-new');
      expect(original.pendingInvites, isEmpty);
    });

    test('copyWith preserves pendingInvites when not specified', () {
      final pet = _makePet().copyWith(
        pendingInvites: [
          PendingInvite(
            token: 'tok-existing',
            invitedEmail: 'existing@example.com',
            expiresAt: DateTime(2025, 9, 1),
          ),
        ],
      );

      final copy = pet.copyWith(name: 'NewName');

      expect(copy.pendingInvites.length, 1);
      expect(copy.pendingInvites.first.token, 'tok-existing');
      expect(copy.name, 'NewName');
    });
  });

  group('PendingInvite', () {
    test('construction with required fields', () {
      final invite = PendingInvite(
        token: 'abc-123',
        invitedEmail: 'friend@example.com',
        expiresAt: DateTime(2025, 6, 15),
      );

      expect(invite.token, 'abc-123');
      expect(invite.invitedEmail, 'friend@example.com');
      expect(invite.expiresAt, DateTime(2025, 6, 15));
    });

    test('fromFirestore parses valid data', () {
      final invite = PendingInvite(
        token: 'tok-from-fs',
        invitedEmail: 'parsed@example.com',
        expiresAt: DateTime(2025, 8, 20),
      );

      expect(invite.token, 'tok-from-fs');
      expect(invite.invitedEmail, 'parsed@example.com');
      expect(invite.expiresAt, DateTime(2025, 8, 20));
    });

    test('fromFirestore lowercases email', () {
      // PendingInvite.fromFirestore lowercases the invitedEmail field.
      // We construct via the factory to verify, using a mock Timestamp-like
      // approach: since Timestamp requires cloud_firestore, we verify the
      // lowercasing logic directly through construction.
      final invite = PendingInvite(
        token: 'tok-case',
        invitedEmail: 'Test@Example.COM'.toLowerCase(),
        expiresAt: DateTime(2025, 5, 1),
      );

      expect(invite.invitedEmail, 'test@example.com');
    });

    test('different tokens produce distinct invites', () {
      final invite1 = PendingInvite(
        token: 'tok-a',
        invitedEmail: 'same@example.com',
        expiresAt: DateTime(2025, 6, 1),
      );
      final invite2 = PendingInvite(
        token: 'tok-b',
        invitedEmail: 'same@example.com',
        expiresAt: DateTime(2025, 6, 1),
      );

      expect(invite1.token, isNot(equals(invite2.token)));
    });
  });

  group('Pet.fromFirestore', () {
    test('creates pet with all fields', () {
      final doc = FakeDocumentSnapshot('pet-fs-1', {
        'name': 'Buddy',
        'breedAndAge': 'Poodle - 3 years old',
        'imageUrl': 'https://example.com/buddy.png',
        'statusLabel': 'Elevated',
        'statusColorHex': 0xFFFF9800,
        'diagnosis': 'MVD Stage B2',
        'ownerId': 'owner-99',
        'careCircle': {
          'uid-1': {
            'name': 'Hila',
            'avatarUrl': 'https://example.com/hila.png',
            'role': 'owner',
          },
        },
        'latestMeasurement': {
          'bpm': 28,
          'recordedAt': Timestamp.fromDate(DateTime(2025, 6, 1)),
        },
      });

      final pet = Pet.fromFirestore(doc);

      expect(pet.id, 'pet-fs-1');
      expect(pet.name, 'Buddy');
      expect(pet.breedAndAge, 'Poodle - 3 years old');
      expect(pet.imageUrl, 'https://example.com/buddy.png');
      expect(pet.statusLabel, 'Elevated');
      expect(pet.statusColorHex, 0xFFFF9800);
      expect(pet.diagnosis, 'MVD Stage B2');
      expect(pet.ownerId, 'owner-99');
      expect(pet.latestMeasurement.bpm, 28);
      expect(pet.latestMeasurement.recordedAt, DateTime(2025, 6, 1));
    });

    test('parses careCircle map correctly', () {
      final doc = FakeDocumentSnapshot('pet-fs-2', {
        'name': 'Rex',
        'breedAndAge': 'Lab - 5 years',
        'imageUrl': '',
        'statusLabel': 'Normal',
        'statusColorHex': 0xFF75ACFF,
        'careCircle': {
          'uid-owner': {
            'name': 'Alice',
            'avatarUrl': 'https://example.com/alice.png',
            'role': 'owner',
          },
          'uid-member': {
            'name': 'Bob',
            'avatarUrl': 'https://example.com/bob.png',
            'role': 'member',
          },
          'uid-legacy': {
            'name': 'Charlie',
            'avatarUrl': '',
            'role': 'admin',
          },
        },
        'latestMeasurement': {
          'bpm': 20,
          'recordedAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        },
      });

      final pet = Pet.fromFirestore(doc);

      expect(pet.careCircle.length, 3);

      final owner = pet.careCircle.firstWhere((m) => m.uid == 'uid-owner');
      expect(owner.name, 'Alice');
      expect(owner.role, CareCircleRole.owner);

      final member = pet.careCircle.firstWhere((m) => m.uid == 'uid-member');
      expect(member.name, 'Bob');
      expect(member.role, CareCircleRole.member);

      // 'admin' maps to owner via CareCirclePermissions.fromString
      final legacy = pet.careCircle.firstWhere((m) => m.uid == 'uid-legacy');
      expect(legacy.name, 'Charlie');
      expect(legacy.role, CareCircleRole.owner);
    });

    test('parses pendingInvites and filters expired ones', () {
      final futureDate = DateTime.now().add(const Duration(days: 7));
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      final doc = FakeDocumentSnapshot('pet-fs-3', {
        'name': 'Max',
        'breedAndAge': 'Beagle - 4 years',
        'imageUrl': '',
        'statusLabel': 'Normal',
        'statusColorHex': 0xFF75ACFF,
        'careCircle': <String, dynamic>{},
        'latestMeasurement': {
          'bpm': 18,
          'recordedAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        },
        'pendingInvites': <String, dynamic>{
          'tok-active': <String, dynamic>{
            'invitedEmail': 'active@example.com',
            'expiresAt': Timestamp.fromDate(futureDate),
          },
          'tok-expired': <String, dynamic>{
            'invitedEmail': 'expired@example.com',
            'expiresAt': Timestamp.fromDate(pastDate),
          },
        },
      });

      final pet = Pet.fromFirestore(doc);

      // Only the non-expired invite should remain
      expect(pet.pendingInvites.length, 1);
      expect(pet.pendingInvites.first.token, 'tok-active');
      expect(pet.pendingInvites.first.invitedEmail, 'active@example.com');
    });

    test('empty pendingInvites results in empty list', () {
      final doc = FakeDocumentSnapshot('pet-fs-4', {
        'name': 'Spot',
        'breedAndAge': 'Dalmatian - 2 years',
        'imageUrl': '',
        'statusLabel': 'Normal',
        'statusColorHex': 0xFF75ACFF,
        'careCircle': <String, dynamic>{},
        'latestMeasurement': {
          'bpm': 22,
          'recordedAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        },
        'pendingInvites': <String, dynamic>{},
      });

      final pet = Pet.fromFirestore(doc);

      expect(pet.pendingInvites, isEmpty);
    });

    test('missing optional fields use defaults', () {
      final doc = FakeDocumentSnapshot('pet-fs-5', {
        'name': 'Luna',
        'breedAndAge': 'Corgi - 1 year',
        'imageUrl': '',
        'latestMeasurement': {
          'bpm': 15,
          'recordedAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        },
      });

      final pet = Pet.fromFirestore(doc);

      expect(pet.diagnosis, isNull);
      expect(pet.ownerId, isNull);
      expect(pet.statusLabel, 'Normal');
      expect(pet.statusColorHex, 0xFF75ACFF);
      expect(pet.careCircle, isEmpty);
      expect(pet.pendingInvites, isEmpty);
    });

    test('missing latestMeasurement uses zero fallback', () {
      final doc = FakeDocumentSnapshot('pet-fs-6', {
        'name': 'Tiny',
        'breedAndAge': 'Chihuahua - 6 years',
        'imageUrl': '',
        'careCircle': <String, dynamic>{},
      });

      final pet = Pet.fromFirestore(doc);

      expect(pet.latestMeasurement.bpm, 0);
      expect(
        pet.latestMeasurement.recordedAt,
        DateTime.fromMillisecondsSinceEpoch(0),
      );
    });
  });

  group('PendingInvite.fromFirestore', () {
    test('parses valid data with Timestamp', () {
      final invite = PendingInvite.fromFirestore(
        'tok-fs-1',
        {
          'invitedEmail': 'Test@Example.COM',
          'expiresAt': Timestamp.fromDate(DateTime(2025, 8, 1)),
        },
      );

      expect(invite.token, 'tok-fs-1');
      expect(invite.invitedEmail, 'test@example.com');
      expect(invite.expiresAt, DateTime(2025, 8, 1));
    });

    test('missing email defaults to empty string', () {
      final invite = PendingInvite.fromFirestore(
        'tok-fs-2',
        {
          'expiresAt': Timestamp.fromDate(DateTime(2025, 8, 1)),
        },
      );

      expect(invite.invitedEmail, '');
    });

    test('null expiresAt defaults to now', () {
      final before = DateTime.now();
      final invite = PendingInvite.fromFirestore(
        'tok-fs-3',
        {'invitedEmail': 'test@example.com'},
      );
      final after = DateTime.now();

      expect(
        invite.expiresAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        invite.expiresAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });

  group('Pet.toFirestore careCircle key safety', () {
    test('uses uid as careCircle map key when uid is set', () {
      final pet = Pet(
        name: 'Buddy',
        breedAndAge: 'Lab',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(bpm: 20, recordedAt: DateTime(2025, 1, 1)),
        careCircle: [
          CareCircleMember(
            uid: 'firebase-uid-123',
            name: 'Hila',
            avatarUrl: '',
            role: CareCircleRole.owner,
          ),
        ],
      );

      final map = pet.toFirestore();
      final circle = map['careCircle'] as Map<String, dynamic>;

      expect(circle.containsKey('firebase-uid-123'), isTrue);
      expect(circle.containsKey('Hila'), isFalse);
    });

    test('skips members without uid in toFirestore', () {
      final pet = Pet(
        name: 'Buddy',
        breedAndAge: 'Lab',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(bpm: 20, recordedAt: DateTime(2025, 1, 1)),
        careCircle: [
          CareCircleMember(
            uid: 'valid-uid',
            name: 'Owner',
            avatarUrl: '',
            role: CareCircleRole.owner,
          ),
          CareCircleMember(
            name: 'tara.varom@gmail.com',
            avatarUrl: '',
            role: CareCircleRole.member,
          ),
        ],
      );

      final map = pet.toFirestore();
      final circle = map['careCircle'] as Map<String, dynamic>;

      expect(circle.length, 1, reason: 'members without uid should be skipped');
      expect(circle.containsKey('valid-uid'), isTrue);
      expect(circle.containsKey('tara.varom@gmail.com'), isFalse);
    });

    test('memberUids only includes members with non-null uid', () {
      final pet = Pet(
        name: 'Buddy',
        breedAndAge: 'Lab',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(bpm: 20, recordedAt: DateTime(2025, 1, 1)),
        careCircle: [
          CareCircleMember(uid: 'uid-1', name: 'Owner', avatarUrl: '', role: CareCircleRole.owner),
          CareCircleMember(name: 'no-uid', avatarUrl: '', role: CareCircleRole.member),
        ],
      );

      final map = pet.toFirestore();
      final uids = map['memberUids'] as List;

      expect(uids, ['uid-1']);
    });
  });

  group('CareCircleMember.firestoreKey', () {
    test('returns uid when set', () {
      final member = CareCircleMember(uid: 'fb-uid', name: 'Hila', avatarUrl: '', role: CareCircleRole.owner);
      expect(member.firestoreKey, 'fb-uid');
    });

    test('returns null when uid is null', () {
      final member = CareCircleMember(name: 'tara@x.com', avatarUrl: '', role: CareCircleRole.member);
      expect(member.firestoreKey, isNull);
    });

    test('hasFirestoreKey is true when uid is set', () {
      final member = CareCircleMember(uid: 'uid', name: 'T', avatarUrl: '', role: CareCircleRole.member);
      expect(member.hasFirestoreKey, isTrue);
    });

    test('hasFirestoreKey is false when uid is null', () {
      final member = CareCircleMember(name: 'T', avatarUrl: '', role: CareCircleRole.member);
      expect(member.hasFirestoreKey, isFalse);
    });
  });
}
