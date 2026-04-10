import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/utils/formatters.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet_access.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/theme/tokens/typography.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/utils/responsive_utils.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:pet_circle/widgets/primary_button.dart';

const _bpmIconAsset = 'assets/figma/bpm_icon.svg';
const _careCircleIconAsset = 'assets/figma/care_circle_icon.svg';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key, this.showScaffold = true});

  final bool showScaffold;

  void _confirmDeletePet(BuildContext context, Pet pet) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadiiTokens.md),
        ),
        title: Text(l10n.deletePet,
            style: AppSemanticTextStyles.headingLg
                .copyWith(color: c.textPrimary)),
        content: Text(l10n.deletePetConfirmation(pet.name),
            style: AppSemanticTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              petStore.removePetWithFirestore(pet.name);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.petDeleted)),
              );
            },
            style: TextButton.styleFrom(backgroundColor: c.error),
            child: Text(l10n.deletePet,
                style: TextStyle(color: c.background)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([petStore, measurementStore]),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final pets = petStore.ownerPets;
    final l10n = AppLocalizations.of(context)!;

    if (petStore.isLoading) {
      final loader = Center(
        child: CircularProgressIndicator(color: c.primary),
      );
      if (!showScaffold) return Container(color: c.surface, child: loader);
      return Scaffold(backgroundColor: c.surface, body: loader);
    }

    if (pets.isEmpty) {
      return _buildEmptyState(context, c, l10n);
    }

    return _buildPetList(context, c, l10n, pets);
  }

  Widget _buildEmptyState(
      BuildContext context, AppSemanticColors c, AppLocalizations l10n) {
    final emptyContent = SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pets,
                  size: 64,
                  color: c.textPrimary.withValues(alpha: 0.3)),
              const SizedBox(height: AppSpacingTokens.md),
              Text(l10n.noPetsYet,
                  style: AppSemanticTextStyles.title3
                      .copyWith(color: c.textPrimary)),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(l10n.addYourFirstPet,
                  style: AppSemanticTextStyles.body
                      .copyWith(color: c.textPrimary),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacingTokens.lg),
              PrimaryButton(
                label: l10n.getStarted,
                fullWidth: false,
                onPressed: () => context.push(AppRoutes.onboarding),
              ),
            ],
          ),
        ),
      ),
    );

    if (!showScaffold) {
      return Container(color: c.surface, child: emptyContent);
    }
    return Scaffold(backgroundColor: c.surface, body: emptyContent);
  }

  Widget _buildPetList(BuildContext context, AppSemanticColors c,
      AppLocalizations l10n, List<Pet> pets) {
    final petCards = pets.map((pet) {
      return Builder(builder: (context) {
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
                  context.go(AppRoutes.shell(tab: 3));
                }
              : null,
          onTrends: () {
            petStore.setActivePet(pet);
            context.go(AppRoutes.shell(tab: 1));
          },
        );
      });
    }).toList();

    final content = SafeArea(
      child: RefreshIndicator(
        onRefresh: () => petStore.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: responsiveMaxWidth(context)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacingTokens.lg),

                  // Title — Figma: Title2 (32px bold)
                  Text(
                    l10n.myPets,
                    style: AppSemanticTextStyles.title2
                        .copyWith(color: c.textPrimary),
                  ),

                  const SizedBox(height: AppSpacingTokens.lg),

                  // Pet cards
                  LayoutBuilder(builder: (context, constraints) {
                    final isWide =
                        constraints.maxWidth >= kTabletBreakpoint;
                    if (isWide) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacingTokens.lg,
                        mainAxisSpacing: AppSpacingTokens.lg,
                        childAspectRatio: 0.85,
                        children: petCards,
                      );
                    }
                    return Column(
                      children: petCards
                          .map((card) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacingTokens.lg),
                                child: card,
                              ))
                          .toList(),
                    );
                  }),

                  // "Add another pet" button — outlined pill with trailing plus icon
                  Center(
                    child: PrimaryButton(
                      label: l10n.addAnotherPet,
                      variant: PrimaryButtonVariant.outlined,
                      fullWidth: false,
                      onPressed: () => context.push(AppRoutes.onboarding),
                      trailingIcon: _AddPetIcon(),
                    ),
                  ),

                  const SizedBox(height: AppSpacingTokens.xl),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );

    if (!showScaffold) {
      return Container(color: c.surface, child: content);
    }
    return Scaffold(backgroundColor: c.surface, body: content);
  }
}

/// Circled plus icon for the "Add another pet" button.
class _AddPetIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: c.primary, width: 1.5),
      ),
      child: Icon(Icons.add, size: 16, color: c.primary),
    );
  }
}

