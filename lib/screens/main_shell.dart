import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/screens/settings/settings_screen.dart';
import 'package:pet_circle/screens/dashboard/owner_dashboard.dart';
import 'package:pet_circle/screens/dashboard/vet_dashboard.dart';
import 'package:pet_circle/screens/measurement/measurement_screen.dart';
import 'package:pet_circle/screens/medication/medication_screen.dart'
    show MedicationScreen;
import 'package:pet_circle/screens/messages/messages_screen.dart'
    show NotificationsDrawer;
import 'package:pet_circle/screens/trends/trends_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/utils/responsive_utils.dart';
import 'package:pet_circle/widgets/app_header.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:pet_circle/widgets/bottom_nav_bar.dart';

/// Icon assets shared between BottomNavBar and NavigationRail.
const _navIconAssets = [
  'assets/figma/nav_home.svg',
  'assets/figma/nav_heartbeat.svg',
  'assets/figma/nav_heart.svg',
];

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
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      _selectedIndex = widget.initialIndex;
    }
  }

  void _onDestinationSelected(int index) {
    if (kIsWeb) {
      // Update the browser URL so the tab state is reflected in the address bar.
      context.go(AppRoutes.shell(widget.role, tab: index));
    } else {
      setState(() => _selectedIndex = index);
    }
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.offWhite,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(pets.length, (i) {
              final pet = pets[i];
              final isSelected = i == petStore.activePetIndex;
              return ListTile(
                leading: ClipOval(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child:
                        DogPhoto(endpoint: pet.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                title: Text(
                  pet.name,
                  style: AppTextStyles.body.copyWith(
                    color: c.chocolate,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  pet.breedAndAge,
                  style:
                      AppTextStyles.caption.copyWith(color: c.chocolate),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: c.lightBlue)
                    : null,
                onTap: () {
                  petStore.setActivePetIndex(i);
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
    final pet = petStore.activePet;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= kTabletBreakpoint;

    final homeScreen = widget.role == AppUserRole.vet
        ? const VetDashboard(showScaffold: false)
        : const OwnerDashboard(showScaffold: false);

    final body = Column(
      children: [
        // -- Persistent header --
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: AppHeader(
            userName: user?.name ?? '',
            userImageUrl: user?.avatarUrl ?? '',
            petName: _selectedIndex == 0 ? null : pet?.name,
            petImageUrl: _selectedIndex == 0 ? null : pet?.imageUrl,
            onPetSelectorTap:
                _selectedIndex == 0 || petStore.ownerPets.length <= 1
                    ? null
                    : _showPetSwitcher,
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
        // -- Tab content --
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              homeScreen,
              const TrendsScreen(showScaffold: false),
              const MeasurementScreen(showScaffold: false),
              const MedicationScreen(showScaffold: false),
            ],
          ),
        ),
      ],
    );

    if (!isWide) {
      return Scaffold(
        backgroundColor: c.white,
        body: SafeArea(child: body),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onDestinationSelected,
        ),
      );
    }

    // Tablet / Desktop: NavigationRail in a Row
    return Scaffold(
      backgroundColor: c.white,
      body: SafeArea(
        child: Row(
          children: [
            _buildNavigationRail(context, c, screenWidth),
            // Vertical divider between rail and content
            VerticalDivider(thickness: 1, width: 1, color: c.chocolate),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRail(
    BuildContext context,
    AppColorsTheme c,
    double screenWidth,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final showLabels = screenWidth >= kDesktopBreakpoint;

    final labels = [
      l10n.navHome,
      l10n.navTrends,
      l10n.navMeasure,
      l10n.navMedication,
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        navigationRailTheme: NavigationRailThemeData(
          selectedLabelTextStyle:
              AppTextStyles.caption.copyWith(color: c.chocolate),
          unselectedLabelTextStyle: AppTextStyles.caption
              .copyWith(color: c.chocolate.withValues(alpha: 0.5)),
        ),
      ),
      child: NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      backgroundColor: c.white,
      labelType: showLabels
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.none,
      indicatorColor: c.offWhite,
      selectedIconTheme: IconThemeData(color: c.chocolate),
      unselectedIconTheme: IconThemeData(color: c.chocolate, opacity: 0.3),
      destinations: List.generate(4, (i) {
        final label = labels[i];
        // First 3 items use SVG assets, 4th uses a Material icon.
        if (i < _navIconAssets.length) {
          return NavigationRailDestination(
            icon: Opacity(
              opacity: 0.3,
              child: SvgPicture.asset(
                _navIconAssets[i],
                width: 28,
                height: 28,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              _navIconAssets[i],
              width: 28,
              height: 28,
            ),
            label: Text(label),
          );
        }
        // Medication icon (Material)
        return NavigationRailDestination(
          icon: Opacity(
            opacity: 0.3,
            child: Icon(Icons.medication_outlined, size: 28, color: c.chocolate),
          ),
          selectedIcon:
              Icon(Icons.medication_outlined, size: 28, color: c.chocolate),
          label: Text(label),
        );
      }),
    ),
    );
  }
}
