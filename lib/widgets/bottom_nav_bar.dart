import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/shadows.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';

/// Bottom navigation bar with 5 tabs: Home, Trends, Diary, Mesure, Medicine.
///
/// Migrated from v1 (4 tabs with SVG icons + opacity) to v2 design system
/// using Material icons, semantic colors, and shadow tokens.
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
    return Container(
      decoration: BoxDecoration(
        color: AppPrimitives.skyWhite,
        boxShadow: AppShadowTokens.small,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.lg,
        vertical: AppSpacingTokens.sm,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final isActive = selectedIndex == i;
            return Expanded(
              child: Semantics(
                label: labels[i],
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacingTokens.xs),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? tab.activeIcon : tab.icon,
                          size: 24,
                          color: isActive
                              ? c.primary
                              : AppPrimitives.inkLight,
                        ),
                        const SizedBox(height: AppSpacingTokens.xs),
                        Text(
                          labels[i],
                          style: AppSemanticTextStyles.caption.copyWith(
                            color: isActive
                                ? c.primary
                                : AppPrimitives.inkLight,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
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
