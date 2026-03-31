import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
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

    testWidgets('displays empty string when value is null', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'Size', value: null, onTap: () {}),
      ));
      // The empty text widget should exist inside the Row
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('shows chevron icon', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'Size', value: null, onTap: () {}),
      ));
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    // ── Interaction test ────────────────────────────────────────────────────
    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'Size', value: 'Small', onTap: () => tapped = true),
      ));

      await tester.tap(find.text('Small'));
      expect(tapped, isTrue);
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

    testWidgets('container uses skyLighter fill', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'L', value: 'V', onTap: () {}),
      ));

      final container = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == AppPrimitives.skyLighter;
        }
        return false;
      });
      expect(container.isNotEmpty, isTrue);
    });

    testWidgets('chevron icon uses textSecondary color', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'L', value: null, onTap: () {}),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.keyboard_arrow_down));
      expect(icon.color, AppSemanticColors.light.textSecondary);
    });

    testWidgets('null value text uses skyDark color', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'L', value: null, onTap: () {}),
      ));

      // When value is null, displayed text is empty string with skyDark color
      final texts = tester.widgetList<Text>(find.byType(Text));
      final valueText = texts.where((t) => t.data == '').firstOrNull;
      expect(valueText?.style?.color, AppPrimitives.skyDark);
    });

    testWidgets('border radius is lg (16)', (tester) async {
      await tester.pumpWidget(testApp(
        AppDropdown(label: 'L', value: 'V', onTap: () {}),
      ));

      final container = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.borderRadius == AppRadiiTokens.borderRadiusLg;
        }
        return false;
      });
      expect(container.isNotEmpty, isTrue);
    });
  });
}
