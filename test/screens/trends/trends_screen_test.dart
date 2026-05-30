import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/trends/trends_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';

import '../../helpers/test_app.dart';
import '../../helpers/mock_stores.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('TrendsScreen', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TrendsScreen), findsOneWidget);
    });

    testWidgets('shows health trends title', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Health Trends'), findsOneWidget);
    });

    testWidgets('shows period dropdown', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      // Default period is "Last 7 days"
      expect(find.text('Last 7 days'), findsOneWidget);
    });

    testWidgets('shows export button', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Export'), findsOneWidget);
      expect(find.byIcon(Icons.file_download), findsOneWidget);
    });

    testWidgets('shows chart legend badges', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Normal (<30)'), findsOneWidget);
      expect(find.text('Elevated (30-40)'), findsOneWidget);
      expect(find.text('Alert (>40)'), findsOneWidget);
    });

    // Regression: the period selector used to store its value as a localized
    // display string. When the app locale changed while the screen stayed
    // mounted, the DropdownButton's value (e.g. "Last 7 days") no longer
    // matched any of its now-Hebrew items, throwing the framework assertion
    // "There should be exactly one item with [DropdownButton]'s value".
    // The value is now a locale-independent [TrendsPeriod] enum, so switching
    // locale must not throw.
    testWidgets('period selector survives a locale switch (regression)',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final localeNotifier = ValueNotifier<Locale>(const Locale('en'));
      addTearDown(localeNotifier.dispose);

      await tester.pumpWidget(
        ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) => MaterialApp(
            theme: buildAppTheme(),
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // const so the same TrendsScreen State survives the locale change.
            home: const Scaffold(body: TrendsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default English label is shown for the selected period.
      expect(find.text('Last 7 days'), findsOneWidget);

      // Switch to Hebrew while the same TrendsScreen State stays mounted.
      localeNotifier.value = const Locale('he');
      await tester.pumpAndSettle();

      // No DropdownButton assertion, and the English label is gone (the
      // dropdown re-rendered its label in Hebrew while keeping the same value).
      expect(tester.takeException(), isNull);
      expect(find.text('Last 7 days'), findsNothing);
    });
  });
}
