import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/data/mock_data.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/bottom_nav_bar.dart';

const _settingsRightAsset = 'assets/figma/settings_right.svg';
const _settingsShareAsset = 'assets/figma/settings_share.svg';
const _settingsDownAsset = 'assets/figma/settings_down.svg';
const _settingsDownCircleAsset = 'assets/figma/settings_down_circle.svg';
const _settingsMoonAsset = 'assets/figma/settings_moon.svg';
const _settingsGlobeAsset = 'assets/figma/settings_globe.svg';
const _settingsChevronAsset = 'assets/figma/settings_chevron.svg';
const _settingsInviteAsset = 'assets/figma/settings_invite.svg';
const _settingsTrashAsset = 'assets/figma/settings_trash.svg';
const _settingsConfigureAsset = 'assets/figma/settings_configure.svg';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.role});

  final AppUserRole role;

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentOwnerUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _ProfileSelector(avatarUrl: user.avatarUrl),
              ),
              const SizedBox(height: 24),
              Text(
                'Settings',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.burgundy,
                  letterSpacing: -0.96,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your PetBreath preferences',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.burgundy,
                  fontSize: 14,
                  letterSpacing: -0.15,
                ),
              ),
              const SizedBox(height: 24),
              _SettingsCard(
                title: 'Appearance',
                subtitle: 'Customize the look and feel',
                child: Column(
                  children: [
                    _SettingsToggleRow(
                      iconAsset: _settingsMoonAsset,
                      label: 'Dark mode',
                      isOn: false,
                    ),
                    const SizedBox(height: 12),
                    _LanguageRow(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Care Circle',
                subtitle: 'Manage caregivers, vets, and pet sitters',
                trailing: _InviteButton(onTap: () {}),
                child: Column(
                  children: const [
                    _CareCircleItem(
                      email: 'sarah@example.com',
                      roleLabel: 'Owner',
                      roleColor: Color(0xFFA15F3B),
                      statusLabel: 'Active',
                      statusColor: AppColors.pink,
                    ),
                    SizedBox(height: 12),
                    _CareCircleItem(
                      email: 'drsmith@vetclinic.com',
                      roleLabel: 'Vet',
                      roleColor: Color(0xFF146FD9),
                      statusLabel: 'Active',
                      statusColor: AppColors.pink,
                    ),
                    SizedBox(height: 12),
                    _CareCircleItem(
                      email: 'petsitter@example.com',
                      roleLabel: 'Viewer',
                      roleColor: Color(0xFFFFECB7),
                      statusLabel: 'Pending',
                      statusColor: AppColors.offWhite,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Notifications',
                subtitle: 'Manage alerts and reminders',
                child: Column(
                  children: [
                    _SettingsToggleRow(
                      label: 'Push notifications',
                      description: 'Receive notifications for measurements',
                      isOn: false,
                    ),
                    const SizedBox(height: 12),
                    _SettingsToggleRow(
                      label: 'Emergency alerts',
                      description:
                          'Critical alerts when SRR exceeds thresholds',
                      isOn: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Measurement settings',
                subtitle: 'Configure measurement modes and thresholds',
                child: Column(
                  children: [
                    _SettingsToggleRow(
                      label: 'VisionRR camera mode',
                      description: 'AI-powered camera-based measurement',
                      isOn: false,
                    ),
                    const SizedBox(height: 12),
                    _ConfigureRow(onTap: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Data & Privacy',
                subtitle: 'Export data and manage privacy settings',
                child: Column(
                  children: [
                    _SettingsToggleRow(
                      label: 'Auto-Export Data',
                      description: 'Weekly CSV export to email',
                      isOn: false,
                    ),
                    const SizedBox(height: 12),
                    _ActionRow(
                      iconAsset: _settingsDownAsset,
                      title: 'Export All Data',
                      description: 'Download complete health records',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _ActionRow(
                      iconAsset: _settingsShareAsset,
                      title: 'Share with Veterinarian',
                      description: 'Generate shareable report link',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'About',
                subtitle: 'App information and support',
                child: Column(
                  children: [
                    _SimpleRow(
                      label: 'Terms of Service',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _SimpleRow(
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _SimpleRow(
                      label: 'Help & Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onTap: (index) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.mainShell,
            arguments: {
              'role': role,
              'initialIndex': index,
            },
          );
        },
      ),
    );
  }
}

class _ProfileSelector extends StatelessWidget {
  const _ProfileSelector({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
          child: ClipOval(
            child: Image.network(avatarUrl, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2),
            ),
            child: Center(
              child: SvgPicture.asset(
                _settingsDownCircleAsset,
                width: 20,
                height: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.burgundy,
                        letterSpacing: -0.54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.burgundy,
                        fontSize: 14,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.label,
    required this.isOn,
    this.description,
    this.iconAsset,
  });

  final String label;
  final String? description;
  final bool isOn;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (iconAsset != null) ...[
                  SvgPicture.asset(iconAsset!, width: 16, height: 16),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.burgundy,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.31,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.burgundy,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          _TogglePill(isOn: isOn),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(_settingsGlobeAsset, width: 16, height: 16),
              const SizedBox(width: 8),
              Text(
                'Language',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.burgundy,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.31,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.pink,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Text(
                  'English',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.burgundy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                SvgPicture.asset(_settingsChevronAsset, width: 16, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteButton extends StatelessWidget {
  const _InviteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warningAmber,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            SvgPicture.asset(_settingsInviteAsset, width: 16, height: 16),
            const SizedBox(width: 6),
            Text(
              'Invite',
              style: AppTextStyles.body.copyWith(
                color: AppColors.burgundy,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareCircleItem extends StatelessWidget {
  const _CareCircleItem({
    required this.email,
    required this.roleLabel,
    required this.roleColor,
    required this.statusLabel,
    required this.statusColor,
  });

  final String email;
  final String roleLabel;
  final Color roleColor;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.burgundy,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.31,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Badge(
                      label: roleLabel,
                      backgroundColor: roleColor,
                      textColor: roleColor == const Color(0xFFFFECB7)
                          ? AppColors.burgundy
                          : AppColors.white,
                    ),
                    const SizedBox(width: 4),
                    _Badge(
                      label: statusLabel,
                      backgroundColor: statusColor,
                      textColor: AppColors.burgundy,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: SvgPicture.asset(
                _settingsTrashAsset,
                width: 16,
                height: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ConfigureRow extends StatelessWidget {
  const _ConfigureRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alert thresholds',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.burgundy,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.31,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customize BPM ranges for alerts',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.burgundy,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warningAmber,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(_settingsConfigureAsset,
                      width: 16, height: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Configure',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.burgundy,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(iconAsset, width: 16, height: 16),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.burgundy,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.31,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.burgundy,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SvgPicture.asset(_settingsRightAsset, width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.burgundy,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.31,
              ),
            ),
            SvgPicture.asset(_settingsRightAsset, width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({required this.isOn});

  final bool isOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.burgundy.withOpacity(0.2),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Align(
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 31,
          height: 31,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
