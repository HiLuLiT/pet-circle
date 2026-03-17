import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/toggle_pill.dart';

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

  void _exportMedicationLog() {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final petId = petStore.activePet?.id ?? '';
    final meds = medicationStore.getMedications(petId);
    final csvLines = meds.map((m) {
      final start = '${m.startDate.year}-${m.startDate.month.toString().padLeft(2, '0')}-${m.startDate.day.toString().padLeft(2, '0')}';
      final status = m.isActive ? l10n.ongoing : l10n.completed;
      return '${m.name},${m.dosage},${m.frequency},$start,$status';
    }).join('\n');
    final csvData = 'Medication,Dosage,Frequency,Start Date,Status\n$csvLines';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.medium)),
        title: Text(l10n.exportMedicationLog, style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.csvPreview, style: AppTextStyles.body),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.offWhite,
                  borderRadius: const BorderRadius.all(AppRadii.sm),
                ),
                child: Text(csvData, style: AppTextStyles.caption.copyWith(fontFamily: 'monospace', fontSize: 10)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close, style: AppTextStyles.body.copyWith(color: c.chocolate)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.medicationLogExported)),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: c.lightBlue,
              shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.small)),
            ),
            child: Text(l10n.downloadCsv, style: AppTextStyles.body.copyWith(color: c.chocolate)),
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.medicationManagement, style: AppTextStyles.heading2),
                      SizedBox(
                        height: 32,
                        child: TextButton.icon(
                          onPressed:
                              access.canManageMedication ? _openMedicationSheet : null,
                          style: TextButton.styleFrom(
                            backgroundColor: c.lightBlue,
                            disabledBackgroundColor:
                                c.lightBlue.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: const BorderRadius.all(AppRadii.full),
                            ),
                          ),
                          icon: Icon(Icons.add, color: c.chocolate, size: 16),
                          label: Text(
                            l10n.addMedication,
                            style: AppTextStyles.caption.copyWith(color: c.chocolate),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$petName • $count active treatments',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 24),
                  _ActiveMedicationsList(
                    onEdit: access.canManageMedication ? _openMedicationSheet : null,
                  ),
                  const SizedBox(height: 24),
                  _SectionCard(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: c.white, shape: BoxShape.circle),
                          child: Icon(Icons.info_outline, color: c.blue),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.clinicalRecordInformation,
                          style: AppTextStyles.heading3,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Medication data is stored locally and included in exported clinical reports. '
                          'Always consult with your veterinarian before starting, stopping, or modifying any medication regimen. '
                          'This tool is for tracking purposes only and does not replace professional veterinary advice.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 40,
                          child: TextButton.icon(
                            onPressed: _exportMedicationLog,
                            style: TextButton.styleFrom(
                              backgroundColor: c.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(AppRadii.full),
                              ),
                            ),
                            icon: Icon(Icons.file_download, color: c.chocolate, size: 16),
                            label: Text(
                              l10n.exportMedicationLog,
                              style: AppTextStyles.body.copyWith(color: c.chocolate),
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
              decoration: BoxDecoration(color: c.white, shape: BoxShape.circle),
              child: Icon(Icons.medication, color: c.chocolate),
            ),
            const SizedBox(height: 12),
            Text(l10n.noMedicationsRecorded, style: AppTextStyles.heading3, textAlign: TextAlign.center),
            const SizedBox(height: 4),
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
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => onEdit?.call(med),
            child: Container(
            padding: const EdgeInsets.all(16),
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
                    color: med.isActive ? c.lightBlue.withValues(alpha: 0.2) : c.offWhite,
                    borderRadius: const BorderRadius.all(AppRadii.small),
                  ),
                  child: Icon(Icons.medication, color: c.chocolate, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: c.chocolate)),
                      Text('${med.dosage} • ${med.frequency}', style: AppTextStyles.caption.copyWith(color: c.chocolate)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: med.isActive ? c.lightBlue.withValues(alpha: 0.2) : c.offWhite,
                        borderRadius: const BorderRadius.all(AppRadii.full),
                      ),
                      child: Text(
                        med.isActive ? l10n.active : l10n.done,
                        style: AppTextStyles.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: c.chocolate),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(dateStr, style: AppTextStyles.caption.copyWith(color: c.chocolate)),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.offWhite,
        borderRadius: const BorderRadius.all(AppRadii.medium),
      ),
      child: child,
    );
  }
}

