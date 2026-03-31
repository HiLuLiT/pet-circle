import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/widgets/app_header.dart';
import 'package:pet_circle/widgets/user_avatar.dart';

import '../helpers/test_app.dart';

void main() {
  group('AppHeader', () {
    // ── Smoke ─────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const AppHeader(userName: 'Alice'),
      ));
      expect(find.byType(AppHeader), findsOneWidget);
    });

    // ── Avatar ────────────────────────────────────────────────────────────
    testWidgets('renders UserAvatar with provided name', (tester) async {
      await tester.pumpWidget(testApp(
        const AppHeader(userName: 'Bob'),
      ));
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    // ── Pet selector ──────────────────────────────────────────────────────
    testWidgets('shows pet name when petName is provided', (tester) async {
      await tester.pumpWidget(testApp(
        const AppHeader(userName: 'Alice', petName: 'Buddy'),
      ));
      expect(find.text('Buddy'), findsOneWidget);
    });

    testWidgets('hides pet selector when petName is null', (tester) async {
      await tester.pumpWidget(testApp(
        const AppHeader(userName: 'Alice'),
      ));
      expect(find.text('Buddy'), findsNothing);
    });

    testWidgets('shows dropdown icon when onPetSelectorTap is provided',
        (tester) async {
      await tester.pumpWidget(testApp(
        AppHeader(
          userName: 'Alice',
          petName: 'Buddy',
          onPetSelectorTap: () {},
        ),
      ));
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    // ── Notification bell ─────────────────────────────────────────────────
    testWidgets('renders notification icon', (tester) async {
      await tester.pumpWidget(testApp(
        const AppHeader(userName: 'Alice'),
      ));
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    // ── Interaction ───────────────────────────────────────────────────────
    testWidgets('tapping notification bell calls onNotificationTap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        AppHeader(userName: 'Alice', onNotificationTap: () => tapped = true),
      ));

      await tester.tap(find.byIcon(Icons.notifications_none));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('tapping pet selector calls onPetSelectorTap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        AppHeader(
          userName: 'Alice',
          petName: 'Buddy',
          onPetSelectorTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Buddy'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    // ── Theme token verification ──────────────────────────────────────────
    testWidgets('notification bell bg uses skyLight', (tester) async {
      await tester.pumpWidget(testApp(
        const AppHeader(userName: 'Alice'),
      ));

      // Find the decorated container for the bell icon
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
        final dec = c.decoration;
        if (dec is BoxDecoration && dec.shape == BoxShape.circle) {
          return dec.color == AppPrimitives.skyLight;
        }
        return false;
      });
      expect(containers.isNotEmpty, isTrue,
          reason: 'Notification bell should use skyLight background');
    });

    testWidgets('notification icon uses inkDarkest color', (tester) async {
      await tester.pumpWidget(testApp(
        const AppHeader(userName: 'Alice'),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.notifications_none));
      expect(icon.color, AppPrimitives.inkDarkest);
    });
  });
}
