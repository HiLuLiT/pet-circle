import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

/// Shared DS text-input decoration — matches the Figma DS "Input" component
/// (node 465:3730 "Type=Text input", DS node 402-1191): white fill, radius
/// [AppRadiiTokens.pcField] (12), no idle border, `p16` content padding,
/// tertiary-tinted Body/Regular placeholder.
///
/// A 2px [AppSemanticColors.primary] ring appears on focus for accessible
/// keyboard-navigation affordance (the DS static mock has no focus state).
///
/// [hintText] is optional — omit it for call sites that use a Material
/// floating [InputDecoration.labelText] instead (via `.copyWith(labelText:
/// ...)`), since setting both to the same string renders the string twice.
///
/// [prefixIcon] renders a leading 24x24 icon per the DS "Input / Text input
/// with icon" variant (node 465:3736): content padding becomes `pl12 pr16
/// py16` (vs `p16` with no icon) with an 8px gap between the icon and text.
InputDecoration appInputDecoration(
  BuildContext context, {
  String? hintText,
  Widget? prefixIcon,
}) {
  final c = AppSemanticColors.of(context);
  final radius = BorderRadius.circular(AppRadiiTokens.pcField);

  final noBorder = OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide.none,
  );
  final focusBorder = OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(color: c.primary, width: 2),
  );
  final errorBorder = OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(color: c.error, width: 1),
  );
  final focusedErrorBorder = OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(color: c.error, width: 2),
  );

  return InputDecoration(
    filled: true,
    fillColor: c.surface,
    hintText: hintText,
    hintStyle: AppSemanticTextStyles.pcBody.copyWith(color: c.textTertiary),
    contentPadding: prefixIcon == null
        ? const EdgeInsets.all(16)
        : const EdgeInsets.fromLTRB(0, 16, 16, 16),
    prefixIcon: prefixIcon == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: SizedBox(width: 24, height: 24, child: prefixIcon),
          ),
    prefixIconConstraints: prefixIcon == null
        ? null
        : const BoxConstraints(minWidth: 0, minHeight: 0),
    border: noBorder,
    enabledBorder: noBorder,
    focusedBorder: focusBorder,
    errorBorder: errorBorder,
    focusedErrorBorder: focusedErrorBorder,
  );
}
