import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/firebase_options.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/screens/auth/auth_screen.dart';
import 'package:pet_circle/screens/auth/verify_email_screen.dart';
import 'package:pet_circle/screens/dashboard/owner_dashboard.dart';
import 'package:pet_circle/screens/dashboard/vet_dashboard.dart';
import 'package:pet_circle/screens/measurement/measurement_screen.dart';
import 'package:pet_circle/screens/onboarding/onboarding_flow.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_screen.dart';
import 'package:pet_circle/screens/welcome_screen.dart';
import 'package:pet_circle/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const PetCircleApp());
}

class PetCircleApp extends StatelessWidget {
  const PetCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Circle',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
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

          case AppRoutes.verifyEmail:
            return MaterialPageRoute(builder: (_) => const VerifyEmailScreen());

          case AppRoutes.onboarding:
            return MaterialPageRoute(builder: (_) => const OnboardingFlow());

          case AppRoutes.vetDashboard:
            return MaterialPageRoute(builder: (_) => const VetDashboard());

          case AppRoutes.ownerDashboard:
            return MaterialPageRoute(builder: (_) => const OwnerDashboard());

          case AppRoutes.dashboard:
            // Legacy route - redirect to owner dashboard
            return MaterialPageRoute(builder: (_) => const OwnerDashboard());

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
    );
  }
}
