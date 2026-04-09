import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/utils/formatters.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';
import 'package:pet_circle/widgets/status_badge.dart';

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
                    _ResponsiveGrid(
                      maxCrossAxisCount: 3,
                      minItemWidth: 280,
                      children: pets
                          .map(
                            (pet) => _PetCard(
                              data: pet,
                              onTap: () => context.go(
                                AppRoutes.shell(tab: 2),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacingTokens.lg),
                    _ResponsiveGrid(
                      maxCrossAxisCount: 3,
                      minItemWidth: 280,
                      childAspectRatio: 3.3,
                      children: [
                        _SummaryCard(
                          iconColor: c.primaryLight.withValues(alpha: 0.15),
                          iconUrl: AppAssets.statusOkIcon,
                          value:
                              '${pets.where((p) => p.statusLabel == 'Normal').length}',
                          label: l10n.normalStatus,
                        ),
                        _SummaryCard(
                          iconColor: c.error.withValues(alpha: 0.15),
                          iconUrl: AppAssets.attentionIcon,
                          value:
                              '${pets.where((p) => p.statusLabel != 'Normal').length}',
                          label: l10n.needAttention,
                        ),
                        _SummaryCard(
                          iconColor: c.primaryLight.withValues(alpha: 0.1),
                          iconUrl: AppAssets.chartIcon,
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

class _PetCard extends StatelessWidget {
  const _PetCard({required this.data, this.onTap});

  final Pet data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final latestFromStore = measurementStore.latestForPet(data.id ?? '');
    final latest = latestFromStore ?? data.latestMeasurement;
    final hasMeasurement = latest.bpm > 0;
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicCard(
        radius: BorderRadius.circular(AppRadiiTokens.md),
        child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 192,
                width: double.infinity,
                  decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [c.primaryLight.withValues(alpha: 0.2), Colors.transparent],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadiiTokens.md)),
                  child: DogPhoto(endpoint: data.imageUrl),
                ),
              ),
              Positioned(
                top: 20,
                right: 16,
                child: StatusBadge(
                  label: data.statusLabel,
                  color: Color(data.statusColorHex),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name,
                    style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
                const SizedBox(height: 4),
                Text(data.breedAndAge, style: AppSemanticTextStyles.bodyMuted),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        NeumorphicCard(
                          inner: true,
                          color: c.surface,
                          padding: const EdgeInsets.all(12),
                          child: Icon(Icons.favorite_border,
                              size: 20, color: c.textPrimary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hasMeasurement ? '${latest.bpm}' : '--',
                                style: AppSemanticTextStyles.headingLg
                                    .copyWith(color: c.textPrimary)),
                            Text(l10n.bpm, style: AppSemanticTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                    Text(hasMeasurement ? formatTimeAgo(latest.recordedAt) : l10n.noMeasurementsYet,
                        style: AppSemanticTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: c.primaryLight.withValues(alpha: 0.15), height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.group, size: 12, color: c.textPrimary),
                        const SizedBox(width: 6),
                        Text(l10n.careCircle, style: AppSemanticTextStyles.caption),
                      ],
                    ),
                    _AvatarStack(avatars: data.careCircle),
                  ],
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.avatars});

  final List<CareCircleMember> avatars;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return SizedBox(
      height: 32,
      width: 32 + (avatars.length - 1) * 24,
      child: Stack(
        children: [
          for (var i = 0; i < avatars.length; i++)
            Positioned(
              left: i * 24,
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: c.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i == 0 ? c.primaryLight : c.surface,
                    width: 2,
                  ),
                  boxShadow: i == 0
                      ? [BoxShadow(color: c.primaryLight.withValues(alpha: 0.3), blurRadius: 0)]
                      : null,
                ),
                child: ClipOval(
                  child: Image.network(avatars[i].avatarUrl, fit: BoxFit.cover),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.iconColor,
    required this.iconUrl,
    required this.value,
    required this.label,
  });

  final Color iconColor;
  final String iconUrl;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return NeumorphicCard(
      radius: BorderRadius.circular(AppRadiiTokens.md),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(AppRadiiTokens.lg),
            ),
            child: Center(
              child: Icon(
                _summaryIcon(iconUrl),
                size: 24,
                color: c.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
              Text(label, style: AppSemanticTextStyles.bodyMuted),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _summaryIcon(String key) {
  switch (key) {
    case AppAssets.statusOkIcon:
      return Icons.check_circle_outline;
    case AppAssets.attentionIcon:
      return Icons.warning_amber_outlined;
    case AppAssets.chartIcon:
      return Icons.bar_chart;
    default:
      return Icons.info_outline;
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({
    required this.children,
    required this.minItemWidth,
    required this.maxCrossAxisCount,
    this.childAspectRatio = 0.83,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxCrossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final count = (width / minItemWidth).floor().clamp(1, maxCrossAxisCount);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: count,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: childAspectRatio,
          children: children,
        );
      },
    );
  }
}
