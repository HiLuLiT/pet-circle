import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 248,
                  height: 248,
                  child: SvgPicture.asset(
                    AppAssets.welcomeGraphic,
                    fit: BoxFit.contain,
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
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.roleSelection),
                  ),
                  const SizedBox(height: 12),
                  _GoogleButton(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.roleSelection),
                  ),
                ],
              ),
            ),
          ],
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
    return SizedBox(
      width: 247,
      height: 58,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(172),
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
    );
  }
}

class _GoogleButton extends StatelessWidget {
  _GoogleButton({required this.onTap});

  final VoidCallback onTap;
  static const _googleLogoAsset = 'assets/figma/google_logo.png';

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return SizedBox(
      width: 247,
      height: 58,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: c.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(172),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(_googleLogoAsset, width: 18, height: 18),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.signInWithGoogle,
              style: AppTextStyles.body.copyWith(
                color: c.chocolate,
                fontSize: 16,
                letterSpacing: -0.32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
