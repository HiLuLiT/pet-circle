import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

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
  });

  final String stepLabel;
  final double progress;
  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? nextLabel;
  final bool isNextLoading;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.lg),
            padding: const EdgeInsets.all(AppSpacingTokens.xl),
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.circular(AppSpacingTokens.md),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(stepLabel: stepLabel, progress: progress, title: title),
                const SizedBox(height: AppSpacingTokens.xl),
                Flexible(child: child),
                const SizedBox(height: AppSpacingTokens.lg),
                Row(
                  children: [
                    if (onBack != null)
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextButton(
                            onPressed: isNextLoading ? null : onBack,
                            style: TextButton.styleFrom(
                              backgroundColor: c.surface,
                              disabledBackgroundColor:
                                  c.surface.withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSpacingTokens.xl),
                              ),
                            ),
                            child: Text(
                              l10n.back,
                              style: AppSemanticTextStyles.button.copyWith(
                                color: isNextLoading
                                    ? AppPrimitives.inkDarkest
                                        .withValues(alpha: 0.4)
                                    : AppPrimitives.inkDarkest,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (onBack != null && (onNext != null || isNextLoading))
                      const SizedBox(width: 12),
                    if (onNext != null || isNextLoading)
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextButton(
                            onPressed: isNextLoading ? null : onNext,
                            style: TextButton.styleFrom(
                              backgroundColor: c.primary,
                              disabledBackgroundColor: c.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSpacingTokens.xl),
                              ),
                            ),
                            child: isNextLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: c.onPrimary,
                                    ),
                                  )
                                : Text(
                                    nextLabel ?? l10n.done,
                                    style: AppSemanticTextStyles.button.copyWith(
                                      color: c.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.stepLabel,
    required this.progress,
    required this.title,
  });

  final String stepLabel;
  final double progress;
  final String title;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: AppSemanticTextStyles.title2),
            ),
            Text(
              stepLabel,
              style: AppSemanticTextStyles.caption.copyWith(
                color: c.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(1000),
          child: Container(
            height: 8,
            color: c.divider,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(color: c.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
