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
    testWidgets('value: true uses accentPurpleTile background', (tester) async {
      await tester.pumpWidget(testApp(const AppToggle(value: true)));

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.accentPurpleTile);
    });

    testWidgets(
      'value: false uses accentButterCream (#E8E4D8) off background',
      (tester) async {
        await tester.pumpWidget(testApp(const AppToggle(value: false)));

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, AppSemanticColors.light.accentButterCream);
        // Token resolves to the Candy/Butter/Cream primitive.
        expect(decoration.color, const Color(0xFFE8E4D8));
      },
    );

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
