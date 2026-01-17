import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/labeled_text_field.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

class OnboardingStep1 extends StatelessWidget {
  const OnboardingStep1({super.key, this.onNext});

  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: 'Setup pet profile',
      stepLabel: 'Step 1 of 4',
      progress: 0.25,
      onNext: onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Tell us about your pet', style: AppTextStyles.heading3),
          SizedBox(height: AppSpacing.md),
          LabeledTextField(label: "Pet's Name", hintText: 'e.g., Max'),
          SizedBox(height: AppSpacing.md),
          LabeledTextField(label: 'Breed', hintText: 'e.g., Golden Retriever'),
          SizedBox(height: AppSpacing.md),
          LabeledTextField(
            label: 'Age (years)',
            hintText: 'e.g., 8',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: AppSpacing.md),
          LabeledTextField(label: 'Photo URL (Optional)', hintText: 'https://...'),
        ],
      ),
    );
  }
}
