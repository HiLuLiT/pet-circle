import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/theme/tokens/typography.dart';

/// Marketing landing (Figma Welcome 181:789). [AppRoutes.welcome] `/`.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    return Scaffold(
      backgroundColor: c.primaryLightest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacingTokens.xl),
              Text(
                l10n.appTitle,
                style: AppTypography.regularNoneBold.copyWith(
                  color: AppPrimitives.inkBase,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              Text(
                l10n.welcomeTagline,
                style: AppSemanticTextStyles.title2.copyWith(
                  color: c.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacingTokens.sm),
                  child: SvgPicture.asset(
                    AppAssets.welcomeCombined,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacingTokens.lg,
                ),
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.signup),
                  style: TextButton.styleFrom(
                    backgroundColor: c.surface,
                    foregroundColor: c.textPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.xl,
                      vertical: AppSpacingTokens.md,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    l10n.getStarted,
                    style: AppSemanticTextStyles.button.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
