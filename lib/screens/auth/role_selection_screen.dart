import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/services/user_service.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _handleRoleSelect(BuildContext context, AppUserRole role) async {
    if (!kEnableFirebase) {
      context.go(AppRoutes.shell(role));
      return;
    }

    final firebaseUser = authProvider.firebaseUser;
    if (firebaseUser != null) {
      await UserService.createUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        role: role,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
      );
      await authProvider.refresh();
      if (context.mounted) {
        context.go(AppRoutes.authGate);
      }
    } else {
      context.push('${AppRoutes.auth}?role=${role.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);

    // Try Firebase displayName first (for Google/Apple social auth users),
    // then userStore name, fallback to generic greeting
    final name = authProvider.firebaseUser?.displayName ??
        userStore.currentUser?.name;
    final greeting = (name != null && name.isNotEmpty)
        ? l10n.hiUser(name)
        : l10n.chooseYourRole;

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: AppSemanticTextStyles.title3.copyWith(
                    color: c.textPrimary,
                    letterSpacing: -0.96,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 93),
                _RoleButton(
                  label: l10n.imAVeterinarian,
                  backgroundColor: c.primary,
                  textColor: c.onPrimary,
                  iconColor: c.onPrimary,
                  onTap: () => _handleRoleSelect(context, AppUserRole.vet),
                ),
                const SizedBox(height: 12),
                _RoleButton(
                  label: l10n.imAPetOwner,
                  backgroundColor: c.primaryLight,
                  textColor: c.textPrimary,
                  iconColor: c.textPrimary,
                  onTap: () => _handleRoleSelect(context, AppUserRole.owner),
                ),
              ],
            ),
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
            borderRadius: AppRadiiTokens.borderRadiusFull,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, color: iconColor, size: 24),
            const SizedBox(width: AppSpacingTokens.sm),
            Text(
              label,
              style: AppSemanticTextStyles.body.copyWith(
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
