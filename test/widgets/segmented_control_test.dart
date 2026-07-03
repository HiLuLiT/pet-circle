import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/segmented_control.dart';

import '../helpers/test_app.dart';

void main() {
  group('AppSegmentedControl', () {
    const options = ['Day', 'Week', 'Month'];

    // ── Smoke: renders all options ──────────────────────────────────────────
    testWidgets('renders every option label', (tester) async {
      await tester.pumpWidget(testApp(
        const AppSegmentedControl(options: options, value: 'Day'),
      ));

      for (final opt in options) {
        expect(find.text(opt), findsOneWidget);
      }
      expect(find.byType(AppSegmentedControl), findsOneWidget);
    });

    // ── Outer container uses recessed surface + pcField radius ──────────────
    testWidgets('outer container uses surfaceRecessed and pcField radius',
        (tester) async {
      await tester.pumpWidget(testApp(
        const AppSegmentedControl(options: options, value: 'Day'),
      ));

      // The first Container descendant inside the widget is the outer one.
      final outer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AppSegmentedControl),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = outer.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.surfaceRecessed);
      expect(
        decoration.borderRadius,
        BorderRadius.circular(AppRadiiTokens.pcField),
      );
      expect(AppRadiiTokens.pcField, 14);
    });

    // ── Active segment styling ──────────────────────────────────────────────
    testWidgets(
        'active segment uses surface background and bold text style',
        (tester) async {
      await tester.pumpWidget(testApp(
        const AppSegmentedControl(options: options, value: 'Week'),
      ));

      // Each segment renders its own Container under the GestureDetector.
      // Find the one wrapping the active label.
      final activeContainer = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Week'),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = activeContainer.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.surface);

      final activeText = tester.widget<Text>(find.text('Week'));
      expect(activeText.style?.fontWeight, FontWeight.w700);
      expect(activeText.style?.color, AppSemanticColors.light.onSurface);
      expect(activeText.style?.fontSize, 15);
    });

    // ── Inactive segment styling ────────────────────────────────────────────
    testWidgets(
        'inactive segment is transparent with tertiary text', (tester) async {
      await tester.pumpWidget(testApp(
        const AppSegmentedControl(options: options, value: 'Week'),
      ));

      final inactiveContainer = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Day'),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = inactiveContainer.decoration as BoxDecoration;
      expect(decoration.color, Colors.transparent);

      final inactiveText = tester.widget<Text>(find.text('Day'));
      expect(inactiveText.style?.fontWeight, FontWeight.w600);
      expect(inactiveText.style?.color, AppSemanticColors.light.textTertiary);
      expect(inactiveText.style?.fontSize, 15);
    });

    // ── onChanged fires on tap of inactive segment ──────────────────────────
    testWidgets('tapping an inactive segment fires onChanged with its value',
        (tester) async {
      final calls = <String>[];
      await tester.pumpWidget(testApp(
        AppSegmentedControl(
          options: options,
          value: 'Day',
          onChanged: calls.add,
        ),
      ));

      await tester.tap(find.text('Month'));
      await tester.pump();

      expect(calls, ['Month']);
    });

    // ── Tapping the active segment is a no-op ───────────────────────────────
    testWidgets('tapping the active segment does NOT fire onChanged',
        (tester) async {
      final calls = <String>[];
      await tester.pumpWidget(testApp(
        AppSegmentedControl(
          options: options,
          value: 'Day',
          onChanged: calls.add,
        ),
      ));

      await tester.tap(find.text('Day'));
      await tester.pump();

      expect(calls, isEmpty);
    });

    // ── onChanged == null disables interaction without crashing ─────────────
    testWidgets('renders without onChanged and ignores taps', (tester) async {
      await tester.pumpWidget(testApp(
        const AppSegmentedControl(options: options, value: 'Day'),
      ));

      await tester.tap(find.text('Week'));
      await tester.pump();
      // No exception means success — also still rendered.
      expect(find.byType(AppSegmentedControl), findsOneWidget);
    });
  });
}
