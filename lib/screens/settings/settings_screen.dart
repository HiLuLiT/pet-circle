import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/bottom_nav_bar.dart';

import 'package:pet_circle/screens/settings/settings_content.dart';

// Re-export constants so existing consumers still find them here.
export 'package:pet_circle/screens/settings/settings_content.dart'
    show kPushNotificationCategories, kEmergencyAlertCategories;

/// Opens the settings as a slide-up drawer (modal bottom sheet).
class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key, required this.role});

  final AppUserRole role;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadiiTokens.lg)),
          child: SettingsContent(
            role: role,
            scrollController: scrollController,
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }
}

/// Standalone settings screen (used when navigated to via route).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.role});

  final AppUserRole role;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SettingsContent(role: role),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onTap: (index) {
          context.go(AppRoutes.shell(role, tab: index));
        },
      ),
    );
  }
}
