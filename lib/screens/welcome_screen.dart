import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);

    return Scaffold(
      backgroundColor: c.pink,
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
                        textColor: c.white,
                        backgroundColor: c.chocolate,
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
              borderRadius: const BorderRadius.all(AppRadii.pill),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
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
    final c = AppColorsTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            backgroundColor: c.white,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(AppRadii.pill),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 18, color: AppColorsTheme.of(context).chocolate),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.signIn,
                style: AppTextStyles.body.copyWith(
                  color: c.chocolate,
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
