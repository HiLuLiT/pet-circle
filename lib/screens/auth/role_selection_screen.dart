import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/repositories/user_repository.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _handleRoleSelect(BuildContext context, AppUserRole role) async {
    if (!kEnableFirebase) {
      context.go(AppRoutes.shell());
      return;
    }

    final firebaseUser = authProvider.firebaseUser;
    if (firebaseUser != null) {
      await userRepository.createUser(
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
      context.push(AppRoutes.signup);
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
      backgroundColor: c.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 393),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: c.primaryGhost,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_outline, size: 36, color: c.primary),
                  ),
                  const SizedBox(height: AppSpacingTokens.pcLg),
                  Text(
                    greeting,
                    style: AppSemanticTextStyles.headingH1.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.pcXs + 2),
                  Text(
                    l10n.tellUsHowYoullUsePetCircle,
                    style: AppSemanticTextStyles.labelLRegular.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.pcXl),
                  _RoleCard(
                    tileColor: c.accentPurpleTile,
                    iconBackgroundColor: c.accentPurple,
                    icon: Icons.medical_services_outlined,
                    title: l10n.imAVeterinarian,
                    subtitle: l10n.monitorPatientsAndCollaborate,
                    onTap: () => _handleRoleSelect(context, AppUserRole.vet),
                  ),
                  const SizedBox(height: AppSpacingTokens.pcSm + 2),
                  _RoleCard(
                    tileColor: c.accentButterTile,
                    iconBackgroundColor: c.accentButter,
                    icon: Icons.pets,
                    title: l10n.imAPetOwner,
                    subtitle: l10n.trackMyOwnPetsHealth,
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.tileColor,
    required this.iconBackgroundColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color tileColor;
  final Color iconBackgroundColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiiTokens.pcCard),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacingTokens.pcMd + 2),
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(AppRadiiTokens.pcCard),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: c.onPrimary),
              ),
              const SizedBox(width: AppSpacingTokens.pcSm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppSemanticTextStyles.pcBodySemibold.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppSemanticTextStyles.labelSRegular.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward, size: 20, color: c.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
