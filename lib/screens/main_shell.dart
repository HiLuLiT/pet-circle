import 'package:flutter/material.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/data/mock_data.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/screens/dashboard/owner_dashboard.dart';
import 'package:pet_circle/screens/dashboard/vet_dashboard.dart';
import 'package:pet_circle/screens/measurement/measurement_screen.dart';
import 'package:pet_circle/screens/messages/messages_screen.dart';
import 'package:pet_circle/screens/trends/trends_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/app_header.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.role == AppUserRole.vet
        ? MockData.currentVetUser
        : MockData.currentOwnerUser;

    final pet = MockData.hilaPets.isNotEmpty ? MockData.hilaPets.first : null;

    final homeScreen = widget.role == AppUserRole.vet
        ? const VetDashboard(showScaffold: false)
        : const OwnerDashboard(showScaffold: false);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Persistent header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: AppHeader(
                userName: user.name,
                userImageUrl: user.avatarUrl,
                petName: pet?.name,
                petImageUrl: pet?.imageUrl,
                onAvatarTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.settings,
                  arguments: widget.role,
                ),
                onNotificationTap: () =>
                    setState(() => _selectedIndex = 3),
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
