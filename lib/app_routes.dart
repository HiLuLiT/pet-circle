import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/screens/auth/auth_gate.dart';
import 'package:pet_circle/screens/auth/signup_screen.dart';
import 'package:pet_circle/screens/auth/login_screen.dart';
import 'package:pet_circle/screens/auth/verify_otp_screen.dart';
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
  static const signup = '/signup';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const invite = '/invite';
  static const vetDashboard = '/vet-dashboard';

  /// Build shell path with an optional tab index.
  static String shell({int tab = 0}) {
    if (tab == 0) return '/shell';
    return '/shell?tab=$tab';
  }

  /// Build pet detail path.
  static String petDetail(String petId) => '/shell/pet/$petId';
}

/// Routes that are exempt from the auth-gate redirect (they handle their own
/// auth logic or are public).
const _publicPaths = {'/', '/auth-gate', '/signup', '/login', '/verify-otp', '/welcome', '/invite', '/onboarding'};

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

      // --- Legacy role-based shell redirect ---
      if (path.startsWith('/shell/') && !path.contains('/pet/')) {
        // Redirect old /shell/owner or /shell/vet to /shell
        final tab = state.uri.queryParameters['tab'];
        return tab != null ? '/shell?tab=$tab' : '/shell';
      }

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
        return consumePendingDeepRoute() ?? AppRoutes.shell();
      }

      // Exit auth-gate for needsOnboarding
      if (path == '/auth-gate' && authState == AuthRouteState.needsOnboarding) {
        return AppRoutes.onboarding;
      }

      // Legacy role-selection redirect — go to auth-gate instead.
      if (path == '/role-selection') {
        return AppRoutes.authGate;
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
      GoRoute(path: '/signup', builder: (_, _) => const SignupScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/verify-otp',
        builder: (_, state) {
          final email = Uri.decodeComponent(state.uri.queryParameters['email'] ?? '');
          final isSignup = state.uri.queryParameters['signup'] == 'true';
          final nameParam = state.uri.queryParameters['name'];
          final name = nameParam != null ? Uri.decodeComponent(nameParam) : null;
          return VerifyOtpScreen(email: email, isSignup: isSignup, name: name);
        },
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
        path: '/shell',
        builder: (_, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final tabIndex = int.tryParse(tabStr ?? '') ?? 0;
          return MainShell(initialIndex: tabIndex);
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
