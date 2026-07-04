import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/services/reminder_service.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';
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
        text: _startDate != null ? _formatDate(_startDate!) : '');
    _endDateController = TextEditingController(
        text: _endDate != null ? _formatDate(_endDate!) : '');

    _notesController = TextEditingController(text: med?.notes ?? '');
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
    final initial = isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now);
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
    final petName = petStore.activePet?.name ?? l10n.petName;
    if (petId.isEmpty) return;

    final name = _nameController.text.trim();
    final dosage = _dosageController.text.trim();
    final startDate = _startDate ?? DateTime.now();
    final notes = _notesController.text.trim();

    if (_isEditing) {
      // prescribedBy/purpose/remindersEnabled aren't collected by this form
      // (not part of the Figma spec) — omitted here so copyWith preserves
      // whatever the record already had rather than silently wiping it.
      final updated = widget.medication!.copyWith(
        name: name,
        dosage: dosage,
        frequency: _frequency,
        startDate: startDate,
        endDate: _endDate,
        clearEndDate: _endDate == null,
        notes: notes.isNotEmpty ? notes : null,
      );
      medicationStore.updateMedication(petId, widget.medication!.id, updated);

      if (!kIsWeb) {
        if (updated.hasEndReminder) {
          ReminderService.instance.scheduleMedicationReminder(
            updated,
            title: l10n.medicationEndingTitle,
            body: l10n.medicationEndingBody(updated.name),
          );
        } else {
          ReminderService.instance
              .cancelMedicationReminder(widget.medication!.id);
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
      );
      medicationStore.addMedication(petId, newMed);

      if (!kIsWeb && newMed.hasEndReminder) {
        ReminderService.instance.scheduleMedicationReminder(
          newMed,
          title: l10n.medicationEndingTitle,
          body: l10n.medicationEndingBody(newMed.name),
        );
      }
    }

    notificationStore.addNotification(
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: _isEditing ? l10n.medicationUpdated : l10n.medicationAdded,
        titleKey: _isEditing ? 'medicationUpdated' : 'medicationAdded',
        body: name,
        type: NotificationType.medication,
        createdAt: DateTime.now(),
        petName: petName,
      ),
    );

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
          content: Text(
              _isEditing ? l10n.medicationUpdated : l10n.medicationAdded)),
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
            child: Text(
              l10n.delete,
              style: TextStyle(color: c.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await medicationStore.removeMedication(petId, med.id);
    if (!mounted) return;

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.medicationDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: c.background,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadiiTokens.pcCard)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacingTokens.pcXl,
                AppSpacingTokens.pcLg, AppSpacingTokens.pcXl, AppSpacingTokens.pcXl),
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
                        icon: const Icon(Icons.keyboard_arrow_up),
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
                            petStore.activePet?.name ?? l10n.petName)
                        : l10n.addMedicationDescription(
                            petStore.activePet?.name ?? l10n.petName),
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
                    onChanged: (value) =>
                        setState(() => _frequency = value),
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

