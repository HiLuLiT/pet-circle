import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/invitation.dart';

Invitation _makeInvitation({
  InvitationStatus status = InvitationStatus.pending,
  DateTime? expiresAt,
}) {
  return Invitation(
    id: 'inv-1',
    petId: 'p-1',
    petName: 'Princess',
    invitedEmail: 'friend@example.com',
    role: CareCircleRole.member,
    invitedByUid: 'u-1',
    invitedByName: 'Hila',
    createdAt: DateTime(2025, 3, 1),
    expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 7)),
    status: status,
  );
}

void main() {
  group('Invitation construction', () {
    test('creates with all required fields', () {
      final invitation = _makeInvitation();

      expect(invitation.id, 'inv-1');
      expect(invitation.petId, 'p-1');
      expect(invitation.petName, 'Princess');
      expect(invitation.invitedEmail, 'friend@example.com');
      expect(invitation.role, CareCircleRole.member);
      expect(invitation.invitedByUid, 'u-1');
      expect(invitation.invitedByName, 'Hila');
      expect(invitation.createdAt, DateTime(2025, 3, 1));
    });

    test('status defaults to pending', () {
      final invitation = Invitation(
        id: 'inv-2',
        petId: 'p-1',
        petName: 'Buddy',
        invitedEmail: 'test@example.com',
        role: CareCircleRole.viewer,
        invitedByUid: 'u-1',
        invitedByName: 'Owner',
        createdAt: DateTime(2025, 1, 1),
        expiresAt: DateTime(2025, 2, 1),
      );

      expect(invitation.status, InvitationStatus.pending);
    });

    test('type defaults to careCircle', () {
      final invitation = _makeInvitation();
      expect(invitation.type, InvitationType.careCircle);
    });

    test('all InvitationStatus values are distinct', () {
      final statuses = InvitationStatus.values;
      expect(statuses.length, 4);
      expect(statuses.toSet().length, 4);
    });

    test('all InvitationType values are distinct', () {
      final types = InvitationType.values;
      expect(types.length, 2);
      expect(types.toSet().length, 2);
    });
  });

  group('Invitation computed properties', () {
    test('isExpired returns false for future expiresAt', () {
      final invitation = _makeInvitation(
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      expect(invitation.isExpired, isFalse);
    });

    test('isExpired returns true for past expiresAt', () {
      final invitation = _makeInvitation(
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(invitation.isExpired, isTrue);
    });

    test('isPending returns true when status is pending and not expired', () {
      final invitation = _makeInvitation(
        status: InvitationStatus.pending,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      expect(invitation.isPending, isTrue);
    });

    test('isPending returns false when status is accepted', () {
      final invitation = _makeInvitation(
        status: InvitationStatus.accepted,
      );

      expect(invitation.isPending, isFalse);
    });

    test('isPending returns false when pending but expired', () {
      final invitation = _makeInvitation(
        status: InvitationStatus.pending,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(invitation.isPending, isFalse);
    });

    test('isPending returns false when cancelled', () {
      final invitation = _makeInvitation(
        status: InvitationStatus.cancelled,
      );

      expect(invitation.isPending, isFalse);
    });
  });

  group('Invitation toFirestore', () {
    test('toFirestore includes all fields', () {
      final invitation = _makeInvitation();
      final map = invitation.toFirestore();

      expect(map['petId'], 'p-1');
      expect(map['petName'], 'Princess');
      expect(map['invitedEmail'], 'friend@example.com');
      expect(map['role'], 'member');
      expect(map['invitedByUid'], 'u-1');
      expect(map['invitedByName'], 'Hila');
      expect(map['status'], 'pending');
      expect(map['type'], 'careCircle');
      expect(map.containsKey('createdAt'), isTrue);
      expect(map.containsKey('expiresAt'), isTrue);
    });

    test('toFirestore lowercases email', () {
      final invitation = Invitation(
        id: 'inv-case',
        petId: 'p-1',
        petName: 'Pet',
        invitedEmail: 'Test@Example.COM',
        role: CareCircleRole.viewer,
        invitedByUid: 'u-1',
        invitedByName: 'Owner',
        createdAt: DateTime(2025, 1, 1),
        expiresAt: DateTime(2025, 2, 1),
      );

      final map = invitation.toFirestore();
      expect(map['invitedEmail'], 'test@example.com');
    });

    test('toFirestore does not include id', () {
      final invitation = _makeInvitation();
      final map = invitation.toFirestore();

      expect(map.containsKey('id'), isFalse);
    });

    test('toFirestore serializes vet type correctly', () {
      final invitation = Invitation(
        id: 'inv-vet',
        petId: 'p-1',
        petName: 'Pet',
        invitedEmail: 'vet@example.com',
        role: CareCircleRole.admin,
        invitedByUid: 'u-1',
        invitedByName: 'Owner',
        createdAt: DateTime(2025, 1, 1),
        expiresAt: DateTime(2025, 2, 1),
        type: InvitationType.vet,
      );

      expect(invitation.toFirestore()['type'], 'vet');
    });
  });
}
