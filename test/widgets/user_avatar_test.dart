import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/widgets/user_avatar.dart';

import '../helpers/test_app.dart';

void main() {
  group('UserAvatar', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const UserAvatar(name: 'Test User'),
      ));
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    // ── Variant / state tests ──────────────────────────────────────────────
    testWidgets('shows initials for single name', (tester) async {
      await tester.pumpWidget(testApp(
        const UserAvatar(name: 'Alice'),
      ));
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('shows two-letter initials for full name', (tester) async {
      await tester.pumpWidget(testApp(
        const UserAvatar(name: 'John Doe'),
      ));
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('shows ? for empty name', (tester) async {
      await tester.pumpWidget(testApp(
        const UserAvatar(name: ''),
      ));
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('attempts network image when imageUrl starts with http',
        (tester) async {
      // Network images fail in tests (no real HTTP), so the errorBuilder
      // falls back to initials. Verify that Image.network is in the tree
      // (proving the URL path was taken) even though the fallback shows.
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      await tester.pumpWidget(testApp(
        const UserAvatar(
          name: 'Jane Doe',
          imageUrl: 'https://example.com/photo.jpg',
        ),
      ));
      await tester.pump();

      FlutterError.onError = oldHandler;
      // Image.network widget is present in the tree (URL path was taken)
      expect(find.byType(Image), findsOneWidget);
      // The errorBuilder shows initials as fallback in test environment
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('falls back to initials when imageUrl is empty', (tester) async {
      await tester.pumpWidget(testApp(
        const UserAvatar(name: 'Bob Smith', imageUrl: ''),
      ));
      expect(find.text('BS'), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(testApp(
        const UserAvatar(name: 'Test', size: 64),
      ));

      final container = tester.widgetList<Container>(find.byType(Container))
          .where((c) => c.constraints?.maxWidth == 64);
      expect(container.isNotEmpty, isTrue);
    });

    // ── Interaction test ────────────────────────────────────────────────────
    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(testApp(
        UserAvatar(name: 'Tap Me', onTap: () => tapped = true),
      ));

      await tester.tap(find.byType(UserAvatar));
      expect(tapped, isTrue);
    });

    // ── Theme token tests ───────────────────────────────────────────────────
    testWidgets('fallback bg is primaryLight', (tester) async {
      await tester.pumpWidget(testApp(
        const UserAvatar(name: 'AB'),
      ));

      final container = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == AppSemanticColors.light.primaryLight;
        }
        return false;
      });
      expect(container.isNotEmpty, isTrue);
    });

    testWidgets('border color is skyWhite', (tester) async {
      await tester.pumpWidget(testApp(
        const UserAvatar(name: 'AB'),
      ));

      final container = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          final border = decoration.border;
          if (border is Border) {
            return border.top.color == AppPrimitives.skyWhite;
          }
        }
        return false;
      });
      expect(container.isNotEmpty, isTrue);
    });

    testWidgets('initials text color is onPrimary', (tester) async {
      await tester.pumpWidget(testApp(
        const UserAvatar(name: 'Charlie Davis'),
      ));

      final text = tester.widget<Text>(find.text('CD'));
      expect(text.style?.color, AppSemanticColors.light.onPrimary);
    });
  });
}
