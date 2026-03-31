import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/services/auth_service.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = false;
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _checkTimer;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Periodically check if email is verified
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkVerification());
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    await authProvider.refresh();
    if (authProvider.isEmailVerified) {
      _checkTimer?.cancel();
      if (mounted) {
        context.go(AppRoutes.authGate);
      }
    }
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    final result = await AuthService.resendVerificationEmail();

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.verificationEmailSent),
          backgroundColor: c.info,
        ),
      );
      _startCooldown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? l10n.failedToSendEmail),
          backgroundColor: c.error,
        ),
      );
    }
  }

  void _startCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (mounted) {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final email = AuthService.currentUser?.email ?? 'your email';

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(AppSpacingTokens.md),
                decoration: BoxDecoration(
                  color: c.primaryLightest,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AppAssets.appLogo,
                    width: 48,
                    height: 48,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.xl),

              // Email icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.background,
                  borderRadius: AppRadiiTokens.borderRadiusLg,
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 64,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.xl),

              Text(
                l10n.verifyYourEmail,
                style: AppSemanticTextStyles.title2.copyWith(color: c.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.md),

              Text(
                l10n.verificationLinkSentTo,
                style: AppSemanticTextStyles.body.copyWith(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                email,
                style: AppSemanticTextStyles.body.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                l10n.clickLinkToVerify,
                style: AppSemanticTextStyles.body.copyWith(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Resend button
              if (_isLoading)
                CircularProgressIndicator(color: c.primary)
              else
                PrimaryButton(
                  label: _canResend
                      ? l10n.resendVerificationEmail
                      : l10n.resendInSeconds(_resendCooldown),
                  onPressed: _canResend ? _resendEmail : null,
                  backgroundColor: c.primary,
                ),

              const SizedBox(height: AppSpacingTokens.md),

              PrimaryButton(
                label: l10n.iveVerifiedMyEmail,
                onPressed: _checkVerification,
                backgroundColor: c.info,
                icon: Icons.check_circle_outline,
              ),

              const SizedBox(height: AppSpacingTokens.xl),

              // Sign out link
              TextButton(
                onPressed: _signOut,
                child: Text(
                  l10n.useDifferentAccount,
                  style: AppSemanticTextStyles.body.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
