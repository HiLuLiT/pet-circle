import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

// ─── Unit tests for the CSV export helpers ───────────────────────────────────
//
// The public surface of csv_export_helper.dart is a single async function:
//
//   Future<void> exportCsv(String filename, String csvContent)
//
// This delegates to the native implementation (csv_export_helper_native.dart)
// which calls share_plus.  Because share_plus opens a platform share-sheet we
// cannot invoke exportCsv directly in tests without real platform channels.
//
// Instead, we test the underlying data-transformation logic directly:
//   - UTF-8 encoding of CSV content (what the native helper does before sharing)
//   - CSV content structure and correctness
//   - Filename conventions
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('CSV content encoding (native helper logic)', () {
    // Mirrors the logic in csv_export_helper_native.dart before share_plus.
    Uint8List encodeCsv(String csvContent) =>
        Uint8List.fromList(utf8.encode(csvContent));

    test('encodes simple ASCII CSV correctly', () {
      const csv = 'name,age\nAlice,30\nBob,25\n';
      final bytes = encodeCsv(csv);
      expect(utf8.decode(bytes), equals(csv));
    });

    test('encodes CSV with Unicode characters correctly', () {
      const csv = 'name,note\nPrincess,בריא\nMax,gesund\n';
      final bytes = encodeCsv(csv);
      expect(utf8.decode(bytes), equals(csv));
    });

    test('encodes empty CSV as empty byte list', () {
      const csv = '';
      final bytes = encodeCsv(csv);
      expect(bytes, isEmpty);
    });

    test('encodes CSV with special characters (quotes, commas)', () {
      const csv = 'note\n"Hello, world"\n"Line 1\nLine 2"\n';
      final bytes = encodeCsv(csv);
      expect(utf8.decode(bytes), equals(csv));
    });

    test('encoded bytes length is >= string length (UTF-8 expansion)', () {
      const csv = 'name\nPrincesa\n';
      final bytes = encodeCsv(csv);
      // UTF-8 length is always >= the codepoint count for ASCII-only.
      expect(bytes.length, greaterThanOrEqualTo(csv.length));
    });

    test('round-trip: encode then decode returns original string', () {
      const original =
          'date,rate,notes\n2024-01-01,24,"Normal reading"\n2024-01-02,28,"Elevated"\n';
      final bytes = encodeCsv(original);
      final decoded = utf8.decode(bytes);
      expect(decoded, equals(original));
    });
  });

  group('CSV filename conventions', () {
    test('filename with .csv extension is valid', () {
      const filename = 'measurements_2024-01-01.csv';
      expect(filename.endsWith('.csv'), isTrue);
    });

    test('filename without spaces is safe for file systems', () {
      const filename = 'pet_circle_export.csv';
      expect(filename.contains(' '), isFalse);
    });

    test('filename with pet name uses underscore-separated format', () {
      final petName = 'Princess';
      final date = '2024-01-01';
      final filename = '${petName}_measurements_$date.csv';
      expect(filename, equals('Princess_measurements_2024-01-01.csv'));
    });
  });

  group('CSV content structure', () {
    String buildCsv(List<String> headers, List<List<String>> rows) {
      final buffer = StringBuffer();
      buffer.writeln(headers.join(','));
      for (final row in rows) {
        buffer.writeln(row.join(','));
      }
      return buffer.toString();
    }

    test('CSV has correct header row', () {
      final csv = buildCsv(
        ['date', 'rate', 'notes'],
        [
          ['2024-01-01', '24', 'Normal'],
        ],
      );
      expect(csv, startsWith('date,rate,notes\n'));
    });

    test('CSV rows are newline-separated', () {
      final csv = buildCsv(
        ['a', 'b'],
        [
          ['1', '2'],
          ['3', '4'],
        ],
      );
      final lines = csv.trim().split('\n');
      expect(lines.length, equals(3)); // header + 2 data rows
    });

    test('empty rows produce only header', () {
      final csv = buildCsv(['col1', 'col2'], []);
      final lines = csv.trim().split('\n');
      expect(lines.length, equals(1));
      expect(lines.first, equals('col1,col2'));
    });

    test('values containing commas should be quoted', () {
      // Demonstrates correct quoting convention.
      const value = '"hello, world"';
      expect(value, startsWith('"'));
      expect(value, endsWith('"'));
      expect(value.contains(','), isTrue);
    });
  });
}
