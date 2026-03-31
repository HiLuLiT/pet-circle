import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/services/auth_service.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.role, this.startWithSignIn = false});

  final AppUserRole? role;
  final bool startWithSignIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isSignUp = !widget.startWithSignIn;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    AuthResult result;

    if (_isSignUp) {
      result = await AuthService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: widget.role ?? AppUserRole.owner,
        displayName: _nameController.text.trim(),
      );
    } else {
      result = await AuthService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      if (_isSignUp || !(result.user?.emailVerified ?? true)) {
        context.go(AppRoutes.verifyEmail);
      } else {
        _navigateAfterAuth();
      }
    } else {
      setState(() => _error = result.error);
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
      _navigateAfterAuth();
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
      _navigateAfterAuth();
    } else {
      setState(() => _error = result.error);
    }
  }

  void _navigateAfterAuth() {
    context.go(AppRoutes.authGate);
  }

  Future<void> _handleForgotPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = l10n.pleaseEnterEmailFirst);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await AuthService.sendPasswordResetEmail(email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordResetSent(email)),
          backgroundColor: AppSemanticColors.of(context).info,
        ),
      );
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
    final roleLabel = widget.role != null
        ? (widget.role == AppUserRole.vet ? l10n.veterinarian : l10n.petOwner)
        : null;

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
              // Logo and header
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
              Text(
                _isSignUp ? l10n.createAccount : 'Welcome Back',
                style: AppSemanticTextStyles.title2.copyWith(color: c.textPrimary),
                textAlign: TextAlign.center,
              ),
              if (roleLabel != null) ...[
              const SizedBox(height: AppSpacingTokens.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md, vertical: AppSpacingTokens.sm),
                decoration: BoxDecoration(
                  color: c.primaryLight.withValues(alpha: 0.3),
                  borderRadius: AppRadiiTokens.borderRadiusLg,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.role == AppUserRole.vet
                          ? Icons.medical_services_outlined
                          : Icons.pets,
                      size: 18,
                      color: c.textPrimary,
                    ),
                    const SizedBox(width: AppSpacingTokens.sm),
                    Text(
                      l10n.signingUpAs(roleLabel),
                      style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
                    ),
                  ],
                ),
              ),
              ],
              const SizedBox(height: AppSpacingTokens.xl),

              // Error message
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacingTokens.md),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.error.withValues(alpha: 0.1),
                    borderRadius: AppRadiiTokens.borderRadiusSm,
                    border: Border.all(color: c.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: c.error, size: 20),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppSemanticTextStyles.body.copyWith(color: c.error),
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
                    if (_isSignUp)
                      _buildTextField(
                        controller: _nameController,
                        label: l10n.fullName,
                        hint: l10n.enterYourName,
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.pleaseEnterName;
                          }
                          return null;
                        },
                      ),
                    if (_isSignUp) const SizedBox(height: AppSpacingTokens.md),
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
                    const SizedBox(height: AppSpacingTokens.md),
                    _buildTextField(
                      controller: _passwordController,
                      label: l10n.password,
                      hint: l10n.enterYourPassword,
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: c.textPrimary,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterPassword;
                        }
                        if (_isSignUp && value.length < 6) {
                          return l10n.passwordMinLength;
                        }
                        return null;
                      },
                    ),
                    if (_isSignUp) ...[
                      const SizedBox(height: AppSpacingTokens.md),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: l10n.confirmPassword,
                        hint: l10n.confirmYourPassword,
                        icon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: c.textPrimary,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return l10n.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),

              if (!_isSignUp) ...[
                const SizedBox(height: AppSpacingTokens.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _handleForgotPassword,
                    child: Text(
                      l10n.forgotPassword,
                      style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacingTokens.lg),

              // Submit button
              PrimaryButton(
                label: _isSignUp ? l10n.createAccount : l10n.signIn,
                onPressed: _isLoading ? null : _handleEmailAuth,
                backgroundColor: c.primary,
              ),

              const SizedBox(height: AppSpacingTokens.lg),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: c.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
                    child: Text(
                      l10n.orContinueWith,
                      style: AppSemanticTextStyles.caption.copyWith(color: c.textSecondary),
                    ),
                  ),
                  Expanded(child: Divider(color: c.divider)),
                ],
              ),

              const SizedBox(height: AppSpacingTokens.lg),

              // Social login buttons
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      label: l10n.google,
                      icon: Icons.g_mobiledata,
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                    ),
                  ),
                  if (isAppleAvailable) ...[
                    const SizedBox(width: AppSpacingTokens.md),
                    Expanded(
                      child: _SocialButton(
                        label: l10n.apple,
                        icon: Icons.apple,
                        onPressed: _isLoading ? null : _handleAppleSignIn,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppSpacingTokens.xl),

              // Toggle sign in / sign up
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    _isSignUp ? l10n.alreadyHaveAccount : l10n.dontHaveAccount,
                    style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() {
                              _isSignUp = !_isSignUp;
                              _error = null;
                            }),
                    child: Text(
                      _isSignUp ? l10n.signIn : l10n.signUp,
                      style: AppSemanticTextStyles.body.copyWith(
                        color: c.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Loading overlay
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
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final c = AppSemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: AppSemanticTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppSemanticTextStyles.body.copyWith(color: c.textTertiary),
            prefixIcon: Icon(icon, color: c.textSecondary, size: 20),
            suffixIcon: suffixIcon,
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
              borderSide: BorderSide(color: c.error.withValues(alpha: 0.4), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: c.divider),
        shape: RoundedRectangleBorder(borderRadius: AppRadiiTokens.borderRadiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: c.textPrimary, size: 24),
          const SizedBox(width: AppSpacingTokens.sm),
          Text(
            label,
            style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}
