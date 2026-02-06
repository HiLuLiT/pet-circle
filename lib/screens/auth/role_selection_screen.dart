import 'package:flutter/material.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _handleRoleSelect(BuildContext context, AppUserRole role) {
    if (kEnableFirebase) {
      Navigator.of(context).pushNamed(AppRoutes.auth, arguments: role);
    } else {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.mainShell,
        arguments: role,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.hiUser('Hila Ben Baruch'),
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.chocolate,
                    letterSpacing: -0.96,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 93),
                _RoleButton(
                  label: l10n.imAVeterinarian,
                  backgroundColor: AppColors.chocolate,
                  textColor: AppColors.white,
                  iconColor: AppColors.white,
                  onTap: () => _handleRoleSelect(context, AppUserRole.vet),
                ),
                const SizedBox(height: 12),
                _RoleButton(
                  label: l10n.imAPetOwner,
                  backgroundColor: AppColors.pink,
                  textColor: AppColors.chocolate,
                  iconColor: AppColors.chocolate,
                  onTap: () => _handleRoleSelect(context, AppUserRole.owner),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(172),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.96,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
