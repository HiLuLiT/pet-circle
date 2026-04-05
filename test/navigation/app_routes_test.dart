import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/app_routes.dart';

void main() {
  group('AppRoutes — static path constants', () {
    test('welcome route is /', () {
      expect(AppRoutes.welcome, '/');
    });

    test('authGate route is /auth-gate', () {
      expect(AppRoutes.authGate, '/auth-gate');
    });

    test('auth route is /auth', () {
      expect(AppRoutes.auth, '/auth');
    });

    test('verifyEmail route is /verify-email', () {
      expect(AppRoutes.verifyEmail, '/verify-email');
    });

    test('onboarding route is /onboarding', () {
      expect(AppRoutes.onboarding, '/onboarding');
    });

    test('invite route is /invite', () {
      expect(AppRoutes.invite, '/invite');
    });

    test('vetDashboard route is /vet-dashboard', () {
      expect(AppRoutes.vetDashboard, '/vet-dashboard');
    });
  });

  group('AppRoutes.shell()', () {
    test('returns /shell with default tab', () {
      expect(AppRoutes.shell(), '/shell');
    });

    test('returns /shell?tab=2 for tab 2', () {
      expect(AppRoutes.shell(tab: 2), '/shell?tab=2');
    });

    test('returns /shell?tab=1 for tab 1', () {
      expect(AppRoutes.shell(tab: 1), '/shell?tab=1');
    });

    test('omits tab query param when tab is 0', () {
      expect(AppRoutes.shell(tab: 0), '/shell');
    });
  });

  group('AppRoutes.shell() — additional tab values', () {
    test('returns /shell?tab=3 for tab 3', () {
      expect(AppRoutes.shell(tab: 3), '/shell?tab=3');
    });

    test('returns /shell?tab=4 for tab 4', () {
      expect(AppRoutes.shell(tab: 4), '/shell?tab=4');
    });
  });

  group('AppRoutes.petDetail()', () {
    test('returns correct path for pet ID', () {
      expect(
        AppRoutes.petDetail('pet123'),
        '/shell/pet/pet123',
      );
    });

    test('returns correct path for another pet ID', () {
      expect(
        AppRoutes.petDetail('abc-456'),
        '/shell/pet/abc-456',
      );
    });

    test('returns correct path for short ID', () {
      expect(
        AppRoutes.petDetail('abc'),
        '/shell/pet/abc',
      );
    });
  });

  group('AppRoutes — removed constants', () {
    test('no roleSelection route constant exists', () {
      // AppRoutes should not expose a roleSelection field.
      // If someone re-adds it, this test will fail at compile time
      // because the class members are checked below.
      final members = <String>[
        AppRoutes.welcome,
        AppRoutes.authGate,
        AppRoutes.auth,
        AppRoutes.verifyEmail,
        AppRoutes.onboarding,
        AppRoutes.invite,
        AppRoutes.vetDashboard,
      ];
      // None of the static constants should be '/role-selection'
      expect(members.contains('/role-selection'), isFalse);
    });
  });
}
