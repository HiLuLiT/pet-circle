import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/data/mock_data.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';
import 'package:pet_circle/widgets/round_icon_button.dart';
import 'package:pet_circle/widgets/status_badge.dart';

class VetDashboard extends StatelessWidget {
  const VetDashboard({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    final pets = MockData.vetClinicPets;
    final user = MockData.currentVetUser;
    final l10n = AppLocalizations.of(context)!;

    // Count stats
    final normalCount = pets.where((p) => p.statusLabel == 'Normal').length;
    final elevatedCount = pets.where((p) => p.statusLabel != 'Normal').length;

    final content = SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.clinicOverview,
                style: AppTextStyles.heading2.copyWith(color: AppColors.burgundy),
              ),
              Text(
                l10n.patientsInYourCare(pets.length),
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.lg),
              _ResponsiveGrid(
                maxCrossAxisCount: 3,
                minItemWidth: 280,
                children: pets
                    .map(
                      (pet) => _PetCard(
                        data: pet,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.petDetail,
                          arguments: pet,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ResponsiveGrid(
                maxCrossAxisCount: 3,
                minItemWidth: 280,
                childAspectRatio: 3.3,
                children: [
                  _SummaryCard(
                    iconColor: const Color(0x267FBA7A),
                    icon: Icons.check_circle_outline,
                    value: '$normalCount',
                    label: l10n.normalStatus,
                  ),
                  _SummaryCard(
                    iconColor: const Color(0x26F39C12),
                    icon: Icons.warning_amber_outlined,
                    value: '$elevatedCount',
                    label: l10n.needAttention,
                  ),
                  _SummaryCard(
                    iconColor: const Color(0x1A5B9BD5),
                    icon: Icons.bar_chart,
                    value: '${pets.length * 6}',
                    label: l10n.measurementsThisWeek,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!showScaffold) {
      return Container(color: AppColors.white, child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: content,
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.data, this.onTap});

  final Pet data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicCard(
        radius: BorderRadius.circular(16),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x335B9BD5), Color(0x00000000)],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: DogPhoto(endpoint: data.imageUrl),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 12,
                  child: StatusBadge(
                    label: data.statusLabel,
                    color: Color(data.statusColorHex),
                  ),
                ),
                // Vet indicator badge
                Positioned(
                  top: 16,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.burgundy.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility, size: 12, color: AppColors.white),
                        const SizedBox(width: 4),
                        Text(
                          l10n.viewOnly,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(data.breedAndAge, style: AppTextStyles.bodyMuted),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          NeumorphicCard(
                            inner: true,
                            color: const Color(0xFFF7F9FC),
                            padding: const EdgeInsets.all(10),
                            child: const Icon(Icons.favorite_border,
                                size: 18, color: AppColors.burgundy),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data.latestMeasurement.bpm}',
                                style: AppTextStyles.heading3
                                    .copyWith(color: AppColors.textPrimary),
                              ),
                              Text(l10n.bpm, style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        data.latestMeasurement.recordedAtLabel,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0x265B9BD5), height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            l10n.ownerLabel(_getOwnerName(data.careCircle, l10n.unknown)),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
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

  String _getOwnerName(List<CareCircleMember> circle, String fallback) {
    final owner = circle.where((m) => m.role == 'Owner').firstOrNull;
    return owner?.name ?? fallback;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.iconColor,
    required this.icon,
    required this.value,
    required this.label,
  });

  final Color iconColor;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      radius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(icon, size: 24, color: AppColors.burgundy),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
              ),
              Text(label, style: AppTextStyles.bodyMuted),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({
    required this.children,
    required this.minItemWidth,
    required this.maxCrossAxisCount,
    this.childAspectRatio = 0.85,
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
