import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/care_circle_member.dart';

void main() {
  group('CareCircleMember construction', () {
    test('creates with all required fields', () {
      final member = CareCircleMember(
        uid: 'u-1',
        name: 'Hila',
        avatarUrl: 'https://example.com/hila.png',
        role: CareCircleRole.owner,
      );

      expect(member.uid, 'u-1');
      expect(member.name, 'Hila');
      expect(member.avatarUrl, 'https://example.com/hila.png');
      expect(member.role, CareCircleRole.owner);
    });

    test('uid defaults to null', () {
      final member = CareCircleMember(
        name: 'Guest',
        avatarUrl: '',
        role: CareCircleRole.member,
      );

      expect(member.uid, isNull);
    });

    test('can create with empty strings', () {
      final member = CareCircleMember(
        name: '',
        avatarUrl: '',
        role: CareCircleRole.member,
      );

      expect(member.name, '');
      expect(member.avatarUrl, '');
    });
  });

  group('CareCircleMember roleLabel', () {
    test('owner role returns Owner', () {
      final member = CareCircleMember(
        name: 'Owner User',
        avatarUrl: '',
        role: CareCircleRole.owner,
      );

      expect(member.roleLabel, 'Owner');
    });

    test('member role returns Member', () {
      final member = CareCircleMember(
        name: 'Member User',
        avatarUrl: '',
        role: CareCircleRole.member,
      );

      expect(member.roleLabel, 'Member');
    });
  });

  group('CareCircleRole permissions', () {
    test('owner can measure', () {
      expect(CareCircleRole.owner.canMeasure, isTrue);
    });

    test('member can measure', () {
      expect(CareCircleRole.member.canMeasure, isTrue);
    });

    test('only owner can edit pet', () {
      expect(CareCircleRole.owner.canEditPet, isTrue);
      expect(CareCircleRole.member.canEditPet, isFalse);
    });

    test('only owner can manage circle', () {
      expect(CareCircleRole.owner.canManageCircle, isTrue);
      expect(CareCircleRole.member.canManageCircle, isFalse);
    });

    test('all roles can add notes', () {
      expect(CareCircleRole.owner.canAddNotes, isTrue);
      expect(CareCircleRole.member.canAddNotes, isTrue);
    });

    test('only owner can delete pet', () {
      expect(CareCircleRole.owner.canDeletePet, isTrue);
      expect(CareCircleRole.member.canDeletePet, isFalse);
    });
  });

  group('CareCirclePermissions fromString', () {
    test('parses owner', () {
      expect(CareCirclePermissions.fromString('owner'), CareCircleRole.owner);
    });

    test('parses member', () {
      expect(CareCirclePermissions.fromString('member'), CareCircleRole.member);
    });

    test('legacy admin maps to owner', () {
      expect(CareCirclePermissions.fromString('admin'), CareCircleRole.owner);
    });

    test('legacy viewer maps to member', () {
      expect(CareCirclePermissions.fromString('viewer'), CareCircleRole.member);
    });

    test('unknown string defaults to member', () {
      expect(CareCirclePermissions.fromString('unknown'), CareCircleRole.member);
    });

    test('empty string defaults to member', () {
      expect(CareCirclePermissions.fromString(''), CareCircleRole.member);
    });
  });

  group('CareCircleMember toFirestore', () {
    test('toFirestore includes role, name, and avatarUrl', () {
      final member = CareCircleMember(
        uid: 'u-1',
        name: 'Hila',
        avatarUrl: 'https://example.com/hila.png',
        role: CareCircleRole.owner,
      );

      final map = member.toFirestore();

      expect(map['role'], 'owner');
      expect(map['name'], 'Hila');
      expect(map['avatarUrl'], 'https://example.com/hila.png');
    });

    test('toFirestore does not include uid', () {
      final member = CareCircleMember(
        uid: 'u-1',
        name: 'Test',
        avatarUrl: '',
        role: CareCircleRole.member,
      );

      final map = member.toFirestore();

      expect(map.containsKey('uid'), isFalse);
    });
  });
}
