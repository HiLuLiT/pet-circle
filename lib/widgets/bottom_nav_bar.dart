import 'package:flutter/material.dart';
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
    _TabDef(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _TabDef(
        icon: Icons.show_chart_outlined,
        activeIcon: Icons.show_chart,
        label: 'Trends'),
    _TabDef(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: 'Circle'),
    _TabDef(
        icon: Icons.monitor_heart_outlined,
        activeIcon: Icons.monitor_heart,
        label: 'Mesure'),
    _TabDef(
        icon: Icons.medication_outlined,
        activeIcon: Icons.medication,
        label: 'Medicine'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
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
                label: tab.label,
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
                          tab.label,
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
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
