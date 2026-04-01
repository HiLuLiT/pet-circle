import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/invite/invite_screen.dart';

import '../../helpers/mock_stores.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  // Note: InviteScreen calls context.go() synchronously from initState
  // when authProvider.appUser is null (the default in tests). This
  // triggers framework errors with both GoRouter and plain MaterialApp
  // wrappers, making full widget rendering tests impractical without
  // mocking authProvider at the Firebase level. We test the widget's
  // public API and construction instead.

  group('InviteScreen', () {
    testWidgets('widget constructor stores token', (tester) async {
      const screen = InviteScreen(token: 'abc-123');
      expect(screen.token, equals('abc-123'));
    });

    testWidgets('widget constructor accepts empty token', (tester) async {
      const screen = InviteScreen(token: '');
      expect(screen.token, equals(''));
    });

    testWidgets('is a StatefulWidget', (tester) async {
      const screen = InviteScreen(token: 'test');
      expect(screen, isA<StatefulWidget>());
    });

    testWidgets('different tokens produce distinct widgets', (tester) async {
      const screen1 = InviteScreen(token: 'token-a');
      const screen2 = InviteScreen(token: 'token-b');
      expect(screen1.token, isNot(equals(screen2.token)));
    });

    testWidgets('can be constructed with a key', (tester) async {
      const key = ValueKey('invite');
      const screen = InviteScreen(key: key, token: 'test');
      expect(screen.key, equals(key));
      expect(screen.token, equals('test'));
    });
  });
}
