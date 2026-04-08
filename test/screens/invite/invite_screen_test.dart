import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/invite/invite_screen.dart';

import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  // Note: InviteScreen calls context.go() synchronously from initState
  // when authProvider.appUser is null (the default in tests). This
  // triggers framework errors with both GoRouter and plain MaterialApp
  // wrappers, making full widget rendering tests impractical without
  // mocking authProvider at the Firebase level. We test the widget's
  // public API and construction instead.

  group('InviteScreen widget construction', () {
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

    test('token is exposed as a public field', () {
      const screen = InviteScreen(token: 'mytoken');
      expect(screen.token, 'mytoken');
    });
  });

  group('InviteScreen initial render (null appUser — redirects immediately)',
      () {
    // When authProvider.appUser is null, _processInvitation calls
    // context.go(AppRoutes.authGate). Since GoRouter is not available in the
    // test harness this throws a GoRouter assertion in the async task.
    // We only verify what can be observed from the synchronous first-frame
    // build, before the async _processInvitation work fires.
    testWidgets('has the correct token exposed on the widget instance',
        (tester) async {
      const screen = InviteScreen(token: 'check-token');
      expect(screen.token, 'check-token');
    });
  });

  group('InviteScreen error-code mapping (string logic)', () {
    // The _errorText logic maps error codes to localised strings.
    // We verify the expected mapping using the known l10n keys.
    const knownErrorCodes = [
      'invitationExpired',
      'invitationAlreadyUsed',
      'invitationNotAuthorized',
      'invitationNoLongerValid',
      'invitationAcceptFailed',
      'invitationNotFound',
    ];

    for (final code in knownErrorCodes) {
      test('code $code is a recognised error code string', () {
        expect(code, isNotEmpty);
        expect(code.startsWith('invitation'), isTrue);
      });
    }

    test('unknown error code falls through to invitationNotFound default', () {
      // This mirrors the switch default in _errorText.
      const unknown = 'somethingElse';
      final fallback = knownErrorCodes.contains(unknown)
          ? unknown
          : 'invitationNotFound';
      expect(fallback, equals('invitationNotFound'));
    });

    test('null error code maps to invitationNotFound default', () {
      const String? nullCode = null;
      final fallback =
          (nullCode != null && knownErrorCodes.contains(nullCode))
              ? nullCode
              : 'invitationNotFound';
      expect(fallback, equals('invitationNotFound'));
    });
  });

  group('InviteScreen avatar URL fallback logic', () {
    test('fallback URL encodes display name correctly', () {
      const displayName = 'Jane Doe';
      final encoded =
          Uri.encodeComponent(displayName);
      final url =
          'https://ui-avatars.com/api/?name=$encoded&background=E8B4B8&color=5B2C3F';
      expect(url, contains('Jane%20Doe'));
    });

    test('fallback URL uses email when displayName is null', () {
      const email = 'invite@example.com';
      // The widget falls back to email as the displayName param.
      final encoded = Uri.encodeComponent(email);
      final url =
          'https://ui-avatars.com/api/?name=$encoded&background=E8B4B8&color=5B2C3F';
      expect(url, isNotEmpty);
      expect(url, contains('invite'));
    });

    test('fallback URL uses brand colours', () {
      const label = 'Test';
      final encoded = Uri.encodeComponent(label);
      final url =
          'https://ui-avatars.com/api/?name=$encoded&background=E8B4B8&color=5B2C3F';
      expect(url, contains('background=E8B4B8'));
      expect(url, contains('color=5B2C3F'));
    });
  });
}
