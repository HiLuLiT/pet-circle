import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/services/auth_service.dart';
import 'package:pet_circle/services/otp_service.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_input_decoration.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/social_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _error;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = _emailController.text.trim();

    if (!kEnableFirebase) {
      if (!mounted) return;
      context.go('${AppRoutes.verifyOtp}?email=${Uri.encodeComponent(email)}&signup=false');
      return;
    }

    try {
      final result = await OtpService.sendOtp(email: email);
      if (!mounted) return;
      if (result.success) {
        context.go('${AppRoutes.verifyOtp}?email=${Uri.encodeComponent(email)}&signup=false');
      } else {
        setState(() {
          _isLoading = false;
          _error = result.error;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (!kEnableFirebase) return;
    setState(() => _isLoading = true);

    final result = await AuthService.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      context.go(AppRoutes.authGate);
    } else if (result.error != null && result.error != 'Sign in cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (!kEnableFirebase) return;

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.appleSignInNotAvailableOnWeb)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.signInWithApple();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      context.go(AppRoutes.authGate);
    } else if (result.error != null && result.error != 'Sign in cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 393),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: c.primaryGhost,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_outline, size: 36, color: c.primary),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm + 4),
                  Text(
                    l10n.welcomeBackToLogin,
                    style: AppSemanticTextStyles.headingH1.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    l10n.enterDetailsToLogin,
                    style: AppSemanticTextStyles.labelLRegular.copyWith(
                      color: c.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.pcXl),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.emailAddress,
                          style: AppSemanticTextStyles.labelMSemibold.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.sm + 4),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          decoration: appInputDecoration(
                            context,
                            hintText: l10n.enterYourEmail,
                          ),
                          style: AppSemanticTextStyles.pcBody,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.pleaseEnterEmail;
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
                              return l10n.enterValidEmail;
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: AppSpacingTokens.sm),
                          Text(
                            _error!,
                            style: AppSemanticTextStyles.caption.copyWith(
                              color: c.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacingTokens.sm + 4),
                        PrimaryButton(
                          label: l10n.login,
                          // Keep onPressed live during loading so the filled
                          // (purple) background stays visible behind the
                          // white spinner; re-entry is guarded inside
                          // _handleLogin.
                          onPressed: _handleLogin,
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: c.onPrimary,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.md + 4),
                  Row(
                    children: [
                      Expanded(child: Divider(color: c.textTertiary)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacingTokens.sm + 4,
                        ),
                        child: Text(
                          l10n.or,
                          style: AppSemanticTextStyles.captionMedium.copyWith(
                            color: c.textTertiary,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: c.textTertiary)),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.md + 4),
                  SocialButton(
                    icon: Image.asset(AppAssets.googleLogo, width: 20, height: 20),
                    label: l10n.continueWithGoogle,
                    onTap: _isLoading ? null : _handleGoogleSignIn,
                  ),
                  const SizedBox(height: AppSpacingTokens.sm + 4),
                  SocialButton(
                    icon: Icon(Icons.apple, size: 20, color: c.textPrimary),
                    label: l10n.continueWithApple,
                    onTap: _isLoading ? null : _handleAppleSignIn,
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  TextButton(
                    onPressed: _isLoading ? null : () => context.push(AppRoutes.signup),
                    child: Text.rich(
                      TextSpan(
                        text: '${l10n.dontHaveAccount} ',
                        style: AppSemanticTextStyles.pcLabelMuted,
                        children: [
                          TextSpan(
                            text: l10n.signUp,
                            style: AppSemanticTextStyles.pcLabelBold.copyWith(
                              color: c.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
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
