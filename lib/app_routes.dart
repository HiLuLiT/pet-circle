import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/screens/auth/auth_gate.dart';
import 'package:pet_circle/screens/auth/auth_screen.dart';
import 'package:pet_circle/screens/auth/role_selection_screen.dart';
import 'package:pet_circle/screens/auth/verify_email_screen.dart';
import 'package:pet_circle/screens/dashboard/vet_dashboard.dart';
import 'package:pet_circle/screens/main_shell.dart';
import 'package:pet_circle/screens/onboarding/onboarding_flow.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_screen.dart';
import 'package:pet_circle/screens/welcome_screen.dart';
import 'package:pet_circle/stores/pet_store.dart';

/// Named path constants for use with context.go() / context.push().
class AppRoutes {
  static const welcome = '/';
  static const authGate = '/auth-gate';
  static const roleSelection = '/role-selection';
  static const auth = '/auth';
  static const verifyEmail = '/verify-email';
  static const onboarding = '/onboarding';
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
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth-gate',
        builder: (_, __) => const AuthGate(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (_, __) => const RoleSelectionScreen(),
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
        builder: (_, __) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingFlow(),
      ),
      GoRoute(
        path: '/vet-dashboard',
        builder: (_, __) => const VetDashboard(),
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
