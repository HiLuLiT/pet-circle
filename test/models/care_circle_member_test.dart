import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/care_circle_member.dart';

void main() {
  group('CareCircleMember construction', () {
    test('creates with all required fields', () {
      final member = CareCircleMember(
        uid: 'u-1',
        name: 'Hila',
        avatarUrl: 'https://example.com/hila.png',
        role: CareCircleRole.admin,
      );

      expect(member.uid, 'u-1');
      expect(member.name, 'Hila');
      expect(member.avatarUrl, 'https://example.com/hila.png');
      expect(member.role, CareCircleRole.admin);
    });

    test('uid defaults to null', () {
      final member = CareCircleMember(
        name: 'Guest',
        avatarUrl: '',
        role: CareCircleRole.viewer,
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
    test('admin role returns Admin', () {
      final member = CareCircleMember(
        name: 'Admin User',
        avatarUrl: '',
        role: CareCircleRole.admin,
      );

      expect(member.roleLabel, 'Admin');
    });

    test('member role returns Member', () {
      final member = CareCircleMember(
        name: 'Member User',
        avatarUrl: '',
        role: CareCircleRole.member,
      );

      expect(member.roleLabel, 'Member');
    });

    test('viewer role returns Viewer', () {
      final member = CareCircleMember(
        name: 'Viewer User',
        avatarUrl: '',
        role: CareCircleRole.viewer,
      );

      expect(member.roleLabel, 'Viewer');
    });
  });

  group('CareCircleRole permissions', () {
    test('admin can measure', () {
      expect(CareCircleRole.admin.canMeasure, isTrue);
    });

    test('member can measure', () {
      expect(CareCircleRole.member.canMeasure, isTrue);
    });

    test('viewer cannot measure', () {
      expect(CareCircleRole.viewer.canMeasure, isFalse);
    });

    test('only admin can edit pet', () {
      expect(CareCircleRole.admin.canEditPet, isTrue);
      expect(CareCircleRole.member.canEditPet, isFalse);
      expect(CareCircleRole.viewer.canEditPet, isFalse);
    });

    test('only admin can manage circle', () {
      expect(CareCircleRole.admin.canManageCircle, isTrue);
      expect(CareCircleRole.member.canManageCircle, isFalse);
      expect(CareCircleRole.viewer.canManageCircle, isFalse);
    });

    test('all roles can add notes', () {
      expect(CareCircleRole.admin.canAddNotes, isTrue);
      expect(CareCircleRole.member.canAddNotes, isTrue);
      expect(CareCircleRole.viewer.canAddNotes, isTrue);
    });

    test('only admin can delete pet', () {
      expect(CareCircleRole.admin.canDeletePet, isTrue);
      expect(CareCircleRole.member.canDeletePet, isFalse);
      expect(CareCircleRole.viewer.canDeletePet, isFalse);
    });
  });

  group('CareCirclePermissions fromString', () {
    test('parses admin', () {
      expect(CareCirclePermissions.fromString('admin'), CareCircleRole.admin);
    });

    test('parses member', () {
      expect(CareCirclePermissions.fromString('member'), CareCircleRole.member);
    });

    test('parses viewer', () {
      expect(CareCirclePermissions.fromString('viewer'), CareCircleRole.viewer);
    });

    test('unknown string defaults to viewer', () {
      expect(CareCirclePermissions.fromString('unknown'), CareCircleRole.viewer);
    });

    test('empty string defaults to viewer', () {
      expect(CareCirclePermissions.fromString(''), CareCircleRole.viewer);
    });
  });

  group('CareCircleMember toFirestore', () {
    test('toFirestore includes role, name, and avatarUrl', () {
      final member = CareCircleMember(
        uid: 'u-1',
        name: 'Hila',
        avatarUrl: 'https://example.com/hila.png',
        role: CareCircleRole.admin,
      );

      final map = member.toFirestore();

      expect(map['role'], 'admin');
      expect(map['name'], 'Hila');
      expect(map['avatarUrl'], 'https://example.com/hila.png');
    });

    test('toFirestore does not include uid', () {
      final member = CareCircleMember(
        uid: 'u-1',
        name: 'Test',
        avatarUrl: '',
        role: CareCircleRole.viewer,
      );

      final map = member.toFirestore();

      expect(map.containsKey('uid'), isFalse);
    });
  });
}
