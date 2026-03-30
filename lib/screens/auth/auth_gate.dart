import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/services/deep_link_service.dart';
import 'package:pet_circle/services/invitation_service.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/app_theme.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    authProvider.addListener(_onAuthChanged);
    _navigate();
  }

  @override
  void dispose() {
    authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  Future<void> _acceptInvitation(String token) async {
    final appUser = authProvider.appUser;
    if (appUser == null) return;

    final result = await InvitationService.acceptInvitation(
      token: token,
      uid: appUser.uid,
      email: appUser.email,
      displayName: appUser.displayName ?? appUser.email,
      avatarUrl: appUser.photoUrl ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(appUser.displayName ?? appUser.email)}&background=E8B4B8&color=5B2C3F',
    );

    deepLinkService.clearPendingToken();

    if (!mounted) return;

    if (result.success) {
      context.go(AppRoutes.shell(appUser.role));
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_invitationErrorText(l10n, result.errorCode))),
    );
    context.go(AppRoutes.shell(appUser.role));
  }

  String _invitationErrorText(AppLocalizations l10n, String? errorCode) {
    switch (errorCode) {
      case 'invitationExpired':
        return l10n.invitationExpired;
      case 'invitationAlreadyUsed':
        return l10n.invitationAlreadyUsed;
      case 'invitationNotAuthorized':
        return l10n.invitationNotAuthorized;
      case 'invitationNoLongerValid':
        return l10n.invitationNoLongerValid;
      case 'invitationAcceptFailed':
        return l10n.invitationAcceptFailed;
      case 'invitationNotFound':
      default:
        return l10n.invitationNotFound;
    }
  }

  void _onAuthChanged() {
    if (!mounted) return;
    _navigate();
  }

  void _navigate() {
    final state = authProvider.routeState;
    if (state == AuthRouteState.loading) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      switch (state) {
        case AuthRouteState.unauthenticated:
          context.go(AppRoutes.welcome);
        case AuthRouteState.needsEmailVerification:
          context.go(AppRoutes.verifyEmail);
        case AuthRouteState.needsRole:
          context.go(AppRoutes.roleSelection);
        case AuthRouteState.authenticated:
          _handleAuthenticated();
        case AuthRouteState.loading:
          break;
      }
    });
  }

  void _handleAuthenticated() {
    final appUser = authProvider.appUser!;
    userStore.seedFromAppUser(appUser);
    petStore.subscribeForUser(appUser.uid);
    notificationStore.subscribeForUser(appUser.uid);

    final pendingToken = deepLinkService.pendingInvitationToken;
    if (pendingToken != null) {
      _acceptInvitation(pendingToken);
      return;
    }

    context.go(AppRoutes.shell(appUser.role));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Scaffold(
      backgroundColor: c.white,
      body: Center(
        child: CircularProgressIndicator(color: c.chocolate),
      ),
    );
  }
}
