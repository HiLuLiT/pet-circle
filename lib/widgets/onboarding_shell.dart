import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';

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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
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
                Flexible(
                  child: SingleChildScrollView(
                    child: child,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.lg),
                Row(
                  children: [
                    if (onBack != null)
                      Expanded(
                        child: PrimaryButton(
                          label: l10n.back,
                          backgroundColor: c.surface,
                          foregroundColor: c.textPrimary,
                          onPressed: isNextLoading ? null : onBack,
                        ),
                      ),
                    if (onBack != null && (onNext != null || isNextLoading))
                      const SizedBox(width: AppSpacingTokens.sm),
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
              ],
            ),
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
