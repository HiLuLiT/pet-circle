import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';

class NeumorphicCard extends StatelessWidget {
  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.radius,
    this.inner = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? radius;
  final bool inner;

  @override
  Widget build(BuildContext context) {
    final cardRadius = radius ?? const BorderRadius.all(AppRadii.medium);
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: cardRadius,
        boxShadow: inner ? AppShadows.neumorphicInner : AppShadows.neumorphicOuter,
      ),
      child: child,
    );
  }
}
