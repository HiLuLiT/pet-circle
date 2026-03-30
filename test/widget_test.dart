import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/welcome_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';

void main() {
  testWidgets('WelcomeScreen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
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
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    // Verify the sign-up button is always present on WelcomeScreen
    expect(find.text('Sign up'), findsOneWidget);
  });
}
