import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/screens/auth/auth_gate.dart';
import 'package:pet_circle/screens/auth/check_email_screen.dart';
import 'package:pet_circle/screens/auth/login_screen.dart';
import 'package:pet_circle/screens/auth/role_selection_screen.dart';
import 'package:pet_circle/screens/auth/auth_callback_screen.dart';
import 'package:pet_circle/screens/auth/signup_screen.dart';
import 'package:pet_circle/screens/dashboard/vet_dashboard.dart';
import 'package:pet_circle/screens/invite/invite_screen.dart';
import 'package:pet_circle/screens/main_shell.dart';
import 'package:pet_circle/screens/onboarding/onboarding_flow.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_screen.dart';
import 'package:pet_circle/screens/welcome_screen.dart';
import 'package:pet_circle/services/deep_link_service.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';

/// Named path constants for use with context.go() / context.push().
class AppRoutes {
  static const welcome = '/';
  static const authGate = '/auth-gate';
  static const roleSelection = '/role-selection';
  static const signup = '/signup';
  static const login = '/login';
  static const checkEmail = '/check-email';
  static const authCallback = '/auth/callback';
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

/// Routes that are exempt from the auth-gate redirect (they handle their own
/// auth logic or are public).
const _publicPaths = {'/', '/auth-gate', '/signup', '/login', '/check-email', '/auth/callback', '/role-selection', '/welcome', '/invite', '/onboarding'};

/// Stashed route the user was trying to reach before being bounced to auth-gate.
/// Consumed once by [AuthGate] after successful authentication.
String? _pendingDeepRoute;

/// Read and clear the pending deep route (consumed once).
String? consumePendingDeepRoute() {
  final route = _pendingDeepRoute;
  _pendingDeepRoute = null;
  return route;
}

/// Build the application [GoRouter].
GoRouter buildRouter() {
  // On native platforms there is no URL bar, so always start at the auth gate.
  // On web, the redirect guard handles bouncing to auth-gate when needed, and
  // GoRouter picks up the browser URL automatically via its default '/' initial
  // location — the redirect will stash the deep route before bouncing.
  final initialLoc = kIsWeb
      ? '/'
      : (kEnableFirebase ? AppRoutes.authGate : AppRoutes.welcome);

  return GoRouter(
    initialLocation: initialLoc,
    observers: kEnableFirebase
        ? [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)]
        : [],
    // Re-evaluate redirects whenever auth state changes (e.g. loading → authenticated).
    refreshListenable: kEnableFirebase ? authProvider : null,
    redirect: (context, state) {
      if (!kEnableFirebase) return null;
      final path = state.uri.path;
      final authState = authProvider.routeState;

      // --- Auth-gate exit: when auth resolves, leave auth-gate. ---
      if (path == '/auth-gate' && authState == AuthRouteState.authenticated) {
        // Invitation acceptance is async — let AuthGate handle it.
        if (deepLinkService.pendingInvitationToken != null) return null;

        // Seed stores before leaving.
        final appUser = authProvider.appUser!;
        userStore.seedFromAppUser(appUser);
        if (petStore.currentSubscribedUid != appUser.uid) {
          petStore.subscribeForUser(appUser.uid);
          notificationStore.subscribeForUser(appUser.uid);
        }
        // Restore the URL the user was on before the bounce, or go to default.
        return consumePendingDeepRoute() ?? AppRoutes.shell(appUser.role);
      }

      // Exit auth-gate for needsOnboarding
      if (path == '/auth-gate' && authState == AuthRouteState.needsOnboarding) {
        return AppRoutes.onboarding;
      }

      // Public paths handle their own auth logic.
      if (_publicPaths.contains(path)) return null;

      // --- Protected route guard ---
      if (authState == AuthRouteState.loading ||
          authState != AuthRouteState.authenticated) {
        // Stash the intended destination (only overwrite with a non-auth-gate path).
        _pendingDeepRoute ??= state.uri.toString();
        return AppRoutes.authGate;
      }

      return null;
    },
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
        path: '/signup',
        builder: (_, state) {
          final roleStr = state.uri.queryParameters['role'];
          final role = roleStr != null ? parseRole(roleStr) : null;
          return SignupScreen(role: role);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/check-email',
        builder: (_, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return CheckEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: '/auth/callback',
        builder: (_, _) => const AuthCallbackScreen(),
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
