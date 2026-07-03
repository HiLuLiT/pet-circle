import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/mascot.dart';
import 'package:pet_circle/widgets/primary_button.dart';

/// Marketing landing (Figma Welcome, DS node 402:1682). [AppRoutes.welcome] `/`.
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
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 5),
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: c.accentPeriwinkleTile,
                  shape: BoxShape.circle,
                ),
                child: Align(
                  alignment: const Alignment(0, 0.15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _MascotBubble(
                        breed: MascotBreed.fluffy,
                        tileColor: c.accentMintTile,
                        mascotColor: c.accentMint,
                        bubbleSize: 72,
                        mascotSize: 54,
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      _MascotBubble(
                        breed: MascotBreed.floppy,
                        tileColor: c.accentPurpleTile,
                        mascotColor: c.accentPurple,
                        bubbleSize: 110,
                        mascotSize: 82,
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      _MascotBubble(
                        breed: MascotBreed.whiskers,
                        tileColor: c.accentBlushTile,
                        mascotColor: c.accentBlush,
                        bubbleSize: 72,
                        mascotSize: 54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xl),
              child: Column(
                children: [
                  Text(
                    l10n.welcomeTagline,
                    style: AppSemanticTextStyles.pcDisplayL.copyWith(
                      color: c.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.pcMd),
                  Text(
                    l10n.landingSubtitle,
                    style: AppSemanticTextStyles.labelLRegular.copyWith(
                      color: c.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacingTokens.pcMd),
                  PrimaryButton(
                    label: l10n.getStarted,
                    variant: PrimaryButtonVariant.filled,
                    onPressed: () => context.push(AppRoutes.signup),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacingTokens.xl),
          ],
        ),
      ),
    );
  }
}

/// A single mascot silhouette inside a circular tinted bubble (per the Figma
/// "Welcome" composition).
class _MascotBubble extends StatelessWidget {
  const _MascotBubble({
    required this.breed,
    required this.tileColor,
    required this.mascotColor,
    required this.bubbleSize,
    required this.mascotSize,
  });

  final MascotBreed breed;
  final Color tileColor;
  final Color mascotColor;
  final double bubbleSize;
  final double mascotSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: bubbleSize,
      height: bubbleSize,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: tileColor,
        shape: BoxShape.circle,
      ),
      child: Mascot(breed: breed, color: mascotColor, size: mascotSize),
    );
  }
}
