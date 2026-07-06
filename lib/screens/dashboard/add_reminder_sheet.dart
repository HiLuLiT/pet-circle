import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/reminder.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/reminder_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/round_icon_button.dart';

import '../medication/medication_form_widgets.dart';

// ---------------------------------------------------------------------------
// Add / Edit Reminder Sheet
// ---------------------------------------------------------------------------

class AddReminderSheet extends StatefulWidget {
  const AddReminderSheet({super.key, this.reminder});

  final Reminder? reminder;

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _detailController;
  late final TextEditingController _dateController;

  DateTime? _date;

  bool get _isEditing => widget.reminder != null;

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    _titleController = TextEditingController(text: reminder?.title ?? '');
    _detailController = TextEditingController(text: reminder?.detail ?? '');

    _date = reminder?.date;
    _dateController =
        TextEditingController(text: _date != null ? _formatDate(_date!) : '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = _formatDate(picked);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    final access = petStore.accessForActivePet();
    if (!access.canManageMedication) return;
    final petId = petStore.activePet?.id ?? '';
    if (petId.isEmpty) return;

    final title = _titleController.text.trim();
    final date = _date ?? DateTime.now();
    final detail = _detailController.text.trim();

    if (_isEditing) {
      final updated = widget.reminder!.copyWith(
        title: title,
        date: date,
        detail: detail.isNotEmpty ? detail : null,
        clearDetail: detail.isEmpty,
      );
      reminderStore.updateReminder(petId, widget.reminder!.id, updated);
    } else {
      final newReminder = Reminder(
        id: 'rem-${DateTime.now().millisecondsSinceEpoch}',
        petId: petId,
        date: date,
        title: title,
        detail: detail.isNotEmpty ? detail : null,
      );
      reminderStore.addReminder(petId, newReminder);
    }

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content:
            Text(_isEditing ? l10n.reminderUpdated : l10n.reminderAdded),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final reminder = widget.reminder;
    if (reminder == null) return;

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
        title: Text(l10n.deleteReminder),
        content: Text(l10n.deleteReminderConfirmation(reminder.title)),
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

    await reminderStore.removeReminder(petId, reminder.id);
    if (!mounted) return;

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.reminderDeleted)),
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
        // minHeight (not a fixed height) pins the sheet's top edge near the
        // top of the screen regardless of how short the form content is —
        // matches the same fix applied to add_medication_sheet.dart, which
        // shares this exact shell pattern.
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
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
                          _isEditing ? l10n.editReminder : l10n.addNewReminder,
                          style: AppSemanticTextStyles.pcDisplay,
                        ),
                      ),
                      if (_isEditing)
                        IconButton(
                          onPressed: _confirmDelete,
                          icon: Icon(Icons.delete_outline, color: c.error),
                          tooltip: l10n.deleteReminder,
                        ),
                      RoundIconButton(
                        icon: Icon(Icons.keyboard_arrow_up, color: c.textPrimary),
                        variant: RoundIconButtonVariant.ghost,
                        size: 36,
                        iconSize: 24,
                        semanticLabel: l10n.close,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.pcXl),
                  ValidatedFormField(
                    label: l10n.reminderTitleLabel,
                    hint: l10n.hintReminderTitle,
                    controller: _titleController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacingTokens.pcMd),
                  DatePickerField(
                    label: l10n.reminderDateLabel,
                    controller: _dateController,
                    onTap: () => _pickDate(),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? l10n.fieldRequired : null,
                  ),
                  const SizedBox(height: AppSpacingTokens.pcMd),
                  ValidatedTextArea(
                    label: l10n.reminderDetailLabel,
                    hint: l10n.hintReminderDetail,
                    controller: _detailController,
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
                          label: _isEditing ? l10n.save : l10n.addReminder,
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
