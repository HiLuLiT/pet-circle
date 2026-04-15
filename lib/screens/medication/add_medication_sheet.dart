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
  bool _remindersEnabled = false;
  late String _frequency;

  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _prescribedByController;
  late final TextEditingController _purposeController;
  late final TextEditingController _notesController;
  late final TextEditingController _totalSupplyController;
  late final TextEditingController _currentSupplyController;
  late final TextEditingController _lowSupplyThresholdController;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _supplyTrackingEnabled = false;

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
    _supplyTrackingEnabled = med?.hasSupplyTracking ?? false;
    _totalSupplyController = TextEditingController(
        text: med?.totalSupply?.toString() ?? '');
    _currentSupplyController = TextEditingController(
        text: med?.currentSupply?.toString() ?? '');
    _lowSupplyThresholdController = TextEditingController(
        text: med?.lowSupplyThreshold?.toString() ?? '7');
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
    _totalSupplyController.dispose();
    _currentSupplyController.dispose();
    _lowSupplyThresholdController.dispose();
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
    final prescribedBy = _prescribedByController.text.trim();
    final purpose = _purposeController.text.trim();
    final notes = _notesController.text.trim();

    final totalSupply = _supplyTrackingEnabled
        ? int.tryParse(_totalSupplyController.text.trim())
        : null;
    final currentSupply = _supplyTrackingEnabled
        ? int.tryParse(_currentSupplyController.text.trim())
        : null;
    final lowSupplyThreshold = _supplyTrackingEnabled
        ? int.tryParse(_lowSupplyThresholdController.text.trim()) ?? 7
        : null;

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
        totalSupply: totalSupply,
        clearTotalSupply: !_supplyTrackingEnabled,
        currentSupply: currentSupply,
        clearCurrentSupply: !_supplyTrackingEnabled,
        lowSupplyThreshold: lowSupplyThreshold,
        clearLowSupplyThreshold: !_supplyTrackingEnabled,
      );
      medicationStore.updateMedication(petId, widget.medication!.id, updated);

      if (!kIsWeb && _remindersEnabled && _frequency != 'As needed') {
        ReminderService.instance.scheduleMedicationReminder(updated);
      } else if (!kIsWeb) {
        ReminderService.instance.cancelMedicationReminder(widget.medication!.id);
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
        totalSupply: totalSupply,
        currentSupply: currentSupply,
        lowSupplyThreshold: lowSupplyThreshold,
      );
      medicationStore.addMedication(petId, newMed);

      if (!kIsWeb && _remindersEnabled && _frequency != 'As needed') {
        ReminderService.instance.scheduleMedicationReminder(newMed);
      }
    }

    notificationStore.addNotification(
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: _isEditing ? l10n.medicationUpdated : l10n.medicationAdded,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadiiTokens.lg)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacingTokens.lg, AppSpacingTokens.lg, AppSpacingTokens.lg, AppSpacingTokens.xl),
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
                  const SizedBox(height: AppSpacingTokens.sm),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _isEditing
                              ? l10n.editMedication
                              : l10n.addNewMedication,
                          style: AppSemanticTextStyles.title3,
                        ),
                        const SizedBox(height: AppSpacingTokens.sm),
                        Text(
                          _isEditing
                              ? l10n.updateMedicationDescription(
                                  petStore.activePet?.name ?? l10n.petName)
                              : l10n.addMedicationDescription(
                                  petStore.activePet?.name ?? l10n.petName),
                          style: AppSemanticTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  ValidatedFormField(
                    label: l10n.medicationNameRequired,
                    hint: 'e.g., Pimobendan',
                    controller: _nameController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  ValidatedFormField(
                    label: l10n.dosageRequired,
                    hint: 'e.g., 5mg',
                    controller: _dosageController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  DropdownField(
                    label: l10n.frequencyRequired,
                    value: _frequency,
                    onChanged: (value) =>
                        setState(() => _frequency = value ?? _frequency),
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
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
                      const SizedBox(width: AppSpacingTokens.md),
                      Expanded(
                        child: DatePickerField(
                          label: l10n.endDateOptional,
                          controller: _endDateController,
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  ValidatedFormField(
                    label: l10n.prescribedBy,
                    hint: 'e.g., Dr. Smith, DVM',
                    controller: _prescribedByController,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  ValidatedFormField(
                    label: l10n.purposeCondition,
                    hint: 'e.g., Congestive Heart Failure',
                    controller: _purposeController,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  ValidatedTextArea(
                    label: l10n.additionalNotes,
                    hint:
                        'Any special instructions, side effects to monitor, or additional information...',
                    controller: _notesController,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  _SupplyTrackingCard(
                    enabled: _supplyTrackingEnabled,
                    onEnabledChanged: (v) =>
                        setState(() => _supplyTrackingEnabled = v),
                    totalSupplyController: _totalSupplyController,
                    currentSupplyController: _currentSupplyController,
                    lowSupplyThresholdController: _lowSupplyThresholdController,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  ReminderCard(
                    enabled: _remindersEnabled,
                    onChanged: (v) =>
                        setState(() => _remindersEnabled = v),
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: c.background,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadiiTokens.full)),
                        ),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      TextButton(
                        onPressed: _save,
                        style: TextButton.styleFrom(
                          backgroundColor: c.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadiiTokens.full)),
                        ),
                        child: Text(
                          _isEditing ? l10n.save : l10n.addMedication,
                          style: TextStyle(color: c.surface),
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

// ── Supply Tracking Card ─────────────────────────────────────────────

class _SupplyTrackingCard extends StatelessWidget {
  const _SupplyTrackingCard({
    required this.enabled,
    required this.onEnabledChanged,
    required this.totalSupplyController,
    required this.currentSupplyController,
    required this.lowSupplyThresholdController,
  });

  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final TextEditingController totalSupplyController;
  final TextEditingController currentSupplyController;
  final TextEditingController lowSupplyThresholdController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      decoration: BoxDecoration(
        color: c.primaryLightest,
        borderRadius: AppRadiiTokens.borderRadiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 20, color: c.primary),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Text(
                  l10n.medicationSupply,
                  style: AppSemanticTextStyles.label.copyWith(color: c.primary),
                ),
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: onEnabledChanged,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: AppSpacingTokens.md),
            Row(
              children: [
                Expanded(
                  child: ValidatedFormField(
                    label: l10n.totalSupply,
                    hint: 'e.g., 60',
                    controller: totalSupplyController,
                    keyboardType: TextInputType.number,
                    validator: enabled
                        ? (v) => (v == null || v.trim().isEmpty || int.tryParse(v.trim()) == null)
                            ? l10n.fieldRequired
                            : null
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.md),
                Expanded(
                  child: ValidatedFormField(
                    label: l10n.currentSupply,
                    hint: 'e.g., 45',
                    controller: currentSupplyController,
                    keyboardType: TextInputType.number,
                    validator: enabled
                        ? (v) => (v == null || v.trim().isEmpty || int.tryParse(v.trim()) == null)
                            ? l10n.fieldRequired
                            : null
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            ValidatedFormField(
              label: l10n.lowSupplyThreshold,
              hint: '7',
              controller: lowSupplyThresholdController,
              keyboardType: TextInputType.number,
            ),
          ],
        ],
      ),
    );
  }
}
