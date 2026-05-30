import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/care_circle_member.dart';

/// Render-time localization for values that are stored in English in the data
/// model (so logic/comparison stays stable) but should be displayed in the
/// user's language. These helpers never change stored values — they only map
/// a known English value to its localized form.

/// Localizes a care-circle [role] for display.
String localizeRole(CareCircleRole role, AppLocalizations l10n) {
  switch (role) {
    case CareCircleRole.owner:
      return l10n.owner;
    case CareCircleRole.member:
      return l10n.roleMember;
  }
}

/// Localizes a role name string (`Admin` / `Member` / `Viewer`) used by the
/// invite dropdown. Unknown values are returned unchanged.
String localizeRoleName(String role, AppLocalizations l10n) {
  switch (role) {
    case 'Admin':
      return l10n.roleAdmin;
    case 'Member':
      return l10n.roleMember;
    case 'Viewer':
      return l10n.roleViewer;
    default:
      return role;
  }
}

/// Localizes a pet status label (`Normal` / `Elevated` / `Critical`).
/// Unknown values are returned unchanged.
String localizeStatus(String status, AppLocalizations l10n) {
  switch (status) {
    case 'Normal':
      return l10n.statusNormal;
    case 'Elevated':
      return l10n.statusElevated;
    case 'Critical':
      return l10n.statusCritical;
    default:
      return status;
  }
}

/// Localizes a medication frequency (`Once daily` / `Twice daily` /
/// `As needed`). Unknown values are returned unchanged.
String localizeFrequency(String frequency, AppLocalizations l10n) {
  switch (frequency) {
    case 'Once daily':
      return l10n.onceDaily;
    case 'Twice daily':
      return l10n.twiceDaily;
    case 'As needed':
      return l10n.asNeeded;
    default:
      return frequency;
  }
}
