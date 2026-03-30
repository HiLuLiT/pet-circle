import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

Future<void> exportCsvImpl(String filename, String csvContent) async {
  final bytes = Uint8List.fromList(utf8.encode(csvContent));
  await Share.shareXFiles(
    [XFile.fromData(bytes, name: filename, mimeType: 'text/csv')],
    subject: filename,
  );
}