/// Pet card — Figma node 196:4191.
///
/// Layout: flex-col, gap-24, items-center, p-24, rounded-16, bg primaryLightest.
/// Content section (avatar + name/breed + rows) is full-width, left-aligned.
/// Button group is content-sized, centered by the card's items-center.
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
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final latestFromStore = measurementStore.latestForPet(data.id ?? '');
    final latest = latestFromStore ?? data.latestMeasurement;
    final hasMeasurement = latest.bpm > 0;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: c.primaryLightest,
          borderRadius: AppRadiiTokens.borderRadiusLg,
        ),
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: Column(
          // Figma: items-center on card — centers the button group
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Content section — full-width, left-aligned
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet avatar — circular 80px
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipOval(
                      child: DogPhoto(endpoint: data.imageUrl),
                    ),
                  ),

                  const SizedBox(height: AppSpacingTokens.lg),

                  // Pet name — Figma: 18px Bold, line-height 18px (largeNoneBold)
                  Text(
                    data.name,
                    style: AppTypography.largeNoneBold
                        .copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  // Breed — Figma: 16px Regular, line-height 24px
                  Text(
                    data.breedAndAge,
                    style: AppSemanticTextStyles.body
                        .copyWith(color: c.textPrimary),
                  ),

                  const SizedBox(height: AppSpacingTokens.lg),

                  // BPM row — Figma: border-b white, pb-12, gap-12
                  _InfoRow(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          _bpmIconAsset,
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ),
                    leadingGap: AppSpacingTokens.md - 4, // 12px
                    title: Text(
                      hasMeasurement ? '${latest.bpm}' : '--',
                      style: AppSemanticTextStyles.headingLg
                          .copyWith(color: c.textPrimary),
                    ),
                    subtitle: Text(
                      l10n.bpm,
                      style: AppSemanticTextStyles.body
                          .copyWith(color: c.textPrimary),
                    ),
                    trailing: Text(
                      hasMeasurement
                          ? formatTimeAgo(latest.recordedAt)
                          : l10n.noMeasurementsYet,
                      style: AppSemanticTextStyles.body
                          .copyWith(color: c.textPrimary),
                    ),
                    borderColor: c.surface,
                  ),

                  const SizedBox(height: AppSpacingTokens.md),

                  // Care circle row — Figma: border-b white, pb-12, gap-4
                  _InfoRow(
                    leading: SvgPicture.asset(
                      _careCircleIconAsset,
                      width: 24,
                      height: 24,
                    ),
                    leadingGap: AppSpacingTokens.xs, // 4px
                    title: Text(
                      l10n.careCircle,
                      style: AppSemanticTextStyles.body
                          .copyWith(color: c.textPrimary),
                    ),
                    trailing: _AvatarStack(avatars: data.careCircle),
                    borderColor: c.surface,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacingTokens.lg),

            // Button group — Figma: flex, gap-16, content-sized, centered
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: l10n.trends,
                  variant: PrimaryButtonVariant.outlined,
                  fullWidth: false,
                  onPressed: onTrends,
                ),
                const SizedBox(width: AppSpacingTokens.md),
                if (onMeasure != null)
                  PrimaryButton(
                    label: l10n.measure,
                    variant: PrimaryButtonVariant.filled,
                    fullWidth: false,
                    onPressed: onMeasure!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable info row with border-bottom — used for BPM and care circle rows.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.leading,
    required this.leadingGap,
    required this.title,
    this.subtitle,
    required this.trailing,
    required this.borderColor,
  });

  final Widget leading;
  final double leadingGap;
  final Widget title;
  final Widget? subtitle;
  final Widget trailing;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacingTokens.md - 4), // 12px
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              leading,
              SizedBox(width: leadingGap),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) subtitle!,
                ],
              ),
            ],
          ),
          trailing,
        ],
      ),
    );
  }
}

/// Overlapping avatar stack for care circle members.
class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.avatars});

  final List<CareCircleMember> avatars;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    const double avatarSize = 24;
    const double overlap = 8;
    final count = avatars.length;
    if (count == 0) return const SizedBox.shrink();

    return SizedBox(
      height: avatarSize,
      width: avatarSize + (count - 1) * (avatarSize - overlap) + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              right: 8 + i * (avatarSize - overlap),
              child: _AvatarCircle(
                member: avatars[i],
                size: avatarSize,
                borderColor: c.primaryLightest,
              ),
            ),
        ],
      ),
    );
  }
}

/// Single avatar circle — shows image or initials.
class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.member,
    required this.size,
    required this.borderColor,
  });

  final CareCircleMember member;
  final double size;
  final Color borderColor;

  String get _initials {
    final parts = member.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return member.name.isNotEmpty
        ? member.name.substring(0, member.name.length.clamp(0, 2)).toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final hasImage = member.avatarUrl.startsWith('http');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
        color: hasImage ? null : c.primary,
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                member.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: c.onPrimary,
                      fontSize: size * 0.42,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  _initials,
                  style: TextStyle(
                    color: c.onPrimary,
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
      ),
    );
  }
}
