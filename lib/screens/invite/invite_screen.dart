import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/services/deep_link_service.dart';
import 'package:pet_circle/services/invitation_service.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';

/// Screen shown when the user navigates to `/invite?token=XYZ`.
///
/// If the user is authenticated the invitation is processed immediately.
/// On success the user is redirected to the dashboard; on failure a
/// user-friendly error is displayed with an option to continue.
class InviteScreen extends StatefulWidget {
  final String token;

  const InviteScreen({super.key, required this.token});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  bool _isProcessing = true;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _processInvitation();
  }

  Future<void> _processInvitation() async {
    final appUser = authProvider.appUser;
    if (appUser == null || widget.token.isEmpty) {
      if (mounted) {
        context.go(AppRoutes.authGate);
      }
      return;
    }

    final result = await InvitationService.acceptInvitation(
      token: widget.token,
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

    setState(() {
      _isProcessing = false;
      _errorCode = result.errorCode;
    });
  }

  String _errorText(AppLocalizations l10n, String? errorCode) {
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

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isProcessing) {
      return Scaffold(
        backgroundColor: c.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: c.textPrimary),
              const SizedBox(height: 16),
              Text(
                l10n.processingInvitation,
                style: TextStyle(color: c.textPrimary),
              ),
            ],
          ),
        ),
      );
    }

    // Error state — show message and a button to continue.
    return Scaffold(
      backgroundColor: c.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: c.textPrimary, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorText(l10n, _errorCode),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: c.textPrimary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final appUser = authProvider.appUser;
                  if (appUser != null) {
                    context.go(AppRoutes.shell(appUser.role));
                  } else {
                    context.go(AppRoutes.authGate);
                  }
                },
                child: Text(l10n.continueButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
