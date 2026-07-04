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

    testWidgets('label uses 16px / 700 weight for outlined (tertiary) variant',
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
      expect(text.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('filled variant uses purple bg and white fg (DS spec)',
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
      // Light theme primary = pcPurple (#7E5CE0), per DS Button/Primary.
      expect(bgColor, AppPrimitives.pcPurple);

      final text = tester.widget<Text>(find.text('Filled'));
      // Light theme onPrimary = pcSurface (white).
      expect(text.style?.color, AppSemanticColors.light.onPrimary);
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

    testWidgets('outlined variant uses transparent bg, ink border, ink fg',
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
      expect(bgColor, Colors.transparent);

      final side = button.style?.side?.resolve({});
      expect(side, isNotNull);
      expect(side!.color, AppPrimitives.pcInk);
      expect(side.width, 1.0);

      final text = tester.widget<Text>(find.text('Outlined'));
      expect(text.style?.color, AppPrimitives.pcInk);
    });

    // ── Layout spec: ~54h, 32x16 padding ─────────────────────────────────────
    testWidgets('uses DS button padding (32x16) and height 54', (tester) async {
      await tester.pumpWidget(testApp(
        PrimaryButton(label: 'Padded', onPressed: () {}),
      ));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      final padding = button.style?.padding?.resolve({}) as EdgeInsets;
      expect(padding.left, 32);
      expect(padding.right, 32);
      expect(padding.top, 16);
      expect(padding.bottom, 16);

      final fixed = button.style?.fixedSize?.resolve({});
      expect(fixed?.height, 54);
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

    // ── link variant (Figma 442:8683) ────────────────────────────────────────
    group('link variant', () {
      testWidgets('renders label text with no background and no 56h fixedSize',
          (tester) async {
        await tester.pumpWidget(testApp(
          PrimaryButton(
            label: 'Learn more',
            variant: PrimaryButtonVariant.link,
            onPressed: () {},
          ),
        ));

        expect(find.text('Learn more'), findsOneWidget);

        final button = tester.widget<TextButton>(find.byType(TextButton));
        // Transparent background — no filled surface.
        expect(button.style?.backgroundColor?.resolve({}), Colors.transparent);
        // No fixed 56h height (intrinsic sizing).
        expect(button.style?.fixedSize?.resolve({}), isNull);
        // No horizontal padding.
        final padding = button.style?.padding?.resolve({}) as EdgeInsets;
        expect(padding, EdgeInsets.zero);
      });

      testWidgets('label uses SemiBold 14 ink text', (tester) async {
        await tester.pumpWidget(testApp(
          PrimaryButton(
            label: 'Skip',
            variant: PrimaryButtonVariant.link,
            onPressed: () {},
          ),
        ));

        final text = tester.widget<Text>(find.text('Skip'));
        expect(text.style?.fontSize, 14);
        expect(text.style?.fontWeight, FontWeight.w600);
        // Light theme onSurface = pcInk.
        expect(text.style?.color, AppPrimitives.pcInk);
      });

      testWidgets('renders optional leading and trailing icons',
          (tester) async {
        await tester.pumpWidget(testApp(
          PrimaryButton(
            label: 'Next',
            variant: PrimaryButtonVariant.link,
            icon: Icons.arrow_back,
            trailingIcon: const Icon(Icons.arrow_forward),
            onPressed: () {},
          ),
        ));

        expect(find.text('Next'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      });

      testWidgets('is intrinsic (not full-width) by default', (tester) async {
        await tester.pumpWidget(testApp(
          PrimaryButton(
            label: 'Link',
            variant: PrimaryButtonVariant.link,
            onPressed: () {},
          ),
        ));

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final fullWidth = sizedBoxes.where((sb) => sb.width == double.infinity);
        expect(fullWidth.isEmpty, isTrue);
      });
    });

    // ── miniPrimary variant (Figma 474:2550) ─────────────────────────────────
    group('miniPrimary variant', () {
      testWidgets('renders purple bg, white text, and 24x12 padding',
          (tester) async {
        await tester.pumpWidget(testApp(
          PrimaryButton(
            label: 'Done',
            variant: PrimaryButtonVariant.miniPrimary,
            onPressed: () {},
          ),
        ));

        expect(find.text('Done'), findsOneWidget);

        final button = tester.widget<TextButton>(find.byType(TextButton));
        // Light theme primary = pcPurple.
        expect(button.style?.backgroundColor?.resolve({}),
            AppSemanticColors.light.primary);

        // Padding 24 horizontal / 12 vertical.
        final padding = button.style?.padding?.resolve({}) as EdgeInsets;
        expect(padding.left, 24);
        expect(padding.right, 24);
        expect(padding.top, 12);
        expect(padding.bottom, 12);

        // Not the fixed 56h height.
        expect(button.style?.fixedSize?.resolve({}), isNull);

        final text = tester.widget<Text>(find.text('Done'));
        // Light theme onPrimary = pcSurface (white).
        expect(text.style?.color, AppSemanticColors.light.onPrimary);
      });

      testWidgets('label uses SemiBold 14', (tester) async {
        await tester.pumpWidget(testApp(
          PrimaryButton(
            label: 'Save',
            variant: PrimaryButtonVariant.miniPrimary,
            onPressed: () {},
          ),
        ));

        final text = tester.widget<Text>(find.text('Save'));
        expect(text.style?.fontSize, 14);
        expect(text.style?.fontWeight, FontWeight.w600);
      });

      testWidgets('is not full-width by default', (tester) async {
        await tester.pumpWidget(testApp(
          PrimaryButton(
            label: 'Compact',
            variant: PrimaryButtonVariant.miniPrimary,
            onPressed: () {},
          ),
        ));

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final fullWidth = sizedBoxes.where((sb) => sb.width == double.infinity);
        expect(fullWidth.isEmpty, isTrue);
      });

      testWidgets('renders optional trailing icon', (tester) async {
        await tester.pumpWidget(testApp(
          PrimaryButton(
            label: 'Go',
            variant: PrimaryButtonVariant.miniPrimary,
            trailingIcon: const Icon(Icons.chevron_right),
            onPressed: () {},
          ),
        ));

        expect(find.text('Go'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });

      testWidgets('calls onPressed when tapped', (tester) async {
        var callCount = 0;
        await tester.pumpWidget(testApp(
          PrimaryButton(
            label: 'Tap',
            variant: PrimaryButtonVariant.miniPrimary,
            onPressed: () => callCount++,
          ),
        ));

        await tester.tap(find.text('Tap'));
        await tester.pump();
        expect(callCount, 1);
      });

      testWidgets('renders at the spec ~44h, not shrunk by visual density',
          (tester) async {
        // Regression: VisualDensity.compact silently shrank this button to
        // 28h in practice despite the documented 24x12 padding around 20px
        // content (24+12+12=44) — found while aligning the trends screen's
        // Export button height to Figma node 474-2575.
        await tester.pumpWidget(testApp(
          PrimaryButton(
            label: 'Export',
            variant: PrimaryButtonVariant.miniPrimary,
            trailingIcon: const Icon(Icons.file_download_outlined),
            onPressed: () {},
          ),
        ));

        final rect = tester.getRect(find.byType(PrimaryButton));
        expect(rect.height, 44);
      });
    });
  });
}
