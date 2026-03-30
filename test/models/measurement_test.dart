import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/measurement.dart';

void main() {
  group('Measurement copyWith', () {
    test('copyWith creates a new instance', () {
      final original = Measurement(
        id: 'm-1',
        bpm: 22,
        recordedAt: DateTime(2025, 1, 1),
        recordedAtLabel: '1 day ago',
        recordedBy: 'Hila',
      );

      final copy = original.copyWith(bpm: 30);

      expect(identical(original, copy), isFalse);
      expect(copy.bpm, 30);
    });

    test('original is unchanged after copyWith', () {
      final original = Measurement(
        id: 'm-1',
        bpm: 22,
        recordedAt: DateTime(2025, 1, 1),
        recordedAtLabel: '1 day ago',
      );

      original.copyWith(bpm: 99, recordedAtLabel: 'new label');

      expect(original.bpm, 22);
      expect(original.recordedAtLabel, '1 day ago');
    });

    test('copyWith preserves all fields when no args given', () {
      final original = Measurement(
        id: 'm-1',
        bpm: 22,
        recordedAt: DateTime(2025, 3, 15, 10, 30),
        recordedAtLabel: 'label',
        recordedBy: 'user-1',
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.bpm, original.bpm);
      expect(copy.recordedAt, original.recordedAt);
      expect(copy.recordedAtLabel, original.recordedAtLabel);
      expect(copy.recordedBy, original.recordedBy);
    });

    test('copyWith can update each field independently', () {
      final original = Measurement(
        bpm: 22,
        recordedAt: DateTime(2025, 1, 1),
      );

      expect(original.copyWith(id: 'new-id').id, 'new-id');
      expect(original.copyWith(bpm: 50).bpm, 50);
      expect(
        original.copyWith(recordedAt: DateTime(2026, 1, 1)).recordedAt,
        DateTime(2026, 1, 1),
      );
      expect(
        original.copyWith(recordedAtLabel: 'now').recordedAtLabel,
        'now',
      );
      expect(original.copyWith(recordedBy: 'doc').recordedBy, 'doc');
    });
  });

  group('Measurement timeAgo', () {
    test('timeAgo returns recordedAtLabel when present', () {
      final m = Measurement(
        bpm: 22,
        recordedAt: DateTime(2020, 1, 1),
        recordedAtLabel: 'custom label',
      );

      expect(m.timeAgo, 'custom label');
    });

    test('timeAgo computes relative time when no label', () {
      final recent = Measurement(
        bpm: 22,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(recent.timeAgo, contains('min ago'));
    });

    test('timeAgo returns Just now for very recent', () {
      final justNow = Measurement(
        bpm: 22,
        recordedAt: DateTime.now(),
      );

      expect(justNow.timeAgo, 'Just now');
    });
  });
}
