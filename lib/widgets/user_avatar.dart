import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';

/// Displays a user avatar. Shows network image if [imageUrl] is non-empty and
/// starts with 'http'. Otherwise falls back to initials derived from [name].
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 36,
    this.onTap,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get _hasNetworkImage =>
      imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppPrimitives.skyWhite, width: 2),
          color: _hasNetworkImage ? null : c.primaryLight,
        ),
        child: ClipOval(
          child: _hasNetworkImage
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      _initials,
                      style: AppSemanticTextStyles.labelSm.copyWith(
                        color: c.onPrimary,
                        fontSize: size * 0.38,
                        height: 1,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    _initials,
                    style: AppSemanticTextStyles.labelSm.copyWith(
                      color: c.onPrimary,
                      fontSize: size * 0.38,
                      height: 1,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
