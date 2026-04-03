import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/services/auth_service.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';

/// Handles the Firebase email link callback on web.
///
/// When the user clicks the magic link in their email, the browser navigates to
/// `/auth/callback?oobCode=...&mode=signIn&...`. This screen processes the link
/// using [AuthService.signInWithEmailLink] and either navigates to the auth gate
/// on success or shows an error with a retry option.
///
/// On native platforms, [DeepLinkService] intercepts the link before GoRouter
/// sees it, so this screen is only reached on web.
class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  bool _isProcessing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _processEmailLink();
  }

  Future<void> _processEmailLink() async {
    if (!kIsWeb) {
      // On native, DeepLinkService handles email links — redirect to auth gate.
      if (mounted) context.go(AppRoutes.authGate);
      return;
    }

    final currentUrl = Uri.base.toString();

    if (!AuthService.isSignInLink(currentUrl)) {
      setState(() {
        _isProcessing = false;
        _error = 'Invalid sign-in link.';
      });
      return;
    }

    final pending = await AuthService.getPendingAuth();
    final email = pending.email;

    if (email == null || email.isEmpty) {
      setState(() {
        _isProcessing = false;
        _error = 'No pending email found. Please try signing in again.';
      });
      return;
    }

    final result = await AuthService.signInWithEmailLink(
      email: email,
      emailLink: currentUrl,
    );

    if (!mounted) return;

    if (result.success && result.user != null) {
      final name = pending.name;
      final isSignup = pending.isSignup;

      if (result.isNewUser && isSignup && name != null && name.isNotEmpty) {
        await result.user!.updateDisplayName(name);
      }

      await AuthService.clearPendingAuth();

      if (mounted) {
        context.go(AppRoutes.authGate);
      }
    } else {
      setState(() {
        _isProcessing = false;
        _error = result.error ?? 'Sign-in failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    if (_isProcessing) {
      return Scaffold(
        backgroundColor: c.primaryLightest,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: c.primary),
              const SizedBox(height: AppSpacingTokens.lg),
              Text(
                'Signing you in…',
                style: AppSemanticTextStyles.bodyLg
                    .copyWith(color: c.textPrimary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: c.primaryLightest,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: c.error,
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  Text(
                    _error ?? l10n.linkInvalid,
                    style: AppSemanticTextStyles.body
                        .copyWith(color: c.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.xl),
                  PrimaryButton(
                    label: l10n.login,
                    onPressed: () => context.go(AppRoutes.login),
                    backgroundColor: c.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
