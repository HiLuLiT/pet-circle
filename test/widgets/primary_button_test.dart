import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
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

    testWidgets('secondary variant renders label text', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Secondary',
          variant: PrimaryButtonVariant.secondary,
          onPressed: () {},
        ),
      ));
      expect(find.text('Secondary'), findsOneWidget);
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

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('disabled button uses spec disabled bg/fg colors',
        (tester) async {
      await tester.pumpWidget(testApp(
        const PrimaryButton(label: 'Disabled', onPressed: null),
      ));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      // Disabled bg matches the React spec (#E2DED5).
      final bg = button.style?.backgroundColor?.resolve({});
      expect(bg, const Color(0xFFE2DED5));

      final text = tester.widget<Text>(find.text('Disabled'));
      expect(text.style?.color, const Color(0xFFA7A2AE));
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
    testWidgets('label uses 16px / 700 weight for filled variant',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Token', onPressed: () {}),
      ));

      final text = tester.widget<Text>(find.text('Token'));
      expect(text.style?.fontSize, 16);
      expect(text.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('label uses 16px / 600 weight for outlined (tertiary) variant',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Tertiary',
          variant: PrimaryButtonVariant.outlined,
          onPressed: () {},
        ),
      ));

      final text = tester.widget<Text>(find.text('Tertiary'));
      expect(text.style?.fontSize, 16);
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('filled variant uses ink bg and white fg (PC v3 spec)',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Filled',
          variant: PrimaryButtonVariant.filled,
          onPressed: () {},
        ),
      ));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      final bgColor = button.style?.backgroundColor?.resolve({});
      // Light theme onSurface = pcInk (#161616).
      expect(bgColor, AppPrimitives.pcInk);

      final text = tester.widget<Text>(find.text('Filled'));
      // Light theme surface = pcSurface (white).
      expect(text.style?.color, AppSemanticColors.light.surface);
    });

    testWidgets('secondary variant uses purpleTile bg and ink fg',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Secondary',
          variant: PrimaryButtonVariant.secondary,
          onPressed: () {},
        ),
      ));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      final bgColor = button.style?.backgroundColor?.resolve({});
      expect(bgColor, AppPrimitives.pcPurpleTile);

      final text = tester.widget<Text>(find.text('Secondary'));
      expect(text.style?.color, AppPrimitives.pcInk);
    });

    testWidgets('outlined variant uses surface bg, hairline border, ink fg',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(
          label: 'Outlined',
          variant: PrimaryButtonVariant.outlined,
          onPressed: () {},
        ),
      ));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      final bgColor = button.style?.backgroundColor?.resolve({});
      expect(bgColor, AppSemanticColors.light.surface);

      final side = button.style?.side?.resolve({});
      expect(side, isNotNull);
      expect(side!.color, AppPrimitives.pcHairline);
      expect(side.width, 1.0);

      final text = tester.widget<Text>(find.text('Outlined'));
      expect(text.style?.color, AppPrimitives.pcInk);
    });

    // ── Layout spec: 56h, 26 horizontal padding ─────────────────────────────
    testWidgets('uses Figma button padding (horizontal 26) and height 56',
        (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Padded', onPressed: () {}),
      ));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      final padding = button.style?.padding?.resolve({}) as EdgeInsets;
      expect(padding.left, 26);
      expect(padding.right, 26);

      final fixed = button.style?.fixedSize?.resolve({});
      expect(fixed?.height, 56);
    });

    // ── Custom foreground color ─────────────────────────────────────────────
    testWidgets('foregroundColor overrides default text color',
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
    testWidgets('tapTargetSize is shrinkWrap', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Compact', fullWidth: false, onPressed: () {}),
      ));

      final button = tester.widget<TextButton>(find.byType(TextButton));
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
