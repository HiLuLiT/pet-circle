import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/utils/responsive_utils.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/invitation.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/services/invitation_service.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';
import 'package:pet_circle/widgets/status_badge.dart';

class VetDashboard extends StatefulWidget {
  const VetDashboard({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  State<VetDashboard> createState() => _VetDashboardState();
}

class _VetDashboardState extends State<VetDashboard> {
  List<Invitation> _pendingInvitations = [];
  final Set<String> _processingTokens = {};

  @override
  void initState() {
    super.initState();
    _loadPendingInvitations();
  }

  Future<void> _loadPendingInvitations() async {
    if (!kEnableFirebase) return;
    final email = userStore.currentUserEmail;
    if (email == null || email.isEmpty) return;

    final invitations =
        await InvitationService.getPendingInvitationsForEmail(email);
    if (mounted) {
      setState(() => _pendingInvitations = invitations);
    }
  }

  Future<void> _acceptInvitation(Invitation inv) async {
    setState(() => _processingTokens.add(inv.id));
    final result = await InvitationService.acceptInvitation(
      token: inv.id,
      uid: userStore.currentUserUid ?? '',
      email: userStore.currentUserEmail ?? '',
      displayName: userStore.currentUserDisplayName ?? '',
      avatarUrl: userStore.currentUserAvatarUrl ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userStore.currentUserDisplayName ?? '')}&background=E8B4B8&color=5B2C3F',
    );
    if (!mounted) return;
    setState(() {
      _processingTokens.remove(inv.id);
      _pendingInvitations.removeWhere((i) => i.id == inv.id);
    });
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success ? l10n.requestAccepted : _invitationErrorText(l10n, result.errorCode),
        ),
      ),
    );
  }

  String _invitationErrorText(AppLocalizations l10n, String? errorCode) {
    switch (errorCode) {
      case 'invitationExpired':
        return l10n.invitationExpired;
      case 'invitationAlreadyUsed':
        return l10n.invitationAlreadyUsed;
      case 'invitationNotAuthorized':
        return l10n.invitationNotAuthorized;
      case 'invitationNoLongerValid':
        return l10n.invitationNoLongerValid;
      case 'invitationAcceptFailed':
        return l10n.invitationAcceptFailed;
      case 'invitationNotFound':
      default:
        return l10n.invitationNotFound;
    }
  }

  Future<void> _declineInvitation(Invitation inv) async {
    setState(() => _processingTokens.add(inv.id));
    await InvitationService.cancelInvitation(inv.id);
    if (!mounted) return;
    setState(() {
      _processingTokens.remove(inv.id);
      _pendingInvitations.removeWhere((i) => i.id == inv.id);
    });
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.requestDeclined)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([petStore, measurementStore]),
      builder: (context, _) {
        final c = AppColorsTheme.of(context);
        final pets = petStore.allClinicPets;
        final l10n = AppLocalizations.of(context)!;

        if (petStore.isLoading) {
          final loader = Center(
            child: CircularProgressIndicator(color: c.chocolate),
          );
          if (!widget.showScaffold) {
            return Container(color: c.white, child: loader);
          }
          return Scaffold(backgroundColor: c.white, body: loader);
        }

        final normalCount = pets.where((p) => p.statusLabel == 'Normal').length;
        final elevatedCount = pets.where((p) => p.statusLabel != 'Normal').length;

        final content = SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: responsiveMaxWidth(context)),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  if (_pendingInvitations.isNotEmpty) ...[
                    _PendingRequestsSection(
                      invitations: _pendingInvitations,
                      processingTokens: _processingTokens,
                      onAccept: _acceptInvitation,
                      onDecline: _declineInvitation,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text(
                    l10n.clinicOverview,
                    style: AppTextStyles.heading2.copyWith(color: c.chocolate),
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
                            onTap: () => context.push(
                              AppRoutes.petDetail(AppUserRole.vet, pet.id ?? ''),
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
                        iconColor: c.lightBlue.withValues(alpha: 0.15),
                        icon: Icons.check_circle_outline,
                        value: '$normalCount',
                        label: l10n.normalStatus,
                      ),
                      _SummaryCard(
                        iconColor: c.cherry.withValues(alpha: 0.15),
                        icon: Icons.warning_amber_outlined,
                        value: '$elevatedCount',
                        label: l10n.needAttention,
                      ),
                      _SummaryCard(
                        iconColor: c.lightBlue.withValues(alpha: 0.1),
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
          ),
        );

        if (!widget.showScaffold) {
          return Container(color: c.white, child: content);
        }

        return Scaffold(
          backgroundColor: c.white,
          body: content,
        );
      },
    );
  }
}

