import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/user.dart';
import 'package:pet_circle/stores/user_store.dart';

void main() {
  late UserStore store;

  setUp(() {
    store = UserStore();
  });

  group('UserStore seed', () {
    test('seed sets currentUser from mock User', () {
      final user = User(
        id: 'u-1',
        name: 'Hila',
        email: 'hila@example.com',
        role: UserRole.owner,
        avatarUrl: 'https://example.com/avatar.png',
      );

      store.seed(user);

      expect(store.currentUser, isNotNull);
      expect(store.currentUser?.name, 'Hila');
      expect(store.currentUser?.id, 'u-1');
    });

    test('seed maps UserRole.vet to AppUserRole.vet', () {
      final vetUser = User(
        id: 'v-1',
        name: 'Dr. Smith',
        email: 'dr@vet.com',
        role: UserRole.vet,
        avatarUrl: 'https://example.com/vet.png',
      );

      store.seed(vetUser);
      expect(store.role, AppUserRole.vet);
      expect(store.isVet, isTrue);
      expect(store.isOwner, isFalse);
    });

    test('seed maps UserRole.owner to AppUserRole.owner', () {
      final ownerUser = User(
        id: 'o-1',
        name: 'Owner',
        email: 'owner@example.com',
        role: UserRole.owner,
        avatarUrl: 'https://example.com/owner.png',
      );

      store.seed(ownerUser);
      expect(store.role, AppUserRole.owner);
      expect(store.isOwner, isTrue);
      expect(store.isVet, isFalse);
    });
  });

  group('UserStore setUser and setRole', () {
    test('setUser updates currentUser', () {
      final user = User(
        id: 'u-1',
        name: 'Alice',
        email: 'alice@example.com',
        role: UserRole.owner,
        avatarUrl: 'https://example.com/alice.png',
      );

      store.setUser(user);
      expect(store.currentUser?.name, 'Alice');
    });

    test('setRole updates role getter', () {
      store.setRole(AppUserRole.vet);
      expect(store.role, AppUserRole.vet);
      expect(store.isVet, isTrue);

      store.setRole(AppUserRole.owner);
      expect(store.role, AppUserRole.owner);
      expect(store.isOwner, isTrue);
    });
  });

  group('UserStore computed properties', () {
    test('currentUserUid returns user id from seed', () {
      final user = User(
        id: 'u-42',
        name: 'Test',
        email: 'test@example.com',
        role: UserRole.owner,
        avatarUrl: 'https://example.com/test.png',
      );

      store.seed(user);
      expect(store.currentUserUid, 'u-42');
    });

    test('currentUserEmail returns email from seed', () {
      final user = User(
        id: 'u-1',
        name: 'Test',
        email: 'test@example.com',
        role: UserRole.owner,
        avatarUrl: 'https://example.com/test.png',
      );

      store.seed(user);
      expect(store.currentUserEmail, 'test@example.com');
    });

    test('currentUserDisplayName returns name from seed', () {
      final user = User(
        id: 'u-1',
        name: 'Hila',
        email: 'hila@example.com',
        role: UserRole.owner,
        avatarUrl: 'https://example.com/hila.png',
      );

      store.seed(user);
      expect(store.currentUserDisplayName, 'Hila');
    });
  });

  group('UserStore seedFromAppUser', () {
    test('seedFromAppUser sets appUser and derives currentUser', () {
      final appUser = AppUser(
        uid: 'app-1',
        email: 'app@example.com',
        role: AppUserRole.vet,
        displayName: 'Dr. App',
      );

      store.seedFromAppUser(appUser);

      expect(store.appUser, isNotNull);
      expect(store.appUser?.uid, 'app-1');
      expect(store.role, AppUserRole.vet);
      expect(store.currentUser, isNotNull);
      expect(store.currentUser?.name, 'Dr. App');
    });
  });

  group('UserStore notifyListeners', () {
    test('notifyListeners called on seed', () {
      int callCount = 0;
      store.addListener(() => callCount++);

      store.seed(User(
        id: 'u-1',
        name: 'Test',
        email: 'test@example.com',
        role: UserRole.owner,
        avatarUrl: 'https://example.com/test.png',
      ));

      expect(callCount, 1);
    });

    test('notifyListeners called on setRole', () {
      int callCount = 0;
      store.addListener(() => callCount++);

      store.setRole(AppUserRole.vet);
      expect(callCount, 1);
    });
  });
}
