import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/widgets/filter_chip.dart';

import '../helpers/test_app.dart';

void main() {
  group('AppFilterChip', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders the label text', (tester) async {
      await tester.pumpWidget(
        testApp(const AppFilterChip(label: 'All')),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.byType(AppFilterChip), findsOneWidget);
    });

    // ── Variant tests ───────────────────────────────────────────────────────
    testWidgets('selected: true uses periwinkle chip background',
        (tester) async {
      await tester.pumpWidget(
        testApp(const AppFilterChip(label: 'Active', selected: true)),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppFilterChip),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.accentPeriwinkleChip);
    });

    testWidgets('selected: false uses recessed surface background',
        (tester) async {
      await tester.pumpWidget(
        testApp(const AppFilterChip(label: 'Inactive')),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppFilterChip),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.surfaceRecessed);
    });

    // ── Interaction tests ───────────────────────────────────────────────────
    testWidgets('fires onTap when tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        testApp(
          AppFilterChip(
            label: 'Tap me',
            onTap: () => tapped += 1,
          ),
        ),
      );

      await tester.tap(find.byType(AppFilterChip));
      await tester.pumpAndSettle();

      expect(tapped, 1);
    });

    testWidgets('does not throw when onTap is null', (tester) async {
      await tester.pumpWidget(
        testApp(const AppFilterChip(label: 'No handler')),
      );

      await tester.tap(find.byType(AppFilterChip));
      await tester.pumpAndSettle();

      expect(find.byType(AppFilterChip), findsOneWidget);
    });
  });
}
