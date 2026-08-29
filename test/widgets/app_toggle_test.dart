import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/widgets/app_toggle.dart';

import '../helpers/test_app.dart';

void main() {
  group('AppToggle', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(const AppToggle(value: true)));
      expect(find.byType(AppToggle), findsOneWidget);
    });

    // ── Background color tests ──────────────────────────────────────────────
    testWidgets('value: true uses toggleTrackOn background', (tester) async {
      await tester.pumpWidget(testApp(const AppToggle(value: true)));

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.toggleTrackOn);
      // Light is unchanged by the dark-contrast fix: still Candy/Purple/Tile.
      expect(decoration.color, const Color(0xFFC3AEF0));
    });

    testWidgets(
      'value: false uses toggleTrackOff (#E8E4D8) off background',
      (tester) async {
        await tester.pumpWidget(testApp(const AppToggle(value: false)));

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, AppSemanticColors.light.toggleTrackOff);
        // Token resolves to the Candy/Butter/Cream primitive.
        expect(decoration.color, const Color(0xFFE8E4D8));
      },
    );

    // ── Dark mode contrast (BUG-055) ────────────────────────────────────────
    // The track used to read the accent *tiles*, which are recessed background
    // washes: in dark both landed within 1.1:1 of the card behind them, and
    // within 1.06:1 of each other, so an on switch was indistinguishable from
    // an off one. These assert the states are separable by colour alone.
    double luminanceOf(Color c) {
      double channel(double v) =>
          v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
      return 0.2126 * channel(c.r) +
          0.7152 * channel(c.g) +
          0.0722 * channel(c.b);
    }

    double contrast(Color a, Color b) {
      final la = luminanceOf(a);
      final lb = luminanceOf(b);
      final hi = math.max(la, lb);
      final lo = math.min(la, lb);
      return (hi + 0.05) / (lo + 0.05);
    }

    testWidgets('dark on-track separates from the card it sits on', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(const AppToggle(value: true), darkMode: true),
      );

      final decoration =
          tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration
              as BoxDecoration;
      expect(decoration.color, AppSemanticColors.dark.toggleTrackOn);
      expect(
        contrast(decoration.color!, AppSemanticColors.dark.surface),
        greaterThan(4.5),
        reason: 'an on switch must be clearly visible against a card',
      );
    });

    testWidgets('dark on and off tracks are distinguishable from each other', (
      tester,
    ) async {
      final dark = AppSemanticColors.dark;
      expect(
        contrast(dark.toggleTrackOn, dark.toggleTrackOff),
        greaterThan(3.0),
        reason:
            'state must be readable from colour, not only knob position; '
            'the accent tiles this replaced sat at 1.06:1',
      );
    });

    testWidgets('dark knob stays legible on both tracks', (tester) async {
      final dark = AppSemanticColors.dark;
      // The knob carries the off state, where the track is deliberately quiet.
      expect(contrast(dark.knobFill, dark.toggleTrackOff), greaterThan(4.5));
    });

    // ── Size & shape ────────────────────────────────────────────────────────
    testWidgets('has fixed pill size 46x28', (tester) async {
      await tester.pumpWidget(testApp(const AppToggle(value: true)));

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(container.constraints?.maxWidth, 46);
      expect(container.constraints?.maxHeight, 28);
    });

    testWidgets('track uses fully-rounded border radius', (tester) async {
      await tester.pumpWidget(testApp(const AppToggle(value: true)));

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(1000));
    });

    // ── Knob position tests ─────────────────────────────────────────────────
    // The knob's position is spring-driven (AnimationController +
    // SpringSimulation, apple-design skill §4) rather than an
    // AnimatedPositioned on a fixed duration/curve, so it settles rather
    // than eases — see `lib/theme/tokens/motion.dart`.
    testWidgets('knob positioned left: 21 when value is true', (tester) async {
      await tester.pumpWidget(testApp(const AppToggle(value: true)));

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.left, 21);
      expect(positioned.top, 3);
    });

    testWidgets('knob positioned left: 3 when value is false', (tester) async {
      await tester.pumpWidget(testApp(const AppToggle(value: false)));

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.left, 3);
      expect(positioned.top, 3);
    });

    testWidgets(
      'knob springs to the new target and settles there when value changes',
      (tester) async {
        await tester.pumpWidget(testApp(const AppToggle(value: false)));
        expect(
          tester.widget<Positioned>(find.byType(Positioned)).left,
          3,
        );

        await tester.pumpWidget(testApp(const AppToggle(value: true)));
        // Mid-flight: the spring has started moving but has not arrived yet.
        await tester.pump(const Duration(milliseconds: 16));
        final midFlight = tester.widget<Positioned>(find.byType(Positioned));
        expect(midFlight.left, greaterThan(3));
        expect(midFlight.left, lessThan(21));

        await tester.pumpAndSettle();
        // SpringSimulation stops once within its default tolerance of the
        // target (~1e-3), not at the exact value — assert closeTo, not ==.
        expect(
          tester.widget<Positioned>(find.byType(Positioned)).left,
          closeTo(21, 0.01),
        );
      },
    );

    testWidgets(
      'reduced motion jumps the knob straight to the target with no spring',
      (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: testApp(const AppToggle(value: false)),
          ),
        );

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: testApp(const AppToggle(value: true)),
          ),
        );
        // A single, zero-duration frame is enough: reduced motion sets the
        // controller's value directly instead of starting a simulation.
        await tester.pump();

        expect(
          tester.widget<Positioned>(find.byType(Positioned)).left,
          21,
        );
      },
    );

    testWidgets('knob is a white 22x22 circle', (tester) async {
      await tester.pumpWidget(testApp(const AppToggle(value: true)));

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      final knob = containers.firstWhere((c) {
        final d = c.decoration;
        return d is BoxDecoration &&
            d.shape == BoxShape.circle &&
            d.color == Colors.white;
      });
      // Knob is a fixed 22x22 Container.
      expect(knob.constraints?.maxWidth, 22);
      expect(knob.constraints?.maxHeight, 22);
    });

    // ── Interaction tests ───────────────────────────────────────────────────
    testWidgets('calls onChanged with !value when tapped (false -> true)', (
      tester,
    ) async {
      bool? received;
      await tester.pumpWidget(
        testApp(AppToggle(value: false, onChanged: (v) => received = v)),
      );

      await tester.tap(find.byType(AppToggle));
      await tester.pump();
      expect(received, isTrue);
    });

    testWidgets('calls onChanged with !value when tapped (true -> false)', (
      tester,
    ) async {
      bool? received;
      await tester.pumpWidget(
        testApp(AppToggle(value: true, onChanged: (v) => received = v)),
      );

      await tester.tap(find.byType(AppToggle));
      await tester.pump();
      expect(received, isFalse);
    });

    testWidgets('does not fire onChanged when disabled', (tester) async {
      var called = false;
      await tester.pumpWidget(
        testApp(
          AppToggle(
            value: false,
            disabled: true,
            onChanged: (_) => called = true,
          ),
        ),
      );

      await tester.tap(find.byType(AppToggle), warnIfMissed: false);
      await tester.pump();
      expect(called, isFalse);
    });

    testWidgets('wraps in Opacity(0.5) when disabled', (tester) async {
      await tester.pumpWidget(
        testApp(const AppToggle(value: true, disabled: true)),
      );

      // The AppToggle places exactly one Opacity at the root when disabled.
      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(AppToggle),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.5);
    });

    testWidgets('does not wrap in Opacity when enabled', (tester) async {
      await tester.pumpWidget(testApp(const AppToggle(value: true)));

      expect(
        find.descendant(
          of: find.byType(AppToggle),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
    });

    testWidgets('tapping with null onChanged does not throw', (tester) async {
      await tester.pumpWidget(testApp(const AppToggle(value: false)));

      await tester.tap(find.byType(AppToggle));
      await tester.pump();
      // No exception means pass.
    });
  });
}
