import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/models/reminder.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/reminder_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/utils/formatters.dart';
import 'package:pet_circle/utils/mascot_mapper.dart';
import 'package:pet_circle/utils/responsive_utils.dart';
import 'package:pet_circle/widgets/app_card.dart';
import 'package:pet_circle/widgets/avatar_stack.dart';
import 'package:pet_circle/widgets/mascot.dart';
import 'package:pet_circle/widgets/pet_card.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/status_badge.dart';

import 'add_reminder_sheet.dart';

/// Owner home screen — Figma node 402:1978.
///
/// An active-pet-focused dashboard: a hero [PetCard] for
/// `petStore.activePet`, a latest-reading summary, the care circle, upcoming
/// reminders, and Measure/Trends shortcuts. Switching pets via the header
/// selector (see [main_shell.dart]) changes what this screen shows.
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

  void _openReminderSheet(BuildContext context, [Reminder? reminder]) {
    final access = petStore.accessForActivePet();
    if (!access.canManageMedication) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReminderSheet(reminder: reminder),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([petStore, measurementStore, reminderStore]),
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
      if (!showScaffold) return Container(color: c.background, child: loader);
      return Scaffold(backgroundColor: c.background, body: loader);
    }

    if (pets.isEmpty) {
      return _buildEmptyState(context, c, l10n);
    }

    final pet = petStore.activePet ?? pets.first;
    return _buildActivePetHome(context, c, l10n, pet);
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
      return Container(color: c.background, child: emptyContent);
    }
    return Scaffold(backgroundColor: c.background, body: emptyContent);
  }

  Widget _buildActivePetHome(BuildContext context, AppSemanticColors c,
      AppLocalizations l10n, Pet pet) {
    final access = petStore.accessForPet(pet);
    final latest = measurementStore.latestForPet(pet.id ?? '');
    final subtitle = latest != null
        ? l10n.petCardSubtitle(pet.breedAndAge, latest.bpm)
        : pet.breedAndAge;
    final reminders = reminderStore.getReminders(pet.id ?? '');

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

                    // Section header — Figma node 407:3528.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.yourPets,
                          style: AppSemanticTextStyles.headingH2
                              .copyWith(color: c.textPrimary),
                        ),
                        PrimaryButton(
                          label: l10n.addPet,
                          variant: PrimaryButtonVariant.link,
                          onPressed: () => context.push(AppRoutes.onboarding),
                          trailingIcon: Icon(
                            Icons.add_circle_outline,
                            color: c.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacingTokens.lg),

                    // Hero pet card — Figma node 442:8893.
                    PetCard(
                      name: pet.name,
                      subtitle: subtitle,
                      status: StatusBadgeStatus.active,
                      statusLabel: l10n.active,
                      size: PetCardSize.hero,
                      media: Mascot(
                        breed: mascotBreedFor(pet.breedAndAge),
                        color: c.accentPurple,
                        size: 90,
                      ),
                      onLongPress:
                          access.canDeletePet ? () => _confirmDeletePet(context, pet) : null,
                    ),

                    const SizedBox(height: AppSpacingTokens.md),

                    // Latest reading card — Figma node 469:939.
                    if (latest != null)
                      AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: c.accentBlushTile,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite,
                                color: c.accentBlush,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacingTokens.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${latest.bpm} ${l10n.bpm}',
                                    style: AppSemanticTextStyles.headingH2
                                        .copyWith(color: c.textPrimary),
                                  ),
                                  Text(
                                    l10n.latestReading,
                                    style: AppSemanticTextStyles.labelSRegular
                                        .copyWith(color: c.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatTimeAgo(latest.recordedAt, l10n),
                              style: AppSemanticTextStyles.labelSRegular
                                  .copyWith(color: c.textTertiary),
                            ),
                          ],
                        ),
                      ),

                    if (latest != null)
                      const SizedBox(height: AppSpacingTokens.md),

                    // Care circle card — Figma node 442:8959.
                    AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.careCircle,
                            style: AppSemanticTextStyles.pcBodySemibold
                                .copyWith(color: c.textPrimary),
                          ),
                          AvatarStack(
                            avatars: pet.careCircle,
                            borderColor: c.surface,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacingTokens.md),

                    // Reminders card — Figma node 442:9012.
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.reminders,
                                style: AppSemanticTextStyles.pcBodySemibold
                                    .copyWith(color: c.textPrimary),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _openReminderSheet(context),
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: c.textPrimary,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          if (reminders.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: AppSpacingTokens.md),
                              child: Text(
                                l10n.noRemindersYet,
                                style: AppSemanticTextStyles.pcBodyMuted,
                              ),
                            )
                          else
                            ...reminders.map((reminder) => Padding(
                                  padding: const EdgeInsets.only(
                                      top: AppSpacingTokens.md),
                                  child: _ReminderTile(
                                    reminder: reminder,
                                    petName: pet.name,
                                    onTap: () =>
                                        _openReminderSheet(context, reminder),
                                  ),
                                )),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacingTokens.lg),

                    // Action buttons — Figma node 426:1182.
                    PrimaryButton(
                      label: l10n.measure,
                      variant: PrimaryButtonVariant.filled,
                      onPressed: () =>
                          context.go(AppRoutes.shell(tab: AppRoutes.tabMeasure)),
                    ),
                    const SizedBox(height: AppSpacingTokens.md),
                    PrimaryButton(
                      label: l10n.trends,
                      variant: PrimaryButtonVariant.outlined,
                      onPressed: () =>
                          context.go(AppRoutes.shell(tab: AppRoutes.tabTrends)),
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
      return Container(color: c.background, child: content);
    }
    return Scaffold(backgroundColor: c.background, body: content);
  }
}

/// A single recessed reminder row inside the Reminders card — Figma node
/// 469:1023. Shows the reminder date + a purple pet-name chip, then the
/// title/detail with a trailing chevron.
class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.petName,
    this.onTap,
  });

  final Reminder reminder;
  final String petName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(AppRadiiTokens.pcCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  formatReminderDate(reminder.date, l10n.localeName),
                  style: AppSemanticTextStyles.bodySm
                      .copyWith(color: c.textSecondary),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                _PetChip(petName: petName),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: AppSemanticTextStyles.pcBodySemibold
                            .copyWith(color: c.textPrimary),
                      ),
                      if (reminder.detail != null &&
                          reminder.detail!.isNotEmpty)
                        Text(
                          reminder.detail!,
                          style: AppSemanticTextStyles.bodySm
                              .copyWith(color: c.textSecondary),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.textPrimary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small pill chip showing the pet's name inside a reminder tile — Figma
/// node 469:1007 ("Badge"). Single call site; not promoted to a shared
/// widget.
class _PetChip extends StatelessWidget {
  const _PetChip({required this.petName});

  final String petName;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.accentPurpleTile,
        borderRadius: BorderRadius.circular(AppRadiiTokens.pcPill),
      ),
      child: Text(
        petName,
        style: AppSemanticTextStyles.labelSSemibold
            .copyWith(color: c.textPrimary),
      ),
    );
  }
}
