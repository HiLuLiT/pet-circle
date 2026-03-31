import 'package:flutter/material.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class AppImage extends StatelessWidget {
  const AppImage.asset(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.fallbackIcon = Icons.image_not_supported_outlined,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _Fallback(
        width: width,
        height: height,
        icon: fallbackIcon,
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.width, this.height, required this.icon});

  final double? width;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppPrimitives.skyLightest,
        borderRadius: AppRadiiTokens.borderRadiusLg,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppPrimitives.skyDark, size: 20),
    );
  }
}
