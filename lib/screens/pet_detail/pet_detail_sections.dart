import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_widgets.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/utils/formatters.dart';
import 'package:pet_circle/stores/note_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';

class PetInfoSection extends StatelessWidget {
  const PetInfoSection({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final latestFromStore = measurementStore.latestForPet(pet.id ?? '');
    final latest = latestFromStore ?? pet.latestMeasurement;
    final hasMeasurement = latest.bpm > 0;
    return NeumorphicCard(
      radius: BorderRadius.circular(AppRadiiTokens.md),
      padding: const EdgeInsets.all(AppSpacingTokens.md + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.latestReading,
            style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: InfoTile(
                  icon: Icons.favorite,
                  iconColor: c.primaryLight,
                  value: hasMeasurement ? '${latest.bpm}' : '--',
                  label: l10n.bpm,
                ),
              ),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: InfoTile(
                  icon: Icons.access_time,
                  iconColor: c.primaryLight,
                  value: hasMeasurement ? formatTimeAgo(latest.recordedAt) : l10n.noMeasurementsYet,
                  label: l10n.lastMeasured,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PetMeasurementHistory extends StatelessWidget {
  const PetMeasurementHistory({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final storeMeasurements = measurementStore.getMeasurements(pet.id ?? '');
    final List<Measurement> measurements = storeMeasurements.isNotEmpty
        ? storeMeasurements
        : (pet.latestMeasurement.bpm > 0 ? [pet.latestMeasurement] : <Measurement>[]);

    return NeumorphicCard(
      radius: BorderRadius.circular(AppRadiiTokens.md),
      padding: const EdgeInsets.all(AppSpacingTokens.md + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.measurementHistory,
                  style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  petStore.setActivePet(pet);
                  context.go(AppRoutes.shell(tab: 1));
                },
                icon: const Icon(Icons.show_chart, size: 18),
                label: Text(l10n.viewGraph),
                style: TextButton.styleFrom(foregroundColor: c.primaryLight),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.md),
          // Simple bar chart visualization
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: measurements.take(5).map((m) {
                final height = (m.bpm / 40) * 60;
                final isElevated = m.bpm > 30;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xs),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${m.bpm}',
                          style: AppSemanticTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isElevated ? c.error : c.primaryLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.xs),
                        Container(
                          height: height.clamp(20, 60),
                          decoration: BoxDecoration(
                            color: isElevated
                                ? c.error.withValues(alpha: 0.3)
                                : c.primaryLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
                            border: Border.all(
                              color: isElevated ? c.error : c.primaryLight,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: measurements.take(5).map((m) {
              return Expanded(
                child: Text(
                  formatTimeAgo(m.recordedAt).replaceAll(' ago', ''),
                  style: AppSemanticTextStyles.caption.copyWith(fontSize: 9),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class PetClinicalNotes extends StatelessWidget {
  const PetClinicalNotes({
    super.key,
    required this.pet,
    required this.noteController,
    required this.onAddNote,
  });

  final Pet pet;
  final TextEditingController noteController;
  final VoidCallback onAddNote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final access = petStore.accessForPet(pet);
    final notes = noteStore.getNotes(pet.id ?? '');
    return NeumorphicCard(
      radius: BorderRadius.circular(AppRadiiTokens.md),
      padding: const EdgeInsets.all(AppSpacingTokens.md + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt_outlined, color: c.textPrimary),
              const SizedBox(width: AppSpacingTokens.sm),
              Text(
                l10n.clinicalNotes,
                style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.md),
          // Add note input
          Container(
            padding: const EdgeInsets.all(AppSpacingTokens.sm + 4),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
            ),
            child: Column(
              children: [
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  readOnly: !access.canAddNotes,
                  decoration: InputDecoration(
                    hintText: l10n.addClinicalNoteHint,
                    hintStyle: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: AppSemanticTextStyles.body,
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: access.canAddNotes ? onAddNote : null,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addNote),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.textPrimary,
                      foregroundColor: c.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacingTokens.md,
                        vertical: AppSpacingTokens.sm + 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadiiTokens.lg),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacingTokens.md + 4),
            const Divider(height: 1),
            const SizedBox(height: AppSpacingTokens.md),
            ...notes.map((note) => NoteCard(note: note)),
          ],
          if (notes.isEmpty) ...[
            const SizedBox(height: AppSpacingTokens.md + 4),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.notes,
                    size: 40,
                    color: c.textPrimary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    l10n.noClinicalNotesYet,
                    style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PetCareCircle extends StatelessWidget {
  const PetCareCircle({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    return NeumorphicCard(
      radius: BorderRadius.circular(AppRadiiTokens.md),
      padding: const EdgeInsets.all(AppSpacingTokens.md + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group, color: c.textPrimary),
              const SizedBox(width: AppSpacingTokens.sm),
              Text(
                l10n.careCircle,
                style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.md),
          ...pet.careCircle.map(
            (member) => MemberTile(member: member),
          ),
        ],
      ),
    );
  }
}
