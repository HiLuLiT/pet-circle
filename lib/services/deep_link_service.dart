import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

// Only import app_links on non-web platforms.
import 'package:app_links/app_links.dart'
    if (dart.library.html) 'package:pet_circle/services/deep_link_service_stub.dart';

import 'package:pet_circle/services/auth_service.dart';

final deepLinkService = DeepLinkService();

/// Handles deep links for invitation tokens.
///
/// On **web**, deep links arrive through the URL bar and are handled directly
/// by GoRouter's `/invite` route — no `app_links` package is needed.
///
/// On **native**, the `app_links` package listens for incoming URIs and
/// navigates to the `/invite` route via GoRouter.
class DeepLinkService {
  StreamSubscription<Uri>? _subscription;

  /// Token saved from a deep link when the user is not yet authenticated.
  String? _pendingInvitationToken;
  String? get pendingInvitationToken => _pendingInvitationToken;

  void setPendingToken(String token) => _pendingInvitationToken = token;
  void clearPendingToken() => _pendingInvitationToken = null;

  /// Reference to the app-wide GoRouter, set during [init].
  GoRouter? _router;

  /// Initialise the service.
  ///
  /// [router] is the app-wide GoRouter used to navigate on native when an
  /// incoming link is received.  On web this parameter is unused because the
  /// browser URL is routed directly by GoRouter.
  Future<void> init({GoRouter? router}) async {
    _router = router;

    // On web, GoRouter handles the initial URL from the address bar.
    if (kIsWeb) return;

    final appLinks = AppLinks();

    // Check for a cold-start link on native.
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) _handleNativeUri(initialUri);

    // Listen for links while the app is already running.
    _subscription = appLinks.uriLinkStream.listen(_handleNativeUri);
  }

  /// Handle an incoming URI on native by routing through GoRouter.
  void _handleNativeUri(Uri uri) {
    final uriString = uri.toString();
    // Check if this is a Firebase email sign-in link
    if (AuthService.isSignInLink(uriString)) {
      _handleEmailSignInLink(uriString);
      return;
    }

    // Supports both:
    //   petcircle://invite?token=XYZ
    //   https://petcircle.app/invite?token=XYZ
    if (uri.path == '/invite' || uri.host == 'invite') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        debugPrint('DeepLinkService: received native invitation token: $token');
        _router?.go('/invite?token=$token');
        return;
      }
    }
    debugPrint('DeepLinkService: ignoring unrecognised URI: $uri');
  }

  Future<void> _handleEmailSignInLink(String link) async {
    final pending = await AuthService.getPendingAuth();
    final email = pending.email;
    if (email == null) {
      debugPrint('DeepLinkService: email link received but no pending email');
      return;
    }

    final result = await AuthService.signInWithEmailLink(
      email: email,
      emailLink: link,
    );

    if (result.success && result.user != null) {
      final name = pending.name;
      final isSignup = pending.isSignup;

      if (result.isNewUser && isSignup && name != null && name.isNotEmpty) {
        await result.user!.updateDisplayName(name);
      }

      await AuthService.clearPendingAuth();
      // Firebase auth state listener in AuthProvider will pick up the change
      debugPrint('DeepLinkService: email link sign-in successful');
    } else {
      debugPrint('DeepLinkService: email link sign-in failed: ${result.error}');
      // Navigate to login screen so the user can retry
      _router?.go('/login');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
