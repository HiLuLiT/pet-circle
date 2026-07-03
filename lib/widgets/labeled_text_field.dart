import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

/// Labeled text field — Pet Circle v3 / Claude-Design palette port of the
/// React `TextInput` component.
///
/// Visuals (per Figma TextInput):
///   - Height 54
///   - Background = `surface` (white)
///   - Radius = `AppRadiiTokens.pcField` (14)
///   - Padding 0px vertical, 16px horizontal
///   - Text style = `AppSemanticTextStyles.pcBody` (16px Instrument Sans, ink)
///   - Border = 1px `hairline` on enabled/idle
///   - Focus = 3px `accentPurple` ring (approximating the React focus shadow)
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
    final fieldRadius = BorderRadius.circular(AppRadiiTokens.pcField);

    final idleBorder = OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide(color: c.hairline, width: 1),
    );

    final focusBorder = OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide(color: c.accentPurple, width: 3),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppSemanticTextStyles.labelSm,
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: AppSemanticTextStyles.pcBody.copyWith(
              color: c.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: c.surface,
              hintText: hintText,
              hintStyle: AppSemanticTextStyles.pcBody.copyWith(
                color: c.textTertiary,
              ),
              isDense: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              constraints: const BoxConstraints(minHeight: 54),
              border: idleBorder,
              enabledBorder: idleBorder,
              focusedBorder: focusBorder,
            ),
          ),
        ),
      ],
    );
  }
}
