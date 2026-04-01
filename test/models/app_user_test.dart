import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/user_settings.dart';

void main() {
  group('AppUser copyWith', () {
    test('copyWith creates a new instance', () {
      final original = AppUser(
        uid: 'u-1',
        email: 'test@example.com',
        role: AppUserRole.owner,
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.png',
        petIds: ['p-1', 'p-2'],
      );

      final copy = original.copyWith(displayName: 'New Name');

      expect(identical(original, copy), isFalse);
      expect(copy.displayName, 'New Name');
      expect(original.displayName, 'Test User');
    });

    test('copyWith preserves all fields when no args given', () {
      final original = AppUser(
        uid: 'u-1',
        email: 'test@example.com',
        role: AppUserRole.vet,
        displayName: 'Dr. Test',
        photoUrl: 'https://example.com/photo.png',
        createdAt: DateTime(2025, 1, 1),
        petIds: ['p-1'],
        settings: UserSettings(elevatedThreshold: 25),
      );

      final copy = original.copyWith();

      expect(copy.uid, original.uid);
      expect(copy.email, original.email);
      expect(copy.role, original.role);
      expect(copy.displayName, original.displayName);
      expect(copy.photoUrl, original.photoUrl);
      expect(copy.createdAt, original.createdAt);
      expect(copy.petIds, original.petIds);
      expect(copy.settings.elevatedThreshold, original.settings.elevatedThreshold);
    });

    test('original is unchanged after copyWith', () {
      final original = AppUser(
        uid: 'u-1',
        email: 'test@example.com',
        role: AppUserRole.owner,
      );

      original.copyWith(
        email: 'new@example.com',
        role: AppUserRole.vet,
      );

      expect(original.email, 'test@example.com');
      expect(original.role, AppUserRole.owner);
    });
  });

  group('AppUserRole', () {
    test('AppUserRole.vet and .owner are distinct', () {
      expect(AppUserRole.vet, isNot(AppUserRole.owner));
    });

    test('isVet returns true for vet role', () {
      final vet = AppUser(
        uid: 'v-1',
        email: 'vet@example.com',
        role: AppUserRole.vet,
      );

      expect(vet.isVet, isTrue);
      expect(vet.isOwner, isFalse);
    });

    test('isOwner returns true for owner role', () {
      final owner = AppUser(
        uid: 'o-1',
        email: 'owner@example.com',
        role: AppUserRole.owner,
      );

      expect(owner.isOwner, isTrue);
      expect(owner.isVet, isFalse);
    });

    test('role name serialization', () {
      expect(AppUserRole.vet.name, 'vet');
      expect(AppUserRole.owner.name, 'owner');
    });
  });

  group('AppUser computed properties', () {
    test('hasPets is true when petIds is non-empty', () {
      final user = AppUser(
        uid: 'u-1',
        email: 'test@example.com',
        role: AppUserRole.owner,
        petIds: ['p-1'],
      );

      expect(user.hasPets, isTrue);
    });

    test('hasPets is false when petIds is empty', () {
      final user = AppUser(
        uid: 'u-1',
        email: 'test@example.com',
        role: AppUserRole.owner,
      );

      expect(user.hasPets, isFalse);
    });
  });

  group('AppUser defaults', () {
    test('default petIds is empty list', () {
      final user = AppUser(
        uid: 'u-1',
        email: 'test@example.com',
        role: AppUserRole.owner,
      );

      expect(user.petIds, isEmpty);
    });

    test('default settings uses UserSettings defaults', () {
      final user = AppUser(
        uid: 'u-1',
        email: 'test@example.com',
        role: AppUserRole.owner,
      );

      expect(user.settings.elevatedThreshold, 30);
      expect(user.settings.criticalThreshold, 40);
    });

    test('optional fields default to null', () {
      final user = AppUser(
        uid: 'u-1',
        email: 'test@example.com',
        role: AppUserRole.owner,
      );

      expect(user.displayName, isNull);
      expect(user.photoUrl, isNull);
      expect(user.createdAt, isNull);
    });

    test('hasCompletedOnboarding defaults to false', () {
      final user = AppUser(
        uid: 'u-1',
        email: 'test@example.com',
        role: AppUserRole.owner,
      );

      expect(user.hasCompletedOnboarding, isFalse);
    });
  });

  group('AppUser hasCompletedOnboarding', () {
    test('copyWith updates hasCompletedOnboarding', () {
      final user = AppUser(
        uid: 'u-1',
        email: 'test@example.com',
        role: AppUserRole.owner,
        hasCompletedOnboarding: false,
      );

      final updated = user.copyWith(hasCompletedOnboarding: true);

      expect(updated.hasCompletedOnboarding, isTrue);
      expect(user.hasCompletedOnboarding, isFalse);
    });

    test('toFirestore includes hasCompletedOnboarding', () {
      final user = AppUser(
        uid: 'u-1',
        email: 'test@example.com',
        role: AppUserRole.owner,
        hasCompletedOnboarding: true,
      );

      final data = user.toFirestore();

      expect(data, containsPair('hasCompletedOnboarding', true));
    });

    test('fromFirestore reads hasCompletedOnboarding', () {
      // Mock DocumentSnapshot with hasCompletedOnboarding = true
      final mockDoc = _MockDocumentSnapshot({
        'uid': 'u-1',
        'email': 'test@example.com',
        'role': 'owner',
        'hasCompletedOnboarding': true,
      });

      final user = AppUser.fromFirestore(mockDoc);

      expect(user.hasCompletedOnboarding, isTrue);
    });

    test('fromFirestore defaults hasCompletedOnboarding to true when field missing (existing user migration)', () {
      // Mock DocumentSnapshot without hasCompletedOnboarding — existing user
      final mockDoc = _MockDocumentSnapshot({
        'uid': 'u-1',
        'email': 'test@example.com',
        'role': 'owner',
      });

      final user = AppUser.fromFirestore(mockDoc);

      // Existing users without the field are treated as already onboarded
      expect(user.hasCompletedOnboarding, isTrue);
    });

    test('fromFirestore reads hasCompletedOnboarding as false when explicitly set', () {
      final mockDoc = _MockDocumentSnapshot({
        'uid': 'u-1',
        'email': 'test@example.com',
        'role': 'owner',
        'hasCompletedOnboarding': false,
      });

      final user = AppUser.fromFirestore(mockDoc);

      expect(user.hasCompletedOnboarding, isFalse);
    });
  });
}

class _MockDocumentSnapshot implements DocumentSnapshot {
  _MockDocumentSnapshot(this._data);

  final Map<String, dynamic> _data;

  @override
  String get id => _data['uid'] ?? '';

  @override
  Object? data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
