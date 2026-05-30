/// Presentation-layer formatting utilities.
///
/// These helpers contain time-dependent or display-oriented logic that was
/// previously embedded in model classes. Keeping models pure data means they
/// remain deterministic and testable.

import 'package:pet_circle/l10n/app_localizations.dart';

String formatTimeAgo(DateTime dateTime, AppLocalizations l10n) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays > 0) {
    return l10n.timeAgoDays(diff.inDays);
  } else if (diff.inHours > 0) {
    return l10n.timeAgoHours(diff.inHours);
  } else if (diff.inMinutes > 0) {
    return l10n.timeAgoMinutes(diff.inMinutes);
  }
  return l10n.justNow;
}

String formatTimeAgoShort(DateTime dateTime, AppLocalizations l10n) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays > 0) {
    return l10n.timeAgoDaysShort(diff.inDays);
  } else if (diff.inHours > 0) {
    return l10n.timeAgoHoursShort(diff.inHours);
  } else if (diff.inMinutes > 0) {
    return l10n.timeAgoMinutesShort(diff.inMinutes);
  }
  return l10n.justNow;
}

bool isInvitationExpired(DateTime expiresAt) =>
    DateTime.now().isAfter(expiresAt);
