import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/theme/app_theme.dart';

const _homeIconAsset = 'assets/figma/nav_home.svg';
const _heartbeatIconAsset = 'assets/figma/nav_heartbeat.svg';
const _heartIconAsset = 'assets/figma/nav_heart.svg';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.white,
        border: Border(
          top: BorderSide(color: c.chocolate, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Semantics(
            label: 'Home',
            button: true,
            child: _NavItem(
              iconAsset: _homeIconAsset,
              isSelected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Semantics(
            label: 'Trends',
            button: true,
            child: _NavItem(
              iconAsset: _heartbeatIconAsset,
              isSelected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          Semantics(
            label: 'Pets',
            button: true,
            child: _NavItem(
              iconAsset: _heartIconAsset,
              isSelected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Semantics(
            label: 'Medications',
            button: true,
            child: _NavItemIcon(
              icon: Icons.medication_outlined,
              isSelected: selectedIndex == 3,
              onTap: () => onTap(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemIcon extends StatelessWidget {
  const _NavItemIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isSelected ? 1 : 0.3,
        child: Icon(icon, size: 36, color: c.chocolate),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.iconAsset,
    required this.isSelected,
    required this.onTap,
  });

  final String iconAsset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isSelected ? 1 : 0.3,
        child: SvgPicture.asset(
          iconAsset,
          width: 36,
          height: 36,
        ),
      ),
    );
  }
}
