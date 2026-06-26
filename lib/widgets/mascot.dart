import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Available dog-breed mascot bodies.
///
/// Each breed maps to a distinct inner-SVG silhouette in [_kMascotBodies].
enum MascotBreed { floppy, perky, fluffy, snout, whiskers }

/// Inner SVG content for each [MascotBreed].
///
/// The contents reference `currentColor` for the body fills so that the
/// [Mascot.color] parameter can recolor the silhouette at build time.
/// Ink features (eyes, mouth) are intentionally fixed at `#161616`.
const Map<MascotBreed, String> _kMascotBodies = <MascotBreed, String>{
  MascotBreed.floppy:
      '<path d="M30 32 C11 34 10 62 21 76 C30 71 33 50 35 41 Z" fill="currentColor"/>'
      '<path d="M70 32 C89 34 90 62 79 76 C70 71 67 50 65 41 Z" fill="currentColor"/>'
      '<circle cx="50" cy="51" r="27" fill="currentColor"/>'
      '<path d="M39 47 q4.6 -4.4 9 -.2" stroke="#161616" stroke-width="3" fill="none" stroke-linecap="round"/>'
      '<path d="M52 47 q4.6 -4.4 9 -.2" stroke="#161616" stroke-width="3" fill="none" stroke-linecap="round"/>'
      '<ellipse cx="50" cy="57" rx="4.2" ry="3.2" fill="#161616"/>'
      '<path d="M43 61 C46.5 66 53.5 65.5 58 61" stroke="#161616" stroke-width="2.4" fill="none" stroke-linecap="round"/>',
  MascotBreed.perky:
      '<path d="M30 36 C25 20 31 10 41 16 C45 22 44 31 42 37 Z" fill="currentColor"/>'
      '<path d="M70 36 C75 20 69 10 59 16 C55 22 56 31 58 37 Z" fill="currentColor"/>'
      '<circle cx="50" cy="53" r="26" fill="currentColor"/>'
      '<path d="M39 50 q4.6 -4.4 9 -.2" stroke="#161616" stroke-width="3" fill="none" stroke-linecap="round"/>'
      '<path d="M52 50 q4.6 -4.4 9 -.2" stroke="#161616" stroke-width="3" fill="none" stroke-linecap="round"/>'
      '<ellipse cx="50" cy="60" rx="4" ry="3" fill="#161616"/>'
      '<path d="M44 63 C47 67.5 53 67 56.5 63" stroke="#161616" stroke-width="2.4" fill="none" stroke-linecap="round"/>',
  MascotBreed.fluffy:
      '<circle cx="36" cy="27" r="13" fill="currentColor"/>'
      '<circle cx="54" cy="20" r="14" fill="currentColor"/>'
      '<circle cx="70" cy="30" r="12" fill="currentColor"/>'
      '<circle cx="24" cy="52" r="14" fill="currentColor"/>'
      '<circle cx="76" cy="52" r="14" fill="currentColor"/>'
      '<circle cx="50" cy="53" r="25" fill="currentColor"/>'
      '<path d="M39 50 q4.6 -4.4 9 -.2" stroke="#161616" stroke-width="3" fill="none" stroke-linecap="round"/>'
      '<path d="M52 50 q4.6 -4.4 9 -.2" stroke="#161616" stroke-width="3" fill="none" stroke-linecap="round"/>'
      '<ellipse cx="50" cy="60" rx="4.2" ry="3.2" fill="#161616"/>'
      '<path d="M44 63 C47 67.5 53 67 56.5 63" stroke="#161616" stroke-width="2.4" fill="none" stroke-linecap="round"/>',
  MascotBreed.snout:
      '<ellipse cx="33" cy="42" rx="11" ry="20" fill="currentColor"/>'
      '<circle cx="52" cy="50" r="24" fill="currentColor"/>'
      '<path d="M55 41 C72 38 89 45 90 54 C89 63 72 65 55 61 Z" fill="currentColor"/>'
      '<ellipse cx="88" cy="54" rx="4.2" ry="3.4" fill="#161616"/>'
      '<path d="M48 47 q4.6 -4.4 9 -.2" stroke="#161616" stroke-width="3" fill="none" stroke-linecap="round"/>',
  MascotBreed.whiskers:
      '<path d="M31 30 C27 17 39 13 45 22 C44 29 39 33 34 34 Z" fill="currentColor"/>'
      '<path d="M69 30 C73 17 61 13 55 22 C56 29 61 33 66 34 Z" fill="currentColor"/>'
      '<circle cx="50" cy="47" r="25" fill="currentColor"/>'
      '<path d="M33 58 C33 80 67 80 67 58 C62 71 38 71 33 58 Z" fill="currentColor"/>'
      '<path d="M37 41 q5 -3.5 9.5 -.5" stroke="#161616" stroke-width="3" fill="none" stroke-linecap="round"/>'
      '<path d="M53 40.5 q5 -3 9.5 .5" stroke="#161616" stroke-width="3" fill="none" stroke-linecap="round"/>'
      '<circle cx="42.5" cy="48" r="2.3" fill="#161616"/>'
      '<circle cx="57.5" cy="48" r="2.3" fill="#161616"/>'
      '<ellipse cx="50" cy="56" rx="4.2" ry="3.2" fill="#161616"/>'
      '<path d="M44 59 C47 63.5 53 63 56.5 59" stroke="#161616" stroke-width="2.4" fill="none" stroke-linecap="round"/>',
};

/// Convert a [Color] into the `#RRGGBB` hex string consumed by the inline SVG.
///
/// Alpha is dropped because the SVG fills are opaque — opacity should be
/// applied externally (e.g. wrap the [Mascot] in `Opacity`) if needed.
@visibleForTesting
String mascotColorToHex(Color color) {
  final int argb = color.toARGB32();
  final int rgb = argb & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// Build the full SVG document string for a given [breed] tinted with [color]
/// and rendered at [size] logical pixels.
@visibleForTesting
String buildMascotSvg({
  required MascotBreed breed,
  required Color color,
  required double size,
}) {
  final String hex = mascotColorToHex(color);
  final String body = _kMascotBodies[breed]!.replaceAll('currentColor', hex);
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" '
      'width="$size" height="$size">$body</svg>';
}

/// A simple dog-breed mascot rendered from an inline SVG silhouette.
///
/// The body is recolorable via [color]; ink features (eyes, mouth, nose) stay
/// fixed at `#161616` to preserve legibility across palette choices.
class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    required this.breed,
    required this.color,
    this.size = 56,
  });

  /// Which mascot silhouette to render.
  final MascotBreed breed;

  /// The color used to fill the mascot body.
  final Color color;

  /// Width and height (in logical pixels) the mascot will be rendered at.
  final double size;

  @override
  Widget build(BuildContext context) {
    final String svg = buildMascotSvg(
      breed: breed,
      color: color,
      size: size,
    );
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
    );
  }
}
