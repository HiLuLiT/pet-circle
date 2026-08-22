import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/widgets/primary_button.dart';

/// Onboarding completion screen — Figma node 424:6047 ("Step 5 (All Set)").
///
/// Shown once the pet has actually been created, so the "profile is ready"
/// copy is true by the time the user reads it. Deliberately has none of the
/// [OnboardingShell] chrome: no Back button, no progress bar, no step label —
/// the Figma frame holds only the mascot, the two lines of copy and the CTA.
///
/// Geometry is taken verbatim from the 393x852 frame: the mascot frame sits at
/// y=109 (65 below the 44pt status bar), the copy block at y=316 and the button
/// at y=444, all on a 32pt horizontal margin.
class OnboardingStep5 extends StatelessWidget {
  const OnboardingStep5({super.key, required this.petName, this.onEnter});

  /// Name of the pet just created — interpolated into the subtitle.
  final String petName;

  /// Invoked by the "Enter Pet Circle" CTA.
  final VoidCallback? onEnter;

  /// Figma: Frame 424:6049 — the 201x202 box the mascot is composed inside.
  static const _mascotFrameWidth = 201.0;
  static const _mascotFrameHeight = 202.0;

  /// Figma: Object 601:1260 — the mascot's size and offset within that frame.
  /// It is nudged 4px right of the frame centre, hence the asymmetric left.
  static const _mascotWidth = 136.093;
  static const _mascotHeight = 162.697;
  static const _mascotLeft = 36.454;
  static const _mascotTop = 19.027;

  /// Vertical rhythm, measured between the Figma frames.
  static const _statusBarToMascot = 65.0; // 109 - 44
  static const _mascotToCopy = 5.0; // 316 - 311
  static const _titleToSubtitle = 12.0; // copy frame gap
  static const _copyToButton = 40.0; // 444 - 404
  static const _horizontalMargin = 32.0; // frame x=32, width 329

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalMargin,
            ),
            child: Column(
              children: [
                const SizedBox(height: _statusBarToMascot),
                SizedBox(
                  width: _mascotFrameWidth,
                  height: _mascotFrameHeight,
                  child: Stack(
                    children: [
                      Positioned(
                        left: _mascotLeft,
                        top: _mascotTop,
                        width: _mascotWidth,
                        height: _mascotHeight,
                        child: Image.asset(
                          AppAssets.onboardingAllSetDog,
                          width: _mascotWidth,
                          height: _mascotHeight,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: _mascotToCopy),
                Text(
                  l10n.allSetTitle,
                  textAlign: TextAlign.center,
                  style: AppSemanticTextStyles.pcDisplay.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: _titleToSubtitle),
                Text(
                  l10n.allSetSubtitle(petName),
                  textAlign: TextAlign.center,
                  style: AppSemanticTextStyles.labelLRegular.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: _copyToButton),
                PrimaryButton(
                  label: l10n.enterPetCircle,
                  onPressed: onEnter,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
