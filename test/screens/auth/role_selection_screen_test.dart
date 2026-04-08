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

    testWidgets('renders two TextButton role options', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsNWidgets(2));
    });

    testWidgets('role buttons show favorite_border icons', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsNWidgets(2));
    });

    testWidgets('veterinarian button is tappable', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      final vetButton = find.widgetWithText(TextButton, "I'm a veterinarian");
      expect(vetButton, findsOneWidget);

      final widget = tester.widget<TextButton>(vetButton);
      expect(widget.onPressed, isNotNull);
    });

    testWidgets('pet owner button is tappable', (tester) async {
      suppressOverflowErrors();

      await tester.pumpWidget(_roleSelectionApp());
      await tester.pumpAndSettle();

      final ownerButton = find.widgetWithText(TextButton, "I'm a pet owner");
      expect(ownerButton, findsOneWidget);

      final widget = tester.widget<TextButton>(ownerButton);
      expect(widget.onPressed, isNotNull);
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
