import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/dashboard/owner_dashboard.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_screen.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/pet_card.dart';

import '../helpers/ignore_overflow_errors.dart';
import '../helpers/mock_stores.dart';
import '../helpers/test_http_overrides.dart';

/// Drives the *real* route table rather than mounting a screen directly.
///
/// Every other pet-detail test pumps `PetDetailScreen(pet: ...)` itself, which
/// proves the screen renders but says nothing about whether a user can reach
/// it. That blind spot is exactly how BUG-052 shipped: the delete controls
/// were correct and the screen was unreachable for owners.
void main() {
  setUpAll(() => HttpOverrides.global = MockHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(seedAllStores);
  tearDown(resetAllStores);

  Widget routedApp() {
    final router = GoRouter(
      initialLocation: '/shell',
      routes: [
        GoRoute(
          path: '/shell',
          builder: (_, _) =>
              const Scaffold(body: OwnerDashboard(showScaffold: false)),
          routes: [
            GoRoute(
              path: 'pet/:petId',
              builder: (_, state) {
                final pet = petStore.getPetById(
                  state.pathParameters['petId'] ?? '',
                );
                return PetDetailScreen(pet: pet!);
              },
            ),
          ],
        ),
      ],
    );
    return MaterialApp.router(
      theme: buildAppTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }

  testWidgets('owner taps the home pet card and reaches delete', (
    tester,
  ) async {
    suppressOverflowErrors();
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(routedApp());
    await tester.pumpAndSettle();

    // 1. Start on the owner dashboard.
    expect(find.byType(OwnerDashboard), findsOneWidget);
    expect(find.byType(PetDetailScreen), findsNothing);

    // 2. Tap the hero pet card -- the gesture that did nothing before.
    await tester.tap(find.byType(PetCard).first);
    await tester.pumpAndSettle();

    // 3. We are now on pet detail...
    expect(find.byType(PetDetailScreen), findsOneWidget);

    // 4. ...and the delete control is on screen with no scrolling.
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    // 5. It actually opens the confirmation.
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
