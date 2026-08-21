import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/landing_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/pounding_heart_hero.dart';

import 'helpers/test_http_overrides.dart';

Widget _app({bool disableAnimations = false}) => MaterialApp(
  theme: buildAppTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  // copyWith, not a fresh MediaQueryData — the latter would zero out the
  // viewport size and break layout.
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: disableAnimations),
      child: const LandingScreen(),
    ),
  ),
);

void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  /// Sizes the test view in logical pixels (devicePixelRatio 1.0).
  void useViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('LandingScreen renders without error', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const Size(1080, 1920));

    await tester.pumpWidget(_app());
    // Not pumpAndSettle: PoundingHeartHero loops forever, so the tree never
    // reaches a settled state.
    await tester.pump();

    expect(find.byType(LandingScreen), findsOneWidget);
    expect(find.text('A smarter way to care for your pet.'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  // Regression: the fixed-height hero + text block used to overflow a short
  // viewport by 16px (BUG-029). The layout must scroll instead of overflowing.
  testWidgets('LandingScreen does not overflow a short viewport', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const Size(393, 442));

    await tester.pumpWidget(_app());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byType(Scrollable), findsWidgets);
  });

  group('animated hero', () {
    testWidgets('renders and keeps animating across frames', (
      WidgetTester tester,
    ) async {
      useViewport(tester, const Size(1080, 1920));

      await tester.pumpWidget(_app());
      await tester.pump();

      expect(find.byType(PoundingHeartHero), findsOneWidget);

      // Advancing time must change the painted transforms — otherwise the
      // ticker is not driving the composition.
      Matrix4 heartTransform() => tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(PoundingHeartHero),
              matching: find.byType(Transform),
            ),
          )
          .map((t) => t.transform)
          .reduce((a, b) => a * b as Matrix4);

      final before = heartTransform();
      // A quarter of the 1.4s beat lands mid-thump.
      await tester.pump(const Duration(milliseconds: 350));
      expect(heartTransform(), isNot(before));
    });

    testWidgets('holds a still frame when animations are disabled', (
      WidgetTester tester,
    ) async {
      useViewport(tester, const Size(1080, 1920));

      await tester.pumpWidget(_app(disableAnimations: true));
      await tester.pump();

      expect(find.byType(PoundingHeartHero), findsOneWidget);
      expect(tester.takeException(), isNull);

      // The point of reduce-motion is that the ticker is actually stopped,
      // not merely ignored while it keeps burning frames.
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });
}
