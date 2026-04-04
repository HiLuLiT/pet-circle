import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/services/auth_service.dart';
import 'package:pet_circle/services/otp_service.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, this.role});

  final AppUserRole? role;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final name = _nameController.text.trim();

      final result = await OtpService.sendOtp(
        email: email,
        name: name,
        isSignup: true,
      );

      if (!mounted) return;

      if (result.success) {
        context.go(
          '/verify-otp?email=${Uri.encodeComponent(email)}&signup=true&name=${Uri.encodeComponent(name)}',
        );
      } else {
        setState(() => _error = result.error);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await AuthService.signInWithGoogle(role: widget.role);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      if (result.isNewUser) {
        context.go(AppRoutes.roleSelection);
      } else {
        context.go(AppRoutes.authGate);
      }
    } else {
      setState(() => _error = result.error);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await AuthService.signInWithApple(role: widget.role);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      if (result.isNewUser) {
        context.go(AppRoutes.roleSelection);
      } else {
        context.go(AppRoutes.authGate);
      }
    } else {
      setState(() => _error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final isAppleAvailable = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);

    return Scaffold(
      backgroundColor: c.primaryLightest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacingTokens.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacingTokens.sm),
                      decoration: BoxDecoration(
                        color: c.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppAssets.appLogo,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),

                  // Title
                  Text(
                    l10n.createAccount,
                    style: AppSemanticTextStyles.title2
                        .copyWith(color: c.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),

                  // Subtitle
                  Text(
                    l10n.pleaseEnterYourDetails,
                    style:
                        AppSemanticTextStyles.body.copyWith(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.xl),

                  // Error message
                  if (_error != null)
                    Container(
                      margin:
                          const EdgeInsets.only(bottom: AppSpacingTokens.md),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.error.withValues(alpha: 0.1),
                        borderRadius: AppRadiiTokens.borderRadiusSm,
                        border:
                            Border.all(color: c.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: c.error, size: 20),
                          const SizedBox(width: AppSpacingTokens.sm),
                          Expanded(
                            child: Text(
                              _error!,
                              style: AppSemanticTextStyles.body
                                  .copyWith(color: c.error),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: l10n.fullName,
                          hint: l10n.enterYourFullName,
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.pleaseEnterName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacingTokens.md),
                        _buildTextField(
                          controller: _emailController,
                          label: l10n.email,
                          hint: l10n.enterYourEmail,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacingTokens.lg),

                  // Send verification code button
                  PrimaryButton(
                    label: l10n.sendVerificationCode,
                    onPressed: _isLoading ? null : _handleSendOtp,
                    backgroundColor: c.primary,
                  ),

                  const SizedBox(height: AppSpacingTokens.lg),

                  // OR divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: c.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacingTokens.md),
                        child: Text(
                          l10n.or,
                          style: AppSemanticTextStyles.caption
                              .copyWith(color: c.textSecondary),
                        ),
                      ),
                      Expanded(child: Divider(color: c.divider)),
                    ],
                  ),

                  const SizedBox(height: AppSpacingTokens.lg),

                  // Continue with Google
                  PrimaryButton(
                    label: l10n.continueWithGoogle,
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    variant: PrimaryButtonVariant.outlined,
                    icon: Icons.g_mobiledata,
                  ),

                  // Continue with Apple (iOS/macOS only)
                  if (isAppleAvailable) ...[
                    const SizedBox(height: AppSpacingTokens.md),
                    PrimaryButton(
                      label: l10n.continueWithApple,
                      onPressed: _isLoading ? null : _handleAppleSignIn,
                      variant: PrimaryButtonVariant.outlined,
                      icon: Icons.apple,
                    ),
                  ],

                  const SizedBox(height: AppSpacingTokens.xl),

                  // Already have an account? Sign in
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: AppSemanticTextStyles.body
                            .copyWith(color: c.textPrimary),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => context.go('/login'),
                        child: Text(
                          l10n.signIn,
                          style: AppSemanticTextStyles.body.copyWith(
                            color: c.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Loading indicator
                  if (_isLoading)
                    Container(
                      margin: const EdgeInsets.only(top: AppSpacingTokens.md),
                      child: Center(
                        child: CircularProgressIndicator(color: c.primary),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final c = AppSemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: AppSemanticTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppSemanticTextStyles.body.copyWith(color: c.textTertiary),
            prefixIcon: Icon(icon, color: c.textSecondary, size: 20),
            filled: true,
            fillColor: c.background,
            border: OutlineInputBorder(
              borderRadius: AppRadiiTokens.borderRadiusLg,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadiiTokens.borderRadiusLg,
              borderSide: BorderSide(color: c.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadiiTokens.borderRadiusLg,
              borderSide:
                  BorderSide(color: c.error.withValues(alpha: 0.4), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.md, vertical: 14),
          ),
        ),
      ],
    );
  }
}
