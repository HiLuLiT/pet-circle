import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

final deepLinkService = DeepLinkService();

class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  /// Token saved from a deep link when the user is not yet authenticated.
  String? _pendingInvitationToken;
  String? get pendingInvitationToken => _pendingInvitationToken;

  void clearPendingToken() => _pendingInvitationToken = null;

  /// Callback invoked when an invitation token is received while the app is running.
  void Function(String token)? onInvitationToken;

  Future<void> init() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleUri(initialUri);

    _subscription = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    // Supports both:
    //   petcircle://invite?token=XYZ
    //   https://petcircle.app/invite?token=XYZ
    if (uri.path == '/invite' || uri.host == 'invite') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        if (onInvitationToken != null) {
          onInvitationToken!(token);
        } else {
          _pendingInvitationToken = token;
        }
        debugPrint('DeepLinkService: received invitation token: $token');
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
