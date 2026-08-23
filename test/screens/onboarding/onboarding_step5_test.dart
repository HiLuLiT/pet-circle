import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/onboarding/onboarding_step5.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';
import 'package:pet_circle/widgets/primary_button.dart';

import '../../helpers/test_app.dart';

/// Parity assertions for Figma node 424:6047 ("Step 5 (All Set)").
///
/// Values below are the *resolved* Figma values read off the node, not token
/// names — so a token drifting away from the design fails here.
void main() {
  Future<void> pumpStep5(
    WidgetTester tester, {
    String petName = 'Princess',
    VoidCallback? onEnter,
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      testApp(
        OnboardingStep5(petName: petName, onEnter: onEnter),
        locale: locale,
      ),
    );
    await tester.pumpAndSettle();
  }

  group('OnboardingStep5 content', () {
    testWidgets('renders the title, subtitle and CTA', (tester) async {
      await pumpStep5(tester);

      expect(tester.takeException(), isNull);
      expect(find.text("You're all set!"), findsOneWidget);
      expect(
        find.text(
          "Princess's profile is ready. Let's take the first measurement "
          'together.',
        ),
        findsOneWidget,
      );
      expect(find.text('Enter Pet Circle'), findsOneWidget);
    });

    testWidgets('interpolates the created pet name into the subtitle', (
      tester,
    ) async {
      await pumpStep5(tester, petName: 'Rocky');

      expect(find.textContaining("Rocky's profile is ready"), findsOneWidget);
    });

    testWidgets('CTA invokes onEnter', (tester) async {
      var entered = 0;
      await pumpStep5(tester, onEnter: () => entered++);

      await tester.tap(find.text('Enter Pet Circle'));
      await tester.pumpAndSettle();

      expect(entered, 1);
    });

    testWidgets('renders in Hebrew', (tester) async {
      await pumpStep5(tester, locale: const Locale('he'));

      expect(tester.takeException(), isNull);
      expect(find.text('הכול מוכן!'), findsOneWidget);
      expect(find.textContaining('הפרופיל של Princess מוכן'), findsOneWidget);
    });

    testWidgets('has none of the OnboardingShell chrome', (tester) async {
      await pumpStep5(tester);

      // Figma 424:6047 has no back button, no progress bar and no step label.
      expect(find.byType(OnboardingShell), findsNothing);
      expect(find.byType(BackButton), findsNothing);
    });
  });

  group('OnboardingStep5 Figma parity', () {
    testWidgets('background is Neutrals/Background #F5F3EF', (tester) async {
      await pumpStep5(tester);

      final scaffold = tester.widget<Scaffold>(
        find.descendant(
          of: find.byType(OnboardingStep5),
          matching: find.byType(Scaffold),
        ),
      );
      expect(scaffold.backgroundColor, const Color(0xFFF5F3EF));
    });

    testWidgets('title matches Display/M — Bold 28/36, -0.14, Ink #161616', (
      tester,
    ) async {
      await pumpStep5(tester);

      final title = tester.widget<Text>(find.text("You're all set!"));
      final style = title.style!;

      expect(style.fontFamily, 'Instrument Sans');
      expect(style.fontSize, 28);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.height, closeTo(36 / 28, 0.0001));
      expect(style.letterSpacing, closeTo(-0.14, 0.0001));
      expect(style.color, const Color(0xFF161616));
      expect(title.textAlign, TextAlign.center);
      // Weight must come from the wght axis, not fontWeight alone (BUG-044).
      expect(
        style.fontVariations,
        contains(const FontVariation('wght', 700)),
      );
    });

    testWidgets(
      'subtitle matches Label/L Regular — 15/20, Secondary #595959',
      (tester) async {
        await pumpStep5(tester);

        final subtitle = tester.widget<Text>(
          find.textContaining("Princess's profile is ready"),
        );
        final style = subtitle.style!;

        expect(style.fontFamily, 'Instrument Sans');
        expect(style.fontSize, 15);
        expect(style.fontWeight, FontWeight.w400);
        expect(style.height, closeTo(20 / 15, 0.0001));
        expect(style.color, const Color(0xFF595959));
        expect(subtitle.textAlign, TextAlign.center);
      },
    );

    testWidgets('mascot renders the exported asset at 136.093x162.697', (
      tester,
    ) async {
      await pumpStep5(tester);

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final image = tester.widget<Image>(imageFinder);
      expect(
        (image.image as AssetImage).assetName,
        AppAssets.onboardingAllSetDog,
      );

      final size = tester.getSize(imageFinder);
      expect(size.width, closeTo(136.093, 0.01));
      expect(size.height, closeTo(162.697, 0.01));
    });

    testWidgets('mascot asset is the animated WebP, not a still frame', (
      tester,
    ) async {
      await pumpStep5(tester);

      final image = tester.widget<Image>(find.byType(Image));
      final name = (image.image as AssetImage).assetName;

      // Animated WebP is played natively by [Image]; a .png here would mean
      // the animation was silently swapped back for a still.
      expect(name, endsWith('.webp'));
      expect(name, AppAssets.onboardingAllSetDog);
    });

    testWidgets('CTA is a full-width filled PrimaryButton, 329x54', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpStep5(tester);

      final button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(button.variant, PrimaryButtonVariant.filled);
      expect(button.fullWidth, isTrue);

      // Figma: 329 wide (393 - 2*32 margin) and 54 tall.
      final size = tester.getSize(find.byType(PrimaryButton));
      expect(size.width, closeTo(329, 0.5));
      expect(size.height, closeTo(54, 0.5));
    });

    testWidgets('vertical rhythm matches the 393x852 frame', (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpStep5(tester);

      // Figma y-offsets, measured from the bottom of the 44pt status bar.
      // The test surface has no notch, so SafeArea contributes nothing and
      // the offsets land at their raw frame values minus the status bar.
      //
      // Only offsets *above* the copy block can be asserted absolutely:
      // widget tests substitute a placeholder font whose glyphs are square,
      // so the two Text blocks wrap differently than they do with Instrument
      // Sans. Everything below them is therefore asserted as a gap, which is
      // what the Figma frame actually specifies.
      final mascotTop = tester.getTopLeft(find.byType(Image)).dy;
      final titleRect = tester.getRect(find.text("You're all set!"));
      final subtitleRect = tester.getRect(
        find.textContaining("Princess's profile is ready"),
      );
      final buttonTop = tester.getTopLeft(find.byType(PrimaryButton)).dy;

      expect(mascotTop, closeTo(109 - 44 + 19.027, 0.5));
      expect(titleRect.top, closeTo(316 - 44, 0.5));
      // Copy frame 424:6062 uses a 12px column gap.
      expect(subtitleRect.top - titleRect.bottom, closeTo(12, 0.5));
      // Copy frame bottom (404) to Button top (444).
      expect(buttonTop - subtitleRect.bottom, closeTo(40, 0.5));
    });
  });
}
