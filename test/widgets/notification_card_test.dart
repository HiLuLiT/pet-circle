import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/notification_card.dart';

import '../helpers/test_app.dart';

void main() {
  group('NotificationCard', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders title, body, and time', (tester) async {
      await tester.pumpWidget(testApp(
        const NotificationCard(
          icon: Icon(Icons.notifications),
          iconTileColor: Color(0xFFC3AEF0),
          title: 'New measurement',
          body: 'Buddy logged a reading of 22 BrPM',
          time: '2m ago',
        ),
      ));

      expect(find.byType(NotificationCard), findsOneWidget);
      expect(find.text('New measurement'), findsOneWidget);
      expect(find.text('Buddy logged a reading of 22 BrPM'), findsOneWidget);
      expect(find.text('2m ago'), findsOneWidget);
    });

    // ── Unread variant ──────────────────────────────────────────────────────
    testWidgets('unread variant shows purple dot', (tester) async {
      await tester.pumpWidget(testApp(
        const NotificationCard(
          icon: Icon(Icons.circle),
          iconTileColor: Color(0xFFC3AEF0),
          title: 'Unread title',
          body: 'Unread body',
          time: 'now',
          unread: true,
        ),
      ));

      expect(
        find.byKey(const ValueKey('notification_card.unread_dot')),
        findsOneWidget,
      );
    });

    testWidgets('unread variant uses surface background', (tester) async {
      await tester.pumpWidget(testApp(
        const NotificationCard(
          icon: Icon(Icons.circle),
          iconTileColor: Color(0xFFC3AEF0),
          title: 'Unread title',
          body: 'Unread body',
          time: 'now',
          unread: true,
        ),
      ));

      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(NotificationCard),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = card.decoration as BoxDecoration;
      expect(decoration.color, AppSemanticColors.light.surface);
      expect(
        decoration.borderRadius,
        BorderRadius.circular(AppRadiiTokens.pcCard),
      );
    });

    // ── Read variant ────────────────────────────────────────────────────────
    testWidgets('read variant does not show purple dot', (tester) async {
      await tester.pumpWidget(testApp(
        const NotificationCard(
          icon: Icon(Icons.circle),
          iconTileColor: Color(0xFFC3AEF0),
          title: 'Read title',
          body: 'Read body',
          time: '1d ago',
        ),
      ));

      expect(
        find.byKey(const ValueKey('notification_card.unread_dot')),
        findsNothing,
      );
    });

    testWidgets('read variant uses warm recessed background', (tester) async {
      await tester.pumpWidget(testApp(
        const NotificationCard(
          icon: Icon(Icons.circle),
          iconTileColor: Color(0xFFC3AEF0),
          title: 'Read title',
          body: 'Read body',
          time: '1d ago',
        ),
      ));

      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(NotificationCard),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = card.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFEFEADF));
    });

    testWidgets('read variant uses muted title color', (tester) async {
      const tileColor = Color(0xFFC3AEF0);
      await tester.pumpWidget(testApp(
        const NotificationCard(
          icon: Icon(Icons.circle),
          iconTileColor: tileColor,
          title: 'Read title',
          body: 'Read body',
          time: '1d ago',
        ),
      ));

      final titleWidget = tester.widget<Text>(find.text('Read title'));
      expect(titleWidget.style?.color, const Color(0xFF6E6E6E));
    });

    testWidgets('unread variant uses ink title color', (tester) async {
      await tester.pumpWidget(testApp(
        const NotificationCard(
          icon: Icon(Icons.circle),
          iconTileColor: Color(0xFFC3AEF0),
          title: 'Unread title',
          body: 'Unread body',
          time: 'now',
          unread: true,
        ),
      ));

      final titleWidget = tester.widget<Text>(find.text('Unread title'));
      expect(titleWidget.style?.color, AppSemanticColors.light.onSurface);
    });

    // ── Interaction ─────────────────────────────────────────────────────────
    testWidgets('onTap callback fires when tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(testApp(
        NotificationCard(
          icon: const Icon(Icons.circle),
          iconTileColor: const Color(0xFFC3AEF0),
          title: 'Tap me',
          body: 'body',
          time: 'now',
          onTap: () => taps++,
        ),
      ));

      await tester.tap(find.byType(NotificationCard));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('without onTap, no InkWell is rendered', (tester) async {
      await tester.pumpWidget(testApp(
        const NotificationCard(
          icon: Icon(Icons.circle),
          iconTileColor: Color(0xFFC3AEF0),
          title: 'No tap',
          body: 'body',
          time: 'now',
        ),
      ));

      expect(find.byType(InkWell), findsNothing);
    });
  });
}
