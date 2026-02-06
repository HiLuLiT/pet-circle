import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/data/mock_data.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = MockData.currentOwnerUser;
    final notifications = _buildNotifications(l10n);

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
                color: AppColors.chocolate,
                letterSpacing: -0.96,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.unreadNotifications(notifications.where((n) => !n.isRead).length),
              style: AppTextStyles.body.copyWith(
                color: AppColors.chocolate,
              ),
            ),
            const SizedBox(height: 24),
            ...notifications.map((notification) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _NotificationCard(notification: notification),
            )),
          ],
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

// ─── Notification Model ──────────────────────────────────────────

enum NotificationType {
  medicationReminder,
  measurementAlert,
  careCircleInvitation,
  generalMessage,
}

class _Notification {
  const _Notification({
    required this.type,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isRead = false,
  });

  final NotificationType type;
  final String title;
  final String description;
  final String timeAgo;
  final bool isRead;
}

// ─── Mock Data ───────────────────────────────────────────────────

List<_Notification> _buildNotifications(AppLocalizations l10n) => [
  _Notification(
    type: NotificationType.measurementAlert,
    title: l10n.elevatedRespiratoryRate,
    description: 'Princess\'s latest measurement of 35 BPM exceeds the normal threshold of 30 BPM. Consider scheduling a vet check-up.',
    timeAgo: '10 min ago',
    isRead: false,
  ),
  _Notification(
    type: NotificationType.medicationReminder,
    title: l10n.medicationDue('Pimobendan'),
    description: 'Princess\'s 5mg dose of Pimobendan is due. Tap to log administration.',
    timeAgo: '1 hour ago',
    isRead: false,
  ),
  _Notification(
    type: NotificationType.careCircleInvitation,
    title: l10n.careCircleInvitationAccepted,
    description: 'Sarah accepted your invitation to join Princess\'s care circle as a Caregiver.',
    timeAgo: '3 hours ago',
    isRead: true,
  ),
  _Notification(
    type: NotificationType.generalMessage,
    title: l10n.weeklyHealthReportReady,
    description: 'Princess\'s weekly respiratory rate report is ready for review. Average SRR: 24 BPM.',
    timeAgo: 'Yesterday',
    isRead: true,
  ),
  _Notification(
    type: NotificationType.medicationReminder,
    title: l10n.medicationDue('Furosemide'),
    description: 'Princess\'s 20mg dose of Furosemide is due this morning.',
    timeAgo: 'Yesterday',
    isRead: true,
  ),
  _Notification(
    type: NotificationType.measurementAlert,
    title: l10n.measurementReminder,
    description: 'It\'s been 24 hours since the last respiratory rate measurement for Princess.',
    timeAgo: '2 days ago',
    isRead: true,
  ),
  _Notification(
    type: NotificationType.careCircleInvitation,
    title: l10n.careCircleInvitationPending,
    description: 'Your invitation to petsitter@example.com is still pending. Tap to resend.',
    timeAgo: '3 days ago',
    isRead: true,
  ),
  _Notification(
    type: NotificationType.generalMessage,
    title: l10n.autoExportComplete,
    description: 'Weekly CSV report has been sent to hila@example.com successfully.',
    timeAgo: '1 week ago',
    isRead: true,
  ),
];

// ─── Notification Card ───────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final _Notification notification;

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.medicationReminder:
        return Icons.medication;
      case NotificationType.measurementAlert:
        return Icons.monitor_heart;
      case NotificationType.careCircleInvitation:
        return Icons.group_add;
      case NotificationType.generalMessage:
        return Icons.mail_outline;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.medicationReminder:
        return AppColors.blue;
      case NotificationType.measurementAlert:
        return AppColors.cherry;
      case NotificationType.careCircleInvitation:
        return AppColors.lightBlue;
      case NotificationType.generalMessage:
        return AppColors.cherry;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? AppColors.white : AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? AppColors.offWhite
              : AppColors.pink.withAlpha(80),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 20, color: _iconColor),
          ),
          const SizedBox(width: 12),
          // Content
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
                          color: AppColors.chocolate,
                          fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.chocolate,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.timeAgo,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.chocolate,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
