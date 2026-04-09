import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

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
    final c = AppSemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppSemanticTextStyles.labelSm,
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppPrimitives.skyLighter,
              hintText: hintText,
              hintStyle: AppSemanticTextStyles.body.copyWith(
                color: AppPrimitives.skyDark,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadiiTokens.borderRadiusLg,
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm + 4, vertical: AppSpacingTokens.xs),
            ),
            style: AppSemanticTextStyles.body.copyWith(
              color: c.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
