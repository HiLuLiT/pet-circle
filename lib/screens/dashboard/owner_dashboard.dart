import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/widgets/dog_photo.dart';

const _bpmIconAsset = 'assets/figma/bpm_icon.svg';
const _careCircleIconAsset = 'assets/figma/care_circle_icon.svg';
const _measureIconAsset = 'assets/figma/measure_icon.svg';
const _trendsIconAsset = 'assets/figma/trends_icon.svg';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key, this.showScaffold = true});

  final bool showScaffold;

  void _confirmDeletePet(BuildContext context, Pet pet) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(AppRadii.medium)),
        title: Text(l10n.deletePet, style: AppTextStyles.heading3.copyWith(color: c.chocolate)),
        content: Text(l10n.deletePetConfirmation(pet.name), style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              petStore.removePet(pet.name);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.petDeleted)),
              );
            },
            style: TextButton.styleFrom(backgroundColor: c.cherry),
            child: Text(l10n.deletePet, style: TextStyle(color: c.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final pets = petStore.ownerPets;
    final l10n = AppLocalizations.of(context)!;

    if (pets.isEmpty) {
      final emptyContent = SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets, size: 64, color: c.chocolate.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  l10n.noPetsYet,
                  style: AppTextStyles.heading2.copyWith(color: c.chocolate),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.addYourFirstPet,
                  style: AppTextStyles.body.copyWith(color: c.chocolate),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.onboarding),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: c.lightBlue,
                      borderRadius: const BorderRadius.all(AppRadii.full),
                    ),
                    child: Text(
                      l10n.getStarted,
                      style: AppTextStyles.body.copyWith(
                        color: c.chocolate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (!showScaffold) {
        return Container(color: c.white, child: emptyContent);
      }
      return Scaffold(backgroundColor: c.white, body: emptyContent);
    }

    final content = SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.myPets,
                style: AppTextStyles.heading2.copyWith(
                  color: c.chocolate,
                  letterSpacing: -0.96,
                ),
              ),
              const SizedBox(height: 24),
              ...pets.map(
                (pet) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _PetCard(
                    data: pet,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.petDetail,
                      arguments: pet,
                    ),
                    onLongPress: (petStore.currentUserRoleFor(pet.name) ?? CareCircleRole.admin).canDeletePet
                        ? () => _confirmDeletePet(context, pet)
                        : null,
                    onMeasure: () => Navigator.of(context).pushNamed(
                      AppRoutes.mainShell,
                      arguments: {
                        'role': AppUserRole.owner,
                        'initialIndex': 2,
                      },
                    ),
                    onTrends: () => Navigator.of(context).pushNamed(
                      AppRoutes.mainShell,
                      arguments: {
                        'role': AppUserRole.owner,
                        'initialIndex': 1,
                      },
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.onboarding),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: c.offWhite,
                    borderRadius: const BorderRadius.all(AppRadii.medium),
                    border: Border.all(
                      color: c.chocolate.withValues(alpha: 0.15),
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20, color: c.chocolate),
                      const SizedBox(width: 8),
                      Text(
                        l10n.addPet,
                        style: AppTextStyles.body.copyWith(
                          color: c.chocolate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
      return Container(color: c.white, child: content);
    }

    return Scaffold(
      backgroundColor: c.white,
      body: content,
    );
  }
}

class _PetCard extends StatelessWidget {
  _PetCard({
    required this.data,
    required this.onMeasure,
    required this.onTrends,
    this.onTap,
    this.onLongPress,
  });

  final Pet data;
  final VoidCallback onMeasure;
  final VoidCallback onTrends;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final latestFromStore = measurementStore.latestForPet(data.name);
    final latest = latestFromStore ?? data.latestMeasurement;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ClipRRect(
      borderRadius: const BorderRadius.all(AppRadii.medium),
      child: Container(
        color: c.offWhite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: AppRadii.medium),
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
                      color: c.chocolate,
                      letterSpacing: -0.96,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.breedAndAge,
                    style: AppTextStyles.body.copyWith(
                      color: c.chocolate,
                      fontSize: 14,
                      letterSpacing: -0.28,
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
                            decoration: BoxDecoration(
                              color: c.white,
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
                                '${latest.bpm}',
                                style: AppTextStyles.heading2.copyWith(
                                  color: c.chocolate,
                                  fontSize: 24,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                l10n.bpm,
                                style: AppTextStyles.caption.copyWith(
                                  color: c.chocolate,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        latest.timeAgo,
                        style: AppTextStyles.caption.copyWith(
                          color: c.chocolate,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  // Care Circle divider
                  Container(
                    height: 1,
                    color: c.chocolate,
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
                            l10n.careCircle,
                            style: AppTextStyles.caption.copyWith(
                              color: c.chocolate,
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
                    color: c.chocolate,
                  ),
                  const SizedBox(height: 17),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: l10n.measure,
                          iconAsset: _measureIconAsset,
                          isPrimary: true,
                          onTap: onMeasure,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          label: l10n.trends,
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
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  _ActionButton({
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
    final c = AppColorsTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isPrimary ? c.pink : c.white,
          borderRadius: const BorderRadius.all(AppRadii.full),
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
                color: c.chocolate,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.28,
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
    final c = AppColorsTheme.of(context);
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
                  border: Border.all(color: c.white, width: 2),
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

