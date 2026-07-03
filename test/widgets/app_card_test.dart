import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_card.dart';

import '../helpers/test_app.dart';

void main() {
  group('AppCard', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(child: Text('Hello')),
      ));
      expect(find.byType(AppCard), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    // ── Variant: surface ────────────────────────────────────────────────────
    testWidgets('surface variant uses semantic surface color',
        (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(child: Text('Surface')),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.surface);
    });

    // ── Variant: tile (default purple) ──────────────────────────────────────
    testWidgets('tile variant defaults to accentPurpleTile',
        (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(
          variant: AppCardVariant.tile,
          child: Text('Tile'),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.accentPurpleTile);
    });

    // ── Variant: tile with override color ───────────────────────────────────
    testWidgets('tile variant respects tileColor override',
        (tester) async {
      const override = Color(0xFFFFAA00);
      await tester.pumpWidget(testApp(
        const AppCard(
          variant: AppCardVariant.tile,
          tileColor: override,
          child: Text('Custom tile'),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, override);
    });

    // ── tileColor is ignored on surface variant ─────────────────────────────
    testWidgets('surface variant ignores tileColor', (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(
          tileColor: Color(0xFFFFAA00),
          child: Text('Surface ignores tileColor'),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.surface);
    });

    // ── Radius ──────────────────────────────────────────────────────────────
    testWidgets('uses AppRadiiTokens.pcCard (18) for border radius',
        (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(child: Text('Radius')),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.borderRadius,
        BorderRadius.circular(AppRadiiTokens.pcCard),
      );
      expect(AppRadiiTokens.pcCard, 18);
    });

    // ── No shadow (flat) ────────────────────────────────────────────────────
    testWidgets('has no shadow (flat surface)', (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(child: Text('Flat')),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNull);
    });

    // ── Padding defaults ────────────────────────────────────────────────────
    testWidgets('default padding is EdgeInsets.all(16)', (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(child: Text('Default padding')),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      expect(container.padding, const EdgeInsets.all(16));
    });

    testWidgets('accepts custom padding', (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(
          padding: EdgeInsets.all(24),
          child: Text('Padded'),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      expect(container.padding, const EdgeInsets.all(24));
    });

    // ── Child can be null ───────────────────────────────────────────────────
    testWidgets('renders without a child', (tester) async {
      await tester.pumpWidget(testApp(
        const AppCard(),
      ));
      expect(find.byType(AppCard), findsOneWidget);
    });
  });
}
