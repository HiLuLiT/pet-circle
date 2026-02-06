import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';

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
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get _hasNetworkImage =>
      imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.white, width: 2),
          color: _hasNetworkImage ? null : c.pink,
        ),
        child: ClipOval(
          child: _hasNetworkImage
              ? Image.network(imageUrl!, fit: BoxFit.cover, width: size, height: size)
              : Center(
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: c.chocolate,
                      fontWeight: FontWeight.w600,
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