// ── Pending Requests Section ──

class _PendingRequestsSection extends StatelessWidget {
  const _PendingRequestsSection({
    required this.invitations,
    required this.processingTokens,
    required this.onAccept,
    required this.onDecline,
  });

  final List<Invitation> invitations;
  final Set<String> processingTokens;
  final void Function(Invitation) onAccept;
  final void Function(Invitation) onDecline;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notification_important_outlined,
                size: 20, color: c.cherry),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.pendingRequests,
              style: AppTextStyles.heading3.copyWith(color: c.chocolate),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...invitations.map((inv) {
          final isProcessing = processingTokens.contains(inv.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: NeumorphicCard(
              radius: const BorderRadius.all(AppRadii.medium),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c.lightBlue.withValues(alpha: 0.15),
                          borderRadius:
                              const BorderRadius.all(AppRadii.large),
                        ),
                        child: Icon(Icons.pets, size: 20, color: c.blue),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inv.petName,
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: c.chocolate),
                            ),
                            Text(
                              l10n.petAssociationRequest(
                                  inv.invitedByName, inv.petName),
                              style: AppTextStyles.caption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            isProcessing ? null : () => onDecline(inv),
                        child: Text(l10n.declineRequest,
                            style: AppTextStyles.caption
                                .copyWith(color: c.cherry)),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.blue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(AppRadii.pill),
                            ),
                          ),
                          onPressed:
                              isProcessing ? null : () => onAccept(inv),
                          child: isProcessing
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: c.white),
                                )
                              : Text(l10n.acceptRequest,
                                  style: AppTextStyles.caption
                                      .copyWith(color: c.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Pet Card ──

class _PetCard extends StatelessWidget {
  const _PetCard({required this.data, this.onTap});

  final Pet data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final latestFromStore = measurementStore.latestForPet(data.id ?? '');
    final latest = latestFromStore ?? data.latestMeasurement;
    final hasMeasurement = latest.bpm > 0;
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicCard(
        radius: const BorderRadius.all(AppRadii.medium),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        c.lightBlue.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: AppRadii.medium),
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
                Positioned(
                  top: 16,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.chocolate.withValues(alpha: 0.9),
                      borderRadius: const BorderRadius.all(AppRadii.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility, size: 12, color: c.white),
                        const SizedBox(width: 4),
                        Text(
                          l10n.viewOnly,
                          style: AppTextStyles.caption.copyWith(
                            color: c.white,
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
                    style:
                        AppTextStyles.heading3.copyWith(color: c.chocolate),
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
                            color: c.offWhite,
                            padding: const EdgeInsets.all(10),
                            child: Icon(Icons.favorite_border,
                                size: 18, color: c.chocolate),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasMeasurement ? '${latest.bpm}' : '--',
                                style: AppTextStyles.heading3
                                    .copyWith(color: c.chocolate),
                              ),
                              Text(l10n.bpm,
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        hasMeasurement ? latest.timeAgo : l10n.noMeasurementsYet,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(
                      color: c.lightBlue.withValues(alpha: 0.15),
                      height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 14, color: c.chocolate),
                          const SizedBox(width: 6),
                          Text(
                            l10n.ownerLabel(_getOwnerName(
                                data.careCircle, l10n.unknown)),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_right,
                          size: 18, color: c.chocolate),
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
    final owner =
        circle.where((m) => m.role == CareCircleRole.admin).firstOrNull;
    return owner?.name ?? fallback;
  }
}

// ── Summary Card ──

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
    final c = AppColorsTheme.of(context);
    return NeumorphicCard(
      radius: const BorderRadius.all(AppRadii.medium),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: const BorderRadius.all(AppRadii.large),
            ),
            child: Center(
              child: Icon(icon, size: 24, color: c.chocolate),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style:
                    AppTextStyles.heading3.copyWith(color: c.chocolate),
              ),
              Text(label, style: AppTextStyles.bodyMuted),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Responsive Grid ──

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
        final count =
            (width / minItemWidth).floor().clamp(1, maxCrossAxisCount);
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
