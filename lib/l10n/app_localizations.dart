import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pet Circle'**
  String get appTitle;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @hiUser.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}!'**
  String hiUser(String name);

  /// No description provided for @imAVeterinarian.
  ///
  /// In en, this message translates to:
  /// **'I\'m a veterinarian'**
  String get imAVeterinarian;

  /// No description provided for @imAPetOwner.
  ///
  /// In en, this message translates to:
  /// **'I\'m a pet owner'**
  String get imAPetOwner;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @petName.
  ///
  /// In en, this message translates to:
  /// **'Pet\'s Name'**
  String get petName;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'Age (years)'**
  String get ageYears;

  /// No description provided for @photoUrl.
  ///
  /// In en, this message translates to:
  /// **'Photo URL (Optional)'**
  String get photoUrl;

  /// No description provided for @medicalInformation.
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
  String get medicalInformation;

  /// No description provided for @diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosis;

  /// No description provided for @diagnosisOptional.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis (Optional)'**
  String get diagnosisOptional;

  /// No description provided for @selectDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Select diagnosis'**
  String get selectDiagnosis;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @targetRespiratoryRate.
  ///
  /// In en, this message translates to:
  /// **'Set Target Respiratory Rate'**
  String get targetRespiratoryRate;

  /// No description provided for @targetRateDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ll alert you when measurements exceed this threshold.'**
  String get targetRateDescription;

  /// No description provided for @normalRange.
  ///
  /// In en, this message translates to:
  /// **'Normal Range'**
  String get normalRange;

  /// No description provided for @normalRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'30 BPM (Standard)'**
  String get normalRangeLabel;

  /// No description provided for @standardRateDescription.
  ///
  /// In en, this message translates to:
  /// **'Recommended for most dogs'**
  String get standardRateDescription;

  /// No description provided for @elevatedRange.
  ///
  /// In en, this message translates to:
  /// **'Elevated Range'**
  String get elevatedRange;

  /// No description provided for @elevatedRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'35 BPM'**
  String get elevatedRangeLabel;

  /// No description provided for @elevatedRateDescription.
  ///
  /// In en, this message translates to:
  /// **'For pets with mild conditions'**
  String get elevatedRateDescription;

  /// No description provided for @customRate.
  ///
  /// In en, this message translates to:
  /// **'Custom Rate'**
  String get customRate;

  /// No description provided for @enterBpm.
  ///
  /// In en, this message translates to:
  /// **'Enter BPM'**
  String get enterBpm;

  /// No description provided for @careCircle.
  ///
  /// In en, this message translates to:
  /// **'Care Circle'**
  String get careCircle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @addToCareCircle.
  ///
  /// In en, this message translates to:
  /// **'Add to pet circle'**
  String get addToCareCircle;

  /// No description provided for @addAnotherPetCircle.
  ///
  /// In en, this message translates to:
  /// **'+ Add another pet circle'**
  String get addAnotherPetCircle;

  /// No description provided for @myPets.
  ///
  /// In en, this message translates to:
  /// **'My pets'**
  String get myPets;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @measure.
  ///
  /// In en, this message translates to:
  /// **'Measure'**
  String get measure;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @managePreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage your PetBreath preferences'**
  String get managePreferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @customizeLookAndFeel.
  ///
  /// In en, this message translates to:
  /// **'Customize the look and feel'**
  String get customizeLookAndFeel;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hebrew.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get hebrew;

  /// No description provided for @manageCaregivers.
  ///
  /// In en, this message translates to:
  /// **'Manage caregivers, vets, and pet sitters'**
  String get manageCaregivers;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageAlerts.
  ///
  /// In en, this message translates to:
  /// **'Manage alerts and reminders'**
  String get manageAlerts;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications for measurements'**
  String get pushNotificationsDesc;

  /// No description provided for @emergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Emergency alerts'**
  String get emergencyAlerts;

  /// No description provided for @emergencyAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Critical alerts when SRR exceeds thresholds'**
  String get emergencyAlertsDesc;

  /// No description provided for @measurementSettings.
  ///
  /// In en, this message translates to:
  /// **'Measurement settings'**
  String get measurementSettings;

  /// No description provided for @configureModes.
  ///
  /// In en, this message translates to:
  /// **'Configure measurement modes and thresholds'**
  String get configureModes;

  /// No description provided for @visionRRCameraMode.
  ///
  /// In en, this message translates to:
  /// **'VisionRR camera mode'**
  String get visionRRCameraMode;

  /// No description provided for @visionRRDesc.
  ///
  /// In en, this message translates to:
  /// **'AI-powered camera-based measurement'**
  String get visionRRDesc;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @alertThresholds.
  ///
  /// In en, this message translates to:
  /// **'Alert thresholds'**
  String get alertThresholds;

  /// No description provided for @customizeBpmRanges.
  ///
  /// In en, this message translates to:
  /// **'Customize BPM ranges for alerts'**
  String get customizeBpmRanges;

  /// No description provided for @configure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configure;

  /// No description provided for @dataAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataAndPrivacy;

  /// No description provided for @exportAndManage.
  ///
  /// In en, this message translates to:
  /// **'Export data and manage privacy settings'**
  String get exportAndManage;

  /// No description provided for @autoExportData.
  ///
  /// In en, this message translates to:
  /// **'Auto-Export Data'**
  String get autoExportData;

  /// No description provided for @autoExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Weekly CSV export to email'**
  String get autoExportDesc;

  /// No description provided for @exportAllData.
  ///
  /// In en, this message translates to:
  /// **'Export All Data'**
  String get exportAllData;

  /// No description provided for @exportAllDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Download complete health records'**
  String get exportAllDataDesc;

  /// No description provided for @shareWithVet.
  ///
  /// In en, this message translates to:
  /// **'Share with Veterinarian'**
  String get shareWithVet;

  /// No description provided for @shareWithVetDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate shareable report link'**
  String get shareWithVetDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appInfoAndSupport.
  ///
  /// In en, this message translates to:
  /// **'App information and support'**
  String get appInfoAndSupport;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @manualMode.
  ///
  /// In en, this message translates to:
  /// **'Manual Mode'**
  String get manualMode;

  /// No description provided for @visionRRMode.
  ///
  /// In en, this message translates to:
  /// **'VisionRR Mode'**
  String get visionRRMode;

  /// No description provided for @timerDuration.
  ///
  /// In en, this message translates to:
  /// **'Timer Duration'**
  String get timerDuration;

  /// No description provided for @tapToBegin.
  ///
  /// In en, this message translates to:
  /// **'Tap to begin'**
  String get tapToBegin;

  /// No description provided for @tapToStop.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop'**
  String get tapToStop;

  /// No description provided for @measurementComplete.
  ///
  /// In en, this message translates to:
  /// **'Measurement Complete'**
  String get measurementComplete;

  /// No description provided for @breathsPerMinute.
  ///
  /// In en, this message translates to:
  /// **'breaths per minute'**
  String get breathsPerMinute;

  /// No description provided for @breathCountMessage.
  ///
  /// In en, this message translates to:
  /// **'You counted {taps} breaths in {seconds} seconds.'**
  String breathCountMessage(int taps, int seconds);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @healthTrends.
  ///
  /// In en, this message translates to:
  /// **'Health Trends'**
  String get healthTrends;

  /// No description provided for @measurementHistory.
  ///
  /// In en, this message translates to:
  /// **'Measurement History'**
  String get measurementHistory;

  /// No description provided for @medicationManagement.
  ///
  /// In en, this message translates to:
  /// **'Medication Management'**
  String get medicationManagement;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @exportMedicationLog.
  ///
  /// In en, this message translates to:
  /// **'Export Medication Log'**
  String get exportMedicationLog;

  /// No description provided for @messagesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Messages coming soon'**
  String get messagesComingSoon;

  /// No description provided for @trendsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Trends coming soon'**
  String get trendsComingSoon;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @veterinarian.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian'**
  String get veterinarian;

  /// No description provided for @caregiver.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get caregiver;

  /// No description provided for @viewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get viewer;

  /// No description provided for @normalThresholdBpm.
  ///
  /// In en, this message translates to:
  /// **'Normal Threshold (BPM)'**
  String get normalThresholdBpm;

  /// No description provided for @alertThresholdBpm.
  ///
  /// In en, this message translates to:
  /// **'Alert Threshold (BPM)'**
  String get alertThresholdBpm;

  /// No description provided for @thresholdsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Thresholds updated'**
  String get thresholdsUpdated;

  /// No description provided for @configureAlertThresholds.
  ///
  /// In en, this message translates to:
  /// **'Configure Alert Thresholds'**
  String get configureAlertThresholds;

  /// No description provided for @configureAlertThresholdsDesc.
  ///
  /// In en, this message translates to:
  /// **'Set custom BPM ranges for your pet\'s respiratory rate alerts.'**
  String get configureAlertThresholdsDesc;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @signingUpAs.
  ///
  /// In en, this message translates to:
  /// **'Signing up as {roleLabel}'**
  String signingUpAs(String roleLabel);

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}'**
  String passwordResetSent(String email);

  /// No description provided for @pleaseEnterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address first'**
  String get pleaseEnterEmailFirst;

  /// No description provided for @petOwner.
  ///
  /// In en, this message translates to:
  /// **'Pet Owner'**
  String get petOwner;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @verificationLinkSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to'**
  String get verificationLinkSentTo;

  /// No description provided for @clickLinkToVerify.
  ///
  /// In en, this message translates to:
  /// **'Click the link to verify your account.'**
  String get clickLinkToVerify;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// No description provided for @resendInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendInSeconds(int seconds);

  /// No description provided for @iveVerifiedMyEmail.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get iveVerifiedMyEmail;

  /// No description provided for @useDifferentAccount.
  ///
  /// In en, this message translates to:
  /// **'Use a different account'**
  String get useDifferentAccount;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get verificationEmailSent;

  /// No description provided for @failedToSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send email'**
  String get failedToSendEmail;

  /// No description provided for @bpm.
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get bpm;

  /// No description provided for @clinicOverview.
  ///
  /// In en, this message translates to:
  /// **'Clinic Overview'**
  String get clinicOverview;

  /// No description provided for @patientsInYourCare.
  ///
  /// In en, this message translates to:
  /// **'{count} patients in your care'**
  String patientsInYourCare(int count);

  /// No description provided for @normalStatus.
  ///
  /// In en, this message translates to:
  /// **'Normal Status'**
  String get normalStatus;

  /// No description provided for @needAttention.
  ///
  /// In en, this message translates to:
  /// **'Need Attention'**
  String get needAttention;

  /// No description provided for @measurementsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Measurements This Week'**
  String get measurementsThisWeek;

  /// No description provided for @viewOnly.
  ///
  /// In en, this message translates to:
  /// **'View Only'**
  String get viewOnly;

  /// No description provided for @ownerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner: {name}'**
  String ownerLabel(String name);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @setupPetProfile.
  ///
  /// In en, this message translates to:
  /// **'Setup pet profile'**
  String get setupPetProfile;

  /// No description provided for @tellUsAboutYourPet.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your pet'**
  String get tellUsAboutYourPet;

  /// No description provided for @medicalInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'This helps us provide more accurate monitoring recommendations.'**
  String get medicalInfoDescription;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note:'**
  String get note;

  /// No description provided for @diagnosisNote.
  ///
  /// In en, this message translates to:
  /// **'This information is used to set appropriate monitoring thresholds and is shared only with your care circle.'**
  String get diagnosisNote;

  /// No description provided for @inviteYourCareCircle.
  ///
  /// In en, this message translates to:
  /// **'Invite Your Care Circle'**
  String get inviteYourCareCircle;

  /// No description provided for @inviteCareCircleDescription.
  ///
  /// In en, this message translates to:
  /// **'Invite family members, pet sitters, and veterinarians to collaborate.'**
  String get inviteCareCircleDescription;

  /// No description provided for @invitationSentTo.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent to {email} as {role}'**
  String invitationSentTo(String email, String role);

  /// No description provided for @pleaseEnterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get pleaseEnterEmailAddress;

  /// No description provided for @duration15s.
  ///
  /// In en, this message translates to:
  /// **'15s'**
  String get duration15s;

  /// No description provided for @duration30s.
  ///
  /// In en, this message translates to:
  /// **'30s'**
  String get duration30s;

  /// No description provided for @duration60s.
  ///
  /// In en, this message translates to:
  /// **'60s'**
  String get duration60s;

  /// No description provided for @visionRRModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your camera to detect subtle chest motion while your pet sleeps. This mode is hands-free and designed for accurate SRR tracking.'**
  String get visionRRModeDescription;

  /// No description provided for @measureRespiratoryRate.
  ///
  /// In en, this message translates to:
  /// **'Measure respiratory rate'**
  String get measureRespiratoryRate;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String unreadNotifications(int count);

  /// No description provided for @elevatedRespiratoryRate.
  ///
  /// In en, this message translates to:
  /// **'Elevated Respiratory Rate'**
  String get elevatedRespiratoryRate;

  /// No description provided for @medicationDue.
  ///
  /// In en, this message translates to:
  /// **'Medication Due: {name}'**
  String medicationDue(String name);

  /// No description provided for @careCircleInvitationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Care Circle Invitation Accepted'**
  String get careCircleInvitationAccepted;

  /// No description provided for @weeklyHealthReportReady.
  ///
  /// In en, this message translates to:
  /// **'Weekly Health Report Ready'**
  String get weeklyHealthReportReady;

  /// No description provided for @measurementReminder.
  ///
  /// In en, this message translates to:
  /// **'Measurement Reminder'**
  String get measurementReminder;

  /// No description provided for @careCircleInvitationPending.
  ///
  /// In en, this message translates to:
  /// **'Care Circle Invitation Pending'**
  String get careCircleInvitationPending;

  /// No description provided for @autoExportComplete.
  ///
  /// In en, this message translates to:
  /// **'Auto-Export Complete'**
  String get autoExportComplete;

  /// No description provided for @averageSrr.
  ///
  /// In en, this message translates to:
  /// **'Average SRR'**
  String get averageSrr;

  /// No description provided for @sevenDayTrend.
  ///
  /// In en, this message translates to:
  /// **'7-Day Trend'**
  String get sevenDayTrend;

  /// No description provided for @bpmChange.
  ///
  /// In en, this message translates to:
  /// **'BPM change'**
  String get bpmChange;

  /// No description provided for @activeTreatments.
  ///
  /// In en, this message translates to:
  /// **'Active treatments'**
  String get activeTreatments;

  /// No description provided for @srrOverTime.
  ///
  /// In en, this message translates to:
  /// **'Sleeping Respiratory Rate (SRR) Over Time'**
  String get srrOverTime;

  /// No description provided for @medicationTimeline.
  ///
  /// In en, this message translates to:
  /// **'Medication Timeline'**
  String get medicationTimeline;

  /// No description provided for @noMedicationsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No Medications Recorded'**
  String get noMedicationsRecorded;

  /// No description provided for @clinicalRecordInformation.
  ///
  /// In en, this message translates to:
  /// **'Clinical Record Information'**
  String get clinicalRecordInformation;

  /// No description provided for @addNewMedication.
  ///
  /// In en, this message translates to:
  /// **'Add New Medication'**
  String get addNewMedication;

  /// No description provided for @medicationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Medication Name *'**
  String get medicationNameRequired;

  /// No description provided for @dosageRequired.
  ///
  /// In en, this message translates to:
  /// **'Dosage *'**
  String get dosageRequired;

  /// No description provided for @frequencyRequired.
  ///
  /// In en, this message translates to:
  /// **'Frequency *'**
  String get frequencyRequired;

  /// No description provided for @startDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Start Date *'**
  String get startDateRequired;

  /// No description provided for @endDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End Date (Optional)'**
  String get endDateOptional;

  /// No description provided for @prescribedBy.
  ///
  /// In en, this message translates to:
  /// **'Prescribed By'**
  String get prescribedBy;

  /// No description provided for @purposeCondition.
  ///
  /// In en, this message translates to:
  /// **'Purpose / Condition'**
  String get purposeCondition;

  /// No description provided for @medicationReminders.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminders'**
  String get medicationReminders;

  /// No description provided for @medicationRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Notify care circle when doses are due'**
  String get medicationRemindersDesc;

  /// No description provided for @csvPreview.
  ///
  /// In en, this message translates to:
  /// **'CSV Preview:'**
  String get csvPreview;

  /// No description provided for @downloadCsv.
  ///
  /// In en, this message translates to:
  /// **'Download CSV'**
  String get downloadCsv;

  /// No description provided for @medicationLogExported.
  ///
  /// In en, this message translates to:
  /// **'Medication log exported successfully'**
  String get medicationLogExported;

  /// No description provided for @exportLabel.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportLabel;

  /// No description provided for @last24Hours.
  ///
  /// In en, this message translates to:
  /// **'Last 24 hours'**
  String get last24Hours;

  /// No description provided for @last3Days.
  ///
  /// In en, this message translates to:
  /// **'Last 3 days'**
  String get last3Days;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get last90Days;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get customRange;

  /// No description provided for @range.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get range;

  /// No description provided for @minMax.
  ///
  /// In en, this message translates to:
  /// **'Min-Max'**
  String get minMax;

  /// No description provided for @trend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @latestReading.
  ///
  /// In en, this message translates to:
  /// **'Latest Reading'**
  String get latestReading;

  /// No description provided for @lastMeasured.
  ///
  /// In en, this message translates to:
  /// **'Last Measured'**
  String get lastMeasured;

  /// No description provided for @viewGraph.
  ///
  /// In en, this message translates to:
  /// **'View Graph'**
  String get viewGraph;

  /// No description provided for @clinicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Clinical Notes'**
  String get clinicalNotes;

  /// No description provided for @addClinicalNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a clinical note...'**
  String get addClinicalNoteHint;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @noClinicalNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No clinical notes yet'**
  String get noClinicalNotesYet;

  /// No description provided for @clinicalNoteAdded.
  ///
  /// In en, this message translates to:
  /// **'Clinical note added'**
  String get clinicalNoteAdded;

  /// No description provided for @termsOfServiceContent.
  ///
  /// In en, this message translates to:
  /// **'By using Pet Circle, you agree to our terms of service. This application is intended for tracking and monitoring pet respiratory rates. All data is stored locally and shared only with members of your care circle. We are not liable for medical decisions made based on this data. Always consult with a licensed veterinarian for medical advice.\n\nLast updated: January 2026'**
  String get termsOfServiceContent;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Pet Circle values your privacy. We collect minimal data necessary to provide our services.\n\n• Personal Information: Name, email, and pet health data are stored securely.\n• Data Sharing: Your data is only shared with care circle members you explicitly invite.\n• Data Storage: Health records are stored locally on your device and optionally synced to our secure cloud.\n• Third Parties: We do not sell or share your data with third parties.\n• Data Deletion: You can export and delete all your data at any time from Settings.\n\nLast updated: January 2026'**
  String get privacyPolicyContent;

  /// No description provided for @helpAndSupportContent.
  ///
  /// In en, this message translates to:
  /// **'Need help? Here are some resources:\n\n• FAQ: Visit our website at petcircle.app/faq\n• Email Support: support@petcircle.app\n• Response Time: We typically respond within 24 hours\n\nCommon Questions:\n• How to measure SRR: Use the Manual Mode tap counter or VisionRR camera mode.\n• Adding care circle members: Go to Settings > Care Circle > Invite.\n• Understanding alerts: Alerts trigger when BPM exceeds your configured thresholds.\n\nApp Version: 1.0.0'**
  String get helpAndSupportContent;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
