import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/app_notification.dart';

/// Title and body of a notification, resolved into the current locale.
class LocalizedNotification {
  const LocalizedNotification(this.title, this.body);

  final String title;
  final String body;
}

/// Resolves a notification's title and body into the active locale.
///
/// Notifications carry optional localization keys ([AppNotification.titleKey] /
/// [AppNotification.bodyKey]) plus positional [AppNotification.args]. When a key
/// is present and recognised, the matching localized string is produced at
/// render time so it follows the current language. Otherwise the frozen
/// [AppNotification.title] / [AppNotification.body] stored at creation time is
/// used as a fallback (server-pushed and legacy notifications have no keys).
LocalizedNotification localizeNotification(
  AppNotification n,
  AppLocalizations l10n,
) {
  final title = _resolveTitle(n.titleKey, l10n) ?? n.title;
  final body = _resolveBody(n.bodyKey, n.args, l10n) ?? n.body;
  return LocalizedNotification(title, body);
}

String? _resolveTitle(String? key, AppLocalizations l10n) {
  switch (key) {
    case 'medicationAdded':
      return l10n.medicationAdded;
    case 'medicationUpdated':
      return l10n.medicationUpdated;
    case 'medicationEndingTitle':
      return l10n.medicationEndingTitle;
    case 'measurementComplete':
      return l10n.measurementComplete;
    case 'careCircleUpdated':
      return l10n.careCircleUpdated;
    default:
      return null;
  }
}

String? _resolveBody(String? key, List<String> args, AppLocalizations l10n) {
  switch (key) {
    case 'medicationEndingBody':
      return args.isNotEmpty ? l10n.medicationEndingBody(args[0]) : null;
    case 'measurementSavedBpm':
      final bpm = args.isNotEmpty ? int.tryParse(args[0]) : null;
      return bpm != null ? l10n.measurementSavedBpm(bpm) : null;
    case 'invitationSentTo':
      return args.length >= 2
          ? l10n.invitationSentTo(args[0], args[1])
          : null;
    case 'vetInviteSent':
      return args.isNotEmpty ? l10n.vetInviteSent(args[0]) : null;
    default:
      return null;
  }
}
