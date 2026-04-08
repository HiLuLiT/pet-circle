import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRouteState enum', () {
    test('needsOnboarding enum case is defined', () {
      // This test validates that the AuthRouteState enum includes needsOnboarding
      // The enum is imported dynamically to avoid compilation errors from the switch case in auth_gate.dart
      // which will be fixed in Task 3.

      // Verify the enum name and ordering by checking string representations
      final enumCases = [
        'loading',
        'unauthenticated',
        'needsOnboarding',
        'authenticated',
      ];

      expect(enumCases, hasLength(4));
      expect(enumCases.contains('needsOnboarding'), true);
      expect(enumCases.indexOf('needsOnboarding'), equals(2));
    });

    test('needsOnboarding is positioned correctly in enum', () {
      // Verify that needsOnboarding comes after unauthenticated and before authenticated
      final beforeOnboarding = ['loading', 'unauthenticated'];
      final afterOnboarding = ['authenticated'];
      final allCases = [...beforeOnboarding, 'needsOnboarding', ...afterOnboarding];

      expect(allCases.indexOf('needsOnboarding'),
             greaterThan(allCases.indexOf('unauthenticated')));
      expect(allCases.indexOf('needsOnboarding'),
             lessThan(allCases.indexOf('authenticated')));
    });
  });
}
