import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/breed_search_field.dart';

import '../helpers/test_app.dart';

void main() {
  group('BreedSearchField', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed'),
      ));
      expect(find.byType(BreedSearchField), findsOneWidget);
    });

    // ── Variant / state tests ──────────────────────────────────────────────
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Dog Breed'),
      ));
      expect(find.text('Dog Breed'), findsOneWidget);
    });

    testWidgets('shows placeholder when no selection', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed'),
      ));
      expect(find.text('e.g., Golden Retriever'), findsOneWidget);
    });

    testWidgets('shows initial value when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed', initialValue: 'Beagle'),
      ));
      expect(find.text('Beagle'), findsOneWidget);
    });

    testWidgets('opens search panel on tap', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed'),
      ));

      // Initially no search field
      expect(find.byIcon(Icons.search), findsNothing);

      // Tap the dropdown trigger
      await tester.tap(find.text('e.g., Golden Retriever'));
      await tester.pumpAndSettle();

      // Search field should appear
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    // ── Interaction test ────────────────────────────────────────────────────
    testWidgets('selecting a breed calls onChanged and closes panel',
        (tester) async {
      String? selected;
      await tester.pumpWidget(testApp(
        BreedSearchField(
          label: 'Breed',
          onChanged: (v) => selected = v,
        ),
      ));

      // Open the dropdown
      await tester.tap(find.text('e.g., Golden Retriever'));
      await tester.pumpAndSettle();

      // Tap on a breed (Akita is early in the list, visible without scroll)
      await tester.tap(find.text('Akita'));
      await tester.pumpAndSettle();

      expect(selected, 'Akita');
      // Panel should be closed — search icon gone
      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('filters breeds when typing in search', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed'),
      ));

      // Open
      await tester.tap(find.text('e.g., Golden Retriever'));
      await tester.pumpAndSettle();

      // Type a search query
      await tester.enterText(find.byType(TextField), 'beagle');
      await tester.pumpAndSettle();

      // Beagle should be visible
      expect(find.text('Beagle'), findsOneWidget);
      // Some breed that does not match should not be visible (Akita)
      expect(find.text('Akita'), findsNothing);
    });

    // ── Theme token tests ───────────────────────────────────────────────────
    testWidgets('label uses semantic labelSm style', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed'),
      ));

      final label = tester.widget<Text>(find.text('Breed'));
      expect(label.style?.fontSize, AppSemanticTextStyles.labelSm.fontSize);
      expect(label.style?.fontWeight, AppSemanticTextStyles.labelSm.fontWeight);
    });

    testWidgets('trigger container uses skyLighter fill', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed'),
      ));

      final containers = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == AppPrimitives.skyLighter;
        }
        return false;
      });
      expect(containers.isNotEmpty, isTrue);
    });

    testWidgets('selected breed highlight uses primaryLightest', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed', initialValue: 'Akita'),
      ));

      // Open dropdown to see the list with Akita selected
      await tester.tap(find.text('Akita'));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == AppSemanticColors.light.primaryLightest;
        }
        return false;
      });
      expect(containers.isNotEmpty, isTrue);
    });
  });
}
