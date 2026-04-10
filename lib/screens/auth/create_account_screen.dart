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

/// Email / social sign-up (Figma create-account). Routed at [AppRoutes.signup].
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _isLoading = false;
  String? _error;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    if (!kEnableFirebase) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go('${AppRoutes.verifyOtp}?email=${Uri.encodeComponent(email)}&signup=true&name=${Uri.encodeComponent(name)}');
      return;
    }

    final result = await OtpService.sendOtp(
      email: email,
      name: name,
      isSignup: true,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      context.go('${AppRoutes.verifyOtp}?email=${Uri.encodeComponent(email)}&signup=true&name=${Uri.encodeComponent(name)}');
    } else {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _error = result.error ?? l10n.failedToSendCode);
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
      backgroundColor: c.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.xl,
              vertical: AppSpacingTokens.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 393),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacingTokens.xl),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: c.primaryLightest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_outline, size: 36, color: c.primary),
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  Text(
                    l10n.createAccount,
                    style: AppSemanticTextStyles.title3.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    l10n.pleaseEnterYourDetails,
                    style: AppSemanticTextStyles.body.copyWith(
                      color: c.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.xl),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.fullName,
                          style: AppSemanticTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.sm),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            c,
                            hintText: l10n.enterYourFullName,
                          ),
                          style: AppSemanticTextStyles.body,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.enterYourFullName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacingTokens.lg),
                        Text(
                          l10n.emailAddress,
                          style: AppSemanticTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.sm),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          decoration: _inputDecoration(
                            c,
                            hintText: l10n.enterYourEmail,
                          ),
                          style: AppSemanticTextStyles.body,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.pleaseEnterEmail;
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
                              return l10n.enterValidEmail;
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _handleSendCode(),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacingTokens.sm),
                    Text(
                      _error!,
                      style: AppSemanticTextStyles.caption.copyWith(color: c.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacingTokens.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSendCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
                        foregroundColor: c.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadiiTokens.xl),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: c.onPrimary,
                              ),
                            )
                          : Text(
                              l10n.sendVerificationCode,
                              style: AppSemanticTextStyles.button.copyWith(
                                color: c.onPrimary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xl),
                  Row(
                    children: [
                      Expanded(child: Divider(color: c.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacingTokens.sm + 4,
                        ),
                        child: Text(
                          l10n.or,
                          style: AppSemanticTextStyles.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: c.divider)),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  _SocialButton(
                    icon: Image.asset(AppAssets.googleLogo, width: 20, height: 20),
                    label: l10n.continueWithGoogle,
                    onTap: _isLoading ? null : _handleGoogleSignIn,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  _SocialButton(
                    icon: Icon(Icons.apple, size: 20, color: c.textPrimary),
                    label: l10n.continueWithApple,
                    onTap: _isLoading ? null : _handleAppleSignIn,
                  ),
                  const SizedBox(height: AppSpacingTokens.xl),
                  TextButton(
                    onPressed: _isLoading ? null : () => context.push(AppRoutes.login),
                    child: Text.rich(
                      TextSpan(
                        text: '${l10n.alreadyHaveAccount} ',
                        style: AppSemanticTextStyles.caption.copyWith(
                          color: c.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: l10n.signIn,
                            style: AppSemanticTextStyles.caption.copyWith(
                              color: c.info,
                              decoration: TextDecoration.underline,
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

  InputDecoration _inputDecoration(AppSemanticColors c, {required String hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: c.surface,
      hintText: hintText,
      hintStyle: AppSemanticTextStyles.body.copyWith(color: c.textTertiary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiiTokens.md),
        borderSide: BorderSide(color: c.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiiTokens.md),
        borderSide: BorderSide(color: c.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiiTokens.md),
        borderSide: BorderSide(color: c.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiiTokens.md),
        borderSide: BorderSide(color: c.error, width: 2),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: c.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadiiTokens.md),
          ),
          backgroundColor: c.surface,
          elevation: 0,
        ).copyWith(
          shadowColor: WidgetStatePropertyAll(
            Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: AppSpacingTokens.sm + 4),
            Text(
              label,
              style: AppSemanticTextStyles.body.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
