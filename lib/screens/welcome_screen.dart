import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/services/auth_service.dart';
import 'package:pet_circle/services/otp_service.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
      context.go('/verify-otp?email=${Uri.encodeComponent(email)}&signup=true&name=${Uri.encodeComponent(name)}');
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
      context.go('/verify-otp?email=${Uri.encodeComponent(email)}&signup=true&name=${Uri.encodeComponent(name)}');
    } else {
      setState(() => _error = result.error ?? 'Failed to send code');
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.lg,
              vertical: AppSpacingTokens.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(AppSpacingTokens.xl),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: c.textPrimary.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.primaryLightest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.bolt, size: 32, color: c.primary),
                    ),
                    const SizedBox(height: AppSpacingTokens.lg),

                    // Heading
                    Text(
                      l10n.createAccount,
                      style: AppSemanticTextStyles.title2,
                    ),
                    const SizedBox(height: AppSpacingTokens.sm),

                    // Subtitle
                    Text(
                      l10n.pleaseEnterYourDetails,
                      style: AppSemanticTextStyles.body.copyWith(
                        color: c.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacingTokens.xl),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name label
                          Text(
                            l10n.fullName,
                            style: AppSemanticTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacingTokens.xs),
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
                          const SizedBox(height: AppSpacingTokens.md),

                          // Email label
                          Text(
                            l10n.emailAddress,
                            style: AppSemanticTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacingTokens.xs),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            decoration: _inputDecoration(
                              c,
                              hintText: 'Enter your Email',
                            ),
                            style: AppSemanticTextStyles.body,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.emailAddress;
                              }
                              if (!value.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleSendCode(),
                          ),
                        ],
                      ),
                    ),

                    // Error
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacingTokens.sm),
                      Text(
                        _error!,
                        style: AppSemanticTextStyles.caption.copyWith(color: c.error),
                      ),
                    ],

                    const SizedBox(height: AppSpacingTokens.lg),

                    // Send email code button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.textPrimary,
                          foregroundColor: c.surface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: c.surface,
                                ),
                              )
                            : Text(
                                l10n.sendVerificationCode,
                                style: AppSemanticTextStyles.button.copyWith(
                                  color: c.surface,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: AppSpacingTokens.xl),

                    // OR divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: c.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacingTokens.md,
                          ),
                          child: Text(
                            l10n.or,
                            style: AppSemanticTextStyles.caption.copyWith(
                              color: c.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: c.divider)),
                      ],
                    ),

                    const SizedBox(height: AppSpacingTokens.xl),

                    // Google button
                    _SocialButton(
                      icon: Image.asset(AppAssets.googleLogo, width: 20, height: 20),
                      label: l10n.continueWithGoogle,
                      onTap: _isLoading ? null : _handleGoogleSignIn,
                    ),
                    const SizedBox(height: AppSpacingTokens.md),

                    // Apple button
                    _SocialButton(
                      icon: Icon(Icons.apple, size: 20, color: c.textPrimary),
                      label: l10n.continueWithApple,
                      onTap: _isLoading ? null : _handleAppleSignIn,
                    ),

                    const SizedBox(height: AppSpacingTokens.xl),

                    // Already have an account? Sign in
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => context.push(AppRoutes.login),
                      child: Text.rich(
                        TextSpan(
                          text: '${l10n.alreadyHaveAccount} ',
                          style: AppSemanticTextStyles.body.copyWith(
                            color: c.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: l10n.signIn,
                              style: AppSemanticTextStyles.body.copyWith(
                                color: c.primary,
                                fontWeight: FontWeight.w600,
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
      ),
    );
  }

  InputDecoration _inputDecoration(AppSemanticColors c, {required String hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: c.surface,
      hintText: hintText,
      hintStyle: AppSemanticTextStyles.body.copyWith(color: c.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.textPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.error, width: 2),
      ),
    );
  }
}

/// Social sign-in button with outlined border, matching the HTML design.
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
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: c.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: c.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
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
