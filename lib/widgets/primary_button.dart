import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.textStyle = AppTextStyles.button,
    this.minHeight = 58,
    this.borderRadius = 172,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final TextStyle textStyle;
  final double minHeight;
  final double borderRadius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final bg = backgroundColor ?? c.chocolate;
    return SizedBox(
      height: minHeight,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textStyle.color ?? c.white, size: 22),
              const SizedBox(width: 10),
            ],
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}
