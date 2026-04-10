import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/utils/formatters.dart';
import 'package:pet_circle/utils/responsive_utils.dart';
import 'package:pet_circle/models/app_notification.dart' as notif;

/// Opens notifications as a slide-up drawer (modal bottom sheet),
/// matching the SettingsDrawer interaction pattern.
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
          final notifications = notificationStore.all;

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.notifications,
                                style: AppSemanticTextStyles.title3.copyWith(
                                  color: c.textPrimary,
                                  letterSpacing: -0.96,
                                ),
                              ),
                              const SizedBox(height: AppSpacingTokens.xs),
                              Text(
                                l10n.unreadNotifications(
                                  notificationStore.unreadCount,
                                ),
                                style: AppSemanticTextStyles.body.copyWith(color: c.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c.background,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.surface, width: 2),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: c.textPrimary,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacingTokens.lg),
                    ...notifications.map((notification) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacingTokens.sm + 4),
                      child: _AppNotificationCard(notification: notification),
                    )),
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
                  child: _AppNotificationCard(notification: notification),
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

class _AppNotificationCard extends StatelessWidget {
  const _AppNotificationCard({required this.notification});

  final notif.AppNotification notification;

  IconData get _icon {
    switch (notification.type) {
      case notif.NotificationType.medication:
        return Icons.medication;
      case notif.NotificationType.measurement:
        return Icons.monitor_heart;
      case notif.NotificationType.careCircle:
        return Icons.group_add;
      case notif.NotificationType.report:
        return Icons.mail_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final iconColor = switch (notification.type) {
      notif.NotificationType.medication => c.primary,
      notif.NotificationType.measurement => c.error,
      notif.NotificationType.careCircle => c.primaryLight,
      notif.NotificationType.report => c.error,
    };

    return GestureDetector(
      onTap: () {
        notificationStore.markRead(notification.id);
        switch (notification.type) {
          case notif.NotificationType.medication:
            context.go(AppRoutes.shell(tab: 3));
          case notif.NotificationType.measurement:
            context.go(AppRoutes.shell(tab: 1));
          case notif.NotificationType.careCircle:
            context.go(AppRoutes.shell(tab: 0));
          case notif.NotificationType.report:
            context.go(AppRoutes.shell(tab: 1));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        decoration: BoxDecoration(
          color: notification.isRead ? c.surface : c.background,
          borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
          border: Border.all(
            color: notification.isRead ? c.background : c.primaryLight.withAlpha(80),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 20, color: iconColor),
            ),
            SizedBox(width: AppSpacingTokens.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppSemanticTextStyles.body.copyWith(
                            color: c.textPrimary,
                            fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: c.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    notification.body,
                    style: AppSemanticTextStyles.caption.copyWith(
                      color: c.textPrimary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    formatTimeAgoShort(notification.createdAt),
                    style: AppSemanticTextStyles.caption.copyWith(
                      color: c.textPrimary,
                      fontSize: 11,
                    ),
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
