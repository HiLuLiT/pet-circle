import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/widgets/dog_photo.dart';

import '../helpers/test_app.dart';

void main() {
  group('DogPhoto', () {
    // ── Smoke ───────────────────────────────────────────────────────────────
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(testApp(
        const DogPhoto(endpoint: ''),
      ));
      expect(find.byType(DogPhoto), findsOneWidget);
    });

    // ── Variant / state tests ──────────────────────────────────────────────
    testWidgets('shows placeholder icon for empty endpoint', (tester) async {
      await tester.pumpWidget(testApp(
        const DogPhoto(endpoint: ''),
      ));
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('shows placeholder for whitespace-only endpoint',
        (tester) async {
      await tester.pumpWidget(testApp(
        const DogPhoto(endpoint: '   '),
      ));
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('non-empty http endpoint does not show placeholder',
        (tester) async {
      // Network images return 400 in tests; silence the expected error.
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      await tester.pumpWidget(testApp(
        const DogPhoto(endpoint: 'https://example.com/dog.jpg'),
      ));
      await tester.pump();

      FlutterError.onError = oldHandler;
      // Should NOT show the empty-endpoint placeholder
      expect(find.byIcon(Icons.pets), findsNothing);
    });

    testWidgets('non-http non-empty endpoint does not show placeholder',
        (tester) async {
      // Asset loading fails in tests; silence the expected error.
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      await tester.pumpWidget(testApp(
        const DogPhoto(endpoint: 'some_local_path'),
      ));
      await tester.pump();

      FlutterError.onError = oldHandler;
      expect(find.byIcon(Icons.pets), findsNothing);
    });

    // ── Theme token tests ───────────────────────────────────────────────────
    testWidgets('placeholder bg uses surface color', (tester) async {
      await tester.pumpWidget(testApp(
        const DogPhoto(endpoint: ''),
      ));

      final container = tester.widgetList<Container>(find.byType(Container))
          .where((c) => c.color == AppSemanticColors.light.surface);
      expect(container.isNotEmpty, isTrue);
    });

    testWidgets('placeholder icon uses textTertiary color', (tester) async {
      await tester.pumpWidget(testApp(
        const DogPhoto(endpoint: ''),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.pets));
      expect(icon.color, AppSemanticColors.light.textTertiary);
    });
  });
}
