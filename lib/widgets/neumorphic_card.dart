import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/shadows.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

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
    final c = AppSemanticColors.of(context);
    final cardRadius = radius ?? AppRadiiTokens.borderRadiusLg;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: cardRadius,
        boxShadow: inner ? AppShadowTokens.small : AppShadowTokens.small,
      ),
      child: child,
    );
  }
}
