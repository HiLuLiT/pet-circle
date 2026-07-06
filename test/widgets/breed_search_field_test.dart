import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
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

    testWidgets('shows placeholder hint when no selection', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed'),
      ));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.hintText, 'e.g., Golden Retriever');
      expect(field.controller?.text, '');
    });

    testWidgets('shows initial value when provided', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed', initialValue: 'Beagle'),
      ));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, 'Beagle');
    });

    // ── Interaction: field itself is the searchable input ──────────────────
    testWidgets('tapping the field opens the option list', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed'),
      ));

      // Initially closed — no options rendered.
      expect(find.text('Akita'), findsNothing);
      // No nested search input should ever exist — only the one trigger field.
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Option list appears; still exactly one TextField (the trigger itself).
      expect(find.text('Akita'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('shows a 2px primary focus ring only while focused',
        (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed'),
      ));

      Container triggerContainer() => tester.widget<Container>(
            find.ancestor(
              of: find.byType(TextField),
              matching: find.byType(Container),
            ).first,
          );

      // Idle: border reserved (no layout shift on focus) but transparent.
      final idleDecoration = triggerContainer().decoration as BoxDecoration;
      expect(idleDecoration.border, isNotNull);
      expect(
        (idleDecoration.border as Border).top.color,
        Colors.transparent,
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final focusedDecoration = triggerContainer().decoration as BoxDecoration;
      final borderSide = (focusedDecoration.border as Border).top;
      expect(borderSide.color, AppSemanticColors.light.primary);
      expect(borderSide.width, 2);
    });

    testWidgets('selecting a breed calls onChanged, fills the field, and closes the list',
        (tester) async {
      String? selected;
      await tester.pumpWidget(testApp(
        BreedSearchField(
          label: 'Breed',
          onChanged: (v) => selected = v,
        ),
      ));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Akita'));
      await tester.pumpAndSettle();

      expect(selected, 'Akita');
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, 'Akita');
      // List closed — other breeds no longer rendered.
      expect(find.text('Affenpinscher'), findsNothing);
    });

    testWidgets('typing directly in the field filters the option list',
        (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed'),
      ));

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'beagle');
      await tester.pumpAndSettle();

      // Beagle should be visible; a non-matching breed should not.
      expect(find.text('Beagle'), findsOneWidget);
      expect(find.text('Akita'), findsNothing);
      // Filtering happens in the trigger field itself — no nested search box.
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('tapping outside closes the option list', (tester) async {
      await tester.pumpWidget(testApp(
        Column(
          children: [
            const BreedSearchField(label: 'Breed'),
            Container(key: const Key('outside'), height: 40, color: Colors.transparent),
          ],
        ),
      ));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('Akita'), findsOneWidget);

      await tester.tap(find.byKey(const Key('outside')));
      await tester.pumpAndSettle();
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

    testWidgets('trigger container uses the DS Input surface fill', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed'),
      ));

      // DS alignment: the trigger matches the shared "Input" component (white
      // surface, not the recessed-grey chip look) so it's visually consistent
      // with the other onboarding step 1 fields.
      final containers = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == AppSemanticColors.light.surface;
        }
        return false;
      });
      expect(containers.isNotEmpty, isTrue);
    });

    testWidgets('selected breed highlight uses accentPurpleTile', (tester) async {
      await tester.pumpWidget(testApp(
        const BreedSearchField(label: 'Breed', initialValue: 'Akita'),
      ));

      // Open the list to see Akita highlighted as the current value.
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // DS alignment (Figma node 510-1220): selected option highlight is the
      // purple tile wash, matching the shared AppDropdown's open-list style.
      final containers = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == AppSemanticColors.light.accentPurpleTile;
        }
        return false;
      });
      expect(containers.isNotEmpty, isTrue);
    });
  });
}
