import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/firebase_options.dart';
import 'package:pet_circle/data/mock_data.dart';
import 'package:pet_circle/models/app_notification.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/providers/auth_provider.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/note_store.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/services/abstract_reminder_service.dart';
import 'package:pet_circle/services/deep_link_service.dart';
import 'package:pet_circle/services/reminder_service.dart';
import 'package:pet_circle/services/web_reminder_service.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/utils/error_handler.dart';

// Set to true when Firebase is fully configured
const bool kEnableFirebase = true;

/// Global locale notifier -- updated from Settings language switcher.
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

/// Global dark-mode notifier -- updated from Settings dark mode toggle.
final ValueNotifier<bool> appDarkMode = ValueNotifier(false);

/// Application-wide GoRouter instance.
late final GoRouter router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wire up global Flutter / platform error handlers before anything else.
  AppErrorHandler.instance.init();

  // Disable runtime font fetching so Inter is only loaded from bundled assets.
  // Falls back gracefully to the system font when the TTF is not bundled.
  GoogleFonts.config.allowRuntimeFetching = false;

  if (kEnableFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    authProvider.init();
  }

  final AbstractReminderService reminderService =
      kIsWeb ? WebReminderService() : ReminderService.instance;
  await reminderService.init();

  if (!kEnableFirebase) {
    _seedMockStores();
  }

  router = buildRouter();

  // Initialise deep links *after* the router is created so that native
  // incoming URIs can be forwarded to GoRouter.  On web the `/invite` route
  // is handled directly by GoRouter from the browser URL bar.
  if (kEnableFirebase) {
    await deepLinkService.init(router: router);
  }

  runApp(const PetCircleApp());
}

void _seedMockStores() {
  userStore.seed(MockData.currentOwnerUser);

  petStore.seed(
    ownerPets: MockData.hilaPets,
    clinicPets: MockData.vetClinicPets,
  );

  final princessId = petStore.getPetByName('Princess')?.id ?? 'mock-princess';
  final maxId = petStore.getPetByName('Max')?.id ?? 'mock-max';

  measurementStore.seed({
    princessId: MockData.princessMeasurements,
  });

  noteStore.seed({
    princessId: MockData.princessNotes,
    maxId: MockData.maxNotes,
  });

  medicationStore.seed({
    princessId: [
      Medication(
        id: 'med-1',
        name: 'Furosemide',
        dosage: '12.5mg',
        frequency: 'Twice daily',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Medication(
        id: 'med-2',
        name: 'Pimobendan',
        dosage: '2.5mg',
        frequency: 'Twice daily',
        startDate: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ],
  });

  notificationStore.seed([
    AppNotification(
      id: 'notif-1',
      title: 'Measurement reminder',
      body: "It's time to measure Princess's sleeping respiratory rate.",
      type: NotificationType.measurement,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      petName: 'Princess',
    ),
    AppNotification(
      id: 'notif-2',
      title: 'Medication due',
      body: 'Furosemide 12.5mg is due for Princess.',
      type: NotificationType.medication,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      petName: 'Princess',
    ),
    AppNotification(
      id: 'notif-3',
      title: 'New care circle member',
      body: 'Dr. Smith has joined Princess\'s care circle.',
      type: NotificationType.careCircle,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      petName: 'Princess',
    ),
    AppNotification(
      id: 'notif-4',
      title: 'Weekly report ready',
      body: "Princess's weekly SRR report is available for review.",
      type: NotificationType.report,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      petName: 'Princess',
    ),
  ]);
}

class PetCircleApp extends StatelessWidget {
  const PetCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => ValueListenableBuilder<bool>(
        valueListenable: appDarkMode,
        builder: (context, isDark, _) => MaterialApp.router(
      routerConfig: router,
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
    ),
    ),
    );
  }
}
