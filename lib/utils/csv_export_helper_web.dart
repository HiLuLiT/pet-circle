// TODO(web): Migrate to package:web + dart:js_interop when Flutter SDK minimum
// is raised to 3.16+. dart:html is deprecated but functional for Flutter 3.10.x.
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// [shareText]/[subject] are ignored on web — a browser file download has no
/// share-sheet equivalent to attach them to. Callers that need the summary
/// text seen by the user should surface it separately (e.g. in a dialog)
/// before triggering the download.
Future<void> exportCsvImpl(
  String filename,
  String csvContent, {
  String? shareText,
  String? subject,
}) async {
  const bom = '\uFEFF';
  final bytes = utf8.encode(bom + csvContent);
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
