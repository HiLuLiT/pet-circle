import 'package:flutter/material.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/data/mock_data.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';
import 'package:pet_circle/widgets/round_icon_button.dart';
import 'package:pet_circle/widgets/status_badge.dart';

class CareCircleDashboard extends StatelessWidget {
  const CareCircleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final pets = MockData.pets;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _Header(),
                const SizedBox(height: AppSpacing.lg),
                _ResponsiveGrid(
                  maxCrossAxisCount: 3,
                  minItemWidth: 280,
                  children: pets
                      .map(
                        (pet) => _PetCard(
                          data: pet,
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.measurement),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ResponsiveGrid(
                  maxCrossAxisCount: 3,
                  minItemWidth: 280,
                  childAspectRatio: 3.3,
                  children: const [
                    _SummaryCard(
                      iconColor: Color(0x267FBA7A),
                      iconUrl: AppAssets.statusOkIcon,
                      value: '2',
                      label: 'Normal Status',
                    ),
                    _SummaryCard(
                      iconColor: Color(0x26F39C12),
                      iconUrl: AppAssets.attentionIcon,
                      value: '1',
                      label: 'Need Attention',
                    ),
                    _SummaryCard(
                      iconColor: Color(0x1A5B9BD5),
                      iconUrl: AppAssets.chartIcon,
                      value: '24',
                      label: 'Measurements This Week',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.pink,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(AppAssets.appLogo, width: 60, height: 60),
        ),
        Row(
          children: [
            RoundIconButton(
              icon: const Icon(Icons.language, color: AppColors.burgundy),
            ),
            const SizedBox(width: 8),
            RoundIconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.burgundy),
            ),
          ],
        ),
      ],
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.data, this.onTap});

  final Pet data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicCard(
        radius: BorderRadius.circular(16),
        child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 192,
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
                    style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
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
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.favorite_border,
                              size: 20, color: AppColors.burgundy),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${data.latestMeasurement.bpm}',
                                style: AppTextStyles.heading3
                                    .copyWith(color: AppColors.textPrimary)),
                            Text('BPM', style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                    Text(data.latestMeasurement.recordedAtLabel,
                        style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0x265B9BD5), height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.group, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text('Care Circle', style: AppTextStyles.caption),
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
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i == 0 ? AppColors.accentBlue : AppColors.offWhite,
                    width: 2,
                  ),
                  boxShadow: i == 0
                      ? const [BoxShadow(color: Color(0x4D5B9BD5), blurRadius: 0)]
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
              child: Icon(
                _summaryIcon(iconUrl),
                size: 24,
                color: AppColors.burgundy,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
              Text(label, style: AppTextStyles.bodyMuted),
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
