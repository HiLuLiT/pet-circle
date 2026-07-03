import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_dropdown.dart';
import 'package:pet_circle/widgets/app_input_decoration.dart';
import 'package:pet_circle/widgets/toggle_pill.dart';

class ValidatedFormField extends StatelessWidget {
  const ValidatedFormField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacingTokens.sm),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: appInputDecoration(context, hintText: hint).copyWith(
            errorStyle: AppSemanticTextStyles.caption.copyWith(color: c.error),
          ),
        ),
      ],
    );
  }
}

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.controller,
    required this.onTap,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacingTokens.sm),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: appInputDecoration(context, hintText: l10n.dateFormatHint)
              .copyWith(
            suffixIcon: Icon(Icons.calendar_today,
                size: 18, color: c.textPrimary.withValues(alpha: 0.5)),
            errorStyle: AppSemanticTextStyles.caption.copyWith(color: c.error),
          ),
        ),
      ],
    );
  }
}

/// Frequency selector backed by the shared PC v3 [AppDropdown].
///
/// Public API is preserved: callers supply the *canonical* [value]
/// (`'Once daily'` / `'Twice daily'` / `'As needed'`) and receive the same
/// canonical string back through [onChanged]. Internally the widget maps
/// canonical values to their localised display labels for presentation, and
/// maps the chosen display label back to canonical on selection.
class DropdownField extends StatefulWidget {
  const DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  /// Stable, ordered canonical values — kept in sync with the parallel
  /// localised display labels built in [build].
  static const List<String> _canonicalValues = <String>[
    'Once daily',
    'Twice daily',
    'As needed',
  ];

  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Display labels parallel to [_canonicalValues] (same order/length).
    final displayLabels = <String>[
      l10n.onceDaily,
      l10n.twiceDaily,
      l10n.asNeeded,
    ];

    final selectedIndex = _canonicalValues.indexOf(widget.value);
    final selectedLabel =
        selectedIndex >= 0 ? displayLabels[selectedIndex] : null;

    return AppDropdown(
      label: widget.label,
      value: selectedLabel,
      isOpen: _isOpen,
      options: displayLabels,
      onTap: () => setState(() => _isOpen = !_isOpen),
      onOptionSelected: (chosenLabel) {
        final index = displayLabels.indexOf(chosenLabel);
        if (index >= 0) {
          widget.onChanged(_canonicalValues[index]);
        }
        setState(() => _isOpen = false);
      },
    );
  }
}

class ValidatedTextArea extends StatelessWidget {
  const ValidatedTextArea({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacingTokens.sm),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: appInputDecoration(context, hintText: hint).copyWith(
            errorStyle: AppSemanticTextStyles.caption.copyWith(color: c.error),
          ),
        ),
      ],
    );
  }
}

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md, vertical: AppSpacingTokens.sm + 4),
      decoration: BoxDecoration(
          color: c.primaryLight,
          borderRadius: BorderRadius.circular(AppRadiiTokens.sm)),
      child: Row(
        children: [
          Icon(Icons.notifications_none, color: c.textPrimary, size: 20),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.medicationReminders,
                    style: AppSemanticTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 1),
                Text(l10n.medicationRemindersDesc,
                    style: AppSemanticTextStyles.caption),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!enabled),
            child: TogglePill(isOn: enabled),
          ),
        ],
      ),
    );
  }
}
