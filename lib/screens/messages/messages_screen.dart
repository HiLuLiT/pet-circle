import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/utils/formatters.dart';
import 'package:pet_circle/utils/notification_localizer.dart';
import 'package:pet_circle/utils/responsive_utils.dart';
import 'package:pet_circle/widgets/notification_card.dart';
import 'package:pet_circle/widgets/primary_button.dart';
import 'package:pet_circle/widgets/round_icon_button.dart';
import 'package:pet_circle/models/app_notification.dart' as notif;

/// Opens notifications as a slide-up drawer (modal bottom sheet),
/// matching the SettingsDrawer interaction pattern.
///
/// Matches Figma DS node 418:2567: a bold display-size title with a
/// chevron-collapse button, an unread count + "Mark all read" pill, and
/// notifications grouped into "New" (unread) and "Earlier" (read) sections.
class NotificationsDrawer extends StatelessWidget {
  const NotificationsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notificationStore,
      builder: (context, _) => DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 0.4,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          final c = AppSemanticColors.of(context);
          final l10n = AppLocalizations.of(context)!;
          final now = DateTime.now();
          final notifications = notificationStore.all.where((n) {
            return n.createdAt.year == now.year &&
                n.createdAt.month == now.month &&
                n.createdAt.day == now.day;
          }).toList();
          final unreadNotifications =
              notifications.where((n) => !n.isRead).toList();
          final readNotifications =
              notifications.where((n) => n.isRead).toList();

          return ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadiiTokens.lg)),
            child: Container(
              color: c.surface,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.lg,
                  vertical: AppSpacingTokens.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.notifications,
                            style: AppSemanticTextStyles.pcDisplay.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                        RoundIconButton(
                          icon: const Icon(Icons.keyboard_arrow_up),
                          variant: RoundIconButtonVariant.ghost,
                          size: 36,
                          iconSize: 24,
                          onTap: () => Navigator.of(context).pop(),
                          semanticLabel: l10n.close,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacingTokens.sm + 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.unreadNotifications(
                            unreadNotifications.length,
                          ),
                          style: AppSemanticTextStyles.pcLabelMuted,
                        ),
                        if (unreadNotifications.isNotEmpty)
                          PrimaryButton(
                            label: l10n.markAllRead,
                            variant: PrimaryButtonVariant.miniPrimary,
                            onPressed: () => notificationStore.markAllRead(),
                          ),
                      ],
                    ),
                    if (notifications.isEmpty) ...[
                      const SizedBox(height: AppSpacingTokens.xl),
                      Center(
                        child: Text(
                          l10n.noNotifications,
                          style: AppSemanticTextStyles.pcLabelMuted,
                        ),
                      ),
                    ],
                    if (unreadNotifications.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacingTokens.pcXl,
                          bottom: AppSpacingTokens.sm,
                        ),
                        child: Text(
                          l10n.notificationsSectionNew,
                          style: AppSemanticTextStyles.captionBold.copyWith(
                            color: c.textTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...unreadNotifications.map((notification) => Padding(
                            padding: EdgeInsets.only(
                              bottom: AppSpacingTokens.sm + 4,
                            ),
                            child: _NotificationRow(notification: notification),
                          )),
                    ],
                    if (readNotifications.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacingTokens.pcXl,
                          bottom: AppSpacingTokens.sm,
                        ),
                        child: Text(
                          l10n.notificationsSectionEarlier,
                          style: AppSemanticTextStyles.captionBold.copyWith(
                            color: c.textTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...readNotifications.map((notification) => Padding(
                            padding: EdgeInsets.only(
                              bottom: AppSpacingTokens.sm + 4,
                            ),
                            child: _NotificationRow(notification: notification),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notificationStore,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final c = AppSemanticColors.of(context);
        final notifications = notificationStore.all;

        final content = SafeArea(
          child: RefreshIndicator(
            onRefresh: () => notificationStore.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacingTokens.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsiveMaxWidth(context)),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacingTokens.md),
                Text(
                  l10n.notifications,
                  style: AppSemanticTextStyles.title3.copyWith(
                    color: c.textPrimary,
                    letterSpacing: -0.96,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                Text(
                  l10n.unreadNotifications(notificationStore.unreadCount),
                  style: AppSemanticTextStyles.body.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.lg),
                ...notifications.map((notification) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacingTokens.sm + 4),
                  child: _NotificationRow(notification: notification),
                )),
              ],
            ),
              ),
            ),
          ),
          ),
        );

        if (!showScaffold) {
          return Container(color: c.surface, child: content);
        }

        return Scaffold(
          backgroundColor: c.surface,
          body: content,
        );
      },
    );
  }
}

// ─── Notification Card ───────────────────────────────────────────

/// Per-type visual + routing descriptor for a notification, derived from
/// [notif.NotificationType]. Keeps the icon, icon color, tile background
/// color, and destination tab in one place so [_NotificationRow] can feed
/// the shared [NotificationCard].
class _NotificationTypeStyle {
  const _NotificationTypeStyle({
    required this.icon,
    required this.iconColor,
    required this.iconTileColor,
    required this.tab,
  });

  final IconData icon;
  final Color iconColor;

  /// Accessible tile background from the DS semantic palette — uses the
  /// `*Tile` wash tokens so icon-on-tile contrast meets WCAG AA.
  final Color iconTileColor;
  final int tab;
}

/// Resolves the per-type icon, colors, and destination tab for [type].
///
/// Icon colors use the base accent; tile backgrounds use the matching
/// `*Tile` wash from [AppSemanticColors] for accessible contrast.
_NotificationTypeStyle _styleForType(
  notif.NotificationType type,
  AppSemanticColors c,
) {
  switch (type) {
    case notif.NotificationType.medication:
      return _NotificationTypeStyle(
        icon: Icons.medication,
        iconColor: c.primary,
        iconTileColor: c.accentPurpleTile,
        tab: AppRoutes.tabMedication,
      );
    case notif.NotificationType.measurement:
      return _NotificationTypeStyle(
        icon: Icons.monitor_heart,
        iconColor: c.error,
        iconTileColor: c.accentBlushTile,
        tab: AppRoutes.tabTrends,
      );
    case notif.NotificationType.careCircle:
      return _NotificationTypeStyle(
        icon: Icons.group_add,
        iconColor: c.accentPeriwinkle,
        iconTileColor: c.accentPeriwinkleTile,
        tab: AppRoutes.tabHome,
      );
    case notif.NotificationType.report:
      return _NotificationTypeStyle(
        icon: Icons.mail_outline,
        iconColor: c.error,
        iconTileColor: c.accentBlushTile,
        tab: AppRoutes.tabTrends,
      );
  }
}

/// Adapts an [notif.AppNotification] onto the shared [NotificationCard]
/// design-system widget: derives the per-type icon/tile color, localizes the
/// title/body, formats the timestamp, and wires tap-to-route (marking the
/// notification read and navigating to the type's destination tab).
class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});

  final notif.AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final localized = localizeNotification(notification, l10n);
    final style = _styleForType(notification.type, c);

    return NotificationCard(
      icon: Icon(style.icon, size: 20, color: style.iconColor),
      iconTileColor: style.iconTileColor,
      title: localized.title,
      body: localized.body,
      time: formatTimeAgoShort(notification.createdAt, l10n),
      unread: !notification.isRead,
      onTap: () {
        notificationStore.markRead(notification.id);
        context.go(AppRoutes.shell(tab: style.tab));
      },
    );
  }
}
