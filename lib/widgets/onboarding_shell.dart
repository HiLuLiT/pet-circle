import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_assets.dart';
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
  });

  final String stepLabel;
  final double progress;
  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Scaffold(
      backgroundColor: c.white,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: c.offWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(stepLabel: stepLabel, progress: progress, title: title),
              const SizedBox(height: 32),
              Flexible(child: child),
            ],
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
          borderRadius: BorderRadius.circular(999),
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

