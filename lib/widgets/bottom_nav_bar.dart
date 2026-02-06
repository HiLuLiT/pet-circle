import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/theme/app_theme.dart';

const _homeIconAsset = 'assets/figma/nav_home.svg';
const _heartbeatIconAsset = 'assets/figma/nav_heartbeat.svg';
const _heartIconAsset = 'assets/figma/nav_heart.svg';
const _messageIconAsset = 'assets/figma/nav_message.svg';

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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.chocolate, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            iconAsset: _homeIconAsset,
            isSelected: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            iconAsset: _heartbeatIconAsset,
            isSelected: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            iconAsset: _heartIconAsset,
            isSelected: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            iconAsset: _messageIconAsset,
            isSelected: selectedIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
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
