// TODO(web): Migrate to package:web + dart:js_interop when Flutter SDK minimum
// is raised to 3.16+. dart:html is deprecated but functional for Flutter 3.10.x.
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<void> exportCsvImpl(String filename, String csvContent) async {
  const bom = '\uFEFF';
  final bytes = utf8.encode(bom + csvContent);
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
