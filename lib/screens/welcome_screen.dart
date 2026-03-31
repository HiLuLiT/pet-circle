import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    return Scaffold(
      backgroundColor: c.primaryLightest,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SizedBox(
                        width: double.infinity,
                        height: 248,
                        child: SvgPicture.asset(
                          AppAssets.welcomeGraphic,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      _PrimaryPillButton(
                        label: l10n.signUp,
                        textColor: c.onPrimary,
                        backgroundColor: c.primary,
                        onTap: () => context.push(AppRoutes.roleSelection),
                      ),
                      const SizedBox(height: 12),
                      _SignInButton(
                        onTap: () =>
                            context.push('${AppRoutes.auth}?signIn=true'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadiiTokens.borderRadiusFull,
            ),
          ),
          child: Text(
            label,
            style: AppSemanticTextStyles.body.copyWith(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.48,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            backgroundColor: c.surface,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadiiTokens.borderRadiusFull,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 18, color: c.textPrimary),
              const SizedBox(width: AppSpacingTokens.sm),
              Text(
                AppLocalizations.of(context)!.signIn,
                style: AppSemanticTextStyles.body.copyWith(
                  color: c.textPrimary,
                  fontSize: 16,
                  letterSpacing: -0.32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
