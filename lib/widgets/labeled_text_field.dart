import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_input_decoration.dart';

/// Labeled text field — Pet Circle v3 / Claude-Design palette port of the
/// Figma DS "Input" component (node 465:3730, DS node 402-1191).
///
/// Visuals (per Figma DS Input):
///   - Height 54
///   - Background = `surface` (white)
///   - Radius = `AppRadiiTokens.pcField` (12)
///   - Padding 16px on all sides (see [appInputDecoration])
///   - Text style = `AppSemanticTextStyles.pcBody` (16px Instrument Sans, ink)
///   - No border on idle/enabled — matches the DS's borderless white field
///   - Focus = 2px `primary` ring (accessible affordance not in the static
///     DS mock)
///   - Label = `AppSemanticTextStyles.labelMSemibold` (14/20 SemiBold) —
///     matches the DS "Full name" label sample exactly
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.controller,
    this.onChanged,
    this.prefixIcon,
  });

  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  /// Optional leading icon (per the DS "Input with icon" variant) — rendered
  /// at 24x24 with an 8px gap before the field text.
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppSemanticTextStyles.labelMSemibold,
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
            decoration: appInputDecoration(
              context,
              hintText: hintText,
              prefixIcon: prefixIcon,
            ).copyWith(
              isDense: false,
              constraints: const BoxConstraints(minHeight: 54),
            ),
          ),
        ),
      ],
    );
  }
}
