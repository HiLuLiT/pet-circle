import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/pounding_heart_hero.dart';
import 'package:pet_circle/widgets/primary_button.dart';

/// Marketing landing (Figma Welcome, DS node 402:1682). [AppRoutes.welcome] `/`.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  /// Vertical rhythm from Figma: the gaps above the hero, above the CTA, and
  /// below it measure 112 : 140 : 164 in the 852-tall frame.
  static const int _flexAboveHero = 27;
  static const int _flexAboveCta = 34;
  static const int _flexBelowCta = 39;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        // Scroll only when the viewport is too short for the fixed-height
        // content; IntrinsicHeight bounds the column so Spacer stays legal.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(flex: _flexAboveHero),
                    const PoundingHeartHero(),
                    const SizedBox(height: AppSpacingTokens.pcLg),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacingTokens.xl,
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.welcomeTagline,
                            style: AppSemanticTextStyles.pcDisplayL.copyWith(
                              color: c.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacingTokens.md),
                          Text(
                            l10n.landingSubtitle,
                            style: AppSemanticTextStyles.labelLRegular.copyWith(
                              color: c.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: _flexAboveCta),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacingTokens.xl,
                      ),
                      child: PrimaryButton(
                        label: l10n.getStarted,
                        variant: PrimaryButtonVariant.filled,
                        borderRadius: AppRadiiTokens.pcPill,
                        onPressed: () => context.push(AppRoutes.signup),
                      ),
                    ),
                    const Spacer(flex: _flexBelowCta),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
