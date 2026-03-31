import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/widgets/primary_button.dart';

import '../helpers/test_app.dart';

void main() {
  group('PrimaryButton', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'OK', onPressed: () {}),
      ));
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    // ── Variant tests ───────────────────────────────────────────────────────
    testWidgets('filled variant renders label text', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Save',
          variant: PrimaryButtonVariant.filled,
          onPressed: () {},
        ),
      ));
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('outlined variant renders label text', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Cancel',
          variant: PrimaryButtonVariant.outlined,
          onPressed: () {},
        ),
      ));
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    // ── State tests ─────────────────────────────────────────────────────────
    testWidgets('disabled button (onPressed: null) does not respond to tap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        const PrimaryButton(label: 'Disabled', onPressed: null),
      ));

      final button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Add', icon: Icons.add, onPressed: () {}),
      ));
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('uses ConstrainedBox with specified minHeight',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Tall', minHeight: 80, onPressed: () {}),
      ));

      final boxes = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .where((cb) => cb.constraints.minHeight == 80.0);
      expect(boxes.isNotEmpty, isTrue);
    });

    testWidgets('full width via SizedBox width: infinity', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Wide', onPressed: () {}),
      ));

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final fullWidth = sizedBoxes.where((sb) => sb.width == double.infinity);
      expect(fullWidth.isNotEmpty, isTrue);
    });

    // ── Interaction test ────────────────────────────────────────────────────
    testWidgets('calls onPressed when tapped', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Tap Me', onPressed: () => callCount++),
      ));

      await tester.tap(find.text('Tap Me'));
      await tester.pump();
      expect(callCount, 1);
    });

    // ── Theme token tests ───────────────────────────────────────────────────
    testWidgets('uses semantic button text style', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Token', onPressed: () {}),
      ));

      final text = tester.widget<Text>(find.text('Token'));
      expect(text.style?.fontSize, AppSemanticTextStyles.button.fontSize);
      expect(text.style?.fontWeight, AppSemanticTextStyles.button.fontWeight);
    });

    testWidgets('default border radius is 48', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Radius', onPressed: () {}),
      ));

      final button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final shape = button.style?.shape?.resolve({}) as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        BorderRadius.circular(48),
      );
    });

    testWidgets('filled variant uses primary bg and onPrimary fg',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Filled',
          variant: PrimaryButtonVariant.filled,
          onPressed: () {},
        ),
      ));

      final button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final bgColor = button.style?.backgroundColor?.resolve({});
      expect(bgColor, AppSemanticColors.light.primary);

      final text = tester.widget<Text>(find.text('Filled'));
      expect(text.style?.color, AppSemanticColors.light.onPrimary);
    });

    testWidgets('outlined variant uses primary for border color',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Outlined',
          variant: PrimaryButtonVariant.outlined,
          onPressed: () {},
        ),
      ));

      final button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final side = button.style?.side?.resolve({});
      expect(side, isNotNull);
      // Border uses primary with alpha
      expect(side!.color.a, closeTo(0.15, 0.01));
    });
  });
}
