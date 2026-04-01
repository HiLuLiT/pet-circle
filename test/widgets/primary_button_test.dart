import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
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
      expect(find.byType(TextButton), findsOneWidget);
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
      expect(find.byType(TextButton), findsOneWidget);
    });

    // ── State tests ─────────────────────────────────────────────────────────
    testWidgets('disabled button (onPressed: null) does not respond to tap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        const PrimaryButton(label: 'Disabled', onPressed: null),
      ));

      final button =
          tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(TextButton));
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

    testWidgets('full width via SizedBox width: infinity', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Wide', onPressed: () {}),
      ));

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final fullWidth = sizedBoxes.where((sb) => sb.width == double.infinity);
      expect(fullWidth.isNotEmpty, isTrue);
    });

    testWidgets('non-fullWidth does not use SizedBox infinity', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Compact', fullWidth: false, onPressed: () {}),
      ));

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final fullWidth = sizedBoxes.where((sb) => sb.width == double.infinity);
      expect(fullWidth.isEmpty, isTrue);
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
          tester.widget<TextButton>(find.byType(TextButton));
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
          tester.widget<TextButton>(find.byType(TextButton));
      final bgColor = button.style?.backgroundColor?.resolve({});
      expect(bgColor, AppSemanticColors.light.primary);

      final text = tester.widget<Text>(find.text('Filled'));
      expect(text.style?.color, AppSemanticColors.light.onPrimary);
    });

    testWidgets('outlined variant uses primary border at full opacity',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Outlined',
          variant: PrimaryButtonVariant.outlined,
          onPressed: () {},
        ),
      ));

      final button =
          tester.widget<TextButton>(find.byType(TextButton));
      final side = button.style?.side?.resolve({});
      expect(side, isNotNull);
      expect(side!.color, AppSemanticColors.light.primary);
    });

    // ── Figma padding spec: px-32 py-16 ─────────────────────────────────────
    testWidgets('uses Figma button padding (horizontal 32, vertical 16)',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Padded', onPressed: () {}),
      ));

      final button =
          tester.widget<TextButton>(find.byType(TextButton));
      final padding = button.style?.padding?.resolve({}) as EdgeInsets;
      expect(padding.left, AppSpacingTokens.xl); // 32
      expect(padding.right, AppSpacingTokens.xl); // 32
      expect(padding.top, AppSpacingTokens.md); // 16
      expect(padding.bottom, AppSpacingTokens.md); // 16
    });

    // ── Custom foreground color ─────────────────────────────────────────────
    testWidgets('foregroundColor overrides default text + border color',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Custom',
          variant: PrimaryButtonVariant.outlined,
          foregroundColor: Colors.red,
          onPressed: () {},
        ),
      ));

      final text = tester.widget<Text>(find.text('Custom'));
      expect(text.style?.color, Colors.red);

      final button = tester.widget<TextButton>(find.byType(TextButton));
      final side = button.style?.side?.resolve({});
      expect(side!.color, Colors.red);
    });

    // ── Trailing icon ───────────────────────────────────────────────────────
    testWidgets('renders trailing icon when provided', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Add',
          variant: PrimaryButtonVariant.outlined,
          fullWidth: false,
          trailingIcon: const Icon(Icons.add_circle_outline, size: 16),
          onPressed: () {},
        ),
      ));

      expect(find.text('Add'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    // ── Figma shrink-0 compliance (no Flutter default inflation) ────────────
    testWidgets('minimumSize is zero and tapTargetSize is shrinkWrap',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Compact', fullWidth: false, onPressed: () {}),
      ));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      final minSize = button.style?.minimumSize?.resolve({});
      expect(minSize, Size.zero);
      expect(button.style?.tapTargetSize, MaterialTapTargetSize.shrinkWrap);
    });

    // ── Child override ──────────────────────────────────────────────────────
    testWidgets('child overrides label content', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          child: const Text('Custom Child'),
          onPressed: () {},
        ),
      ));

      expect(find.text('Custom Child'), findsOneWidget);
    });
  });
}
