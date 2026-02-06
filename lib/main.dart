// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/app_routes.dart';
// import 'package:pet_circle/firebase_options.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/screens/auth/auth_screen.dart';
import 'package:pet_circle/screens/auth/role_selection_screen.dart';
import 'package:pet_circle/screens/auth/verify_email_screen.dart';
import 'package:pet_circle/screens/dashboard/owner_dashboard.dart';
import 'package:pet_circle/screens/dashboard/vet_dashboard.dart';
import 'package:pet_circle/screens/main_shell.dart';
import 'package:pet_circle/screens/measurement/measurement_screen.dart';
import 'package:pet_circle/screens/messages/messages_screen.dart';
import 'package:pet_circle/screens/onboarding/onboarding_flow.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_screen.dart';
import 'package:pet_circle/screens/settings/settings_screen.dart';
import 'package:pet_circle/screens/trends/trends_screen.dart';
import 'package:pet_circle/screens/welcome_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';

// Set to true when Firebase is fully configured
const bool kEnableFirebase = false;

/// Global locale notifier – updated from Settings language switcher.
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

/// Global dark-mode notifier – updated from Settings dark mode toggle.
final ValueNotifier<bool> appDarkMode = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Uncomment when Firebase is configured:
  // if (kEnableFirebase) {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // }
  
  runApp(const PetCircleApp());
}

class PetCircleApp extends StatelessWidget {
  const PetCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => ValueListenableBuilder<bool>(
        valueListenable: appDarkMode,
        builder: (context, isDark, _) => MaterialApp(
      title: 'Pet Circle',
      debugShowCheckedModeBanner: false,
      theme: isDark ? buildDarkTheme() : buildAppTheme(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('he'),
      ],
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.welcome:
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());

          case AppRoutes.auth:
            final role = settings.arguments as AppUserRole? ?? AppUserRole.owner;
            return MaterialPageRoute(
              builder: (_) => AuthScreen(role: role),
            );

          case AppRoutes.roleSelection:
            return MaterialPageRoute(
              builder: (_) => const RoleSelectionScreen(),
            );

          case AppRoutes.verifyEmail:
            return MaterialPageRoute(builder: (_) => const VerifyEmailScreen());

          case AppRoutes.onboarding:
            return MaterialPageRoute(builder: (_) => const OnboardingFlow());

          case AppRoutes.vetDashboard:
            return MaterialPageRoute(builder: (_) => const VetDashboard());

          case AppRoutes.ownerDashboard:
            return MaterialPageRoute(builder: (_) => const OwnerDashboard());

          case AppRoutes.dashboard:
            // Legacy route - redirect to main shell (owner)
            return MaterialPageRoute(
              builder: (_) => const MainShell(role: AppUserRole.owner),
            );

          case AppRoutes.mainShell:
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              final role = args['role'] as AppUserRole? ?? AppUserRole.owner;
              final initialIndex = args['initialIndex'] as int? ?? 0;
              return MaterialPageRoute(
                builder: (_) => MainShell(role: role, initialIndex: initialIndex),
              );
            }
            final role = args as AppUserRole? ?? AppUserRole.owner;
            return MaterialPageRoute(builder: (_) => MainShell(role: role));

          case AppRoutes.trends:
            return MaterialPageRoute(builder: (_) => const TrendsScreen());

          case AppRoutes.messages:
            return MaterialPageRoute(builder: (_) => const MessagesScreen());

          case AppRoutes.settings:
            AppUserRole role = AppUserRole.owner;
            if (settings.arguments is AppUserRole) {
              role = settings.arguments as AppUserRole;
            }
            return MaterialPageRoute(builder: (_) => SettingsScreen(role: role));

          case AppRoutes.petDetail:
            final pet = settings.arguments as Pet;
            return MaterialPageRoute(
              builder: (_) => PetDetailScreen(pet: pet),
            );

          case AppRoutes.measurement:
            return MaterialPageRoute(builder: (_) => const MeasurementScreen());

          default:
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
        }
      },
    ),
    ),
    );
  }
}
