import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/user.dart';

User _makeUser() {
  return User(
    id: 'u-1',
    name: 'Hila',
    email: 'hila@example.com',
    role: UserRole.owner,
    avatarUrl: 'https://example.com/hila.png',
    pets: [],
  );
}

void main() {
  group('User construction', () {
    test('creates with all required fields', () {
      final user = _makeUser();

      expect(user.id, 'u-1');
      expect(user.name, 'Hila');
      expect(user.email, 'hila@example.com');
      expect(user.role, UserRole.owner);
      expect(user.avatarUrl, 'https://example.com/hila.png');
    });

    test('pets defaults to empty list', () {
      final user = User(
        id: 'u-2',
        name: 'Test',
        email: 'test@example.com',
        role: UserRole.vet,
        avatarUrl: '',
      );

      expect(user.pets, isEmpty);
    });

    test('all UserRole values are distinct', () {
      final roles = UserRole.values;
      expect(roles.length, 3);
      expect(roles.toSet().length, 3);
    });
  });

  group('User roleLabel', () {
    test('vet role returns Veterinarian', () {
      final user = User(
        id: 'u-vet',
        name: 'Dr. Smith',
        email: 'vet@example.com',
        role: UserRole.vet,
        avatarUrl: '',
      );

      expect(user.roleLabel, 'Veterinarian');
    });

    test('owner role returns Pet Owner', () {
      final user = _makeUser();
      expect(user.roleLabel, 'Pet Owner');
    });

    test('caregiver role returns Caregiver', () {
      final user = User(
        id: 'u-care',
        name: 'Caregiver',
        email: 'care@example.com',
        role: UserRole.caregiver,
        avatarUrl: '',
      );

      expect(user.roleLabel, 'Caregiver');
    });
  });

  group('User copyWith', () {
    test('copyWith creates a new instance', () {
      final original = _makeUser();
      final copy = original.copyWith(name: 'NewName');

      expect(identical(original, copy), isFalse);
      expect(copy.name, 'NewName');
      expect(original.name, 'Hila');
    });

    test('copyWith preserves all fields when no args given', () {
      final original = _makeUser();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.email, original.email);
      expect(copy.role, original.role);
      expect(copy.avatarUrl, original.avatarUrl);
      expect(copy.pets.length, original.pets.length);
    });

    test('original is unchanged after copyWith', () {
      final original = _makeUser();

      original.copyWith(
        name: 'Changed',
        email: 'changed@example.com',
        role: UserRole.vet,
      );

      expect(original.name, 'Hila');
      expect(original.email, 'hila@example.com');
      expect(original.role, UserRole.owner);
    });

    test('copyWith can update each field independently', () {
      final original = _makeUser();

      expect(original.copyWith(id: 'new-id').id, 'new-id');
      expect(original.copyWith(name: 'Rex').name, 'Rex');
      expect(
        original.copyWith(email: 'new@example.com').email,
        'new@example.com',
      );
      expect(original.copyWith(role: UserRole.vet).role, UserRole.vet);
      expect(
        original.copyWith(avatarUrl: 'new.png').avatarUrl,
        'new.png',
      );
    });

    test('copyWith can replace pets list', () {
      final original = _makeUser();
      final copy = original.copyWith(pets: []);

      expect(copy.pets, isEmpty);
    });
  });

  group('User edge cases', () {
    test('can create with empty strings', () {
      final user = User(
        id: '',
        name: '',
        email: '',
        role: UserRole.owner,
        avatarUrl: '',
      );

      expect(user.id, '');
      expect(user.name, '');
      expect(user.email, '');
      expect(user.avatarUrl, '');
    });
  });
}
