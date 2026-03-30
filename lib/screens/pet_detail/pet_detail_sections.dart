import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_widgets.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/note_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';

class PetInfoSection extends StatelessWidget {
  const PetInfoSection({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final latestFromStore = measurementStore.latestForPet(pet.id ?? '');
    final latest = latestFromStore ?? pet.latestMeasurement;
    final hasMeasurement = latest.bpm > 0;
    return NeumorphicCard(
      radius: const BorderRadius.all(AppRadii.medium),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.latestReading,
            style: AppTextStyles.heading3.copyWith(color: c.chocolate),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoTile(
                  icon: Icons.favorite,
                  iconColor: c.pink,
                  value: hasMeasurement ? '${latest.bpm}' : '--',
                  label: l10n.bpm,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InfoTile(
                  icon: Icons.access_time,
                  iconColor: c.lightBlue,
                  value: hasMeasurement ? latest.timeAgo : l10n.noMeasurementsYet,
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
    final c = AppColorsTheme.of(context);
    final storeMeasurements = measurementStore.getMeasurements(pet.id ?? '');
    final List<Measurement> measurements = storeMeasurements.isNotEmpty
        ? storeMeasurements
        : (pet.latestMeasurement.bpm > 0 ? [pet.latestMeasurement] : <Measurement>[]);

    return NeumorphicCard(
      radius: const BorderRadius.all(AppRadii.medium),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.measurementHistory,
                style: AppTextStyles.heading3.copyWith(color: c.chocolate),
              ),
              TextButton.icon(
                onPressed: () {
                  petStore.setActivePet(pet);
                  context.go(AppRoutes.shell(userStore.role, tab: 1));
                },
                icon: const Icon(Icons.show_chart, size: 18),
                label: Text(l10n.viewGraph),
                style: TextButton.styleFrom(foregroundColor: c.lightBlue),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${m.bpm}',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isElevated ? c.cherry : c.lightBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(20, 60),
                          decoration: BoxDecoration(
                            color: isElevated
                                ? c.cherry.withValues(alpha: 0.3)
                                : c.lightBlue.withValues(alpha: 0.3),
                            borderRadius: const BorderRadius.all(AppRadii.xs),
                            border: Border.all(
                              color: isElevated ? c.cherry : c.lightBlue,
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: measurements.take(5).map((m) {
              return Expanded(
                child: Text(
                  m.timeAgo.replaceAll(' ago', ''),
                  style: AppTextStyles.caption.copyWith(fontSize: 9),
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
    final c = AppColorsTheme.of(context);
    final access = petStore.accessForPet(pet);
    final notes = noteStore.getNotes(pet.id ?? '');
    return NeumorphicCard(
      radius: const BorderRadius.all(AppRadii.medium),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt_outlined, color: c.chocolate),
              const SizedBox(width: 8),
              Text(
                l10n.clinicalNotes,
                style: AppTextStyles.heading3.copyWith(color: c.chocolate),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Add note input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.offWhite,
              borderRadius: const BorderRadius.all(AppRadii.small),
            ),
            child: Column(
              children: [
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  readOnly: !access.canAddNotes,
                  decoration: InputDecoration(
                    hintText: l10n.addClinicalNoteHint,
                    hintStyle: AppTextStyles.body.copyWith(color: c.chocolate),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: access.canAddNotes ? onAddNote : null,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addNote),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.chocolate,
                      foregroundColor: c.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(AppRadii.large),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            ...notes.map((note) => NoteCard(note: note)),
          ],
          if (notes.isEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.notes,
                    size: 40,
                    color: c.chocolate.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noClinicalNotesYet,
                    style: AppTextStyles.body.copyWith(color: c.chocolate),
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
    final c = AppColorsTheme.of(context);
    return NeumorphicCard(
      radius: const BorderRadius.all(AppRadii.medium),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group, color: c.chocolate),
              const SizedBox(width: 8),
              Text(
                l10n.careCircle,
                style: AppTextStyles.heading3.copyWith(color: c.chocolate),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...pet.careCircle.map(
            (member) => MemberTile(member: member),
          ),
        ],
      ),
    );
  }
}
