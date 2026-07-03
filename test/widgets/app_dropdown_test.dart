import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_dropdown.dart';

import '../helpers/test_app.dart';

void main() {
  group('AppDropdown', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'Size', value: null, onTap: () {}),
      ));
      expect(find.byType(AppDropdown), findsOneWidget);
    });

    // ── Variant / state tests ──────────────────────────────────────────────
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'Breed', value: null, onTap: () {}),
      ));
      expect(find.text('Breed'), findsOneWidget);
    });

    testWidgets('displays selected value', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'Size', value: 'Large', onTap: () {}),
      ));
      expect(find.text('Large'), findsOneWidget);
    });

    testWidgets('displays placeholder when value is null', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(
          label: 'Size',
          value: null,
          placeholder: 'Choose…',
          onTap: () {},
        ),
      ));
      expect(find.text('Choose…'), findsOneWidget);
    });

    testWidgets('shows chevron-down icon when closed', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'Size', value: null, onTap: () {}),
      ));
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('shows chevron-up icon when open', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(
          label: 'Size',
          value: 'Small',
          isOpen: true,
          onTap: () {},
        ),
      ));
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    });

    // ── Interaction tests ───────────────────────────────────────────────────
    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'Size', value: 'Small', onTap: () => tapped = true),
      ));

      await tester.tap(find.text('Small'));
      expect(tapped, isTrue);
    });

    testWidgets('renders option list when open with options', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(
          label: 'Size',
          value: 'Medium',
          isOpen: true,
          options: const ['Small', 'Medium', 'Large'],
          onTap: () {},
          onOptionSelected: (_) {},
        ),
      ));
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsWidgets); // trigger + option
      expect(find.text('Large'), findsOneWidget);
    });

    testWidgets(
      'does not render option list when closed',
      (tester) async {
        await tester.pumpWidget(testApp(
          AppDropdown(
            label: 'Size',
            value: null,
            options: const ['Small', 'Medium', 'Large'],
            onTap: () {},
          ),
        ));
        expect(find.text('Small'), findsNothing);
        expect(find.text('Large'), findsNothing);
      },
    );

    testWidgets('calls onOptionSelected when option tapped', (tester) async {
      String? picked;
      await tester.pumpWidget(testApp(
        AppDropdown(
          label: 'Size',
          value: null,
          isOpen: true,
          options: const ['Small', 'Medium', 'Large'],
          onTap: () {},
          onOptionSelected: (v) => picked = v,
        ),
      ));

      await tester.tap(find.text('Large'));
      expect(picked, 'Large');
    });

    // ── Theme token tests ───────────────────────────────────────────────────
    testWidgets('label uses semantic labelSm style', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'MyLabel', value: null, onTap: () {}),
      ));

      final label = tester.widget<Text>(find.text('MyLabel'));
      expect(label.style?.fontSize, AppSemanticTextStyles.labelSm.fontSize);
      expect(label.style?.fontWeight, AppSemanticTextStyles.labelSm.fontWeight);
    });

    testWidgets('trigger uses surface fill (pc v3)', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'L', value: 'V', onTap: () {}),
      ));

      final surfaceColor = AppSemanticColors.light.surface;
      final hit = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.color == surfaceColor;
      });
      expect(hit.isNotEmpty, isTrue);
    });

    testWidgets('chevron icon uses textSecondary color', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'L', value: null, onTap: () {}),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.keyboard_arrow_down));
      expect(icon.color, AppSemanticColors.light.textSecondary);
    });

    testWidgets('placeholder text uses textTertiary color', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(
          label: 'L',
          value: null,
          placeholder: 'Pick one',
          onTap: () {},
        ),
      ));

      final text = tester.widget<Text>(find.text('Pick one'));
      expect(text.style?.color, AppSemanticColors.light.textTertiary);
    });

    testWidgets('selected value text uses onSurface color', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'L', value: 'Picked', onTap: () {}),
      ));

      final text = tester.widget<Text>(find.text('Picked'));
      expect(text.style?.color, AppSemanticColors.light.onSurface);
    });

    testWidgets('trigger border radius is pcField (14)', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'L', value: 'V', onTap: () {}),
      ));

      final hit = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
        final d = c.decoration;
        return d is BoxDecoration &&
            d.borderRadius == AppRadiiTokens.borderRadiusField;
      });
      expect(hit.isNotEmpty, isTrue);
    });

    testWidgets(
      'selected option uses accentPeriwinkleChip background',
      (tester) async {
        await tester.pumpWidget(testApp(
          AppDropdown(
            label: 'L',
            value: 'Medium',
            isOpen: true,
            options: const ['Small', 'Medium', 'Large'],
            onTap: () {},
            onOptionSelected: (_) {},
          ),
        ));

        final chipColor = AppSemanticColors.light.accentPeriwinkleChip;
        final hit = tester
            .widgetList<Container>(find.byType(Container))
            .where((c) {
          final d = c.decoration;
          return d is BoxDecoration && d.color == chipColor;
        });
        expect(hit.isNotEmpty, isTrue);
      },
    );
  });
}
