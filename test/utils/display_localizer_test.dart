import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations_en.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/utils/display_localizer.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('localizeRole', () {
    test('maps owner to the owner label', () {
      expect(localizeRole(CareCircleRole.owner, l10n), l10n.owner);
    });

    test('maps member to the member role label', () {
      expect(localizeRole(CareCircleRole.member, l10n), l10n.roleMember);
    });
  });

  group('localizeRoleName', () {
    test('maps Admin/Member/Viewer to localized labels', () {
      expect(localizeRoleName('Admin', l10n), l10n.roleAdmin);
      expect(localizeRoleName('Member', l10n), l10n.roleMember);
      expect(localizeRoleName('Viewer', l10n), l10n.roleViewer);
    });

    test('returns unknown values unchanged', () {
      expect(localizeRoleName('Something', l10n), 'Something');
    });
  });

  group('localizeStatus', () {
    test('maps known statuses to localized labels', () {
      expect(localizeStatus('Normal', l10n), l10n.statusNormal);
      expect(localizeStatus('Elevated', l10n), l10n.statusElevated);
      expect(localizeStatus('Critical', l10n), l10n.statusCritical);
    });

    test('returns unknown status unchanged', () {
      expect(localizeStatus('Unknown', l10n), 'Unknown');
    });
  });

  group('localizeFrequency', () {
    test('maps known frequencies to localized labels', () {
      expect(localizeFrequency('Once daily', l10n), l10n.onceDaily);
      expect(localizeFrequency('Twice daily', l10n), l10n.twiceDaily);
      expect(localizeFrequency('As needed', l10n), l10n.asNeeded);
    });

    test('returns unknown frequency unchanged', () {
      expect(localizeFrequency('Hourly', l10n), 'Hourly');
    });
  });
}
