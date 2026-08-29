import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';

/// A labelled row whose trailing action opens a time picker.
///
/// Extracted from the settings screen so medication dose reminders and
/// measurement reminders can share one presentation. Deliberately free of
/// any feature-specific logic — it only renders [label], the formatted
/// [value], and reports the picked time through [onChanged].
class ReminderTimeRow extends StatelessWidget {
  const ReminderTimeRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// Localised description of what this time controls.
  final String label;

  /// Currently selected time, shown formatted for the active locale.
  final TimeOfDay value;

  /// Called with the newly picked time. Not called when the user cancels.
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppSemanticTextStyles.bodySm.copyWith(
              color: c.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: value,
              initialEntryMode: TimePickerEntryMode.input,
            );
            if (picked != null) onChanged(picked);
          },
          child: Text(value.format(context)),
        ),
      ],
    );
  }
}
