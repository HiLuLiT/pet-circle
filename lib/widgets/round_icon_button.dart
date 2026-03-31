import 'package:flutter/material.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.onTap,
    this.size = 36,
    this.iconSize = 16,
  });

  final Widget icon;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadiiTokens.borderRadiusFull,
        child: Container(
          height: size,
          width: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? AppPrimitives.skyLight,
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
