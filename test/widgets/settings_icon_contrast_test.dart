import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/screens/settings/settings_care_circle_widgets.dart';
import 'package:pet_circle/screens/settings/settings_widgets.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/widgets/settings_row.dart';

import '../helpers/test_app.dart';

/// The Figma-exported settings SVGs hardcode `#440206` (near-black maroon) and
/// `#FF3034` in their fills, so an untinted `SvgPicture` renders the same
/// glyph in both themes while the tile behind it swaps to a dark wash. Every
/// call site must therefore apply a `ColorFilter` sourced from
/// `AppSemanticColors`. These tests assert the rendered filter rather than
/// eyeballing a screenshot.
void main() {
  final darkColors = buildDarkTheme().extension<AppSemanticColors>()!;
  final lightColors = buildAppTheme().extension<AppSemanticColors>()!;

  ColorFilter? filterOf(WidgetTester tester, Finder finder) =>
      tester.widget<SvgPicture>(finder).colorFilter;

  ColorFilter expected(Color color) => ColorFilter.mode(color, BlendMode.srcIn);

  group('settings icon contrast (dark mode)', () {
    testWidgets('SettingsToggleRow tints the moon icon with iconColor', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          SettingsToggleRow(
            label: 'Dark mode',
            isOn: true,
            iconAsset: settingsMoonAsset,
            iconTileColor: darkColors.accentPeriwinkleTile,
            iconColor: darkColors.accentPeriwinkle,
          ),
          darkMode: true,
        ),
      );

      expect(
        filterOf(tester, find.byType(SvgPicture)),
        expected(darkColors.accentPeriwinkle),
      );
    });

    testWidgets('SettingsToggleRow falls back to accentPeriwinkle', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          const SettingsToggleRow(
            label: 'Dark mode',
            isOn: false,
            iconAsset: settingsMoonAsset,
          ),
          darkMode: true,
        ),
      );

      expect(
        filterOf(tester, find.byType(SvgPicture)),
        expected(darkColors.accentPeriwinkle),
      );
    });

    testWidgets('LanguageRow tints the globe icon with accentMint', (
      tester,
    ) async {
      await tester.pumpWidget(testApp(const LanguageRow(), darkMode: true));

      expect(
        filterOf(tester, find.byType(SvgPicture)),
        expected(darkColors.accentMint),
      );
    });

    testWidgets('ActionRow tints an SVG icon with textPrimary', (tester) async {
      await tester.pumpWidget(
        testApp(
          ActionRow(
            iconAsset: settingsShareAsset,
            title: 'Share with vet',
            description: 'Send a summary',
            onTap: () {},
          ),
          darkMode: true,
        ),
      );

      expect(
        filterOf(tester, find.byType(SvgPicture)),
        expected(darkColors.textPrimary),
      );
    });

    testWidgets('CareCircleItem tints the trash icon with error', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          CareCircleItem(
            email: 'vet@example.com',
            roleLabel: 'Viewer',
            roleColor: darkColors.surface,
            statusLabel: 'Active',
            onRemove: () {},
          ),
          darkMode: true,
        ),
      );

      expect(
        filterOf(tester, find.byType(SvgPicture)),
        expected(darkColors.error),
      );
    });

    testWidgets('InviteButton tints the invite icon with onSurface', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(InviteButton(onTap: () {}), darkMode: true),
      );

      expect(
        filterOf(tester, find.byType(SvgPicture)),
        expected(darkColors.onSurface),
      );
    });

    testWidgets('SettingsRow tints its icon with textPrimary', (tester) async {
      await tester.pumpWidget(
        testApp(
          const SettingsRow(title: 'Profile', iconAsset: settingsChevronAsset),
          darkMode: true,
        ),
      );

      expect(
        filterOf(tester, find.byType(SvgPicture)),
        expected(darkColors.textPrimary),
      );
    });
  });

  group('settings icon contrast (light mode)', () {
    testWidgets('the same call sites resolve to light tokens', (tester) async {
      await tester.pumpWidget(testApp(const LanguageRow()));
      expect(
        filterOf(tester, find.byType(SvgPicture)),
        expected(lightColors.accentMint),
      );

      await tester.pumpWidget(
        testApp(
          CareCircleItem(
            email: 'vet@example.com',
            roleLabel: 'Viewer',
            roleColor: lightColors.surface,
            statusLabel: 'Active',
            onRemove: () {},
          ),
        ),
      );
      expect(
        filterOf(tester, find.byType(SvgPicture)),
        expected(lightColors.error),
      );
    });

    testWidgets('dark and light tokens actually differ', (tester) async {
      expect(darkColors.accentMint, isNot(lightColors.accentMint));
      expect(darkColors.accentPeriwinkle, isNot(lightColors.accentPeriwinkle));
      expect(darkColors.textPrimary, isNot(lightColors.textPrimary));
      expect(darkColors.error, isNot(lightColors.error));
    });
  });
}
