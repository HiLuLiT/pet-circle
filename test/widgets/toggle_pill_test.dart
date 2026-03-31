import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/toggle_pill.dart';

import '../helpers/test_app.dart';

void main() {
  group('TogglePill', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(const TogglePill(isOn: true)));
      expect(find.byType(TogglePill), findsOneWidget);
    });

    // ── Variant tests ───────────────────────────────────────────────────────
    testWidgets('isOn: true uses primary background', (tester) async {
      await tester.pumpWidget(testApp(const TogglePill(isOn: true)));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.primary);
    });

    testWidgets('isOn: false uses disabled background', (tester) async {
      await tester.pumpWidget(testApp(const TogglePill(isOn: false)));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.disabled);
    });

    // ── State tests ─────────────────────────────────────────────────────────
    testWidgets('isOn: true aligns knob to the right', (tester) async {
      await tester.pumpWidget(testApp(const TogglePill(isOn: true)));

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('isOn: false aligns knob to the left', (tester) async {
      await tester.pumpWidget(testApp(const TogglePill(isOn: false)));

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('has fixed size of 75x36', (tester) async {
      await tester.pumpWidget(testApp(const TogglePill(isOn: true)));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxWidth, 75);
      expect(container.constraints?.maxHeight, 36);
    });

    // ── Interaction test ────────────────────────────────────────────────────
    testWidgets('GestureDetector wrapping TogglePill calls onTap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        GestureDetector(
          onTap: () => tapped = true,
          child: const TogglePill(isOn: false),
        ),
      ));

      await tester.tap(find.byType(TogglePill));
      await tester.pump();
      expect(tapped, isTrue);
    });

    // ── Theme token tests ───────────────────────────────────────────────────
    testWidgets('knob is white (AppPrimitives.skyWhite)', (tester) async {
      await tester.pumpWidget(testApp(const TogglePill(isOn: true)));

      // The knob is the inner Container with BoxDecoration circle shape
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final knob = containers.where((c) {
        final d = c.decoration;
        return d is BoxDecoration &&
            d.shape == BoxShape.circle &&
            d.color == AppPrimitives.skyWhite;
      });
      expect(knob.isNotEmpty, isTrue,
          reason: 'Knob should use AppPrimitives.skyWhite');
    });

    testWidgets('uses AppRadiiTokens.borderRadiusFull for track',
        (tester) async {
      await tester.pumpWidget(testApp(const TogglePill(isOn: true)));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, AppRadiiTokens.borderRadiusFull);
    });

    testWidgets('does not use hardcoded chocolate color', (tester) async {
      await tester.pumpWidget(testApp(const TogglePill(isOn: true)));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      // Chocolate was Color(0xFF402A24) — should no longer be used
      expect(decoration.color, isNot(const Color(0xFF402A24)));
    });
  });
}
