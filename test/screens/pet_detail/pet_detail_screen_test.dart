import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_screen.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/widgets/status_badge.dart';

import '../../helpers/test_app.dart';
import '../../helpers/mock_stores.dart';

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  Pet testPet() => petStore.ownerPets.first;

  group('PetDetailScreen', () {
    testWidgets('renders without error', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        // Suppress overflow and network image errors in tests.
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) {
          errors.add(details);
          return;
        }
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      await tester.pumpWidget(
        testApp(PetDetailScreen(pet: testPet())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PetDetailScreen), findsOneWidget);
    });

    testWidgets('shows pet name in app bar', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) return;
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      final pet = testPet();
      await tester.pumpWidget(
        testApp(PetDetailScreen(pet: pet)),
      );
      await tester.pumpAndSettle();

      expect(find.text(pet.name), findsOneWidget);
    });

    testWidgets('shows breed and age', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) return;
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      final pet = testPet();
      await tester.pumpWidget(
        testApp(PetDetailScreen(pet: pet)),
      );
      await tester.pumpAndSettle();

      expect(find.text(pet.breedAndAge), findsOneWidget);
    });

    testWidgets('shows status badge', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) return;
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      final pet = testPet();
      await tester.pumpWidget(
        testApp(PetDetailScreen(pet: pet)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text(pet.statusLabel), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('HTTP request failed')) return;
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      await tester.pumpWidget(
        testApp(PetDetailScreen(pet: testPet())),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
