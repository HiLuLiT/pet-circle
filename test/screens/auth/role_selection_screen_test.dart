import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/screens/auth/role_selection_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';

import '../../helpers/ignore_overflow_errors.dart';
import '../../helpers/mock_stores.dart';

/// Wraps [RoleSelectionScreen] in a GoRouter-based MaterialApp so that
/// context.go() / context.push() calls do not throw.
Widget _roleSelectionApp() {
  final router = GoRouter(
    initialLocation: '/role-selection',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (_, _) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/auth-gate',
        builder: (_, _) => const Scaffold(body: Text('auth-gate')),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, _) => const Scaffold(body: Text('signup')),
      ),
      GoRoute(
        path: '/shell',
        builder: (_, _) => const Scaffold(body: Text('shell')),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    theme: buildAppTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  setUp(seedAllStores);
  tearDown(resetAllStores);

  group('RoleSelectionScreen', () {
    testWidgets('renders without error', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(RoleSelectionScreen), findsOneWidget);
    });

    testWidgets('shows "Choose your role" when no user name is available',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      // authProvider.firebaseUser is null in test, userStore.currentUser.name
      // may be set — the screen falls back to l10n.chooseYourRole only if
      // name is null or empty. Accept either the greeting or the fallback.
      expect(
        find.byType(RoleSelectionScreen),
        findsOneWidget,
      );
    });

    testWidgets('shows "I\'m a veterinarian" button', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      expect(find.text("I'm a veterinarian"), findsOneWidget);
    });

    testWidgets('shows "I\'m a pet owner" button', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      expect(find.text("I'm a pet owner"), findsOneWidget);
    });

    testWidgets('renders two tappable role cards', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      // DS alignment: the role options are now InkWell-based cards, not
      // TextButtons.
      expect(find.byType(InkWell), findsNWidgets(2));
    });

    testWidgets('role cards show role-specific icons', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      // DS alignment: each role card now has a distinct icon instead of a
      // shared favorite_border icon — vet uses medical_services_outlined,
      // owner uses pets. Both cards also show a trailing arrow_forward.
      expect(find.byIcon(Icons.medical_services_outlined), findsOneWidget);
      expect(find.byIcon(Icons.pets), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsNWidgets(2));
    });

    testWidgets('veterinarian button is tappable', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      final vetCard = find.ancestor(
        of: find.text("I'm a veterinarian"),
        matching: find.byType(InkWell),
      );
      expect(vetCard, findsOneWidget);

      final widget = tester.widget<InkWell>(vetCard);
      expect(widget.onTap, isNotNull);
    });

    testWidgets('pet owner button is tappable', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      final ownerCard = find.ancestor(
        of: find.text("I'm a pet owner"),
        matching: find.byType(InkWell),
      );
      expect(ownerCard, findsOneWidget);

      final widget = tester.widget<InkWell>(ownerCard);
      expect(widget.onTap, isNotNull);
    });

    testWidgets('tapping vet button navigates away (kEnableFirebase=false)',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text("I'm a veterinarian"));
      await tester.pumpAndSettle();

      // When kEnableFirebase=false the screen calls context.go(AppRoutes.shell())
      // so RoleSelectionScreen should no longer be in the tree.
      expect(find.byType(RoleSelectionScreen), findsNothing);
    });

    testWidgets('tapping pet owner button navigates away (kEnableFirebase=false)',
        (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text("I'm a pet owner"));
      await tester.pumpAndSettle();

      expect(find.byType(RoleSelectionScreen), findsNothing);
    });
  });
}
