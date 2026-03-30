import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/theme/app_theme.dart';
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
