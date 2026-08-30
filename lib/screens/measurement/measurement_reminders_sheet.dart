import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_toggle.dart';
import 'package:pet_circle/widgets/reminder_time_row.dart';
import 'package:pet_circle/widgets/round_icon_button.dart';
import 'package:pet_circle/widgets/segmented_control.dart';

/// Bottom sheet for configuring recurring measurement reminders.
///
/// Lives next to the feature it controls (the Measure tab) rather than in
/// Settings. Purely a view over [settingsStore] — the store already derives
/// [SettingsStore.measurementReminderDays] from the chosen frequency and
/// notifies `main.dart`, which reschedules through `ReminderService`.
class MeasurementRemindersSheet extends StatelessWidget {
  const MeasurementRemindersSheet({super.key});

  /// Weekly cadences offered by the segmented control, in display order.
  static const List<int> frequencyOptions = <int>[2, 3, 7];

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadiiTokens.pcCard),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacingTokens.pcXl,
            AppSpacingTokens.pcLg,
            AppSpacingTokens.pcXl,
            AppSpacingTokens.pcXl,
          ),
          child: ListenableBuilder(
            listenable: settingsStore,
            builder: (context, _) {
              final enabled = settingsStore.measurementRemindersEnabled;
              final labels = <int, String>{
                2: l10n.frequencyTwoPerWeek,
                3: l10n.frequencyThreePerWeek,
                7: l10n.frequencyDaily,
              };
              final frequency = settingsStore.measurementReminderFrequency;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.measurementReminders,
                          style: AppSemanticTextStyles.headingH2,
                        ),
                      ),
                      RoundIconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: c.textPrimary,
                        ),
                        variant: RoundIconButtonVariant.ghost,
                        size: 36,
                        iconSize: 24,
                        semanticLabel: l10n.close,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.pcMd),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.measurementRemindersDesc,
                          style: AppSemanticTextStyles.pcBodyMuted,
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.pcMd),
                      AppToggle(
                        value: enabled,
                        onChanged: (_) =>
                            settingsStore.toggleMeasurementReminders(),
                      ),
                    ],
                  ),
                  if (enabled) ...[
                    const SizedBox(height: AppSpacingTokens.pcLg),
                    Text(
                      l10n.measurementReminderFrequency,
                      style: AppSemanticTextStyles.bodySm.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacingTokens.pcSm),
                    AppSegmentedControl(
                      options: frequencyOptions
                          .map((value) => labels[value]!)
                          .toList(),
                      // Falls back to the 3x label if a persisted document ever
                      // carries a frequency outside the offered set: an
                      // unmatched value would leave every segment looking
                      // inactive rather than showing the stored cadence.
                      value: labels[frequency] ?? labels[3]!,
                      onChanged: (label) {
                        final index = frequencyOptions.indexWhere(
                          (value) => labels[value] == label,
                        );
                        if (index >= 0) {
                          settingsStore.setMeasurementReminderFrequency(
                            frequencyOptions[index],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacingTokens.pcSm),
                    ReminderTimeRow(
                      label: l10n.measurementReminderTime,
                      value: TimeOfDay(
                        hour: settingsStore.measurementReminderHour,
                        minute: settingsStore.measurementReminderMinute,
                      ),
                      onChanged: (picked) => settingsStore
                          .setMeasurementReminderTime(picked.hour, picked.minute),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
