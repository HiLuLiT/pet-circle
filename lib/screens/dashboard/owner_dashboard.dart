import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/data/mock_data.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/dog_photo.dart';

const _bpmIconAsset = 'assets/figma/bpm_icon.svg';
const _careCircleIconAsset = 'assets/figma/care_circle_icon.svg';
const _measureIconAsset = 'assets/figma/measure_icon.svg';
const _trendsIconAsset = 'assets/figma/trends_icon.svg';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    final pets = MockData.hilaPets;
    final user = MockData.currentOwnerUser;

    final content = SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _Header(
                avatarUrl: user.avatarUrl,
                onSettingsTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.settings,
                  arguments: AppUserRole.owner,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'My pets',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.burgundy,
                  letterSpacing: -0.96,
                ),
              ),
              const SizedBox(height: 24),
              ...pets.map(
                (pet) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _PetCard(
                    data: pet,
                    onMeasure: () => Navigator.of(context).pushNamed(
                      AppRoutes.measurement,
                      arguments: pet,
                    ),
                    onTrends: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Trends coming soon')),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.avatarUrl,
    this.onSettingsTap,
  });

  final String avatarUrl;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile avatar on left
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
          child: ClipOval(
            child: Image.network(avatarUrl, fit: BoxFit.cover),
          ),
        ),
        // Settings icon on right
        GestureDetector(
          onTap: onSettingsTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.offWhite,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.settings,
              color: AppColors.burgundy,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.data,
    required this.onMeasure,
    required this.onTrends,
  });

  final Pet data;
  final VoidCallback onMeasure;
  final VoidCallback onTrends;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: AppColors.offWhite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 216,
                width: double.infinity,
                child: DogPhoto(endpoint: data.imageUrl),
              ),
            ),
            // Pet info
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and breed
                  Text(
                    data.name,
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.burgundy,
                      letterSpacing: -0.96,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.breedAndAge,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.burgundy,
                      fontSize: 14,
                      letterSpacing: -0.15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // BPM row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Heart icon in circle
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                _bpmIconAsset,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data.latestMeasurement.bpm}',
                                style: AppTextStyles.heading2.copyWith(
                                  color: AppColors.burgundy,
                                  fontSize: 24,
                                  height: 1.33,
                                ),
                              ),
                              Text(
                                'BPM',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.burgundy,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        data.latestMeasurement.recordedAtLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.burgundy,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  // Care Circle divider
                  Container(
                    height: 1,
                    color: AppColors.burgundy,
                  ),
                  const SizedBox(height: 17),
                  // Care Circle row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            _careCircleIconAsset,
                            width: 12,
                            height: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Care Circle',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.burgundy,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      _AvatarStack(avatars: data.careCircle),
                    ],
                  ),
                  const SizedBox(height: 17),
                  // Buttons divider
                  Container(
                    height: 1,
                    color: AppColors.burgundy,
                  ),
                  const SizedBox(height: 17),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Measure',
                          iconAsset: _measureIconAsset,
                          isPrimary: true,
                          onTap: onMeasure,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          label: 'Trends',
                          iconAsset: _trendsIconAsset,
                          isPrimary: false,
                          onTap: onTrends,
                        ),
                      ),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.iconAsset,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.pink : AppColors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.burgundy,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.15,
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
    const double avatarSize = 31;
    const double overlap = 12;

    return SizedBox(
      height: avatarSize,
      width: avatarSize + (avatars.length - 1) * (avatarSize - overlap),
      child: Stack(
        children: [
          for (var i = 0; i < avatars.length; i++)
            Positioned(
              right: i * (avatarSize - overlap),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
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

