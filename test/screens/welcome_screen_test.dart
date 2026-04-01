import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/welcome_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';

Widget _buildApp() {
  return MaterialApp(
    theme: buildAppTheme(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('he'),
    ],
    home: const WelcomeScreen(),
  );
}

void main() {
  group('WelcomeScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('displays Pet Circle subtitle', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Pet Circle'), findsOneWidget);
    });

    testWidgets('displays welcome tagline', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(
        find.text('A smarter way to care for your pet.'),
        findsOneWidget,
      );
    });

    testWidgets('displays sign-up button', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('displays sign-in with Google button', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('sign-up button is a TextButton and enabled', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final signUpButton = find.widgetWithText(TextButton, 'Sign up');
      expect(signUpButton, findsOneWidget);

      final button = tester.widget<TextButton>(signUpButton);
      expect(button.onPressed, isNotNull,
          reason: 'Sign-up button should be tappable (onPressed != null)');
    });

    testWidgets('Google sign-in button is a TextButton and enabled',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final googleButton =
          find.widgetWithText(TextButton, 'Sign in with Google');
      expect(googleButton, findsOneWidget);

      final button = tester.widget<TextButton>(googleButton);
      expect(button.onPressed, isNotNull,
          reason: 'Google sign-in button should be tappable');
    });

    testWidgets('displays prominent Sign In button', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('displays sign-in with Apple button on iOS', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Sign in with Apple'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('has primaryLightest background scaffold', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });
  });
}
