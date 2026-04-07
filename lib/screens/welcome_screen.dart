import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/services/auth_service.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    return Scaffold(
      backgroundColor: c.primaryLightest,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Illustration layer — behind everything, clipped to screen
                    _WelcomeIllustration(
                      screenWidth: constraints.maxWidth,
                      screenHeight: constraints.maxHeight,
                    ),

                    // Foreground content
                    Column(
                      children: [
                        const SizedBox(height: AppSpacingTokens.xl),

                        // "Pet Circle" subtitle
                        Text(
                          l10n.appTitle,
                          style: AppSemanticTextStyles.headingMd.copyWith(
                            color: c.textSecondary,
                          ),
                        ),

                        const SizedBox(height: AppSpacingTokens.md),

                        // Main title
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacingTokens.xl,
                          ),
                          child: Text(
                            l10n.welcomeTagline,
                            style: AppSemanticTextStyles.title2,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const Spacer(),

                        // Buttons at the bottom
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacingTokens.xl,
                          ),
                          child: Column(
                            children: [
                              PrimaryButton(
                                label: l10n.signUp,
                                backgroundColor:
                                    AppSemanticColors.of(context).surface,
                                foregroundColor:
                                    AppSemanticColors.of(context).textPrimary,
                                onPressed: () =>
                                    context.push(AppRoutes.signup),
                              ),
                              const SizedBox(height: AppSpacingTokens.md),
                              _GoogleSignInButton(
                                label: l10n.signInWithGoogle,
                                onTap: _isLoading ? null : _handleGoogleSignIn,
                              ),
                                  const SizedBox(height: AppSpacingTokens.sm),
                              _AppleSignInButton(
                                label: l10n.signInWithApple,
                                onTap: _isLoading ? null : _handleAppleSignIn,
                              ),
                              const SizedBox(height: AppSpacingTokens.md),
                              PrimaryButton(
                                label: l10n.signIn,
                                variant: PrimaryButtonVariant.outlined,
                                onPressed: _isLoading
                                    ? null
                                    : () => context
                                        .push(AppRoutes.login),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Cat + dog illustration positioned to match the Figma layout.
///
/// Figma frame: 393 × 852.
/// Cat (Layer_1): left -24, top 164, 311 × 380.
/// Dog (Group 220): rotated -12.48 deg, offset right and overlapping cat.
class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration({
    required this.screenWidth,
    required this.screenHeight,
  });

  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    // Scale proportionally from the Figma frame (393 wide).
    final scale = screenWidth / 393;
    // Vertical offset scaled from Figma (top: 164 out of 852).
    final topOffset = screenHeight * 0.19;

    return Positioned.fill(
      child: ClipRect(
        child: Stack(
          children: [
            // Cat — extends past left edge
            Positioned(
              left: -24 * scale,
              top: topOffset,
              width: 311 * scale,
              height: 380 * scale,
              child: SvgPicture.asset(
                AppAssets.welcomeCat,
                fit: BoxFit.contain,
              ),
            ),
            // Dog — overlapping, rotated -12.48 degrees
            Positioned(
              left: screenWidth * 0.15,
              top: topOffset + 16 * scale,
              width: 365 * scale,
              height: 418 * scale,
              child: Transform.rotate(
                angle: -12.48 * math.pi / 180,
                child: SvgPicture.asset(
                  AppAssets.welcomeDog,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Sign in with Apple" row — Apple icon + label, no background.
class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadiiTokens.borderRadiusXl,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apple, color: c.textPrimary, size: 24),
            const SizedBox(width: AppSpacingTokens.sm),
            Text(
              label,
              style: AppSemanticTextStyles.button.copyWith(
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Sign in with Google" row — Figma: Google icon + label, no background.
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadiiTokens.borderRadiusXl,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.googleLogo,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Text(
              label,
              style: AppSemanticTextStyles.button.copyWith(
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
