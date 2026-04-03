import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/models/app_user.dart';

void main() {
  group('AppRoutes — static path constants', () {
    test('welcome route is /', () {
      expect(AppRoutes.welcome, '/');
    });

    test('authGate route is /auth-gate', () {
      expect(AppRoutes.authGate, '/auth-gate');
    });

    test('roleSelection route is /role-selection', () {
      expect(AppRoutes.roleSelection, '/role-selection');
    });

    test('signup route is /signup', () {
      expect(AppRoutes.signup, '/signup');
    });

    test('login route is /login', () {
      expect(AppRoutes.login, '/login');
    });

    test('checkEmail route is /check-email', () {
      expect(AppRoutes.checkEmail, '/check-email');
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
    test('returns /shell/owner for owner role with default tab', () {
      expect(AppRoutes.shell(AppUserRole.owner), '/shell/owner');
    });

    test('returns /shell/vet for vet role with default tab', () {
      expect(AppRoutes.shell(AppUserRole.vet), '/shell/vet');
    });

    test('returns /shell/owner?tab=2 for owner role with tab 2', () {
      expect(AppRoutes.shell(AppUserRole.owner, tab: 2), '/shell/owner?tab=2');
    });

    test('returns /shell/vet?tab=1 for vet role with tab 1', () {
      expect(AppRoutes.shell(AppUserRole.vet, tab: 1), '/shell/vet?tab=1');
    });

    test('omits tab query param when tab is 0', () {
      expect(AppRoutes.shell(AppUserRole.owner, tab: 0), '/shell/owner');
    });
  });

  group('AppRoutes.petDetail()', () {
    test('returns correct path for owner with pet ID', () {
      expect(
        AppRoutes.petDetail(AppUserRole.owner, 'pet123'),
        '/shell/owner/pet/pet123',
      );
    });

    test('returns correct path for vet with pet ID', () {
      expect(
        AppRoutes.petDetail(AppUserRole.vet, 'abc-456'),
        '/shell/vet/pet/abc-456',
      );
    });
  });

  group('parseRole()', () {
    test('parses "vet" as AppUserRole.vet', () {
      expect(parseRole('vet'), AppUserRole.vet);
    });

    test('parses "owner" as AppUserRole.owner', () {
      expect(parseRole('owner'), AppUserRole.owner);
    });

    test('parses null as AppUserRole.owner (default)', () {
      expect(parseRole(null), AppUserRole.owner);
    });

    test('parses unknown string as AppUserRole.owner (default)', () {
      expect(parseRole('admin'), AppUserRole.owner);
    });
  });
}
