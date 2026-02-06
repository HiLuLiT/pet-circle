import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: User avatar -> opens settings
        UserAvatar(
          name: userName,
          imageUrl: userImageUrl,
          size: 36,
          onTap: onAvatarTap,
        ),
        // Center: Pet selector (optional)
        if (petName != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPetSelectorTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (petImageUrl != null && petImageUrl!.isNotEmpty)
                    ClipOval(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: DogPhoto(
                          endpoint: petImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (petImageUrl != null && petImageUrl!.isNotEmpty)
                    const SizedBox(width: 6),
                  Text(
                    petName!,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.chocolate,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.chocolate),
                ],
              ),
            ),
          ),
        // Right: Notification bell
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onNotificationTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.chocolate,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
