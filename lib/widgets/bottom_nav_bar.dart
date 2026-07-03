import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';

/// Bottom navigation bar with 5 tabs: Home, Trends, Diary, Measure, Medicine.
///
/// Ported to PC v3 (Claude-Design) visuals:
/// - Translucent surface (0.92) with a 12px backdrop blur.
/// - Active item uses `onSurface` (pcInk); inactive uses `textTertiary`.
/// - Padding 14/10/14/26 to match the React component.
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

  static const _tabs = [
    _TabDef(icon: Icons.home_outlined, activeIcon: Icons.home),
    _TabDef(icon: Icons.show_chart_outlined, activeIcon: Icons.show_chart),
    _TabDef(icon: Icons.people_outline, activeIcon: Icons.people),
    _TabDef(icon: Icons.monitor_heart_outlined, activeIcon: Icons.monitor_heart),
    _TabDef(icon: Icons.medication_outlined, activeIcon: Icons.medication),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.navHome,
      l10n.navTrends,
      l10n.navCircle,
      l10n.navMeasure,
      l10n.navMedication,
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
                          Icon(
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
  const _TabDef({
    required this.icon,
    required this.activeIcon,
  });

  final IconData icon;
  final IconData activeIcon;
}
