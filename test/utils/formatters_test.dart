import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/utils/formatters.dart';

void main() {
  group('formatTimeAgo', () {
    test('returns "Just now" for time within the last minute', () {
      final now = DateTime.now();
      expect(formatTimeAgo(now), 'Just now');
      expect(formatTimeAgo(now.subtract(const Duration(seconds: 30))), 'Just now');
    });

    test('returns minutes ago for time within the last hour', () {
      final time = DateTime.now().subtract(const Duration(minutes: 5));
      expect(formatTimeAgo(time), '5 min ago');
    });

    test('returns singular minute for 1 minute ago', () {
      final time = DateTime.now().subtract(const Duration(minutes: 1));
      expect(formatTimeAgo(time), '1 min ago');
    });

    test('returns hours ago for time within the last day', () {
      final time = DateTime.now().subtract(const Duration(hours: 3));
      expect(formatTimeAgo(time), '3 hours ago');
    });

    test('returns singular hour for 1 hour ago', () {
      final time = DateTime.now().subtract(const Duration(hours: 1));
      expect(formatTimeAgo(time), '1 hour ago');
    });

    test('returns days ago for time beyond a day', () {
      final time = DateTime.now().subtract(const Duration(days: 2));
      expect(formatTimeAgo(time), '2 days ago');
    });

    test('returns singular day for 1 day ago', () {
      final time = DateTime.now().subtract(const Duration(days: 1));
      expect(formatTimeAgo(time), '1 day ago');
    });
  });

  group('formatTimeAgoShort', () {
    test('returns "Just now" for recent times', () {
      expect(formatTimeAgoShort(DateTime.now()), 'Just now');
    });

    test('returns abbreviated minutes', () {
      final time = DateTime.now().subtract(const Duration(minutes: 10));
      expect(formatTimeAgoShort(time), '10m ago');
    });

    test('returns abbreviated hours', () {
      final time = DateTime.now().subtract(const Duration(hours: 5));
      expect(formatTimeAgoShort(time), '5h ago');
    });

    test('returns abbreviated days', () {
      final time = DateTime.now().subtract(const Duration(days: 3));
      expect(formatTimeAgoShort(time), '3d ago');
    });
  });

  group('isInvitationExpired', () {
    test('returns true for past dates', () {
      expect(
        isInvitationExpired(DateTime.now().subtract(const Duration(hours: 1))),
        isTrue,
      );
    });

    test('returns false for future dates', () {
      expect(
        isInvitationExpired(DateTime.now().add(const Duration(hours: 1))),
        isFalse,
      );
    });
  });
}
