import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/models/user.dart';

void main() {
  group('AppUser immutability', () {
    test('petIds list is unmodifiable', () {
      final user = AppUser(
        uid: 'u1',
        email: 'a@b.com',
        role: AppUserRole.owner,
        petIds: ['p1', 'p2'],
      );
      expect(() => user.petIds.add('p3'), throwsUnsupportedError);
      expect(user.petIds, ['p1', 'p2']);
    });

    test('modifying the source list does not affect the model', () {
      final ids = ['p1', 'p2'];
      final user = AppUser(
        uid: 'u1',
        email: 'a@b.com',
        role: AppUserRole.owner,
        petIds: ids,
      );
      ids.add('p3');
      expect(user.petIds.length, 2);
    });
  });

  group('Pet immutability', () {
    Pet _makePet({
      List<CareCircleMember>? circle,
      List<PendingInvite>? invites,
    }) {
      return Pet(
        id: 'pet1',
        name: 'Buddy',
        breedAndAge: 'Labrador, 3y',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(bpm: 20, recordedAt: DateTime(2025, 1, 1)),
        careCircle: circle ?? [
          CareCircleMember(
            uid: 'u1',
            name: 'Owner',
            role: CareCircleRole.owner,
            avatarUrl: '',
          ),
        ],
        pendingInvites: invites ?? const [],
      );
    }

    test('careCircle list is unmodifiable', () {
      final pet = _makePet();
      expect(
        () => pet.careCircle.add(CareCircleMember(
          uid: 'u2', name: 'New', role: CareCircleRole.member, avatarUrl: '',
        )),
        throwsUnsupportedError,
      );
    });

    test('pendingInvites list is unmodifiable', () {
      final pet = _makePet(invites: [
        PendingInvite(
          token: 't1',
          invitedEmail: 'x@y.com',
          expiresAt: DateTime(2099, 1, 1),
        ),
      ]);
      expect(() => pet.pendingInvites.removeAt(0), throwsUnsupportedError);
    });

    test('modifying the source list does not affect the model', () {
      final circle = [
        CareCircleMember(
          uid: 'u1', name: 'Owner', role: CareCircleRole.owner, avatarUrl: '',
        ),
      ];
      final pet = _makePet(circle: circle);
      circle.add(CareCircleMember(
        uid: 'u2', name: 'Extra', role: CareCircleRole.member, avatarUrl: '',
      ));
      expect(pet.careCircle.length, 1);
    });
  });

  group('User immutability', () {
    test('pets list is unmodifiable', () {
      final pet = Pet(
        name: 'Buddy',
        breedAndAge: 'Lab, 3y',
        imageUrl: '',
        statusLabel: 'Normal',
        statusColorHex: 0xFF75ACFF,
        latestMeasurement: Measurement(bpm: 20, recordedAt: DateTime(2025, 1, 1)),
        careCircle: [],
      );
      final user = User(
        id: 'u1',
        name: 'Test',
        email: 'a@b.com',
        role: UserRole.owner,
        avatarUrl: '',
        pets: [pet],
      );
      expect(() => user.pets.add(pet), throwsUnsupportedError);
    });
  });
}