class _AddMedicationSheet extends StatefulWidget {
  const _AddMedicationSheet({this.medication});

  final Medication? medication;

  @override
  State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  bool _remindersEnabled = false;
  late String _frequency;
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;

  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?.name ?? '');
    _dosageController = TextEditingController(text: widget.medication?.dosage ?? '');
    _frequency = widget.medication?.frequency ?? 'Once daily';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      Text(
                        _isEditing ? l10n.editMedication : l10n.addNewMedication,
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _isEditing
                            ? l10n.updateMedicationDescription(petStore.activePet?.name ?? l10n.petName)
                            : l10n.addMedicationDescription(petStore.activePet?.name ?? l10n.petName),
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _FormField(label: l10n.medicationNameRequired, hint: 'e.g., Pimobendan', controller: _nameController),
                const SizedBox(height: 16),
                _FormField(label: l10n.dosageRequired, hint: 'e.g., 5mg', controller: _dosageController),
                const SizedBox(height: 16),
                _DropdownField(
                  label: l10n.frequencyRequired,
                  value: _frequency,
                  onChanged: (value) => setState(() => _frequency = value ?? _frequency),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _FormField(label: l10n.startDateRequired, hint: '')),
                    const SizedBox(width: 16),
                    Expanded(child: _FormField(label: l10n.endDateOptional, hint: '')),
                  ],
                ),
                const SizedBox(height: 16),
                _FormField(label: l10n.prescribedBy, hint: 'e.g., Dr. Smith, DVM'),
                const SizedBox(height: 16),
                _FormField(label: l10n.purposeCondition, hint: 'e.g., Congestive Heart Failure'),
                const SizedBox(height: 16),
                _TextArea(label: l10n.additionalNotes, hint: 'Any special instructions, side effects to monitor, or additional information...'),
                const SizedBox(height: 16),
                _ReminderCard(enabled: _remindersEnabled, onChanged: (v) => setState(() => _remindersEnabled = v)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: c.offWhite,
                        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.full)),
                      ),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final access = petStore.accessForActivePet();
                        if (!access.canManageMedication) return;
                        final petId = petStore.activePet?.id ?? '';
                        final petName = petStore.activePet?.name ?? l10n.petName;
                        if (petId.isEmpty) return;
                        final name = _nameController.text.isNotEmpty ? _nameController.text : l10n.newMedication;
                        final dosage = _dosageController.text;

                        if (_isEditing) {
                          await medicationStore.updateMedication(
                            petId,
                            widget.medication!.id,
                            widget.medication!.copyWith(
                              name: name,
                              dosage: dosage,
                              frequency: _frequency,
                            ),
                          );
                        } else {
                          await medicationStore.addMedication(
                            petId,
                            Medication(
                              id: 'med-${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              dosage: dosage,
                              frequency: _frequency,
                              startDate: DateTime.now(),
                            ),
                          );
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
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_isEditing ? l10n.medicationUpdated : l10n.medicationAdded)),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: c.blue,
                        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.full)),
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
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.hint, this.controller});

  final String label;
  final String hint;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: c.offWhite,
              hintText: hint,
              hintStyle: AppTextStyles.body.copyWith(color: c.chocolate.withValues(alpha: 0.3)),
              border: OutlineInputBorder(borderRadius: const BorderRadius.all(AppRadii.xs), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({required this.label, required this.value, required this.onChanged});

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
        Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: c.offWhite, borderRadius: const BorderRadius.all(AppRadii.xs)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: [
                DropdownMenuItem(value: 'Once daily', child: Text(l10n.onceDaily)),
                DropdownMenuItem(value: 'Twice daily', child: Text(l10n.twiceDaily)),
                DropdownMenuItem(value: 'As needed', child: Text(l10n.asNeeded)),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _TextArea extends StatelessWidget {
  const _TextArea({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.offWhite,
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: c.chocolate.withValues(alpha: 0.3)),
            border: OutlineInputBorder(borderRadius: const BorderRadius.all(AppRadii.xs), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: c.pink, borderRadius: const BorderRadius.all(AppRadii.small)),
      child: Row(
        children: [
          Icon(Icons.notifications_none, color: c.chocolate, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.medicationReminders, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 1),
                Text(l10n.medicationRemindersDesc, style: AppTextStyles.caption),
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
