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
/// [emailLinkUrl] must be the full URL including query parameters. On web,
/// `Uri.base` only returns the document base URI (affected by the `<base>` tag),
/// so the GoRoute builder constructs the full URL from `Uri.base.origin` +
/// `GoRouterState.uri`.
///
/// On native platforms, [DeepLinkService] intercepts the link before GoRouter
/// sees it, so this screen is only reached on web.
class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key, this.emailLinkUrl});

  /// The full URL containing Firebase sign-in parameters (oobCode, mode, etc.).
  final String? emailLinkUrl;

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

enum _CallbackState { processing, needsEmail, error }

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  _CallbackState _state = _CallbackState.processing;
  String? _error;
  String? _linkUrl;
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _linkUrl = widget.emailLinkUrl;
    _processEmailLink();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _processEmailLink() async {
    if (!kIsWeb) {
      // On native, DeepLinkService handles email links — redirect to auth gate.
      if (mounted) context.go(AppRoutes.authGate);
      return;
    }

    final url = _linkUrl;
    if (url == null || !AuthService.isSignInLink(url)) {
      setState(() {
        _state = _CallbackState.error;
        _error = null; // will fall back to l10n.invalidSignInLink
      });
      return;
    }

    final pending = await AuthService.getPendingAuth();
    final email = pending.email;

    if (email == null || email.isEmpty) {
      // Cross-device scenario: show email input instead of error
      setState(() => _state = _CallbackState.needsEmail);
      return;
    }

    await _completeSignIn(email: email, link: url);
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final email = _emailController.text.trim();
    final url = _linkUrl;
    if (url == null) return;

    await _completeSignIn(email: email, link: url);

    if (mounted && _isSubmitting) {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _completeSignIn({
    required String email,
    required String link,
  }) async {
    final pending = await AuthService.getPendingAuth();
    final result = await AuthService.signInWithEmailLink(
      email: email,
      emailLink: link,
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
        _state = _CallbackState.error;
        _error = result.error;
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    return Scaffold(
      backgroundColor: c.primaryLightest,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: switch (_state) {
                _CallbackState.processing => _buildProcessing(l10n, c),
                _CallbackState.needsEmail => _buildEmailInput(l10n, c),
                _CallbackState.error => _buildError(l10n, c),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessing(AppLocalizations l10n, AppSemanticColors c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: c.primary),
        const SizedBox(height: AppSpacingTokens.lg),
        Text(
          l10n.signingYouIn,
          style: AppSemanticTextStyles.bodyLg.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }

  Widget _buildEmailInput(AppLocalizations l10n, AppSemanticColors c) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.email_outlined, size: 64, color: c.primary),
          const SizedBox(height: AppSpacingTokens.lg),
          Text(
            l10n.enterEmailToComplete,
            style: AppSemanticTextStyles.body.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: l10n.email,
              hintText: l10n.enterYourEmail,
              filled: true,
              fillColor: c.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterEmail;
              }
              if (!value.contains('@') || !value.contains('.')) {
                return l10n.pleaseEnterValidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          if (_isSubmitting)
            CircularProgressIndicator(color: c.primary)
          else
            PrimaryButton(
              label: l10n.completeSignIn,
              onPressed: _submitEmail,
              backgroundColor: c.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, AppSemanticColors c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 64, color: c.error),
        const SizedBox(height: AppSpacingTokens.lg),
        Text(
          _error ?? l10n.invalidSignInLink,
          style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacingTokens.xl),
        PrimaryButton(
          label: l10n.login,
          onPressed: () => context.go(AppRoutes.login),
          backgroundColor: c.primary,
        ),
      ],
    );
  }
}
