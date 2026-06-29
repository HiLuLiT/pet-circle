import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/widgets/mascot.dart';
import 'package:pet_circle/widgets/pet_card.dart';
import 'package:pet_circle/widgets/status_badge.dart';

import '../helpers/test_app.dart';

void main() {
  group('PetCard', () {
    testWidgets('renders name, subtitle, status label and media',
        (tester) async {
      await tester.pumpWidget(testApp(
        const PetCard(
          name: 'Princess',
          subtitle: 'Coton de Tulear · SPR 31 bpm',
          status: StatusBadgeStatus.active,
          statusLabel: 'Active',
          media: Mascot(breed: MascotBreed.floppy, color: Color(0xFF7E5CE0)),
        ),
      ));

      expect(find.text('Princess'), findsOneWidget);
      expect(find.text('Coton de Tulear · SPR 31 bpm'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.byType(Mascot), findsOneWidget);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(testApp(
        PetCard(
          name: 'Buddy',
          subtitle: 'Labrador',
          status: StatusBadgeStatus.normal,
          statusLabel: 'Normal',
          media: const SizedBox.shrink(),
          onTap: () => tapped++,
        ),
      ));

      await tester.tap(find.byType(PetCard));
      await tester.pump();

      expect(tapped, 1);
    });

    testWidgets('fires onLongPress when long-pressed', (tester) async {
      var longPressed = 0;
      await tester.pumpWidget(testApp(
        PetCard(
          name: 'Rex',
          subtitle: 'German Shepherd',
          status: StatusBadgeStatus.alert,
          statusLabel: 'Critical',
          media: const SizedBox.shrink(),
          onLongPress: () => longPressed++,
        ),
      ));

      await tester.longPress(find.byType(PetCard));
      await tester.pump();

      expect(longPressed, 1);
    });

    testWidgets('renders footer slot widget', (tester) async {
      await tester.pumpWidget(testApp(
        const PetCard(
          name: 'Luna',
          subtitle: 'Poodle',
          status: StatusBadgeStatus.normal,
          statusLabel: 'Normal',
          media: SizedBox.shrink(),
          footer: Text('footer-content'),
        ),
      ));

      expect(find.text('footer-content'), findsOneWidget);
    });

    testWidgets('renders trailing slot widget', (tester) async {
      await tester.pumpWidget(testApp(
        const PetCard(
          name: 'Max',
          subtitle: 'Beagle',
          status: StatusBadgeStatus.normal,
          statusLabel: 'Normal',
          media: SizedBox.shrink(),
          trailing: Text('trailing-content'),
        ),
      ));

      expect(find.text('trailing-content'), findsOneWidget);
    });

    testWidgets('is non-interactive (no GestureDetector) when no callbacks',
        (tester) async {
      await tester.pumpWidget(testApp(
        const PetCard(
          name: 'Coco',
          subtitle: 'Pug',
          status: StatusBadgeStatus.normal,
          statusLabel: 'Normal',
          media: SizedBox.shrink(),
        ),
      ));

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
