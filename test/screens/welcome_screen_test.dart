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

    testWidgets('displays sign-up button', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('displays sign-in button', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
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

    testWidgets('sign-in button is a TextButton and enabled', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final signInButton = find.widgetWithText(TextButton, 'Sign In');
      expect(signInButton, findsOneWidget);

      final button = tester.widget<TextButton>(signInButton);
      expect(button.onPressed, isNotNull,
          reason: 'Sign-in button should be tappable (onPressed != null)');
    });

    testWidgets('has pink background scaffold', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.pink);
    });
  });
}
