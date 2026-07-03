import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/auth/create_account_screen.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/social_button.dart';

import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('CreateAccountScreen', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const CreateAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(CreateAccountScreen), findsOneWidget);
    });

    testWidgets('shows name and email input fields', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const CreateAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
    });

    testWidgets('primary CTA is a PrimaryButton', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const CreateAccountScreen()));
      await tester.pumpAndSettle();

      final cta = find.byType(PrimaryButton);
      expect(cta, findsOneWidget);

      final widget = tester.widget<PrimaryButton>(cta);
      expect(widget.onPressed, isNotNull);
    });

    testWidgets('shows "Continue with Google" social button', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const CreateAccountScreen()));
      await tester.pumpAndSettle();

      final googleButton = find.widgetWithText(
        SocialButton,
        'Continue with Google',
      );
      expect(googleButton, findsOneWidget);

      final widget = tester.widget<SocialButton>(googleButton);
      expect(widget.onTap, isNotNull);
    });

    testWidgets('shows "Continue with Apple" social button', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const CreateAccountScreen()));
      await tester.pumpAndSettle();

      final appleButton = find.widgetWithText(
        SocialButton,
        'Continue with Apple',
      );
      expect(appleButton, findsOneWidget);

      final widget = tester.widget<SocialButton>(appleButton);
      expect(widget.onTap, isNotNull);
    });

    testWidgets('renders exactly two social buttons', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const CreateAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SocialButton), findsNWidgets(2));
    });

    testWidgets('Apple social button has Apple icon', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const CreateAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.apple), findsOneWidget);
    });

    testWidgets('shows OR divider', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const CreateAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.text('OR'), findsOneWidget);
    });

    testWidgets('empty fields show validation errors on submit',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const CreateAccountScreen()));
      await tester.pumpAndSettle();

      // Tap the CTA without entering anything.
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // Email validator returns "Please enter your email" for empty input.
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('invalid email shows validation error', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const CreateAccountScreen()));
      await tester.pumpAndSettle();

      // Fill the name field so only the email validator fails.
      await tester.enterText(
        find.byType(TextFormField).first,
        'Jane Doe',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'not-an-email',
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });
  });
}
