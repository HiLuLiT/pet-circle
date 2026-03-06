import 'package:flutter/material.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/screens/settings/settings_screen.dart';
import 'package:pet_circle/screens/dashboard/owner_dashboard.dart';
import 'package:pet_circle/screens/dashboard/vet_dashboard.dart';
import 'package:pet_circle/screens/measurement/measurement_screen.dart';
import 'package:pet_circle/screens/messages/messages_screen.dart' show MessagesScreen, NotificationsDrawer;
import 'package:pet_circle/screens/trends/trends_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/app_header.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:pet_circle/widgets/bottom_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.role,
    this.initialIndex = 0,
  });

  final AppUserRole role;
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedIndex;
  int _activePetIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _showPetSwitcher() {
    final c = AppColorsTheme.of(context);
    final pets = petStore.ownerPets;
    if (pets.length <= 1) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: c.offWhite, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ...List.generate(pets.length, (i) {
              final pet = pets[i];
              final isSelected = i == _activePetIndex;
              return ListTile(
                leading: ClipOval(
                  child: SizedBox(
                    width: 36, height: 36,
                    child: DogPhoto(endpoint: pet.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                title: Text(pet.name, style: AppTextStyles.body.copyWith(
                  color: c.chocolate,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                )),
                subtitle: Text(pet.breedAndAge, style: AppTextStyles.caption.copyWith(color: c.chocolate)),
                trailing: isSelected ? Icon(Icons.check_circle, color: c.lightBlue) : null,
                onTap: () {
                  setState(() => _activePetIndex = i);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    final user = userStore.currentUser;
    final pets = petStore.ownerPets;
    final petIndex = _activePetIndex.clamp(0, pets.isEmpty ? 0 : pets.length - 1);
    final pet = pets.isNotEmpty ? pets[petIndex] : null;

    final homeScreen = widget.role == AppUserRole.vet
        ? const VetDashboard(showScaffold: false)
        : const OwnerDashboard(showScaffold: false);

    return Scaffold(
      backgroundColor: c.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Persistent header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: AppHeader(
                userName: user?.name ?? '',
                userImageUrl: user?.avatarUrl ?? '',
                petName: pet?.name,
                petImageUrl: pet?.imageUrl,
                onPetSelectorTap: pets.length > 1 ? _showPetSwitcher : null,
                onAvatarTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => SettingsDrawer(role: widget.role),
                ),
                onNotificationTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const NotificationsDrawer(),
                ),
              ),
            ),
            // ── Tab content ──
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  homeScreen,
                  const TrendsScreen(showScaffold: false),
                  const MeasurementScreen(showScaffold: false),
                  const MessagesScreen(showScaffold: false),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
