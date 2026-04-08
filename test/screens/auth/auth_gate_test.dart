import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/auth/auth_gate.dart';

import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('AuthGate widget', () {
    testWidgets('renders a Scaffold with a CircularProgressIndicator',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const AuthGate()));
      // Single pump — don't settle, because AuthGate schedules a
      // post-frame navigation callback that needs GoRouter context.
      await tester.pump();

      expect(find.byType(AuthGate), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows a centered loading indicator', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const AuthGate()));
      await tester.pump();

      final center = find.byType(Center);
      expect(center, findsAtLeastNWidgets(1));
    });

    testWidgets('is a StatefulWidget', (tester) async {
      suppressOverflowErrors();

      const gate = AuthGate();
      expect(gate, isA<StatefulWidget>());
    });

    testWidgets('can be constructed with a key', (tester) async {
      suppressOverflowErrors();

      const key = ValueKey('auth_gate');
      const gate = AuthGate(key: key);
      expect(gate.key, equals(key));
    });

    testWidgets('scaffold background is not transparent', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(testApp(const AuthGate()));
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      // Background color is set from theme — should not be null
      expect(scaffold.backgroundColor, isNotNull);
    });
  });
}
