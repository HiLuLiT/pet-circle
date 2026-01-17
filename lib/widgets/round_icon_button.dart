import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    this.backgroundColor = AppColors.offWhite,
    this.onTap,
    this.size = 36,
    this.iconSize = 16,
  });

  final Widget icon;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(AppRadii.pill),
        child: Container(
          height: size,
          width: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                height: iconSize,
                width: iconSize,
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
