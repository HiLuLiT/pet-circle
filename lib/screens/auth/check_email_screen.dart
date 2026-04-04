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

class CheckEmailScreen extends StatefulWidget {
  const CheckEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  bool _isLoading = false;
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    authProvider.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    authProvider.removeListener(_onAuthStateChanged);
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (authProvider.routeState != AuthRouteState.unauthenticated &&
        authProvider.routeState != AuthRouteState.loading) {
      if (mounted) {
        context.go(AppRoutes.authGate);
      }
    }
  }

  Future<void> _resendLink() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.sendSignInLink(email: widget.email);

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      final c = AppSemanticColors.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.verificationEmailSent),
          backgroundColor: c.info,
        ),
      );
      _startCooldown();
    } catch (e) {
      if (!mounted) return;

      final c = AppSemanticColors.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: c.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    return Scaffold(
      backgroundColor: c.primaryLightest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
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
                  const SizedBox(height: AppSpacingTokens.xl),

                  // Email icon
                  Center(
                    child: Container(
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
                  ),
                  const SizedBox(height: AppSpacingTokens.xl),

                  // Title
                  Text(
                    l10n.checkYourEmail,
                    style: AppSemanticTextStyles.title2
                        .copyWith(color: c.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),

                  // "We sent a sign-in link to" + email
                  Text(
                    l10n.weSentSignInLinkTo,
                    style: AppSemanticTextStyles.body
                        .copyWith(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    widget.email,
                    style: AppSemanticTextStyles.body.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),

                  // Click the link instruction
                  Text(
                    l10n.clickLinkToSignIn,
                    style: AppSemanticTextStyles.body
                        .copyWith(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),

                  // Spam folder hint
                  Text(
                    l10n.checkSpamFolder,
                    style: AppSemanticTextStyles.bodySm
                        .copyWith(color: c.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Resend button
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(color: c.primary),
                    )
                  else
                    PrimaryButton(
                      label: _canResend
                          ? l10n.resendLink
                          : l10n.resendLinkInSeconds(_resendCooldown),
                      onPressed: _canResend ? _resendLink : null,
                      backgroundColor: c.primary,
                    ),

                  const SizedBox(height: AppSpacingTokens.xl),

                  // Use a different email
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/signup');
                        }
                      },
                      child: Text(
                        l10n.useDifferentEmail,
                        style: AppSemanticTextStyles.body
                            .copyWith(color: c.textSecondary),
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
