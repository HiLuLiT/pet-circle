import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/widgets/avatar_stack.dart';

import 'dart:io';

import '../helpers/test_app.dart';
import '../helpers/test_http_overrides.dart';

CareCircleMember _member(String name, {String avatarUrl = ''}) {
  return CareCircleMember(
    name: name,
    avatarUrl: avatarUrl,
    role: CareCircleRole.member,
  );
}

void main() {
  // Note: no MockHttpOverrides here on purpose — the error-fallback test relies
  // on real network image loads failing in the test environment so the
  // errorBuilder fires. All other tests use empty URLs (no network).
  group('AvatarStack', () {
    testWidgets('renders nothing for an empty list', (tester) async {
      await tester.pumpWidget(testApp(
        const AvatarStack(avatars: []),
      ));

      expect(find.byType(AvatarStack), findsOneWidget);
      // No images and no initials text should be rendered.
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders one circle per member', (tester) async {
      await tester.pumpWidget(testApp(
        AvatarStack(avatars: [
          _member('Alice Smith'),
          _member('Bob Jones'),
          _member('Cara Lee'),
        ]),
      ));

      // Empty URLs -> initials fallback for each member.
      expect(find.text('AS'), findsOneWidget);
      expect(find.text('BJ'), findsOneWidget);
      expect(find.text('CL'), findsOneWidget);
    });

    testWidgets('empty avatarUrl falls back to initials (no network image)',
        (tester) async {
      await tester.pumpWidget(testApp(
        AvatarStack(avatars: [_member('Dana Park', avatarUrl: '')]),
      ));

      expect(find.text('DP'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('single-word name uses first letter', (tester) async {
      await tester.pumpWidget(testApp(
        AvatarStack(avatars: [_member('Madonna')]),
      ));

      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('blank name falls back to "?"', (tester) async {
      await tester.pumpWidget(testApp(
        AvatarStack(avatars: [_member('   ')]),
      ));

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('network image error falls back to initials placeholder',
        (tester) async {
      // Install a failing HTTP layer so the network load fails
      // deterministically (no reliance on real-network flakiness), making the
      // errorBuilder fire and render the neutral initials fallback.
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);
      HttpOverrides.global = FailingHttpOverrides();

      try {
        await tester.pumpWidget(testApp(
          AvatarStack(avatars: [
            _member('Erin Cole', avatarUrl: 'https://example.com/a.jpg'),
          ]),
        ));
        await tester.pumpAndSettle();
      } finally {
        HttpOverrides.global = null;
        FlutterError.onError = oldHandler;
      }

      // The URL path was taken (Image.network is in the tree) ...
      expect(find.byType(Image), findsOneWidget);
      // ... and the errorBuilder rendered the initials fallback.
      expect(find.text('EC'), findsOneWidget);
    });

    testWidgets('left and right alignment both render', (tester) async {
      await tester.pumpWidget(testApp(
        Column(
          children: [
            AvatarStack(
              avatars: [_member('Ann Bell')],
              alignment: AvatarStackAlignment.left,
            ),
            AvatarStack(
              avatars: [_member('Cy Dorn')],
              alignment: AvatarStackAlignment.right,
            ),
          ],
        ),
      ));

      expect(find.text('AB'), findsOneWidget);
      expect(find.text('CD'), findsOneWidget);
    });

    testWidgets('highlightFirst renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        AvatarStack(
          avatars: [_member('Fay Glen'), _member('Hal Iver')],
          avatarSize: 32,
          alignment: AvatarStackAlignment.left,
          highlightFirst: true,
        ),
      ));

      expect(find.byType(AvatarStack), findsOneWidget);
      expect(find.text('FG'), findsOneWidget);
      expect(find.text('HI'), findsOneWidget);
    });
  });
}
