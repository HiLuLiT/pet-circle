import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/auth/signup_screen.dart';
import 'package:pet_circle/screens/auth/login_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/primary_button.dart';

Widget _buildSignupApp() {
  return MaterialApp(
    theme: buildAppTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const SignupScreen(),
  );
}

Widget _buildLoginApp() {
  return MaterialApp(
    theme: buildAppTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const LoginScreen(),
  );
}

void main() {
  group('SignupScreen', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSignupApp());
      await tester.pumpAndSettle();

      expect(find.byType(SignupScreen), findsOneWidget);
    });

    testWidgets('shows name and email fields but no password', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSignupApp());
      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsNothing);
    });

    testWidgets('shows send-email-link CTA', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSignupApp());
      await tester.pumpAndSettle();

      expect(find.text('Send email link'), findsOneWidget);
    });

    testWidgets('shows social auth options', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSignupApp());
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('shows sign-in link for existing users', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSignupApp());
      await tester.pumpAndSettle();

      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('validates empty name field on submit', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSignupApp());
      await tester.pumpAndSettle();

      // Tap the submit button without filling in fields
      await tester.tap(find.text('Send email link'));
      await tester.pumpAndSettle();

      // Validation error should appear
      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('validates empty email field on submit', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSignupApp());
      await tester.pumpAndSettle();

      // Enter name but not email
      await tester.enterText(find.byType(TextFormField).first, 'Test User');

      await tester.tap(find.text('Send email link'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildSignupApp());
      await tester.pumpAndSettle();

      // Enter name and invalid email
      await tester.enterText(find.byType(TextFormField).first, 'Test User');
      await tester.enterText(find.byType(TextFormField).last, 'not-an-email');

      await tester.tap(find.text('Send email link'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });

  group('LoginScreen', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildLoginApp());
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('shows email field but no name or password', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildLoginApp());
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Full Name'), findsNothing);
      expect(find.text('Password'), findsNothing);
    });

    testWidgets('shows login CTA button', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildLoginApp());
      await tester.pumpAndSettle();

      // "Login" appears as both title and button — at least 2
      expect(find.text('Login'), findsAtLeast(2));
    });

    testWidgets('shows enter-details subtitle', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildLoginApp());
      await tester.pumpAndSettle();

      expect(find.text('Enter your details to login.'), findsOneWidget);
    });

    testWidgets('validates empty email on submit', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildLoginApp());
      await tester.pumpAndSettle();

      // Tap the first PrimaryButton (Login CTA) — skip social auth buttons
      await tester.tap(find.byType(PrimaryButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildLoginApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'bad-email');
      await tester.tap(find.byType(PrimaryButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows social auth options', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildLoginApp());
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);
    });
  });
}
