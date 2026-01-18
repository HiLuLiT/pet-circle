import 'package:flutter/material.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/screens/dashboard/owner_dashboard.dart';
import 'package:pet_circle/screens/dashboard/vet_dashboard.dart';
import 'package:pet_circle/screens/measurement/measurement_screen.dart';
import 'package:pet_circle/screens/messages/messages_screen.dart';
import 'package:pet_circle/screens/trends/trends_screen.dart';
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
    final homeScreen = widget.role == AppUserRole.vet
        ? const VetDashboard(showScaffold: false)
        : const OwnerDashboard(showScaffold: false);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          homeScreen,
          const TrendsScreen(showScaffold: false),
          const MeasurementScreen(showScaffold: false),
          const MessagesScreen(showScaffold: false),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
