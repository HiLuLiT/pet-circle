import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/auth/login_screen.dart';

import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('LoginScreen', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('shows "Login" heading', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      // The Login text appears both as the heading and on the button.
      expect(find.text('Login'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows email input field', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      // The label "Email address" should be visible above the field.
      expect(find.text('Email address'), findsOneWidget);
    });

    testWidgets('shows "Login" button', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
      // The ElevatedButton contains "Login" text.
      expect(find.text('Login'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows "Continue with Google" button', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('shows "Continue with Apple" button', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Continue with Apple'), findsOneWidget);
    });

    testWidgets('empty email shows validation error on submit', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      // Tap the Login button without entering an email
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Validator returns "Please enter your email" for empty input
      expect(find.text('Please enter your email'), findsOneWidget);
    });
  });
}
