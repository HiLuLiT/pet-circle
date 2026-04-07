import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/invitation.dart';

import '../helpers/fake_document_snapshot.dart';

Invitation _makeInvitation({
  InvitationStatus status = InvitationStatus.pending,
  DateTime? expiresAt,
}) {
  return Invitation(
    id: 'inv-1',
    petId: 'p-1',
    petName: 'Princess',
    invitedEmail: 'friend@example.com',
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
        invitedByUid: 'u-1',
        invitedByName: 'Owner',
        createdAt: DateTime(2025, 1, 1),
        expiresAt: DateTime(2025, 2, 1),
      );

      expect(invitation.status, InvitationStatus.pending);
    });

    test('all InvitationStatus values are distinct', () {
      final statuses = InvitationStatus.values;
      expect(statuses.length, 4);
      expect(statuses.toSet().length, 4);
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
      expect(map.containsKey('createdAt'), isTrue);
      expect(map.containsKey('expiresAt'), isTrue);
    });

    test('toFirestore lowercases email', () {
      final invitation = Invitation(
        id: 'inv-case',
        petId: 'p-1',
        petName: 'Pet',
        invitedEmail: 'Test@Example.COM',
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

    test('toFirestore always writes role as member', () {
      final invitation = _makeInvitation();
      final map = invitation.toFirestore();

      expect(map['role'], 'member');
    });

    test('toFirestore role is hardcoded member regardless of construction', () {
      final accepted = _makeInvitation(status: InvitationStatus.accepted);
      final cancelled = _makeInvitation(status: InvitationStatus.cancelled);

      expect(accepted.toFirestore()['role'], 'member');
      expect(cancelled.toFirestore()['role'], 'member');
    });

    test('toFirestore does not include type field', () {
      final invitation = _makeInvitation();
      final map = invitation.toFirestore();

      expect(map.containsKey('type'), isFalse);
    });
  });

  group('Invitation construction (simplified model)', () {
    test('creates with all required fields and no optional role/type', () {
      final invitation = Invitation(
        id: 'inv-simple',
        petId: 'p-2',
        petName: 'Buddy',
        invitedEmail: 'new@example.com',
        invitedByUid: 'u-2',
        invitedByName: 'Owner',
        createdAt: DateTime(2025, 4, 1),
        expiresAt: DateTime(2025, 4, 8),
      );

      expect(invitation.id, 'inv-simple');
      expect(invitation.petId, 'p-2');
      expect(invitation.petName, 'Buddy');
      expect(invitation.invitedEmail, 'new@example.com');
      expect(invitation.invitedByUid, 'u-2');
      expect(invitation.invitedByName, 'Owner');
      expect(invitation.status, InvitationStatus.pending);
    });
  });

  group('Invitation _parseStatus edge cases', () {
    // _parseStatus is exercised indirectly through construction with
    // explicit status values, since it is a private static method.

    test('null status defaults to pending via constructor default', () {
      // When no status is provided, the constructor default is pending.
      final invitation = Invitation(
        id: 'inv-null',
        petId: 'p-1',
        petName: 'Pet',
        invitedEmail: 'a@b.com',
        invitedByUid: 'u-1',
        invitedByName: 'Owner',
        createdAt: DateTime(2025, 1, 1),
        expiresAt: DateTime(2025, 2, 1),
      );

      expect(invitation.status, InvitationStatus.pending);
    });

    test('expired status is correctly represented', () {
      final invitation = _makeInvitation(status: InvitationStatus.expired);

      expect(invitation.status, InvitationStatus.expired);
      expect(invitation.status.name, 'expired');
    });

    test('all status names round-trip through .name', () {
      expect(InvitationStatus.pending.name, 'pending');
      expect(InvitationStatus.accepted.name, 'accepted');
      expect(InvitationStatus.expired.name, 'expired');
      expect(InvitationStatus.cancelled.name, 'cancelled');
    });

    test('toFirestore serializes expired status correctly', () {
      final invitation = _makeInvitation(status: InvitationStatus.expired);
      final map = invitation.toFirestore();

      expect(map['status'], 'expired');
    });

    test('toFirestore serializes cancelled status correctly', () {
      final invitation = _makeInvitation(status: InvitationStatus.cancelled);
      final map = invitation.toFirestore();

      expect(map['status'], 'cancelled');
    });
  });

  group('Invitation.fromFirestore', () {
    test('parses all fields correctly', () {
      final doc = FakeDocumentSnapshot('inv-fs-1', {
        'petId': 'p-100',
        'petName': 'Buddy',
        'invitedEmail': 'alice@example.com',
        'invitedByUid': 'u-50',
        'invitedByName': 'Owner Bob',
        'createdAt': Timestamp.fromDate(DateTime(2025, 6, 1)),
        'expiresAt': Timestamp.fromDate(DateTime(2025, 6, 8)),
        'status': 'pending',
      });

      final invitation = Invitation.fromFirestore(doc);

      expect(invitation.id, 'inv-fs-1');
      expect(invitation.petId, 'p-100');
      expect(invitation.petName, 'Buddy');
      expect(invitation.invitedEmail, 'alice@example.com');
      expect(invitation.invitedByUid, 'u-50');
      expect(invitation.invitedByName, 'Owner Bob');
      expect(invitation.createdAt, DateTime(2025, 6, 1));
      expect(invitation.expiresAt, DateTime(2025, 6, 8));
      expect(invitation.status, InvitationStatus.pending);
    });

    test('missing fields use defaults', () {
      final doc = FakeDocumentSnapshot('inv-fs-2', {
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'expiresAt': Timestamp.fromDate(DateTime(2025, 2, 1)),
      });

      final invitation = Invitation.fromFirestore(doc);

      expect(invitation.id, 'inv-fs-2');
      expect(invitation.petId, '');
      expect(invitation.petName, '');
      expect(invitation.invitedEmail, '');
      expect(invitation.invitedByUid, '');
      expect(invitation.invitedByName, '');
      expect(invitation.status, InvitationStatus.pending);
    });

    test('status "accepted" parses correctly', () {
      final doc = FakeDocumentSnapshot('inv-fs-3', {
        'petId': 'p-1',
        'petName': 'Rex',
        'invitedEmail': 'test@example.com',
        'invitedByUid': 'u-1',
        'invitedByName': 'Owner',
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
        'expiresAt': Timestamp.fromDate(DateTime(2025, 3, 8)),
        'status': 'accepted',
      });

      final invitation = Invitation.fromFirestore(doc);

      expect(invitation.status, InvitationStatus.accepted);
    });

    test('status "expired" parses correctly', () {
      final doc = FakeDocumentSnapshot('inv-fs-4', {
        'petId': 'p-1',
        'petName': 'Rex',
        'invitedEmail': 'test@example.com',
        'invitedByUid': 'u-1',
        'invitedByName': 'Owner',
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
        'expiresAt': Timestamp.fromDate(DateTime(2025, 3, 8)),
        'status': 'expired',
      });

      final invitation = Invitation.fromFirestore(doc);

      expect(invitation.status, InvitationStatus.expired);
    });

    test('unknown status defaults to pending', () {
      final doc = FakeDocumentSnapshot('inv-fs-5', {
        'petId': 'p-1',
        'petName': 'Rex',
        'invitedEmail': 'test@example.com',
        'invitedByUid': 'u-1',
        'invitedByName': 'Owner',
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
        'expiresAt': Timestamp.fromDate(DateTime(2025, 3, 8)),
        'status': 'some_unknown_status',
      });

      final invitation = Invitation.fromFirestore(doc);

      expect(invitation.status, InvitationStatus.pending);
    });

    test('null status defaults to pending', () {
      final doc = FakeDocumentSnapshot('inv-fs-6', {
        'petId': 'p-1',
        'petName': 'Rex',
        'invitedEmail': 'test@example.com',
        'invitedByUid': 'u-1',
        'invitedByName': 'Owner',
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
        'expiresAt': Timestamp.fromDate(DateTime(2025, 3, 8)),
      });

      final invitation = Invitation.fromFirestore(doc);

      expect(invitation.status, InvitationStatus.pending);
    });
  });
}
