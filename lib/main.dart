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
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/services/abstract_push_notification_service.dart';
import 'package:pet_circle/services/abstract_reminder_service.dart';
import 'package:pet_circle/services/deep_link_service.dart';
import 'package:pet_circle/services/push_notification_service.dart';
import 'package:pet_circle/services/reminder_service.dart';
import 'package:pet_circle/services/web_push_notification_service.dart';
import 'package:pet_circle/services/web_reminder_service.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/utils/error_handler.dart';
import 'package:pet_circle/config/app_config.dart';

/// Application-wide GoRouter instance.
late final GoRouter router;

/// Application-wide push notification service instance.
late final AbstractPushNotificationService pushService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wire up global Flutter / platform error handlers before anything else.
  AppErrorHandler.instance.init();

  // Allow runtime fetching so google_fonts can download Instrument Sans.
  // TODO: bundle static Instrument Sans font files to avoid network dependency.
  GoogleFonts.config.allowRuntimeFetching = true;

  if (kEnableFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    authProvider.init();
  }

  final AbstractReminderService reminderService =
      kIsWeb ? WebReminderService() : ReminderService.instance;
  await reminderService.init();

  pushService =
      kIsWeb ? WebPushNotificationService() : PushNotificationService.instance;
  if (kEnableFirebase) {
    await pushService.init();
  }

  // Wire the push toggle callback so disabling notifications cancels
  // all reminders and unregisters the FCM token, and re-enabling restores them.
  settingsStore.onPushToggleChanged = (enabled) async {
    final uid = authProvider.firebaseUser?.uid;
    if (!enabled) {
      await reminderService.cancelAllReminders();
      if (uid != null) await pushService.unregisterToken(uid);
    } else {
      if (uid != null) await pushService.registerToken(uid);
      // Reschedule measurement reminders with current settings.
      if (settingsStore.measurementRemindersEnabled) {
        await reminderService.scheduleMeasurementReminder(
          days: settingsStore.measurementReminderDays,
          hour: settingsStore.measurementReminderHour,
          minute: settingsStore.measurementReminderMinute,
        );
      }
    }
  };

  // Wire measurement reminder settings changes to reschedule notifications.
  settingsStore.onMeasurementReminderChanged = ({
    required List<int> days,
    required int hour,
    required int minute,
    required bool enabled,
  }) async {
    await reminderService.cancelMeasurementReminder();
    if (enabled) {
      await reminderService.scheduleMeasurementReminder(
        days: days,
        hour: hour,
        minute: minute,
      );
    }
  };

  if (!kEnableFirebase) {
    _seedMockStores();
  }

  router = buildRouter();

  // Wire push notification handlers after the router is created.
  if (kEnableFirebase) {
    pushService.setupForegroundHandler();
    pushService.setupNotificationTapHandler(router.go);
  }

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

class PetCircleApp extends StatefulWidget {
  const PetCircleApp({super.key});

  @override
  State<PetCircleApp> createState() => _PetCircleAppState();
}

class _PetCircleAppState extends State<PetCircleApp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _overlayController;
  bool _isDark = false;
  bool _themeSwapped = false;
  Color _overlayColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _isDark = appDarkMode.value;
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _overlayController.addListener(_swapThemeAtMidpoint);
    _overlayController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _overlayController.reset();
        _themeSwapped = false;
      }
    });
    appDarkMode.addListener(_onDarkModeToggled);
  }

  void _onDarkModeToggled() {
    _themeSwapped = false;
    _overlayColor = appDarkMode.value ? Colors.black : Colors.white;
    _overlayController.forward(from: 0.0);
  }

  void _swapThemeAtMidpoint() {
    if (_overlayController.value >= 0.5 && !_themeSwapped) {
      _themeSwapped = true;
      setState(() => _isDark = appDarkMode.value);
    }
  }

  @override
  void dispose() {
    appDarkMode.removeListener(_onDarkModeToggled);
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          ValueListenableBuilder<Locale>(
            valueListenable: appLocale,
            builder: (context, locale, _) => MaterialApp.router(
              routerConfig: router,
              title: 'Pet Circle',
              debugShowCheckedModeBanner: false,
              theme: _isDark ? buildDarkTheme() : buildAppTheme(),
              themeAnimationDuration: Duration.zero,
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
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _overlayController,
                builder: (context, _) {
                  final v = _overlayController.value;
                  final fade = v <= 0.5 ? v * 2 : (1.0 - v) * 2;
                  return ColoredBox(
                    color: _overlayColor.withValues(alpha: fade * 0.35),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
