import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/services/reminder_service.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/toggle_pill.dart';
import 'package:share_plus/share_plus.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  void _openMedicationSheet([Medication? medication]) {
    final access = petStore.accessForActivePet();
    if (!access.canManageMedication) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMedicationSheet(medication: medication),
    );
  }

  Future<void> _exportMedicationLog() async {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final petId = petStore.activePet?.id ?? '';
    final petName = petStore.activePet?.name ?? l10n.petName;
    final meds = medicationStore.getMedications(petId);

    String fmtDate(DateTime? d) {
      if (d == null) return '';
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    String csvEscape(String? v) {
      if (v == null || v.isEmpty) return '';
      if (v.contains(',') || v.contains('"') || v.contains('\n')) {
        return '"${v.replaceAll('"', '""')}"';
      }
      return v;
    }

    final header =
        'Medication,Dosage,Frequency,Start Date,End Date,Status,Prescribed By,Purpose,Notes';
    final csvLines = meds.map((m) {
      final status = m.isActive ? l10n.ongoing : l10n.completed;
      return [
        csvEscape(m.name),
        csvEscape(m.dosage),
        csvEscape(m.frequency),
        fmtDate(m.startDate),
        fmtDate(m.endDate),
        status,
        csvEscape(m.prescribedBy),
        csvEscape(m.purpose),
        csvEscape(m.notes),
      ].join(',');
    }).join('\n');
    final csvData = '$header\n$csvLines';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(AppRadii.medium)),
        title: Text(l10n.exportMedicationLog, style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.csvPreview, style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.sm + 4),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 4),
                decoration: BoxDecoration(
                  color: c.offWhite,
                  borderRadius: const BorderRadius.all(AppRadii.sm),
                ),
                child: Text(csvData,
                    style: AppTextStyles.caption
                        .copyWith(fontFamily: 'monospace', fontSize: 10)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close,
                style: AppTextStyles.body.copyWith(color: c.chocolate)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final dir = await getTemporaryDirectory();
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final file = File(
                    '${dir.path}/${petName}_medications_$timestamp.csv');
                await file.writeAsString(csvData);
                await Share.shareXFiles(
                  [XFile(file.path)],
                  subject: l10n.exportMedicationLog,
                );
              } catch (_) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(l10n.medicationLogExported)),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: c.lightBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(AppRadii.small)),
            ),
            child: Text(l10n.downloadCsv,
                style: AppTextStyles.body.copyWith(color: c.chocolate)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final content = ListenableBuilder(
      listenable: Listenable.merge([medicationStore, petStore]),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final access = petStore.accessForActivePet();
        final petId = petStore.activePet?.id ?? '';
        final petName = petStore.activePet?.name ?? l10n.petName;
        final count = medicationStore.getActiveMedications(petId).length;
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.medicationManagement,
                          style: AppTextStyles.heading2),
                      SizedBox(
                        height: 32,
                        child: TextButton.icon(
                          onPressed: access.canManageMedication
                              ? _openMedicationSheet
                              : null,
                          style: TextButton.styleFrom(
                            backgroundColor: c.lightBlue,
                            disabledBackgroundColor:
                                c.lightBlue.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  const BorderRadius.all(AppRadii.full),
                            ),
                          ),
                          icon: Icon(Icons.add, color: c.chocolate, size: 16),
                          label: Text(
                            l10n.addMedication,
                            style: AppTextStyles.caption
                                .copyWith(color: c.chocolate),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$petName • $count ${l10n.activeTreatments.toLowerCase()}',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ActiveMedicationsList(
                    onEdit:
                        access.canManageMedication ? _openMedicationSheet : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionCard(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                              color: c.white, shape: BoxShape.circle),
                          child: Icon(Icons.info_outline, color: c.blue),
                        ),
                        const SizedBox(height: AppSpacing.sm + 4),
                        Text(
                          l10n.clinicalRecordInformation,
                          style: AppTextStyles.heading3,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.clinicalRecordDisclaimer,
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          height: 40,
                          child: TextButton.icon(
                            onPressed: _exportMedicationLog,
                            style: TextButton.styleFrom(
                              backgroundColor: c.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    const BorderRadius.all(AppRadii.full),
                              ),
                            ),
                            icon: Icon(Icons.file_download,
                                color: c.chocolate, size: 16),
                            label: Text(
                              l10n.exportMedicationLog,
                              style: AppTextStyles.body
                                  .copyWith(color: c.chocolate),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!widget.showScaffold) {
      return Container(color: c.white, child: content);
    }
    return Scaffold(backgroundColor: c.white, body: content);
  }
}

class _ActiveMedicationsList extends StatelessWidget {
  const _ActiveMedicationsList({this.onEdit});

  final void Function(Medication)? onEdit;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final petId = petStore.activePet?.id ?? '';
    final petName = petStore.activePet?.name ?? l10n.petName;
    final meds = medicationStore.getMedications(petId);

    if (meds.isEmpty) {
      return _SectionCard(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration:
                  BoxDecoration(color: c.white, shape: BoxShape.circle),
              child: Icon(Icons.medication, color: c.chocolate),
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            Text(l10n.noMedicationsRecorded,
                style: AppTextStyles.heading3, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.keepTrackOfMedications(petName),
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: meds.map((med) {
        final dateStr = '${med.startDate.month}/${med.startDate.day}';
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
          child: GestureDetector(
            onTap: () => onEdit?.call(med),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: c.offWhite,
                borderRadius: const BorderRadius.all(AppRadii.small),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: med.isActive
                          ? c.lightBlue.withValues(alpha: 0.2)
                          : c.offWhite,
                      borderRadius: const BorderRadius.all(AppRadii.small),
                    ),
                    child:
                        Icon(Icons.medication, color: c.chocolate, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(med.name,
                            style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: c.chocolate)),
                        Text('${med.dosage} • ${med.frequency}',
                            style: AppTextStyles.caption
                                .copyWith(color: c.chocolate)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: med.isActive
                              ? c.lightBlue.withValues(alpha: 0.2)
                              : c.offWhite,
                          borderRadius:
                              const BorderRadius.all(AppRadii.full),
                        ),
                        child: Text(
                          med.isActive ? l10n.active : l10n.done,
                          style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: c.chocolate),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(dateStr,
                          style: AppTextStyles.caption
                              .copyWith(color: c.chocolate)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.offWhite,
        borderRadius: const BorderRadius.all(AppRadii.medium),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit Medication Sheet
// ---------------------------------------------------------------------------

class _AddMedicationSheet extends StatefulWidget {
  const _AddMedicationSheet({this.medication});

  final Medication? medication;

  @override
  State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _remindersEnabled = false;
  late String _frequency;

  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _prescribedByController;
  late final TextEditingController _purposeController;
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

    _prescribedByController =
        TextEditingController(text: med?.prescribedBy ?? '');
    _purposeController = TextEditingController(text: med?.purpose ?? '');
    _notesController = TextEditingController(text: med?.notes ?? '');
    _remindersEnabled = med?.remindersEnabled ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _prescribedByController.dispose();
    _purposeController.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final access = petStore.accessForActivePet();
    if (!access.canManageMedication) return;
    final petId = petStore.activePet?.id ?? '';
    final l10n = AppLocalizations.of(context)!;
    final petName = petStore.activePet?.name ?? l10n.petName;
    if (petId.isEmpty) return;

    final name = _nameController.text.trim();
    final dosage = _dosageController.text.trim();
    final startDate = _startDate ?? DateTime.now();
    final prescribedBy = _prescribedByController.text.trim();
    final purpose = _purposeController.text.trim();
    final notes = _notesController.text.trim();

    if (_isEditing) {
      final updated = widget.medication!.copyWith(
        name: name,
        dosage: dosage,
        frequency: _frequency,
        startDate: startDate,
        endDate: _endDate,
        clearEndDate: _endDate == null,
        prescribedBy: prescribedBy.isNotEmpty ? prescribedBy : null,
        purpose: purpose.isNotEmpty ? purpose : null,
        notes: notes.isNotEmpty ? notes : null,
        remindersEnabled: _remindersEnabled,
      );
      await medicationStore.updateMedication(petId, widget.medication!.id, updated);

      if (_remindersEnabled && _frequency != 'As needed') {
        await ReminderService.instance.scheduleMedicationReminder(updated);
      } else {
        await ReminderService.instance.cancelMedicationReminder(widget.medication!.id);
      }
    } else {
      final newMed = Medication(
        id: 'med-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        dosage: dosage,
        frequency: _frequency,
        startDate: startDate,
        endDate: _endDate,
        prescribedBy: prescribedBy.isNotEmpty ? prescribedBy : null,
        purpose: purpose.isNotEmpty ? purpose : null,
        notes: notes.isNotEmpty ? notes : null,
        remindersEnabled: _remindersEnabled,
      );
      await medicationStore.addMedication(petId, newMed);

      if (_remindersEnabled && _frequency != 'As needed') {
        await ReminderService.instance.scheduleMedicationReminder(newMed);
      }
    }

    await notificationStore.addNotification(
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: _isEditing ? l10n.medicationUpdated : l10n.medicationAdded,
        body: name,
        type: NotificationType.medication,
        createdAt: DateTime.now(),
        petName: petName,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              _isEditing ? l10n.medicationUpdated : l10n.medicationAdded)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: c.white,
          borderRadius: const BorderRadius.vertical(top: AppRadii.medium),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _isEditing
                              ? l10n.editMedication
                              : l10n.addNewMedication,
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _isEditing
                              ? l10n.updateMedicationDescription(
                                  petStore.activePet?.name ?? l10n.petName)
                              : l10n.addMedicationDescription(
                                  petStore.activePet?.name ?? l10n.petName),
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ValidatedFormField(
                    label: l10n.medicationNameRequired,
                    hint: 'e.g., Pimobendan',
                    controller: _nameController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ValidatedFormField(
                    label: l10n.dosageRequired,
                    hint: 'e.g., 5mg',
                    controller: _dosageController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DropdownField(
                    label: l10n.frequencyRequired,
                    value: _frequency,
                    onChanged: (value) =>
                        setState(() => _frequency = value ?? _frequency),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: l10n.startDateRequired,
                          controller: _startDateController,
                          onTap: () => _pickDate(isStart: true),
                          validator: (v) => (v == null || v.isEmpty)
                              ? l10n.fieldRequired
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _DatePickerField(
                          label: l10n.endDateOptional,
                          controller: _endDateController,
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ValidatedFormField(
                    label: l10n.prescribedBy,
                    hint: 'e.g., Dr. Smith, DVM',
                    controller: _prescribedByController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ValidatedFormField(
                    label: l10n.purposeCondition,
                    hint: 'e.g., Congestive Heart Failure',
                    controller: _purposeController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ValidatedTextArea(
                    label: l10n.additionalNotes,
                    hint:
                        'Any special instructions, side effects to monitor, or additional information...',
                    controller: _notesController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ReminderCard(
                    enabled: _remindersEnabled,
                    onChanged: (v) =>
                        setState(() => _remindersEnabled = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: c.offWhite,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  const BorderRadius.all(AppRadii.full)),
                        ),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      TextButton(
                        onPressed: _save,
                        style: TextButton.styleFrom(
                          backgroundColor: c.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  const BorderRadius.all(AppRadii.full)),
                        ),
                        child: Text(
                          _isEditing ? l10n.save : l10n.addMedication,
                          style: TextStyle(color: c.white),
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
// Reusable form widgets
// ---------------------------------------------------------------------------

class _ValidatedFormField extends StatelessWidget {
  const _ValidatedFormField({
    required this.label,
    required this.hint,
    this.controller,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.offWhite,
            hintText: hint,
            hintStyle: AppTextStyles.body
                .copyWith(color: c.chocolate.withValues(alpha: 0.3)),
            border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(AppRadii.xs),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 4, vertical: AppSpacing.xs),
            errorStyle: AppTextStyles.caption.copyWith(color: c.cherry),
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
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
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.offWhite,
            hintText: l10n.dateFormatHint,
            hintStyle: AppTextStyles.body
                .copyWith(color: c.chocolate.withValues(alpha: 0.3)),
            suffixIcon: Icon(Icons.calendar_today,
                size: 18, color: c.chocolate.withValues(alpha: 0.5)),
            border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(AppRadii.xs),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 4, vertical: AppSpacing.xs),
            errorStyle: AppTextStyles.caption.copyWith(color: c.cherry),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField(
      {required this.label, required this.value, required this.onChanged});

  final String label;
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 4),
          decoration: BoxDecoration(
              color: c.offWhite,
              borderRadius: const BorderRadius.all(AppRadii.xs)),
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

class _ValidatedTextArea extends StatelessWidget {
  const _ValidatedTextArea({
    required this.label,
    required this.hint,
    this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.offWhite,
            hintText: hint,
            hintStyle: AppTextStyles.body
                .copyWith(color: c.chocolate.withValues(alpha: 0.3)),
            border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(AppRadii.xs),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(AppSpacing.sm + 4),
            errorStyle: AppTextStyles.caption.copyWith(color: c.cherry),
          ),
        ),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
      decoration: BoxDecoration(
          color: c.pink,
          borderRadius: const BorderRadius.all(AppRadii.small)),
      child: Row(
        children: [
          Icon(Icons.notifications_none, color: c.chocolate, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.medicationReminders,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 1),
                Text(l10n.medicationRemindersDesc,
                    style: AppTextStyles.caption),
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
