import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/settings_row.dart';

import '../helpers/test_app.dart';

void main() {
  group('SettingsRow', () {
    // ── Smoke ─────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const SettingsRow(title: 'Profile'),
      ));
      expect(find.byType(SettingsRow), findsOneWidget);
    });

    // ── Content ───────────────────────────────────────────────────────────
    testWidgets('displays title text', (tester) async {
      await tester.pumpWidget(testApp(
        const SettingsRow(title: 'Notifications'),
      ));
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('displays description when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const SettingsRow(
          title: 'Language',
          description: 'Choose your preferred language',
        ),
      ));
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Choose your preferred language'), findsOneWidget);
    });

    testWidgets('hides description when null', (tester) async {
      await tester.pumpWidget(testApp(
        const SettingsRow(title: 'About'),
      ));
      // Only 1 Text widget (the title) under the SettingsRow
      final texts = find.descendant(
        of: find.byType(SettingsRow),
        matching: find.byType(Text),
      );
      expect(texts, findsOneWidget);
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const SettingsRow(
          title: 'Toggle',
          trailing: Icon(Icons.chevron_right),
        ),
      ));
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    // ── Interaction ───────────────────────────────────────────────────────
    testWidgets('tapping calls onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        SettingsRow(title: 'Account', onTap: () => tapped = true),
      ));

      await tester.tap(find.byType(SettingsRow));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('does not crash when onTap is null', (tester) async {
      await tester.pumpWidget(testApp(
        const SettingsRow(title: 'Info'),
      ));

      await tester.tap(find.byType(SettingsRow));
      await tester.pump();
      // No assertion needed — just verify no crash
    });

    // ── Theme token verification ──────────────────────────────────────────
    testWidgets('title uses body style with textPrimary color',
        (tester) async {
      await tester.pumpWidget(testApp(
        const SettingsRow(title: 'Profile'),
      ));

      final titleWidget = tester.widget<Text>(find.text('Profile'));
      expect(titleWidget.style?.fontSize, AppSemanticTextStyles.body.fontSize);
      expect(titleWidget.style?.color, AppSemanticColors.light.textPrimary);
    });

    testWidgets('description uses bodySm style with textSecondary color',
        (tester) async {
      await tester.pumpWidget(testApp(
        const SettingsRow(
          title: 'Theme',
          description: 'Light mode',
        ),
      ));

      final descWidget = tester.widget<Text>(find.text('Light mode'));
      expect(descWidget.style?.fontSize, AppSemanticTextStyles.bodySm.fontSize);
      expect(descWidget.style?.color, AppSemanticColors.light.textSecondary);
    });

    testWidgets('container uses surface color and lg radius', (tester) async {
      await tester.pumpWidget(testApp(
        const SettingsRow(title: 'Test'),
      ));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SettingsRow),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.surface);
      expect(
        decoration.borderRadius,
        BorderRadius.circular(AppRadiiTokens.lg),
      );
    });
  });
}
