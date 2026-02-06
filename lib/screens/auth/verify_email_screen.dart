import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/services/auth_service.dart';
import 'package:pet_circle/services/user_service.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/app_theme.dart';
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
    await AuthService.reloadUser();
    if (AuthService.isEmailVerified) {
      _checkTimer?.cancel();
      if (mounted) {
        _navigateAfterVerification();
      }
    }
  }

  Future<void> _navigateAfterVerification() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final appUser = await UserService.getUser(user.uid);
    if (!mounted) return;

    if (appUser?.role == AppUserRole.vet) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.vetDashboard);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    final result = await AuthService.resendVerificationEmail();

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.verificationEmailSent),
          backgroundColor: AppColors.successGreen,
        ),
      );
      _startCooldown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? l10n.failedToSendEmail),
          backgroundColor: Colors.red,
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
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = AuthService.currentUser?.email ?? 'your email';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pink.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.pink,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AppAssets.appLogo,
                    width: 48,
                    height: 48,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Email icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 64,
                  color: AppColors.burgundy,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                l10n.verifyYourEmail,
                style: AppTextStyles.heading1.copyWith(color: AppColors.burgundy),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                l10n.verificationLinkSentTo,
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.burgundy,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.clickLinkToVerify,
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Resend button
              if (_isLoading)
                const CircularProgressIndicator(color: AppColors.burgundy)
              else
                PrimaryButton(
                  label: _canResend
                      ? l10n.resendVerificationEmail
                      : l10n.resendInSeconds(_resendCooldown),
                  onPressed: _canResend ? _resendEmail : null,
                  backgroundColor:
                      _canResend ? AppColors.burgundy : AppColors.textMuted,
                ),

              const SizedBox(height: 16),

              // Check manually button
              TextButton.icon(
                onPressed: _checkVerification,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.iveVerifiedMyEmail),
                style: TextButton.styleFrom(foregroundColor: AppColors.burgundy),
              ),

              const SizedBox(height: 32),

              // Sign out link
              TextButton(
                onPressed: _signOut,
                child: Text(
                  l10n.useDifferentAccount,
                  style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
