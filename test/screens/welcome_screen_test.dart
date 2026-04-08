import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/welcome_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';

import '../helpers/ignore_overflow_errors.dart';
import '../helpers/test_http_overrides.dart';

Widget _buildApp() {
  return MaterialApp(
    theme: buildAppTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const WelcomeScreen(),
  );
}

/// Pump the WelcomeScreen with overflow errors suppressed.
/// The social-sign-in button rows overflow in the test environment because
/// Flutter's test font metrics differ from real device rendering.
Future<void> _pumpWelcome(WidgetTester tester) async {
  suppressOverflowErrors();

  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_buildApp());
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  group('WelcomeScreen', () {
    testWidgets('renders without error', (tester) async {
      await _pumpWelcome(tester);

      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('shows "Create an account" heading', (tester) async {
      await _pumpWelcome(tester);

      expect(find.text('Create an account'), findsOneWidget);
    });

    testWidgets('shows Full Name input field', (tester) async {
      await _pumpWelcome(tester);

      // Label text above the field
      expect(find.text('Full Name'), findsOneWidget);
      // Hint text inside the field
      expect(find.text('Enter your full name'), findsOneWidget);
    });

    testWidgets('shows Email input field', (tester) async {
      await _pumpWelcome(tester);

      // Label text above the field
      expect(find.text('Email address'), findsOneWidget);
      // Hint text inside the field
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('shows "Send email code" button', (tester) async {
      await _pumpWelcome(tester);

      final button = find.widgetWithText(ElevatedButton, 'Send email code');
      expect(button, findsOneWidget);
    });

    testWidgets('shows OR divider', (tester) async {
      await _pumpWelcome(tester);

      expect(find.text('OR'), findsOneWidget);
    });

    testWidgets('shows "Continue with Google" button', (tester) async {
      await _pumpWelcome(tester);

      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('shows "Continue with Apple" button', (tester) async {
      await _pumpWelcome(tester);

      expect(find.text('Continue with Apple'), findsOneWidget);
    });

    testWidgets('shows "Already have an account?" with "Sign In" link',
        (tester) async {
      await _pumpWelcome(tester);

      // Text.rich concatenates spans: "Already have an account? " + "Sign In"
      final richTextFinder = find.byWidgetPredicate((widget) {
        if (widget is! RichText) return false;
        final text = widget.text.toPlainText();
        return text.contains('Already have an account?') &&
            text.contains('Sign In');
      });
      expect(richTextFinder, findsOneWidget);
    });

    testWidgets('shows bolt icon in circular logo', (tester) async {
      await _pumpWelcome(tester);

      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });

    testWidgets('shows subtitle text', (tester) async {
      await _pumpWelcome(tester);

      expect(
        find.text('Please enter your details to create an account.'),
        findsOneWidget,
      );
    });

    testWidgets('form validation: empty name shows error', (tester) async {
      await _pumpWelcome(tester);

      // Leave both fields empty and tap Send email code
      await tester.tap(find.text('Send email code'));
      await tester.pumpAndSettle();

      // The name validator returns l10n.enterYourFullName on empty input.
      // There is already a hint "Enter your full name", so after validation
      // there should be two instances: hint + error.
      expect(find.text('Enter your full name'), findsNWidgets(2));
    });

    testWidgets('form validation: invalid email shows error', (tester) async {
      await _pumpWelcome(tester);

      // Fill in a valid name so we get past name validation
      await tester.enterText(
        find.byType(TextFormField).first,
        'Test User',
      );
      // Enter invalid email
      await tester.enterText(
        find.byType(TextFormField).last,
        'not-an-email',
      );

      await tester.tap(find.text('Send email code'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('has non-null background color on Scaffold', (tester) async {
      await _pumpWelcome(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });

    testWidgets('form validation: valid name + valid email passes validation',
        (tester) async {
      await _pumpWelcome(tester);

      // Fill in a valid name
      await tester.enterText(
        find.byType(TextFormField).first,
        'Test User',
      );
      // Fill in a valid email
      await tester.enterText(
        find.byType(TextFormField).last,
        'test@example.com',
      );

      await tester.tap(find.text('Send email code'));
      await tester.pumpAndSettle();

      // No validation errors should appear.
      // The hint "Enter your full name" should still appear once (hint only, no error).
      expect(find.text('Enter your full name'), findsOneWidget);
      // "Enter a valid email" error should NOT appear.
      expect(find.text('Enter a valid email'), findsNothing);
      // "Please enter your email" error should NOT appear.
      expect(find.text('Please enter your email'), findsNothing);
    });

    testWidgets('form validation: empty email shows error', (tester) async {
      await _pumpWelcome(tester);

      // Fill in a valid name but leave email empty
      await tester.enterText(
        find.byType(TextFormField).first,
        'Test User',
      );

      await tester.tap(find.text('Send email code'));
      await tester.pumpAndSettle();

      // The email validator returns "Please enter your email" on empty input.
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('Google sign-in button is tappable', (tester) async {
      await _pumpWelcome(tester);

      // Find the Google button as an OutlinedButton with the correct text
      final googleButton = find.widgetWithText(
        OutlinedButton,
        'Continue with Google',
      );
      expect(googleButton, findsOneWidget);

      // Verify the button is enabled (onPressed is not null before loading)
      final button = tester.widget<OutlinedButton>(googleButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Apple sign-in button is tappable', (tester) async {
      await _pumpWelcome(tester);

      // Find the Apple button as an OutlinedButton with the correct text
      final appleButton = find.widgetWithText(
        OutlinedButton,
        'Continue with Apple',
      );
      expect(appleButton, findsOneWidget);

      // Verify the button is enabled (onPressed is not null before loading)
      final button = tester.widget<OutlinedButton>(appleButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Google button uses OutlinedButton style', (tester) async {
      await _pumpWelcome(tester);

      final googleButton = find.widgetWithText(
        OutlinedButton,
        'Continue with Google',
      );
      expect(googleButton, findsOneWidget);

      // Verify it renders as an OutlinedButton (not ElevatedButton)
      final widget = tester.widget<OutlinedButton>(googleButton);
      expect(widget, isA<OutlinedButton>());
    });

    testWidgets('Apple button uses OutlinedButton style', (tester) async {
      await _pumpWelcome(tester);

      final appleButton = find.widgetWithText(
        OutlinedButton,
        'Continue with Apple',
      );
      expect(appleButton, findsOneWidget);

      // Verify it renders as an OutlinedButton (not ElevatedButton)
      final widget = tester.widget<OutlinedButton>(appleButton);
      expect(widget, isA<OutlinedButton>());
    });

    testWidgets('Apple button has Apple icon', (tester) async {
      await _pumpWelcome(tester);

      expect(find.byIcon(Icons.apple), findsOneWidget);
    });
  });
}
