import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet_access.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/utils/responsive_utils.dart';
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
              Navigator.pop(ctx);
              petStore.removePetWithFirestore(pet.name);
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
    return ListenableBuilder(
      listenable: petStore,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final pets = petStore.ownerPets;
    final l10n = AppLocalizations.of(context)!;

    if (petStore.isLoading) {
      final loader = Center(
        child: CircularProgressIndicator(color: c.chocolate),
      );
      if (!showScaffold) return Container(color: c.white, child: loader);
      return Scaffold(backgroundColor: c.white, body: loader);
    }

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
                  onTap: () => context.push(AppRoutes.onboarding),
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

    final petCards = pets.map(
      (pet) => Builder(
        builder: (context) {
          final access = petStore.accessForPet(pet);
          return _PetCard(
            data: pet,
            access: access,
            onLongPress: access.canDeletePet
                ? () => _confirmDeletePet(context, pet)
                : null,
            onMeasure: access.canMeasure
                ? () {
                    petStore.setActivePet(pet);
                    context.go(AppRoutes.shell(AppUserRole.owner, tab: 2));
                  }
                : null,
            onTrends: () {
              petStore.setActivePet(pet);
              context.go(AppRoutes.shell(AppUserRole.owner, tab: 1));
            },
          );
        },
      ),
    ).toList();

    final content = SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsiveMaxWidth(context)),
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= kTabletBreakpoint;
                      if (isWide) {
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.75,
                          children: petCards,
                        );
                      }
                      return Column(
                        children: petCards
                            .map((card) => Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: card,
                                ))
                            .toList(),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.onboarding),
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
  const _PetCard({
    required this.data,
    required this.onMeasure,
    required this.onTrends,
    required this.access,
    this.onLongPress,
  });

  final Pet data;
  final VoidCallback? onMeasure;
  final VoidCallback onTrends;
  final PetAccess access;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final latestFromStore = measurementStore.latestForPet(data.id ?? '');
    final latest = latestFromStore ?? data.latestMeasurement;
    final hasMeasurement = latest.bpm > 0;
    return GestureDetector(
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.name,
                          style: AppTextStyles.heading2.copyWith(
                            color: c.chocolate,
                            letterSpacing: -0.96,
                          ),
                        ),
                      ),
                      if (access.role != CareCircleRole.admin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: access.role == CareCircleRole.member
                                ? c.lightBlue.withValues(alpha: 0.12)
                                : c.blue.withValues(alpha: 0.12),
                            borderRadius: const BorderRadius.all(AppRadii.small),
                          ),
                          child: Text(
                            access.role.name[0].toUpperCase() + access.role.name.substring(1),
                            style: AppTextStyles.caption.copyWith(
                              color: access.role == CareCircleRole.member ? c.lightBlue : c.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
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
                                hasMeasurement ? '${latest.bpm}' : '--',
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
                        hasMeasurement ? latest.timeAgo : l10n.noMeasurementsYet,
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
                      if (onMeasure != null)
                        Expanded(
                          child: _ActionButton(
                            label: l10n.measure,
                            iconAsset: _measureIconAsset,
                            isPrimary: true,
                            onTap: onMeasure!,
                          ),
                        ),
                      if (onMeasure != null)
                        const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          label: l10n.trends,
                          iconAsset: _trendsIconAsset,
                          isPrimary: onMeasure == null,
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

