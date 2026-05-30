import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
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
          decoration: InputDecoration(
            filled: true,
            fillColor: c.background,
            hintText: hint,
            hintStyle: AppSemanticTextStyles.body
                .copyWith(color: c.textPrimary.withValues(alpha: 0.3)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.sm + 4, vertical: AppSpacingTokens.xs),
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
          decoration: InputDecoration(
            filled: true,
            fillColor: c.background,
            hintText: l10n.dateFormatHint,
            hintStyle: AppSemanticTextStyles.body
                .copyWith(color: c.textPrimary.withValues(alpha: 0.3)),
            suffixIcon: Icon(Icons.calendar_today,
                size: 18, color: c.textPrimary.withValues(alpha: 0.5)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.sm + 4, vertical: AppSpacingTokens.xs),
            errorStyle: AppSemanticTextStyles.caption.copyWith(color: c.error),
          ),
        ),
      ],
    );
  }
}

class DropdownField extends StatelessWidget {
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
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm + 4),
          decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.circular(AppRadiiTokens.sm)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: [
                DropdownMenuItem(
                    value: 'Once daily', child: Text(l10n.onceDaily)),
                DropdownMenuItem(
                    value: 'Twice daily', child: Text(l10n.twiceDaily)),
                DropdownMenuItem(
                    value: 'As needed', child: Text(l10n.asNeeded)),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
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
          decoration: InputDecoration(
            filled: true,
            fillColor: c.background,
            hintText: hint,
            hintStyle: AppSemanticTextStyles.body
                .copyWith(color: c.textPrimary.withValues(alpha: 0.3)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(AppSpacingTokens.sm + 4),
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
