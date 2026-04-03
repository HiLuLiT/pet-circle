import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/auth/signup_screen.dart';
import 'package:pet_circle/screens/auth/login_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';

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
  });
}
