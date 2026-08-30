import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/screens/trends/trends_screen.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/widgets/app_dropdown.dart';
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

      // Default period is the unfiltered "All measurements".
      expect(find.text('All measurements'), findsOneWidget);
    });

    testWidgets('opening the period dropdown and selecting updates the value', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      // Closed: only the trigger shows the current value, the other options
      // are not rendered yet.
      expect(find.text('All measurements'), findsOneWidget);
      expect(find.text('Last 24 hours'), findsNothing);

      // Tap the trigger to open the inline option list.
      await tester.tap(find.text('All measurements'));
      await tester.pumpAndSettle();

      // The selected option now appears in both the trigger and the open
      // list, and the other options become visible.
      expect(find.text('Last 24 hours'), findsOneWidget);

      // Select a different period; the list closes and the trigger updates.
      await tester.tap(find.text('Last 24 hours'));
      await tester.pumpAndSettle();

      expect(find.text('Last 24 hours'), findsOneWidget);
      // The previously-selected label is no longer shown anywhere.
      expect(find.text('All measurements'), findsNothing);
    });

    // BUG-061: the open list lives in the root Overlay and is positioned in
    // absolute screen coordinates captured when it opens. Left alone it kept
    // floating over whatever the user scrolled to, detached from its trigger.
    testWidgets('scrolling the page closes the open period list', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('All measurements'));
      await tester.pumpAndSettle();
      expect(find.text('Last 24 hours'), findsOneWidget);

      await tester.drag(find.byType(TrendsScreen), const Offset(0, -200));
      await tester.pumpAndSettle();

      // The list is gone and the trigger still shows the unchanged value.
      expect(find.text('Last 24 hours'), findsNothing);
      expect(find.text('All measurements'), findsOneWidget);
    });

    testWidgets('tapping outside the open period list closes it', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('All measurements'));
      await tester.pumpAndSettle();
      expect(find.text('Last 24 hours'), findsOneWidget);

      // Top-left corner is the barrier, well clear of the list itself.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.text('Last 24 hours'), findsNothing);
      expect(find.text('All measurements'), findsOneWidget);
    });

    // BUG-063: the barrier is translucent, so a tap on the trigger hit both
    // it and the trigger. The barrier closed the list and the trigger's own
    // onTap immediately re-opened it — leaving it open, and re-entering
    // didUpdateWidget mid-build, where markNeedsBuild on the overlay entry
    // throws "setState() or markNeedsBuild() called during build".
    testWidgets('tapping the trigger repeatedly toggles cleanly, no exception', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('All measurements').first);
        await tester.pumpAndSettle();
        expect(
          find.text('Last 24 hours'),
          findsOneWidget,
          reason: 'tap ${i * 2 + 1} should open the list',
        );

        await tester.tap(find.text('All measurements').first);
        await tester.pumpAndSettle();
        expect(
          find.text('Last 24 hours'),
          findsNothing,
          reason: 'tap ${i * 2 + 2} should close the list',
        );
      }

      expect(tester.takeException(), isNull);
    });

    // BUG-063: the trigger sat in a fixed 165px box, so "All measurements"
    // — the new default, and longer than every "Last N days" label — was
    // rendered with an ellipsis. It now takes the row's spare width.
    //
    // This asserts the box flexes rather than asserting glyph widths: the
    // widget-test font is a fixed-advance stub whose metrics say nothing
    // about whether real Instrument Sans fits.
    testWidgets('the period trigger takes the row width instead of a fixed box', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 600+, like the other tests here: at phone widths the stub test font
      // overflows the unrelated metric row.
      tester.view.physicalSize = const Size(600, 1400);
      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();
      final narrow = tester.getSize(find.byType(AppDropdown)).width;

      tester.view.physicalSize = const Size(900, 1400);
      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();
      final wide = tester.getSize(find.byType(AppDropdown)).width;

      expect(
        wide,
        greaterThan(narrow),
        reason: 'the trigger is still a fixed-width box, so long labels clip',
      );
      expect(narrow, isNot(165.0));
    });

    testWidgets('history is paginated and "Show more" reveals the next page', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 25 readings — more than the 10-per-page history window.
      final petId = petStore.ownerPets.first.id!;
      measurementStore.seed({
        petId: List.generate(
          25,
          (i) => Measurement(
            bpm: 20 + i,
            recordedAt: DateTime.now().subtract(Duration(minutes: i + 1)),
          ),
        ),
      });

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Showing 10 of 25'), findsOneWidget);
      expect(find.text('Show 10 more'), findsOneWidget);
      // 11th reading (bpm 30) is on the next page.
      expect(find.text('30 BPM'), findsNothing);

      await tester.tap(find.text('Show 10 more'));
      await tester.pumpAndSettle();

      expect(find.text('Showing 20 of 25'), findsOneWidget);
      expect(find.text('30 BPM'), findsOneWidget);

      // Last page is partial, so the button offers only the remainder.
      expect(find.text('Show 5 more'), findsOneWidget);
      await tester.tap(find.text('Show 5 more'));
      await tester.pumpAndSettle();

      expect(find.text('Showing 25 of 25'), findsOneWidget);
      expect(find.textContaining('Show '), findsNothing);
    });

    testWidgets('narrowing the period resets history back to the first page', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final petId = petStore.ownerPets.first.id!;
      measurementStore.seed({
        petId: List.generate(
          25,
          (i) => Measurement(
            bpm: 20 + i,
            recordedAt: DateTime.now().subtract(Duration(minutes: i + 1)),
          ),
        ),
      });

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show 10 more'));
      await tester.pumpAndSettle();
      expect(find.text('Showing 20 of 25'), findsOneWidget);

      // All 25 readings fall inside 24 hours, so only the paging resets.
      await tester.tap(find.text('All measurements'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last 24 hours'));
      await tester.pumpAndSettle();

      expect(find.text('Showing 10 of 25'), findsOneWidget);
    });

    testWidgets('shows export button', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Export'), findsOneWidget);
      // DS alignment: the export button icon is now the outlined variant.
      expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);
    });

    testWidgets('shows chart legend badges', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(testApp(const TrendsScreen()));
      await tester.pumpAndSettle();

      // DS alignment: legend copy now uses the legendNormal/legendElevated/
      // legendAlert l10n keys with default thresholds 30/40.
      expect(find.text('Normal ≤30'), findsOneWidget);
      expect(find.text('Elevated 30-40'), findsOneWidget);
      expect(find.text('Alert >40'), findsOneWidget);
    });

    // Regression: the period selector used to store its value as a localized
    // display string. When the app locale changed while the screen stayed
    // mounted, the DropdownButton's value (e.g. "All measurements") no longer
    // matched any of its now-Hebrew items, throwing the framework assertion
    // "There should be exactly one item with [DropdownButton]'s value".
    // The value is now a locale-independent [TrendsPeriod] enum, so switching
    // locale must not throw.
    testWidgets('period selector survives a locale switch (regression)', (
      tester,
    ) async {
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
      expect(find.text('All measurements'), findsOneWidget);

      // Switch to Hebrew while the same TrendsScreen State stays mounted.
      localeNotifier.value = const Locale('he');
      await tester.pumpAndSettle();

      // No DropdownButton assertion, and the English label is gone (the
      // dropdown re-rendered its label in Hebrew while keeping the same value).
      expect(tester.takeException(), isNull);
      expect(find.text('All measurements'), findsNothing);
    });
  });
}
