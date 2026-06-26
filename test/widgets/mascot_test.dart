import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/widgets/mascot.dart';

import '../helpers/test_app.dart';

void main() {
  group('Mascot', () {
    // ── Smoke: every breed renders without error ───────────────────────────
    for (final breed in MascotBreed.values) {
      testWidgets('renders ${breed.name} without error', (tester) async {
        await tester.pumpWidget(testApp(
          Mascot(breed: breed, color: const Color(0xFF6B4EFF)),
        ));
        expect(find.byType(Mascot), findsOneWidget);
        expect(find.byType(SvgPicture), findsOneWidget);
      });
    }

    // ── Size param is applied to the rendered widget ───────────────────────
    testWidgets('respects size param (default = 56)', (tester) async {
      await tester.pumpWidget(testApp(
        const Mascot(breed: MascotBreed.floppy, color: Color(0xFF6B4EFF)),
      ));
      final SvgPicture picture = tester.widget(find.byType(SvgPicture));
      expect(picture.width, 56);
      expect(picture.height, 56);
    });

    testWidgets('respects custom size param', (tester) async {
      await tester.pumpWidget(testApp(
        const Mascot(
          breed: MascotBreed.perky,
          color: Color(0xFF6B4EFF),
          size: 128,
        ),
      ));
      final SvgPicture picture = tester.widget(find.byType(SvgPicture));
      expect(picture.width, 128);
      expect(picture.height, 128);
    });

    // ── Color helpers ──────────────────────────────────────────────────────
    test('mascotColorToHex strips alpha and uppercases', () {
      expect(mascotColorToHex(const Color(0xFF6B4EFF)), '#6B4EFF');
      expect(mascotColorToHex(const Color(0x806B4EFF)), '#6B4EFF');
      expect(mascotColorToHex(const Color(0xFF000000)), '#000000');
      expect(mascotColorToHex(const Color(0xFFFFFFFF)), '#FFFFFF');
    });

    test('mascotColorToHex pads short components with leading zeros', () {
      expect(mascotColorToHex(const Color(0xFF010203)), '#010203');
    });

    // ── Color param is applied to the body fills ───────────────────────────
    test('buildMascotSvg embeds the body color and drops currentColor', () {
      const Color color = Color(0xFF6B4EFF);
      final String svg = buildMascotSvg(
        breed: MascotBreed.floppy,
        color: color,
        size: 56,
      );
      expect(svg.contains('#6B4EFF'), isTrue);
      expect(svg.contains('currentColor'), isFalse);
      // Ink features must remain untouched.
      expect(svg.contains('#161616'), isTrue);
      // Dimensions and viewBox are wired through.
      expect(svg.contains('viewBox="0 0 100 100"'), isTrue);
      expect(svg.contains('width="56.0"'), isTrue);
      expect(svg.contains('height="56.0"'), isTrue);
    });

    test('buildMascotSvg differs per breed', () {
      final String floppy = buildMascotSvg(
        breed: MascotBreed.floppy,
        color: const Color(0xFF6B4EFF),
        size: 56,
      );
      final String whiskers = buildMascotSvg(
        breed: MascotBreed.whiskers,
        color: const Color(0xFF6B4EFF),
        size: 56,
      );
      expect(floppy == whiskers, isFalse);
    });
  });
}
