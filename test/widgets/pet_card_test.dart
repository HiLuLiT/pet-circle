import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/widgets/mascot.dart';
import 'package:pet_circle/widgets/pet_card.dart';
import 'package:pet_circle/widgets/status_badge.dart';

import '../helpers/test_app.dart';

void main() {
  group('PetCard', () {
    testWidgets(
      'renders name and subtitle in Neutrals/Ink per Figma 442:8893',
      (tester) async {
        await tester.pumpWidget(
          testApp(
            const PetCard(
              name: 'Princess',
              subtitle: 'Coton de Tulear \u00b7 SPR 31 bpm',
              status: StatusBadgeStatus.active,
              statusLabel: 'Active',
              size: PetCardSize.hero,
              media: Mascot(
                breed: MascotBreed.floppy,
                color: Color(0xFF7E5CE0),
              ),
            ),
          ),
        );

        // The card tile is a fixed light purple, so both lines must be ink
        // (#161616) — not the muted tertiary grey pcLabelMuted defaults to.
        final name = tester.widget<Text>(find.text('Princess'));
        final subtitle = tester.widget<Text>(
          find.text('Coton de Tulear \u00b7 SPR 31 bpm'),
        );
        expect(name.style?.color, AppPrimitives.pcInk);
        expect(subtitle.style?.color, AppPrimitives.pcInk);
        expect(subtitle.style?.color, isNot(AppPrimitives.pcInkTertiary));
      },
    );

    testWidgets('matches every Figma 442:8893 value', (tester) async {
      await tester.pumpWidget(
        testApp(
          const PetCard(
            name: 'Princess',
            subtitle: 'Coton de Tulear \u00b7 SPR 31 bpm',
            status: StatusBadgeStatus.active,
            statusLabel: 'Active',
            size: PetCardSize.hero,
            media: SizedBox(width: 90, height: 90),
          ),
        ),
      );

      // ── Card: bg Candy/Purple/Tile #C3AEF0, radius 16, padding 16 ──
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PetCard),
              matching: find.byType(Container),
            )
            .first,
      );
      final deco = card.decoration! as BoxDecoration;
      expect(deco.color, AppPrimitives.pcPurpleTile);
      expect(deco.borderRadius, BorderRadius.circular(16));
      expect(card.padding, const EdgeInsets.all(16));

      // ── Name: Display/M — 28px w700, lh 36, tracking -0.14, ink ──
      final name = tester.widget<Text>(find.text('Princess')).style!;
      expect(name.fontSize, 28);
      expect(name.fontWeight, FontWeight.w700);
      expect(name.height, closeTo(36 / 28, 0.001));
      expect(name.letterSpacing, closeTo(-0.14, 0.001));
      expect(name.color, AppPrimitives.pcInk);

      // ── Subtitle: Label/M Regular — 14px w400, lh 20, ink ──
      final sub = tester
          .widget<Text>(find.text('Coton de Tulear \u00b7 SPR 31 bpm'))
          .style!;
      expect(sub.fontSize, 14);
      expect(sub.fontWeight, FontWeight.w400);
      expect(sub.height, closeTo(20 / 14, 0.001));
      expect(sub.color, AppPrimitives.pcInk);

      // ── Figma gaps: 4px name->subtitle, 24px pill->row ──
      final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(boxes.where((b) => b.height == 4), isNotEmpty);
      expect(boxes.where((b) => b.height == 24), isNotEmpty);

      // ── Pill: mint tile bg, mint accent text, 13/18 w600, px16 py8 ──
      final pill = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(StatusBadge),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (pill.decoration! as BoxDecoration).color,
        AppPrimitives.pcMintTile,
      );
      expect(
        pill.padding,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
      final pillText = tester.widget<Text>(find.text('Active')).style!;
      expect(pillText.color, AppPrimitives.pcMint);
      expect(pillText.fontSize, 13);
      expect(pillText.fontWeight, FontWeight.w600);
      expect(pillText.height, closeTo(18 / 13, 0.001));
    });

    testWidgets('renders name, subtitle, status label and media', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          const PetCard(
            name: 'Princess',
            subtitle: 'Coton de Tulear · SPR 31 bpm',
            status: StatusBadgeStatus.active,
            statusLabel: 'Active',
            media: Mascot(breed: MascotBreed.floppy, color: Color(0xFF7E5CE0)),
          ),
        ),
      );

      expect(find.text('Princess'), findsOneWidget);
      expect(find.text('Coton de Tulear · SPR 31 bpm'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.byType(Mascot), findsOneWidget);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        testApp(
          PetCard(
            name: 'Buddy',
            subtitle: 'Labrador',
            status: StatusBadgeStatus.normal,
            statusLabel: 'Normal',
            media: const SizedBox.shrink(),
            onTap: () => tapped++,
          ),
        ),
      );

      await tester.tap(find.byType(PetCard));
      await tester.pump();

      expect(tapped, 1);
    });

    testWidgets('fires onLongPress when long-pressed', (tester) async {
      var longPressed = 0;
      await tester.pumpWidget(
        testApp(
          PetCard(
            name: 'Rex',
            subtitle: 'German Shepherd',
            status: StatusBadgeStatus.alert,
            statusLabel: 'Critical',
            media: const SizedBox.shrink(),
            onLongPress: () => longPressed++,
          ),
        ),
      );

      await tester.longPress(find.byType(PetCard));
      await tester.pump();

      expect(longPressed, 1);
    });

    testWidgets('renders footer slot widget', (tester) async {
      await tester.pumpWidget(
        testApp(
          const PetCard(
            name: 'Luna',
            subtitle: 'Poodle',
            status: StatusBadgeStatus.normal,
            statusLabel: 'Normal',
            media: SizedBox.shrink(),
            footer: Text('footer-content'),
          ),
        ),
      );

      expect(find.text('footer-content'), findsOneWidget);
    });

    testWidgets('renders trailing slot widget', (tester) async {
      await tester.pumpWidget(
        testApp(
          const PetCard(
            name: 'Max',
            subtitle: 'Beagle',
            status: StatusBadgeStatus.normal,
            statusLabel: 'Normal',
            media: SizedBox.shrink(),
            trailing: Text('trailing-content'),
          ),
        ),
      );

      expect(find.text('trailing-content'), findsOneWidget);
    });

    testWidgets('is non-interactive (no GestureDetector) when no callbacks', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          const PetCard(
            name: 'Coco',
            subtitle: 'Pug',
            status: StatusBadgeStatus.normal,
            statusLabel: 'Normal',
            media: SizedBox.shrink(),
          ),
        ),
      );

      // The card itself adds no GestureDetector when neither onTap nor
      // onLongPress is supplied.
      expect(
        find.descendant(
          of: find.byType(PetCard),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });
  });
}
