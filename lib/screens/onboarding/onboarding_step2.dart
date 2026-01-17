import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

class OnboardingStep2 extends StatelessWidget {
  const OnboardingStep2({super.key, this.onBack, this.onNext});

  final VoidCallback? onBack;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: 'Setup pet profile',
      stepLabel: 'Step 2 of 4',
      progress: 0.5,
      onBack: onBack,
      onNext: onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Medical Information', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'This helps us provide more accurate monitoring recommendations.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Diagnosis (Optional)',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hintText: 'e.g., Mitral valve disease, DCM, etc.',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Additional Notes (Optional)',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hintText: 'Any other medical history or notes...',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
