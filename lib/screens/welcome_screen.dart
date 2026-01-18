import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/main.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _handleVetTap(BuildContext context) {
    if (kEnableFirebase) {
      Navigator.of(context).pushNamed(AppRoutes.auth, arguments: AppUserRole.vet);
    } else {
      // Skip auth - go directly to main shell
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.mainShell,
        arguments: AppUserRole.vet,
      );
    }
  }

  void _handleOwnerTap(BuildContext context) {
    if (kEnableFirebase) {
      Navigator.of(context).pushNamed(AppRoutes.auth, arguments: AppUserRole.owner);
    } else {
      // Skip auth - go directly to main shell
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.mainShell,
        arguments: AppUserRole.owner,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pink,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: SvgPicture.asset(
                AppAssets.welcomeGraphic,
                width: 248,
                height: 248,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: "I'm a Veterinarian",
                  onPressed: () => _handleVetTap(context),
                  backgroundColor: AppColors.burgundy,
                  textStyle: AppTextStyles.button.copyWith(fontSize: 20),
                  icon: Icons.medical_services_outlined,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: "I'm a Pet Owner",
                  onPressed: () => _handleOwnerTap(context),
                  backgroundColor: AppColors.white,
                  textStyle: AppTextStyles.button
                      .copyWith(fontSize: 20, color: AppColors.burgundy),
                  icon: Icons.pets,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
