/// Presentation-layer formatting utilities.
///
/// These helpers contain time-dependent or display-oriented logic that was
/// previously embedded in model classes. Keeping models pure data means they
/// remain deterministic and testable.

String formatTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays > 0) {
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  } else if (diff.inHours > 0) {
    return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
  } else if (diff.inMinutes > 0) {
    return '${diff.inMinutes} min ago';
  }
  return 'Just now';
}

String formatTimeAgoShort(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays > 0) {
    return '${diff.inDays}d ago';
  } else if (diff.inHours > 0) {
    return '${diff.inHours}h ago';
  } else if (diff.inMinutes > 0) {
    return '${diff.inMinutes}m ago';
  }
  return 'Just now';
}

bool isInvitationExpired(DateTime expiresAt) =>
    DateTime.now().isAfter(expiresAt);
