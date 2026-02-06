import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.keyboardType,
  });

  final String label;
  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 36,
          child: TextField(
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hintText: hintText,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.chocolate.withOpacity(0.3),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }
}
