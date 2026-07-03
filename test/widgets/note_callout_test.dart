import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/widgets/note_callout.dart';

import '../helpers/test_app.dart';

void main() {
  group('NoteCallout', () {
    // ── Smoke / content ───────────────────────────────────────────────────
    testWidgets('renders title and body text', (tester) async {
      await tester.pumpWidget(testApp(
        const NoteCallout(
          title: 'Note:',
          body: 'This is a note body.',
        ),
      ));

      expect(find.byType(NoteCallout), findsOneWidget);
      expect(find.text('Note:'), findsOneWidget);
      expect(find.text('This is a note body.'), findsOneWidget);
    });

    // ── Default icon ──────────────────────────────────────────────────────
    testWidgets('renders default info_outline icon', (tester) async {
      await tester.pumpWidget(testApp(
        const NoteCallout(title: 'Note:', body: 'Body'),
      ));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.info_outline);
      expect(icon.size, 24);
    });

    // ── Custom icon ───────────────────────────────────────────────────────
    testWidgets('respects a custom icon', (tester) async {
      await tester.pumpWidget(testApp(
        const NoteCallout(
          title: 'Note:',
          body: 'Body',
          icon: Icons.error_outline,
        ),
      ));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.error_outline);
    });

    // ── Background uses the warm-cream accentButterCream token ──────────────
    testWidgets('uses the accentButterCream (#E8E4D8) background token',
        (tester) async {
      await tester.pumpWidget(testApp(
        const NoteCallout(title: 'Note:', body: 'Body'),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.accentButterCream);
    });

    // ── Radius 12 ───────────────────────────────────────────────────────────
    testWidgets('uses a 12px border radius', (tester) async {
      await tester.pumpWidget(testApp(
        const NoteCallout(title: 'Note:', body: 'Body'),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    // ── Padding 16 ──────────────────────────────────────────────────────────
    testWidgets('uses 16px padding', (tester) async {
      await tester.pumpWidget(testApp(
        const NoteCallout(title: 'Note:', body: 'Body'),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, const EdgeInsets.all(16));
    });

    // ── Flat (no shadow) ──────────────────────────────────────────────────
    testWidgets('has no shadow (flat surface)', (tester) async {
      await tester.pumpWidget(testApp(
        const NoteCallout(title: 'Note:', body: 'Body'),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNull);
    });
  });
}
