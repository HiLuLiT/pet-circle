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
        // Figma 442:6748 — the avatar and pet selector are ONE left-aligned
        // group with a 12px gap, not two children spread apart by
        // spaceBetween (which pushed the pet name to the centre).
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(
              name: userName,
              imageUrl: userImageUrl,
              size: 32,
              backgroundColor: c.accentPurpleTile,
              foregroundColor: c.primary,
              // Figma 442:6750 — the initial is Label/S Bold 13/18.
              textStyle: AppSemanticTextStyles.labelSBold,
              onTap: onAvatarTap,
            ),
            if (petName != null) ...[
              const SizedBox(width: AppSpacingTokens.pcMd),
              Flexible(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onPetSelectorTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          petName!,
                          style: AppSemanticTextStyles.headingH2.copyWith(
                            color: c.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onPetSelectorTap != null) ...[
                        // Figma 442:6751 gap is 8px.
                        const SizedBox(width: AppSpacingTokens.pcSm),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 24,
                          color: c.textPrimary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        // Right: notification bell. Figma 442:8694 is a white pill with 12px
        // padding around a 16.615px glyph (40.615 total) and NO shadow.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onNotificationTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacingTokens.pcMd),
            decoration: BoxDecoration(
              color: c.surface,
              // Figma specifies a pill with NO shadow. main had tokenized the
              // old hardcoded black-8% shadow to AppShadowTokens.smallOf() for
              // dark mode; dropping the shadow entirely satisfies that intent
              // too (no light-pinned literal) while matching the design.
              borderRadius: AppRadiiTokens.borderRadiusPill,
            ),
            child: Icon(
              Icons.notifications_none,
              color: c.textPrimary,
              size: 16.615,
            ),
          ),
        ),
      ],
    );
  }
}
