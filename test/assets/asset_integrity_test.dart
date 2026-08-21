import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Guards against committing an image that a browser will happily render but
/// Flutter's decoder will not.
///
/// This exists because of BUG-031: `welcome_heart.png` arrived from the design
/// project with a corrupt IDAT CRC32 and a bad trailing adler32. Chrome ignores
/// PNG checksums by design, so the animation looked fine in the web preview —
/// but Skia rejects them, and [AppImage] swallows decode failures to show its
/// fallback, so the only symptom was a silent grey box with no Dart exception.
/// Nothing failed loudly, which is exactly why it cost a full build-and-verify
/// cycle to find.
///
/// Decoding through `instantiateImageCodec` is the same path the running app
/// takes, so anything that passes here will render.
void main() {
  test('every bundled image decodes through the Flutter codec', () async {
    final dir = Directory('assets/figma');
    expect(dir.existsSync(), isTrue, reason: 'assets/figma is missing');

    final images = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) {
          final p = f.path.toLowerCase();
          return p.endsWith('.png') || p.endsWith('.jpg') ||
              p.endsWith('.jpeg') || p.endsWith('.webp');
        })
        .toList();

    expect(images, isNotEmpty, reason: 'no raster assets found to verify');

    final failures = <String>[];
    for (final file in images) {
      try {
        final bytes = await file.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        if (frame.image.width == 0 || frame.image.height == 0) {
          failures.add('${file.path}: decoded to a zero-sized image');
        }
        frame.image.dispose();
        codec.dispose();
      } on Object catch (e) {
        // The BUG-031 signature is a zlib "incorrect data check" here.
        failures.add('${file.path}: $e');
      }
    }

    expect(
      failures,
      isEmpty,
      reason:
          'These assets are corrupt and will render as a silent fallback:\n'
          '${failures.join('\n')}',
    );
  });
}
