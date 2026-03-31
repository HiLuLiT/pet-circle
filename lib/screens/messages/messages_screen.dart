import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/user_store.dart';
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
          final c = AppColorsTheme.of(context);
          final l10n = AppLocalizations.of(context)!;
          final notifications = notificationStore.all;

          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: AppRadii.medium),
            child: Container(
              color: c.white,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                                style: AppTextStyles.heading2.copyWith(
                                  color: c.chocolate,
                                  letterSpacing: -0.96,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.unreadNotifications(
                                  notificationStore.unreadCount,
                                ),
                                style: AppTextStyles.body.copyWith(color: c.chocolate),
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
                              color: c.offWhite,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.white, width: 2),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: c.chocolate,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...notifications.map((notification) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
        final c = AppColorsTheme.of(context);
        final notifications = notificationStore.all;

        final content = SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  l10n.notifications,
                  style: AppTextStyles.heading2.copyWith(
                    color: c.chocolate,
                    letterSpacing: -0.96,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.unreadNotifications(notificationStore.unreadCount),
                  style: AppTextStyles.body.copyWith(
                    color: c.chocolate,
                  ),
                ),
                const SizedBox(height: 24),
                ...notifications.map((notification) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AppNotificationCard(notification: notification),
                )),
              ],
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
    final c = AppColorsTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final iconColor = switch (notification.type) {
      notif.NotificationType.medication => c.blue,
      notif.NotificationType.measurement => c.cherry,
      notif.NotificationType.careCircle => c.lightBlue,
      notif.NotificationType.report => c.cherry,
    };

    return GestureDetector(
      onTap: () {
        notificationStore.markRead(notification.id);
        switch (notification.type) {
          case notif.NotificationType.medication:
            context.go(AppRoutes.shell(userStore.role, tab: 3));
          case notif.NotificationType.measurement:
            context.go(AppRoutes.shell(userStore.role, tab: 1));
          case notif.NotificationType.careCircle:
            context.go(AppRoutes.shell(userStore.role, tab: 0));
          case notif.NotificationType.report:
            context.go(AppRoutes.shell(userStore.role, tab: 1));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? c.white : c.offWhite,
          borderRadius: const BorderRadius.all(AppRadii.small),
          border: Border.all(
            color: notification.isRead ? c.offWhite : c.pink.withAlpha(80),
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
            const SizedBox(width: 12),
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
                          style: AppTextStyles.body.copyWith(
                            color: c.chocolate,
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
                            color: c.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppTextStyles.caption.copyWith(
                      color: c.chocolate,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.timeAgo,
                    style: AppTextStyles.caption.copyWith(
                      color: c.chocolate,
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
