import 'dart:io';
import 'dart:math' as math;

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
      // The default tempo of 0.7 stretches the 1.4s beat to 2.0s of
      // wall-clock, so 160ms lands mid-thump.
      await tester.pump(const Duration(milliseconds: 160));
      expect(heartTransform(), isNot(before));
    });

    // Regression (BUG-033): the beat, drift and breath used to share one 4.2s
    // controller. At the authored tempo of 0.7 a beat lasts 2.0s, so 4.2s is
    // 2.1 beats and the restart landed 89% up the first thump — the heart
    // snapped ~7px back to rest once per loop. Each clock now wraps on its own
    // boundary, so no frame may jump further than ordinary motion does.
    testWidgets('loops without a visible jump', (WidgetTester tester) async {
      useViewport(tester, const Size(1080, 1920));

      await tester.pumpWidget(_app());
      await tester.pump();

      // storage[13] is the accumulated y translation — the axis the snap was
      // on (lift + drift both move the heart vertically).
      double y() => tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(PoundingHeartHero),
              matching: find.byType(Transform),
            ),
          )
          .map((t) => t.transform)
          .reduce((a, b) => a * b as Matrix4)
          .storage[13];

      // Sweep past where the old 4.2s restart fell, sampling finely enough
      // that a one-frame discontinuity cannot hide between samples.
      const step = Duration(milliseconds: 16);
      var previous = y();
      var worst = 0.0;
      for (
        var elapsed = Duration.zero;
        elapsed < const Duration(seconds: 5);
        elapsed += step
      ) {
        await tester.pump(step);
        final current = y();
        worst = math.max(worst, (current - previous).abs());
        previous = current;
      }

      // A thump moves the heart ~0.3px per 16ms frame at its fastest; the old
      // restart moved it ~7px in one frame.
      expect(worst, lessThan(1.0));
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
