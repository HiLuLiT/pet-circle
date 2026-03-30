import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/screens/auth/auth_gate.dart';
import 'package:pet_circle/screens/auth/auth_screen.dart';
import 'package:pet_circle/screens/auth/role_selection_screen.dart';
import 'package:pet_circle/screens/auth/verify_email_screen.dart';
import 'package:pet_circle/screens/dashboard/vet_dashboard.dart';
import 'package:pet_circle/screens/invite/invite_screen.dart';
import 'package:pet_circle/screens/main_shell.dart';
import 'package:pet_circle/screens/onboarding/onboarding_flow.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_screen.dart';
import 'package:pet_circle/screens/welcome_screen.dart';
import 'package:pet_circle/services/deep_link_service.dart';
import 'package:pet_circle/stores/pet_store.dart';

/// Named path constants for use with context.go() / context.push().
class AppRoutes {
  static const welcome = '/';
  static const authGate = '/auth-gate';
  static const roleSelection = '/role-selection';
  static const auth = '/auth';
  static const verifyEmail = '/verify-email';
  static const onboarding = '/onboarding';
  static const invite = '/invite';
  static const vetDashboard = '/vet-dashboard';

  /// Build shell path for a given role and optional tab index.
  static String shell(AppUserRole role, {int tab = 0}) {
    if (tab == 0) return '/shell/${role.name}';
    return '/shell/${role.name}?tab=$tab';
  }

  /// Build pet detail path.
  static String petDetail(AppUserRole role, String petId) =>
      '/shell/${role.name}/pet/$petId';
}

/// Parse an [AppUserRole] from a URL path segment.
AppUserRole parseRole(String? roleStr) {
  if (roleStr == 'vet') return AppUserRole.vet;
  return AppUserRole.owner;
}

/// Build the application [GoRouter].
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: kEnableFirebase ? AppRoutes.authGate : AppRoutes.welcome,
    observers: kEnableFirebase
        ? [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)]
        : [],
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth-gate',
        builder: (_, _) => const AuthGate(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (_, _) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, state) {
          final roleStr = state.uri.queryParameters['role'];
          final signIn =
              state.uri.queryParameters['signIn'] == 'true';
          final role = roleStr != null ? parseRole(roleStr) : null;
          return AuthScreen(role: role, startWithSignIn: signIn);
        },
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingFlow(),
      ),
      GoRoute(
        path: '/invite',
        builder: (_, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return InviteScreen(token: token);
        },
        redirect: (context, state) {
          final token = state.uri.queryParameters['token'];
          if (token == null || token.isEmpty) {
            // No token — redirect to the auth gate / welcome.
            return kEnableFirebase ? AppRoutes.authGate : AppRoutes.welcome;
          }
          if (authProvider.routeState != AuthRouteState.authenticated) {
            // Not logged in — stash the token for after authentication.
            deepLinkService.setPendingToken(token);
            return AppRoutes.authGate;
          }
          // Authenticated with valid token — render InviteScreen.
          return null;
        },
      ),
      GoRoute(
        path: '/vet-dashboard',
        builder: (_, _) => const VetDashboard(),
      ),
      GoRoute(
        path: '/shell/:role',
        builder: (_, state) {
          final role = parseRole(state.pathParameters['role']);
          final tabStr = state.uri.queryParameters['tab'];
          final tabIndex = int.tryParse(tabStr ?? '') ?? 0;
          return MainShell(role: role, initialIndex: tabIndex);
        },
        routes: [
          GoRoute(
            path: 'pet/:petId',
            builder: (_, state) {
              final petId = state.pathParameters['petId'] ?? '';
              final pet = petStore.getPetById(petId);
              if (pet == null) {
                return const Scaffold(
                  body: Center(child: Text('Pet not found')),
                );
              }
              return PetDetailScreen(pet: pet);
            },
          ),
        ],
      ),
    ],
  );
}
