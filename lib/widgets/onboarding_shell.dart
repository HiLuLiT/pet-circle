import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_theme.dart';

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
  });

  final String stepLabel;
  final double progress;
  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? nextLabel;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.white,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: c.offWhite,
              borderRadius: const BorderRadius.all(AppRadii.medium),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(stepLabel: stepLabel, progress: progress, title: title),
                const SizedBox(height: 32),
                Flexible(child: child),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (onBack != null)
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextButton(
                            onPressed: onBack,
                            style: TextButton.styleFrom(
                              backgroundColor: c.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(AppRadii.full),
                              ),
                            ),
                            child: Text(
                              l10n.back,
                              style: AppTextStyles.body.copyWith(color: c.chocolate, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    if (onBack != null && onNext != null)
                      const SizedBox(width: 12),
                    if (onNext != null)
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextButton(
                            onPressed: onNext,
                            style: TextButton.styleFrom(
                              backgroundColor: c.chocolate,
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(AppRadii.full),
                              ),
                            ),
                            child: Text(
                              nextLabel ?? l10n.done,
                              style: AppTextStyles.body.copyWith(color: c.white, fontWeight: FontWeight.w600),
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
    final c = AppColorsTheme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: AppTextStyles.heading2),
            ),
            Text(stepLabel, style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: const BorderRadius.all(AppRadii.pill),
          child: Container(
            height: 8,
            color: c.chocolate.withOpacity(0.08),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(color: c.pink),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

