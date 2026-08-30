import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/services/reminder_service.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/app_card.dart';
import 'package:pet_circle/widgets/app_toggle.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/reminder_time_row.dart';
import 'package:pet_circle/widgets/round_icon_button.dart';

import 'medication_form_widgets.dart';

// ---------------------------------------------------------------------------
// Add / Edit Medication Sheet
// ---------------------------------------------------------------------------

class AddMedicationSheet extends StatefulWidget {
  const AddMedicationSheet({super.key, this.medication});

  final Medication? medication;

  @override
  State<AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<AddMedicationSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _frequency;

  /// Default dose time per slot, used when a slot is first revealed.
  /// Index 0 = 09:00 (once/first dose), index 1 = 21:00 (second dose).
  static const List<TimeOfDay> _defaultDoseTimes = <TimeOfDay>[
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 21, minute: 0),
  ];

  /// Number of dose-time rows implied by a canonical frequency value
  /// (see `FrequencyChipSelector`). "As needed" has no fixed schedule.
  static int _doseCountFor(String frequency) {
    switch (frequency) {
      case 'Once daily':
        return 1;
      case 'Twice daily':
        return 2;
      default:
        return 0;
    }
  }

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay? _parseTime(String raw) {
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  bool _remindersEnabled = false;
  List<TimeOfDay> _reminderTimes = const [];

  /// Grow/shrink [_reminderTimes] to [count], preserving already-chosen
  /// values (grow appends the next default; shrink drops the tail).
  static List<TimeOfDay> _resizeTimes(List<TimeOfDay> current, int count) {
    if (current.length == count) return current;
    if (current.length > count) {
      return List<TimeOfDay>.unmodifiable(current.take(count));
    }
    return List<TimeOfDay>.unmodifiable([
      ...current,
      for (var i = current.length; i < count; i++)
        _defaultDoseTimes[i < _defaultDoseTimes.length
            ? i
            : _defaultDoseTimes.length - 1],
    ]);
  }

  /// The times to persist: empty unless reminders are on AND the frequency
  /// defines a fixed dose schedule.
  List<String> get _reminderTimeStrings => _remindersEnabled
      ? _reminderTimes.map(_formatTime).toList(growable: false)
      : const <String>[];

  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _notesController;

  DateTime? _startDate;
  DateTime? _endDate;

  bool get _isEditing => widget.medication != null;

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    final med = widget.medication;
    _nameController = TextEditingController(text: med?.name ?? '');
    _dosageController = TextEditingController(text: med?.dosage ?? '');
    _frequency = med?.frequency ?? 'Once daily';

    _startDate = med?.startDate;
    _endDate = med?.endDate;
    _startDateController = TextEditingController(
      text: _startDate != null ? _formatDate(_startDate!) : '',
    );
    _endDateController = TextEditingController(
      text: _endDate != null ? _formatDate(_endDate!) : '',
    );

    _notesController = TextEditingController(text: med?.notes ?? '');

    _remindersEnabled = med?.remindersEnabled ?? false;
    final seeded = (med?.reminderTimes ?? const <String>[])
        .map(_parseTime)
        .whereType<TimeOfDay>()
        .toList(growable: false);
    _reminderTimes = _resizeTimes(seeded, _doseCountFor(_frequency));
  }

  void _onFrequencyChanged(String value) {
    setState(() {
      _frequency = value;
      _reminderTimes = _resizeTimes(_reminderTimes, _doseCountFor(value));
    });
  }

  void _onDoseTimeChanged(int index, TimeOfDay picked) {
    setState(() {
      _reminderTimes = List<TimeOfDay>.unmodifiable([
        for (var i = 0; i < _reminderTimes.length; i++)
          i == index ? picked : _reminderTimes[i],
      ]);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);
    final firstDate = isStart ? DateTime(2000) : (_startDate ?? DateTime(2000));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateController.text = _formatDate(picked);
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
          _endDateController.clear();
        }
      } else {
        _endDate = picked;
        _endDateController.text = _formatDate(picked);
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final access = petStore.accessForActivePet();
    if (!access.canManageMedication) return;
    final petId = petStore.activePet?.id ?? '';
    final l10n = AppLocalizations.of(context)!;
    if (petId.isEmpty) return;

    final name = _nameController.text.trim();
    final dosage = _dosageController.text.trim();
    final startDate = _startDate ?? DateTime.now();
    final notes = _notesController.text.trim();

    final reminderTimes = _reminderTimeStrings;

    if (_isEditing) {
      // prescribedBy/purpose aren't collected by this form (not part of the
      // Figma spec) — omitted here so copyWith preserves whatever the record
      // already had rather than silently wiping it.
      final updated = widget.medication!.copyWith(
        name: name,
        dosage: dosage,
        frequency: _frequency,
        startDate: startDate,
        endDate: _endDate,
        clearEndDate: _endDate == null,
        notes: notes.isNotEmpty ? notes : null,
        remindersEnabled: _remindersEnabled,
        reminderTimes: reminderTimes,
      );
      medicationStore.updateMedication(petId, widget.medication!.id, updated);

      if (!kIsWeb) {
        if (updated.hasEndReminder) {
          ReminderService.instance.scheduleMedicationReminder(
            updated,
            title: l10n.medicationEndingTitle,
            body: l10n.medicationEndingBody(
              petStore.activePet?.name ?? updated.name,
              updated.name,
            ),
          );
        } else {
          ReminderService.instance.cancelMedicationReminder(
            widget.medication!.id,
          );
        }

        if (updated.hasDoseReminders) {
          ReminderService.instance.scheduleMedicationDoseReminders(
            updated,
            times: updated.reminderTimes,
            title: l10n.medicationDoseTitle(updated.name),
            body: l10n.medicationDoseBody(
              petStore.activePet?.name ?? updated.name,
              updated.dosage,
              updated.name,
            ),
          );
        } else {
          ReminderService.instance.cancelMedicationDoseReminders(
            widget.medication!.id,
          );
        }
      }
    } else {
      final newMed = Medication(
        id: 'med-${DateTime.now().millisecondsSinceEpoch}',
        petId: petId,
        name: name,
        dosage: dosage,
        frequency: _frequency,
        startDate: startDate,
        endDate: _endDate,
        notes: notes.isNotEmpty ? notes : null,
        remindersEnabled: _remindersEnabled,
        reminderTimes: reminderTimes,
      );
      medicationStore.addMedication(petId, newMed);

      if (!kIsWeb) {
        if (newMed.hasEndReminder) {
          ReminderService.instance.scheduleMedicationReminder(
            newMed,
            title: l10n.medicationEndingTitle,
            body: l10n.medicationEndingBody(
              petStore.activePet?.name ?? newMed.name,
              newMed.name,
            ),
          );
        }
        if (newMed.hasDoseReminders) {
          ReminderService.instance.scheduleMedicationDoseReminders(
            newMed,
            times: newMed.reminderTimes,
            title: l10n.medicationDoseTitle(newMed.name),
            body: l10n.medicationDoseBody(
              petStore.activePet?.name ?? newMed.name,
              newMed.dosage,
              newMed.name,
            ),
          );
        }
      }
    }

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? l10n.medicationUpdated : l10n.medicationAdded,
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final med = widget.medication;
    if (med == null) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    final access = petStore.accessForActivePet();
    if (!access.canManageMedication) return;
    final petId = petStore.activePet?.id ?? '';
    if (petId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteMedication),
        content: Text(l10n.deleteMedicationConfirmation(med.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete, style: TextStyle(color: c.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await medicationStore.removeMedication(petId, med.id);
    if (!mounted) return;

    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(l10n.medicationDeleted)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        // minHeight (not a fixed height) pins the sheet's top edge near the
        // top of the screen regardless of how short the form content is,
        // while still letting it grow taller (and scroll) if content ever
        // exceeds this. Without it the sheet only grew tall enough to fit
        // its content, stopping partway down the screen instead of reaching
        // the top like a full-height drawer.
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadiiTokens.pcCard),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacingTokens.pcXl,
              AppSpacingTokens.pcLg,
              AppSpacingTokens.pcXl,
              AppSpacingTokens.pcXl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _isEditing
                              ? l10n.editMedication
                              : l10n.addNewMedication,
                          style: AppSemanticTextStyles.pcDisplay,
                        ),
                      ),
                      if (_isEditing)
                        IconButton(
                          onPressed: _confirmDelete,
                          icon: Icon(Icons.delete_outline, color: c.error),
                          tooltip: l10n.deleteMedication,
                        ),
                      RoundIconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_up,
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
                  const SizedBox(height: AppSpacingTokens.pcSm),
                  Text(
                    _isEditing
                        ? l10n.updateMedicationDescription(
                            petStore.activePet?.name ?? l10n.petName,
                          )
                        : l10n.addMedicationDescription(
                            petStore.activePet?.name ?? l10n.petName,
                          ),
                    style: AppSemanticTextStyles.pcBodyMuted,
                  ),
                  const SizedBox(height: AppSpacingTokens.pcXl),
                  ValidatedFormField(
                    label: l10n.medicationNameRequired,
                    hint: l10n.hintMedicationName,
                    controller: _nameController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacingTokens.pcMd),
                  ValidatedFormField(
                    label: l10n.dosageRequired,
                    hint: l10n.hintDosage,
                    controller: _dosageController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacingTokens.pcMd),
                  FrequencyChipSelector(
                    label: l10n.frequencyRequired,
                    value: _frequency,
                    onChanged: _onFrequencyChanged,
                  ),
                  const SizedBox(height: AppSpacingTokens.pcMd),
                  _RemindersSection(
                    enabled: _remindersEnabled,
                    times: _reminderTimes,
                    onEnabledChanged: (value) =>
                        setState(() => _remindersEnabled = value),
                    onTimeChanged: _onDoseTimeChanged,
                  ),
                  const SizedBox(height: AppSpacingTokens.pcMd),
                  Row(
                    children: [
                      Expanded(
                        child: DatePickerField(
                          label: l10n.startDateRequired,
                          controller: _startDateController,
                          onTap: () => _pickDate(isStart: true),
                          validator: (v) => (v == null || v.isEmpty)
                              ? l10n.fieldRequired
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.pcMd),
                      Expanded(
                        child: DatePickerField(
                          label: l10n.endDateOptional,
                          controller: _endDateController,
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.pcMd),
                  ValidatedTextArea(
                    label: l10n.additionalNotes,
                    hint: l10n.hintMedicationNotes,
                    controller: _notesController,
                  ),
                  const SizedBox(height: AppSpacingTokens.pcLg),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: l10n.cancel,
                          variant: PrimaryButtonVariant.outlined,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.pcMd),
                      Expanded(
                        child: PrimaryButton(
                          label: _isEditing ? l10n.save : l10n.addMedication,
                          variant: PrimaryButtonVariant.filled,
                          onPressed: _save,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Per-medication reminders block
// ---------------------------------------------------------------------------

/// On/off switch plus the dose-time rows it reveals.
///
/// The number of rows is driven entirely by [times] — the parent derives it
/// from the selected frequency, so "As needed" simply passes an empty list
/// and the toggle then governs only the end-of-course reminder.
class _RemindersSection extends StatelessWidget {
  const _RemindersSection({
    required this.enabled,
    required this.times,
    required this.onEnabledChanged,
    required this.onTimeChanged,
  });

  final bool enabled;
  final List<TimeOfDay> times;
  final ValueChanged<bool> onEnabledChanged;
  final void Function(int index, TimeOfDay picked) onTimeChanged;

  String _labelFor(AppLocalizations l10n, int index) {
    if (times.length == 1) return l10n.medicationReminderTime;
    return index == 0
        ? l10n.medicationFirstDoseTime
        : l10n.medicationSecondDoseTime;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacingTokens.pcMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.medicationRemindersLabel,
                      style: AppSemanticTextStyles.labelMSemibold,
                    ),
                    const SizedBox(height: AppSpacingTokens.pcXs),
                    Text(
                      l10n.medicationRemindersDesc,
                      style: AppSemanticTextStyles.pcCaption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.pcMd),
              AppToggle(value: enabled, onChanged: onEnabledChanged),
            ],
          ),
          if (enabled && times.isNotEmpty) ...[
            const SizedBox(height: AppSpacingTokens.pcSm),
            for (var i = 0; i < times.length; i++)
              ReminderTimeRow(
                label: _labelFor(l10n, i),
                value: times[i],
                onChanged: (picked) => onTimeChanged(i, picked),
              ),
          ],
        ],
      ),
    );
  }
}
