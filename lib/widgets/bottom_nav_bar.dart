import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableCircleTab;
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';

/// Bottom navigation bar with 5 tabs: Home, Trends, Diary, Measure, Medicine.
///
/// Ported to PC v3 (Claude-Design) visuals:
/// - Translucent surface (0.92) with a 12px backdrop blur.
/// - Active item uses `onSurface` (pcInk); inactive uses `textTertiary`.
/// - Padding 14/10/14/26 to match the React component.
/// - Icons are the Figma DS outline set (node 500:1106), tinted per-state via
///   `SvgPicture`'s `colorFilter` rather than swapping asset files, since the
///   design uses a single outline glyph per tab (not separate active/inactive
///   artwork like Material's outlined/filled icon pairs).
///
/// Public API (`selectedIndex`, `onTap`) is unchanged.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final void Function(int) onTap;

  // The Circle tab is hidden behind kEnableCircleTab and wasn't part of the
  // Figma tab-bar export (which shows Diary in that slot instead) -- it
  // keeps its Material icon fallback rather than an unsourced SVG.
  static const _allTabs = [
    _TabDef.svg('assets/figma/nav_home.svg'),
    _TabDef.svg('assets/figma/nav_trends.svg'),
    _TabDef.icon(Icons.people_outline, Icons.people),
    _TabDef.svg('assets/figma/nav_measure.svg'),
    _TabDef.svg('assets/figma/nav_medicine.svg'),
  ];

  /// Tabs to render, excluding the Circle tab (index 2) when
  /// [kEnableCircleTab] is false. Kept in sync index-for-index with the
  /// `labels` list built in [build].
  static List<_TabDef> get _tabs => kEnableCircleTab
      ? _allTabs
      : [
          for (var i = 0; i < _allTabs.length; i++)
            if (i != 2) _allTabs[i],
        ];

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final allLabels = [
      l10n.navHome,
      l10n.navTrends,
      l10n.navCircle,
      l10n.navMeasure,
      l10n.navMedication,
    ];
    final labels = kEnableCircleTab
        ? allLabels
        : [
            for (var i = 0; i < allLabels.length; i++)
              if (i != 2) allLabels[i],
          ];

    final activeColor = c.onSurface;
    final inactiveColor = c.textTertiary;

    // BackdropFilter must be clipped to the bar's bounds, otherwise the blur
    // bleeds into the rest of the scene.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: c.surface.withValues(alpha: 0.92),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 26),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isActive = selectedIndex == i;
                final color = isActive ? activeColor : inactiveColor;
                return Expanded(
                  child: Semantics(
                    label: labels[i],
                    button: true,
                    selected: isActive,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          tab.assetPath != null
                              ? SvgPicture.asset(
                                  tab.assetPath!,
                                  width: 24,
                                  height: 24,
                                  colorFilter:
                                      ColorFilter.mode(color, BlendMode.srcIn),
                                )
                              : Icon(
                                  isActive ? tab.activeIcon : tab.icon,
                                  size: 24,
                                  color: color,
                                ),
                          const SizedBox(height: 4),
                          Text(
                            labels[i],
                            style: AppSemanticTextStyles.pcCaption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _TabDef {
  const _TabDef.svg(this.assetPath)
      : icon = null,
        activeIcon = null;

  const _TabDef.icon(this.icon, this.activeIcon) : assetPath = null;

  final String? assetPath;
  final IconData? icon;
  final IconData? activeIcon;
}
