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
import 'package:pet_circle/utils/display_localizer.dart';
import 'package:pet_circle/widgets/app_card.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/status_badge.dart';

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
      useSafeArea: true,
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

    const header = 'Medication,Dosage,Frequency,Start Date,End Date,Status,Prescribed By,Purpose,Notes';
    final csvLines = meds.map((m) {
      final status = m.isActive ? 'Ongoing' : 'Completed';
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
                debugPrint('[MedicationScreen] CSV export failed: $e');
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.exportFailedWithError)),
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
                  Text(l10n.medicationManagement,
                      style: AppSemanticTextStyles.headingH2),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    '$petName • $count ${l10n.activeTreatments.toLowerCase()}',
                    style: AppSemanticTextStyles.pcLabelMuted,
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  _ActiveMedicationsList(
                    onEdit:
                        access.canManageMedication ? _openMedicationSheet : null,
                  ),
                  if (access.canManageMedication) ...[
                    const SizedBox(height: AppSpacingTokens.md),
                    PrimaryButton(
                      label: l10n.addMedication,
                      variant: PrimaryButtonVariant.secondary,
                      onPressed: _openMedicationSheet,
                      trailingIcon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                  const SizedBox(height: AppSpacingTokens.lg),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.clinicalRecordInformation,
                          style: AppSemanticTextStyles.headingH2,
                        ),
                        const SizedBox(height: AppSpacingTokens.sm),
                        Text(
                          l10n.clinicalRecordDisclaimer,
                          style: AppSemanticTextStyles.pcBodyMuted,
                        ),
                        const SizedBox(height: AppSpacingTokens.md),
                        PrimaryButton(
                          label: l10n.exportMedicationLog,
                          variant: PrimaryButtonVariant.filled,
                          onPressed: _exportMedicationLog,
                          trailingIcon: const Icon(Icons.file_download_outlined),
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
      return Container(color: c.background, child: content);
    }
    return Scaffold(backgroundColor: c.background, body: content);
  }
}

class _ActiveMedicationsList extends StatelessWidget {
  // Deliberately not const: build() reads petStore/medicationStore globals
  // directly, so a `const _ActiveMedicationsList()` call site would get
  // canonicalized to one instance and silently stop rebuilding on store
  // changes (see BUG-033). Not currently called with const, but the
  // constructor shouldn't offer the option.
  // ignore: prefer_const_constructors_in_immutables
  _ActiveMedicationsList({this.onEdit});

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
                  BoxDecoration(color: c.accentBlushTile, shape: BoxShape.circle),
              child: Icon(Icons.medication, color: c.accentBlush),
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
                color: c.surface,
                borderRadius: BorderRadius.circular(AppRadiiTokens.pcCard),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.accentBlushTile,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.medication, color: c.accentBlush, size: 20),
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
                        Text('${med.dosage} • ${localizeFrequency(med.frequency, l10n)}',
                            style: AppSemanticTextStyles.caption
                                .copyWith(color: c.textPrimary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusBadge(
                        label: med.isActive ? l10n.active : l10n.done,
                        status: med.isActive
                            ? StatusBadgeStatus.active
                            : StatusBadgeStatus.normal,
                      ),
                      const SizedBox(height: AppSpacingTokens.xs),
                      Text(dateStr,
                          style: AppSemanticTextStyles.caption
                              .copyWith(color: c.textPrimary)),
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
    final c = AppSemanticColors.of(context);
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        variant: AppCardVariant.tile,
        tileColor: c.surface,
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: child,
      ),
    );
  }
}
