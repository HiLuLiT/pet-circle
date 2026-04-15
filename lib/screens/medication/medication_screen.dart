import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/utils/csv_export_helper.dart';

import 'add_medication_sheet.dart';

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
      builder: (context) => AddMedicationSheet(medication: medication),
    );
  }

  Future<void> _exportMedicationLog() async {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
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
            borderRadius: BorderRadius.circular(AppRadiiTokens.lg)),
        title: Text(l10n.exportMedicationLog, style: AppSemanticTextStyles.headingLg),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.csvPreview, style: AppSemanticTextStyles.body),
              const SizedBox(height: AppSpacingTokens.sm + 4),
              Container(
                padding: const EdgeInsets.all(AppSpacingTokens.sm + 4),
                decoration: BoxDecoration(
                  color: c.background,
                  borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                ),
                child: Text(csvData,
                    style: AppSemanticTextStyles.caption
                        .copyWith(fontFamily: 'monospace', fontSize: 10)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close,
                style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary)),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              try {
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final filename = '${petName}_medications_$timestamp.csv';
                await exportCsv(filename, csvData);
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.medicationLogExported)),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Export failed: $e')),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: c.primaryLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadiiTokens.sm)),
            ),
            child: Text(l10n.downloadCsv,
                style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final content = ListenableBuilder(
      listenable: Listenable.merge([medicationStore, petStore, userStore]),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final access = petStore.accessForActivePet();
        final petId = petStore.activePet?.id ?? '';
        final petName = petStore.activePet?.name ?? l10n.petName;
        final count = medicationStore.getActiveMedications(petId).length;
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => medicationStore.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacingTokens.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(l10n.medicationManagement,
                            style: AppSemanticTextStyles.title3),
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      SizedBox(
                        height: 32,
                        child: TextButton.icon(
                          onPressed: access.canManageMedication
                              ? _openMedicationSheet
                              : null,
                          style: TextButton.styleFrom(
                            backgroundColor: c.primaryLight,
                            disabledBackgroundColor:
                                c.primaryLight.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadiiTokens.full),
                            ),
                          ),
                          icon: Icon(Icons.add, color: c.textPrimary, size: 16),
                          label: Text(
                            l10n.addMedication,
                            style: AppSemanticTextStyles.caption
                                .copyWith(color: c.textPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    '$petName • $count ${l10n.activeTreatments.toLowerCase()}',
                    style: AppSemanticTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  _ActiveMedicationsList(
                    onEdit:
                        access.canManageMedication ? _openMedicationSheet : null,
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  _SectionCard(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                              color: c.surface, shape: BoxShape.circle),
                          child: Icon(Icons.info_outline, color: c.primary),
                        ),
                        const SizedBox(height: AppSpacingTokens.sm + 4),
                        Text(
                          l10n.clinicalRecordInformation,
                          style: AppSemanticTextStyles.headingLg,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacingTokens.xs),
                        Text(
                          l10n.clinicalRecordDisclaimer,
                          style: AppSemanticTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacingTokens.lg),
                        SizedBox(
                          height: 40,
                          child: TextButton.icon(
                            onPressed: _exportMedicationLog,
                            style: TextButton.styleFrom(
                              backgroundColor: c.primaryLight,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadiiTokens.full),
                              ),
                            ),
                            icon: Icon(Icons.file_download,
                                color: c.textPrimary, size: 16),
                            label: Text(
                              l10n.exportMedicationLog,
                              style: AppSemanticTextStyles.body
                                  .copyWith(color: c.textPrimary),
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
          ),
        );
      },
    );

    if (!widget.showScaffold) {
      return Container(color: c.surface, child: content);
    }
    return Scaffold(backgroundColor: c.surface, body: content);
  }
}

class _ActiveMedicationsList extends StatelessWidget {
  const _ActiveMedicationsList({this.onEdit});

  final void Function(Medication)? onEdit;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
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
                  BoxDecoration(color: c.surface, shape: BoxShape.circle),
              child: Icon(Icons.medication, color: c.textPrimary),
            ),
            const SizedBox(height: AppSpacingTokens.sm + 4),
            Text(l10n.noMedicationsRecorded,
                style: AppSemanticTextStyles.headingLg, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              l10n.keepTrackOfMedications(petName),
              style: AppSemanticTextStyles.body,
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
          padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm + 4),
          child: GestureDetector(
            onTap: () => onEdit?.call(med),
            child: Container(
              padding: const EdgeInsets.all(AppSpacingTokens.md),
              decoration: BoxDecoration(
                color: c.background,
                borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: med.isActive
                          ? c.primaryLight.withValues(alpha: 0.2)
                          : c.background,
                      borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                    ),
                    child:
                        Icon(Icons.medication, color: c.textPrimary, size: 20),
                  ),
                  const SizedBox(width: AppSpacingTokens.sm + 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(med.name,
                            style: AppSemanticTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: c.textPrimary)),
                        Text('${med.dosage} • ${med.frequency}',
                            style: AppSemanticTextStyles.caption
                                .copyWith(color: c.textPrimary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacingTokens.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: med.isActive
                              ? c.primaryLight.withValues(alpha: 0.2)
                              : c.background,
                          borderRadius:
                              BorderRadius.circular(AppRadiiTokens.full),
                        ),
                        child: Text(
                          med.isActive ? l10n.active : l10n.done,
                          style: AppSemanticTextStyles.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary),
                        ),
                      ),
                      if (med.hasSupplyTracking) ...[
                        const SizedBox(height: AppSpacingTokens.xs),
                        Text(
                          '${med.currentSupply}/${med.totalSupply} ${l10n.dosesLeft}',
                          style: AppSemanticTextStyles.caption.copyWith(
                            color: med.isLowSupply ? c.error : c.textPrimary,
                            fontWeight: med.isLowSupply
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacingTokens.xs),
                      Text(dateStr,
                          style: AppSemanticTextStyles.caption
                              .copyWith(color: c.textPrimary)),
                      if (med.isActive && med.hasSupplyTracking) ...[
                        const SizedBox(height: AppSpacingTokens.xs),
                        _MarkDoseButton(petId: petId, medication: med),
                      ],
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

class _MarkDoseButton extends StatelessWidget {
  const _MarkDoseButton({required this.petId, required this.medication});

  final String petId;
  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    return SizedBox(
      height: 28,
      child: TextButton(
        onPressed: () async {
          final updated =
              await medicationStore.markDoseTaken(petId, medication.id);
          if (!context.mounted) return;
          if (updated != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.doseTakenConfirmation)),
            );
            if (updated.isLowSupply) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.lowSupplyAlertBody(
                      medication.name,
                      updated.currentSupply ?? 0,
                    ),
                  ),
                  backgroundColor: c.error,
                ),
              );
            }
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: c.primary.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadiiTokens.full),
          ),
        ),
        child: Text(
          l10n.markDoseTaken,
          style: AppSemanticTextStyles.caption.copyWith(
            color: c.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadiiTokens.lg),
      ),
      child: child,
    );
  }
}
