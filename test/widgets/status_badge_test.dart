import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/status_badge.dart';

import '../helpers/test_app.dart';

void main() {
  group('StatusBadge', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'OK', color: AppPrimitives.greenBase),
      ));
      expect(find.byType(StatusBadge), findsOneWidget);
    });

    // ── Variant tests (different status colors) ─────────────────────────────
    testWidgets('renders with success color', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Normal', color: AppPrimitives.greenBase),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppPrimitives.greenBase);
    });

    testWidgets('renders with warning color', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(
            label: 'Elevated', color: AppPrimitives.yellowLightest),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppPrimitives.yellowLightest);
    });

    testWidgets('renders with error color', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Critical', color: AppPrimitives.redBase),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppPrimitives.redBase);
    });

    // ── State tests (label text) ────────────────────────────────────────────
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Active', color: AppPrimitives.primaryBase),
      ));
      expect(find.text('Active'), findsOneWidget);
    });

    // ── Interaction test (badge is non-interactive) ─────────────────────────
    testWidgets('is non-interactive (no InkWell or GestureDetector)',
        (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Test', color: AppPrimitives.blueBase),
      ));
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });

    // ── Theme token tests ───────────────────────────────────────────────────
    testWidgets('uses AppSemanticTextStyles.labelSm', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Token', color: AppPrimitives.primaryBase),
      ));

      final text = tester.widget<Text>(find.text('Token'));
      expect(text.style?.fontSize, AppSemanticTextStyles.labelSm.fontSize);
      expect(text.style?.fontWeight, AppSemanticTextStyles.labelSm.fontWeight);
    });

    testWidgets('uses full border radius (pill)', (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Pill', color: AppPrimitives.primaryBase),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, AppRadiiTokens.borderRadiusFull);
    });

    testWidgets('text color uses onPrimary from semantic colors',
        (tester) async {
      await tester.pumpWidget(testApp(
        const StatusBadge(label: 'Color', color: AppPrimitives.primaryBase),
      ));

      final text = tester.widget<Text>(find.text('Color'));
      expect(text.style?.color, AppSemanticColors.light.onPrimary);
    });
  });
}
