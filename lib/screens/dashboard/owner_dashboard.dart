import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/data/mock_data.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/theme/app_assets.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';
import 'package:pet_circle/widgets/round_icon_button.dart';
import 'package:pet_circle/widgets/status_badge.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final pets = MockData.hilaPets;
    final user = MockData.currentOwnerUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.onboarding),
        backgroundColor: AppColors.burgundy,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text(
          'Add Pet',
          style: AppTextStyles.body.copyWith(color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(userName: user.name, avatarUrl: user.avatarUrl),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'My Pets',
                  style: AppTextStyles.heading2.copyWith(color: AppColors.burgundy),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pets.length} pet${pets.length > 1 ? 's' : ''} in your care',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.lg),
                ...pets.map(
                  (pet) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _OwnerPetCard(
                      data: pet,
                      onMeasure: () => Navigator.of(context).pushNamed(
                        AppRoutes.measurement,
                        arguments: pet,
                      ),
                      onEdit: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit profile coming soon')),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _QuickActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.userName, required this.avatarUrl});

  final String userName;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.pink,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(AppAssets.appLogo, width: 48, height: 48),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello,',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
                Text(
                  userName,
                  style: AppTextStyles.heading3.copyWith(color: AppColors.burgundy),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            RoundIconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.burgundy),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(avatarUrl),
            ),
          ],
        ),
      ],
    );
  }
}

class _OwnerPetCard extends StatelessWidget {
  const _OwnerPetCard({
    required this.data,
    required this.onMeasure,
    required this.onEdit,
  });

  final Pet data;
  final VoidCallback onMeasure;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      radius: BorderRadius.circular(20),
      child: Column(
        children: [
          // Pet image with status
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x33E8B4B8), Color(0x00000000)],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: DogPhoto(endpoint: data.imageUrl),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: StatusBadge(
                  label: data.statusLabel,
                  color: Color(data.statusColorHex),
                ),
              ),
              // Edit button
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.burgundy),
                  ),
                ),
              ),
            ],
          ),
          // Pet info
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(data.breedAndAge, style: AppTextStyles.bodyMuted),
                      ],
                    ),
                    // Latest BPM display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Color(data.statusColorHex),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data.latestMeasurement.bpm}',
                                style: AppTextStyles.heading3
                                    .copyWith(color: AppColors.textPrimary),
                              ),
                              Text('BPM', style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Last measured: ${data.latestMeasurement.recordedAtLabel}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                // Measure Now button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onMeasure,
                    icon: const Icon(Icons.favorite_border, size: 22),
                    label: const Text('Measure Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.burgundy,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: AppTextStyles.button.copyWith(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0x26E8B4B8), height: 1),
                const SizedBox(height: 12),
                // Care circle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.group, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text('Care Circle', style: AppTextStyles.caption),
                      ],
                    ),
                    _AvatarStack(avatars: data.careCircle),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.avatars});

  final List<CareCircleMember> avatars;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 32 + (avatars.length - 1) * 20,
      child: Stack(
        children: [
          for (var i = 0; i < avatars.length; i++)
            Positioned(
              left: i * 20.0,
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.offWhite, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(avatars[i].avatarUrl, fit: BoxFit.cover),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.heading3.copyWith(color: AppColors.burgundy),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.history,
                label: 'History',
                color: AppColors.accentBlue,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionCard(
                icon: Icons.person_add_outlined,
                label: 'Invite',
                color: AppColors.successGreen,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionCard(
                icon: Icons.settings_outlined,
                label: 'Settings',
                color: AppColors.warningAmber,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicCard(
        radius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
