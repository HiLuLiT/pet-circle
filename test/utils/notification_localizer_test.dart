import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/l10n/app_localizations_en.dart';
import 'package:pet_circle/l10n/app_localizations_he.dart';
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/utils/notification_localizer.dart';

AppNotification _notif({
  String title = 'stored title',
  String body = 'stored body',
  String? titleKey,
  String? bodyKey,
  List<String> args = const [],
}) {
  return AppNotification(
    id: 'n',
    title: title,
    body: body,
    titleKey: titleKey,
    bodyKey: bodyKey,
    args: args,
    type: NotificationType.medication,
    createdAt: DateTime(2025, 1, 1),
  );
}

void main() {
  final en = AppLocalizationsEn();
  final he = AppLocalizationsHe();

  group('localizeNotification — title resolution', () {
    test('resolves a known title key (en)', () {
      final n = _notif(titleKey: 'medicationAdded');
      expect(localizeNotification(n, en).title, en.medicationAdded);
    });

    test('resolves a known title key (he)', () {
      final n = _notif(titleKey: 'medicationAdded');
      expect(localizeNotification(n, he).title, he.medicationAdded);
    });

    test('resolves all supported title keys', () {
      final cases = {
        'medicationAdded': en.medicationAdded,
        'medicationUpdated': en.medicationUpdated,
        'medicationEndingTitle': en.medicationEndingTitle,
        'measurementComplete': en.measurementComplete,
        'careCircleUpdated': en.careCircleUpdated,
      };
      for (final entry in cases.entries) {
        final n = _notif(titleKey: entry.key);
        expect(localizeNotification(n, en).title, entry.value,
            reason: entry.key);
      }
    });

    test('falls back to stored title when titleKey is null', () {
      final n = _notif(title: 'frozen title');
      expect(localizeNotification(n, en).title, 'frozen title');
    });

    test('falls back to stored title when key is unknown', () {
      final n = _notif(title: 'frozen title', titleKey: 'bogusKey');
      expect(localizeNotification(n, en).title, 'frozen title');
    });
  });

  group('localizeNotification — body resolution', () {
    test('resolves templated body with string arg (medicationEndingBody)', () {
      final n = _notif(bodyKey: 'medicationEndingBody', args: const ['Rex']);
      expect(localizeNotification(n, en).body, en.medicationEndingBody('Rex'));
    });

    test('resolves measurementSavedBpm with int arg', () {
      final n = _notif(bodyKey: 'measurementSavedBpm', args: const ['12']);
      expect(localizeNotification(n, en).body, en.measurementSavedBpm(12));
    });

    test('resolves invitationSentTo with two args', () {
      final n = _notif(
          bodyKey: 'invitationSentTo', args: const ['a@b.com', 'Member']);
      expect(localizeNotification(n, en).body,
          en.invitationSentTo('a@b.com', 'Member'));
    });

    test('resolves vetInviteSent with one arg', () {
      final n = _notif(bodyKey: 'vetInviteSent', args: const ['a@b.com']);
      expect(localizeNotification(n, en).body, en.vetInviteSent('a@b.com'));
    });

    test('localizes body in Hebrew', () {
      final n = _notif(bodyKey: 'medicationEndingBody', args: const ['Rex']);
      expect(localizeNotification(n, he).body, he.medicationEndingBody('Rex'));
    });

    test('falls back to stored body when bodyKey is null', () {
      final n = _notif(body: 'frozen body');
      expect(localizeNotification(n, en).body, 'frozen body');
    });

    test('falls back to stored body when args are insufficient', () {
      final n = _notif(body: 'frozen body', bodyKey: 'measurementSavedBpm');
      expect(localizeNotification(n, en).body, 'frozen body');
    });

    test('falls back to stored body when bpm arg is not numeric', () {
      final n = _notif(
          body: 'frozen body', bodyKey: 'measurementSavedBpm', args: const ['x']);
      expect(localizeNotification(n, en).body, 'frozen body');
    });
  });
}
