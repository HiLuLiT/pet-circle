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

    testWidgets('valid email passes validation', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      // Enter a valid email
      await tester.enterText(find.byType(TextFormField), 'user@example.com');

      // Tap the Login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // No validation errors should appear
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Enter a valid email'), findsNothing);
    });

    testWidgets('invalid email shows validation error', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      // Enter an invalid email
      await tester.enterText(find.byType(TextFormField), 'not-an-email');

      // Tap the Login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Validator returns "Enter a valid email" for invalid format
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('shows OR divider', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('OR'), findsOneWidget);
    });

    testWidgets('shows person icon in logo', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('shows email hint text', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('shows subtitle text', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter your details to login.'),
        findsOneWidget,
      );
    });

    testWidgets('Google button is tappable (not disabled)', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      final googleButton = find.widgetWithText(
        OutlinedButton,
        'Continue with Google',
      );
      expect(googleButton, findsOneWidget);

      final widget = tester.widget<OutlinedButton>(googleButton);
      expect(widget.onPressed, isNotNull);
    });

    testWidgets('Apple button is tappable (not disabled)', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      final appleButton = find.widgetWithText(
        OutlinedButton,
        'Continue with Apple',
      );
      expect(appleButton, findsOneWidget);

      final widget = tester.widget<OutlinedButton>(appleButton);
      expect(widget.onPressed, isNotNull);
    });

    testWidgets('Apple button has Apple icon', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.apple), findsOneWidget);
    });

    testWidgets('login button is ElevatedButton', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const LoginScreen()));
      await tester.pumpAndSettle();

      final loginButton = find.byType(ElevatedButton);
      expect(loginButton, findsOneWidget);

      final widget = tester.widget<ElevatedButton>(loginButton);
      expect(widget.onPressed, isNotNull);
    });
  });
}
