import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/utils/display_localizer.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/widgets/avatar_stack.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:pet_circle/widgets/pet_card.dart';
import 'package:pet_circle/widgets/responsive_grid.dart';
import 'package:pet_circle/widgets/summary_card.dart';

class CareCircleDashboard extends StatelessWidget {
  const CareCircleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([petStore, measurementStore]),
      builder: (context, _) {
        final c = AppSemanticColors.of(context);
        final pets = petStore.allClinicPets;
        final l10n = AppLocalizations.of(context)!;

        return Container(
          color: c.background,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ResponsiveGrid(
                      maxCrossAxisCount: 3,
                      minItemWidth: 280,
                      childAspectRatio: 0.83,
                      children: pets
                          .map(
                            (pet) => _CareCirclePetCard(
                              data: pet,
                              onTap: () => context.go(
                                AppRoutes.shell(tab: 2),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacingTokens.lg),
                    ResponsiveGrid(
                      maxCrossAxisCount: 3,
                      minItemWidth: 280,
                      childAspectRatio: 3.3,
                      children: [
                        SummaryCard(
                          iconColor: c.primaryLight.withValues(alpha: 0.15),
                          icon: Icons.check_circle_outline,
                          value:
                              '${pets.where((p) => p.statusLabel == 'Normal').length}',
                          label: l10n.normalStatus,
                        ),
                        SummaryCard(
                          iconColor: c.error.withValues(alpha: 0.15),
                          icon: Icons.warning_amber_outlined,
                          value:
                              '${pets.where((p) => p.statusLabel != 'Normal').length}',
                          label: l10n.needAttention,
                        ),
                        SummaryCard(
                          iconColor: c.primaryLight.withValues(alpha: 0.1),
                          icon: Icons.bar_chart,
                          value: '${measurementStore.thisWeekCount}',
                          label: l10n.measurementsThisWeek,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Care-circle-context adapter around the shared [PetCard].
///
/// Adds the patient subtitle (breed · SPR bpm) and the care-circle label +
/// avatar stack (footer slot) while delegating the base layout to [PetCard].
class _CareCirclePetCard extends StatelessWidget {
  const _CareCirclePetCard({required this.data, this.onTap});

  final Pet data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final latestFromStore = measurementStore.latestForPet(data.id ?? '');
    final latest = latestFromStore ?? data.latestMeasurement;
    final hasMeasurement = latest.bpm > 0;
    final subtitle = hasMeasurement
        ? l10n.petCardSubtitle(data.breedAndAge, latest.bpm)
        : data.breedAndAge;

    return PetCard(
      name: data.name,
      subtitle: subtitle,
      status: statusBadgeStatusFor(data.statusLabel),
      statusLabel: localizeStatus(data.statusLabel, l10n),
      media: ClipOval(child: DogPhoto(endpoint: data.imageUrl)),
      onTap: onTap,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.group, size: 12, color: c.textPrimary),
              const SizedBox(width: 6),
              Text(l10n.careCircle, style: AppSemanticTextStyles.caption),
            ],
          ),
          AvatarStack(
            avatars: data.careCircle,
            avatarSize: 32,
            alignment: AvatarStackAlignment.left,
            highlightFirst: true,
          ),
        ],
      ),
    );
  }
}
