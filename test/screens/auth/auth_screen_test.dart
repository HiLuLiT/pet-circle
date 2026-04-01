import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/auth/auth_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';

/// Wraps [AuthScreen] in a full-screen MaterialApp (no outer Scaffold)
/// to avoid layout overflow in constrained test viewports.
Widget _buildApp({bool startWithSignIn = false}) {
  return MaterialApp(
    theme: buildAppTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: AuthScreen(startWithSignIn: startWithSignIn),
  );
}

void main() {
  group('AuthScreen', () {
    testWidgets('renders sign-up mode without error', (tester) async {
      // Use a tall viewport so the scrollable form content doesn't overflow.
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);
    });

    testWidgets('renders sign-in mode when startWithSignIn is true',
        (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp(startWithSignIn: true));
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('Welcome back,'), findsOneWidget);
    });

    testWidgets('shows email and password fields', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows Google social button', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Google'), findsOneWidget);
    });

    testWidgets('toggles between sign-up and sign-in modes', (tester) async {
      tester.view.physicalSize = const Size(480, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Initially in sign-up mode — "Sign In" toggle visible
      expect(find.text('Sign In'), findsOneWidget);

      // Tap toggle to switch to sign-in mode
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back,'), findsOneWidget);
    });
  });
}
