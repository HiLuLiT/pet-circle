// Conditional import: use web implementation on web, native on other platforms.
// ignore: uri_does_not_exist
import 'csv_export_helper_native.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'csv_export_helper_web.dart';

/// [shareText]/[subject] are passed through to the native share sheet
/// alongside the CSV file. On web there is no share sheet (a browser
/// download is triggered instead), so both are ignored there.
Future<void> exportCsv(
  String filename,
  String csvContent, {
  String? shareText,
  String? subject,
}) =>
    exportCsvImpl(filename, csvContent, shareText: shareText, subject: subject);
