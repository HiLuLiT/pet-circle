// Conditional import: use web implementation on web, native on other platforms.
// ignore: uri_does_not_exist
import 'csv_export_helper_native.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'csv_export_helper_web.dart';

Future<void> exportCsv(String filename, String csvContent) =>
    exportCsvImpl(filename, csvContent);
