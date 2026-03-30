import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.controller,
    this.onChanged,
  });

  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
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
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: c.white,
              hintText: hintText,
              hintStyle: AppTextStyles.body.copyWith(
                color: c.chocolate.withValues(alpha: 0.3),
              ),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(AppRadii.xs),
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
