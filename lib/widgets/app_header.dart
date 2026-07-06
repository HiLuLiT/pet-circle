import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/user_avatar.dart';

/// Reusable app header with avatar (left), optional pet selector (center),
/// and notification bell (right).
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.userName,
    this.userImageUrl,
    this.petName,
    this.petImageUrl,
    this.onAvatarTap,
    this.onNotificationTap,
    this.onPetSelectorTap,
  });

  final String userName;
  final String? userImageUrl;
  final String? petName;
  final String? petImageUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onPetSelectorTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: User avatar -> opens settings
        UserAvatar(
          name: userName,
          imageUrl: userImageUrl,
          size: 32,
          backgroundColor: c.accentPurpleTile,
          foregroundColor: c.primary,
          onTap: onAvatarTap,
        ),
        // Center: Pet selector (optional)
        if (petName != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPetSelectorTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    petName!,
                    style: AppSemanticTextStyles.headingH2
                        .copyWith(color: c.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onPetSelectorTap != null) ...[
                  const SizedBox(width: AppSpacingTokens.xs),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 24,
                    color: c.textPrimary,
                  ),
                ],
              ],
            ),
          ),
        // Right: Notification bell
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onNotificationTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_none,
              color: c.textPrimary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
