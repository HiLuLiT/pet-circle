import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/round_icon_button.dart';

class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    super.key,
    required this.stepLabel,
    required this.progress,
    required this.title,
    required this.child,
    this.onBack,
    this.onNext,
    this.nextLabel,
    this.isNextLoading = false,
    this.onClose,
  });

  /// Kept for API compatibility with existing call sites — the current DS
  /// spec (Figma nodes 402:1861 "Step 1", 402:1880 "Step 2") drops the
  /// "Step X of Y" text entirely in favor of the progress bar alone, so this
  /// is accepted but no longer rendered.
  final String stepLabel;
  final double progress;
  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? nextLabel;
  final bool isNextLoading;

  /// When non-null, a close (X) button is shown in the header so the user can
  /// exit the flow (e.g. "Add pet" launched from the dashboard). Left null for
  /// mandatory new-user onboarding where there is nowhere to go back to.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
              child: _ProgressBar(progress: progress),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 36, 32, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onClose != null)
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: IconButton(
                          onPressed: isNextLoading ? null : onClose,
                          icon: const Icon(Icons.close),
                          tooltip: l10n.close,
                          color: c.textSecondary,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    Text(
                      title,
                      style: AppSemanticTextStyles.pcDisplay.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacingTokens.pcLg + 2),
                    Expanded(
                      child: SingleChildScrollView(
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, AppSpacingTokens.pcMd, 32, 32),
              child: Row(
                children: [
                  if (onBack != null) ...[
                    RoundIconButton(
                      icon: const Icon(Icons.arrow_back),
                      variant: RoundIconButtonVariant.ghost,
                      iconSize: 24,
                      semanticLabel: l10n.back,
                      onTap: isNextLoading ? null : onBack,
                    ),
                    const SizedBox(width: AppSpacingTokens.sm + 4),
                  ],
                  if (onNext != null || isNextLoading)
                    Expanded(
                      child: isNextLoading
                          ? PrimaryButton(
                              label: '',
                              onPressed: null,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: c.onPrimary,
                                ),
                              ),
                            )
                          : PrimaryButton(
                              label: nextLabel ?? l10n.done,
                              onPressed: onNext,
                            ),
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

/// Thin pill progress bar per Figma node 402:1861 — white track, purple
/// fill, height 4 (distinct from the shared `ProgressBar` widget's default
/// styling, since the DS onboarding spec fixes bg/height precisely).
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return ClipRRect(
      borderRadius: AppRadiiTokens.borderRadiusFull,
      child: Container(
        height: 4,
        color: c.surface,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(color: c.primary),
          ),
        ),
      ),
    );
  }
}
