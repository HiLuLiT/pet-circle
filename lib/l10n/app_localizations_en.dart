// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pet Circle';

  @override
  String get signUp => 'Sign up';

  @override
  String get signIn => 'Sign In';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String hiUser(String name) {
    return 'Hi $name!';
  }

  @override
  String get imAVeterinarian => 'I\'m a veterinarian';

  @override
  String get imAPetOwner => 'I\'m a pet owner';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get petName => 'Pet\'s Name';

  @override
  String get breed => 'Breed';

  @override
  String get age => 'Age';

  @override
  String get ageYears => 'Age (years)';

  @override
  String get photoUrl => 'Photo URL (Optional)';

  @override
  String get medicalInformation => 'Medical Information';

  @override
  String get diagnosis => 'Diagnosis';

  @override
  String get diagnosisOptional => 'Diagnosis (Optional)';

  @override
  String get selectDiagnosis => 'Select diagnosis';

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get targetRespiratoryRate => 'Set Target Respiratory Rate';

  @override
  String get targetRateDescription =>
      'We\'ll alert you when measurements exceed this threshold.';

  @override
  String get normalRange => 'Normal Range';

  @override
  String get normalRangeLabel => '30 BPM (Standard)';

  @override
  String get standardRateDescription => 'Recommended for most dogs';

  @override
  String get elevatedRange => 'Elevated Range';

  @override
  String get elevatedRangeLabel => '35 BPM';

  @override
  String get elevatedRateDescription => 'For pets with mild conditions';

  @override
  String get customRate => 'Custom Rate';

  @override
  String get enterBpm => 'Enter BPM';

  @override
  String get careCircle => 'Care Circle';

  @override
  String get emailAddress => 'Email address';

  @override
  String get role => 'Role';

  @override
  String get addToCareCircle => 'Add to pet circle';

  @override
  String get addAnotherPetCircle => '+ Add another pet circle';

  @override
  String get myPets => 'My pets';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get measure => 'Measure';

  @override
  String get trends => 'Trends';

  @override
  String get settings => 'Settings';

  @override
  String get managePreferences => 'Manage your PetBreath preferences';

  @override
  String get appearance => 'Appearance';

  @override
  String get customizeLookAndFeel => 'Customize the look and feel';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hebrew => 'Hebrew';

  @override
  String get manageCaregivers => 'Manage caregivers, vets, and pet sitters';

  @override
  String get invite => 'Invite';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageAlerts => 'Manage alerts and reminders';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get pushNotificationsDesc => 'Receive notifications for measurements';

  @override
  String get emergencyAlerts => 'Emergency alerts';

  @override
  String get emergencyAlertsDesc =>
      'Critical alerts when SRR exceeds thresholds';

  @override
  String get measurementSettings => 'Measurement settings';

  @override
  String get configureModes => 'Configure measurement modes and thresholds';

  @override
  String get visionRRCameraMode => 'VisionRR camera mode';

  @override
  String get visionRRDesc => 'AI-powered camera-based measurement';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get alertThresholds => 'Alert thresholds';

  @override
  String get customizeBpmRanges => 'Customize BPM ranges for alerts';

  @override
  String get configure => 'Configure';

  @override
  String get dataAndPrivacy => 'Data & Privacy';

  @override
  String get exportAndManage => 'Export data and manage privacy settings';

  @override
  String get autoExportData => 'Auto-Export Data';

  @override
  String get autoExportDesc => 'Weekly CSV export to email';

  @override
  String get exportAllData => 'Export All Data';

  @override
  String get exportAllDataDesc => 'Download complete health records';

  @override
  String get shareWithVet => 'Share with Veterinarian';

  @override
  String get shareWithVetDesc => 'Generate shareable report link';

  @override
  String get about => 'About';

  @override
  String get appInfoAndSupport => 'App information and support';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get manualMode => 'Manual Mode';

  @override
  String get visionRRMode => 'VisionRR Mode';

  @override
  String get timerDuration => 'Timer Duration';

  @override
  String get tapToBegin => 'Tap to begin';

  @override
  String get tapToStop => 'Tap to stop';

  @override
  String get measurementComplete => 'Measurement Complete';

  @override
  String get breathsPerMinute => 'breaths per minute';

  @override
  String breathCountMessage(int taps, int seconds) {
    return 'You counted $taps breaths in $seconds seconds.';
  }

  @override
  String get done => 'Done';

  @override
  String get addToGraph => 'Add to Graph';

  @override
  String get measureAgain => 'Measure Again';

  @override
  String get healthTrends => 'Health Trends';

  @override
  String get measurementHistory => 'Measurement History';

  @override
  String get medicationManagement => 'Medication Management';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get exportMedicationLog => 'Export Medication Log';

  @override
  String get messagesComingSoon => 'Messages coming soon';

  @override
  String get trendsComingSoon => 'Trends coming soon';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get active => 'Active';

  @override
  String get pending => 'Pending';

  @override
  String get owner => 'Owner';

  @override
  String get veterinarian => 'Veterinarian';

  @override
  String get caregiver => 'Caregiver';

  @override
  String get viewer => 'Viewer';

  @override
  String get normalThresholdBpm => 'Normal Threshold (BPM)';

  @override
  String get alertThresholdBpm => 'Alert Threshold (BPM)';

  @override
  String get thresholdsUpdated => 'Thresholds updated';

  @override
  String get configureAlertThresholds => 'Configure Alert Thresholds';

  @override
  String get configureAlertThresholdsDesc =>
      'Set custom BPM ranges for your pet\'s respiratory rate alerts.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get email => 'Email';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String signingUpAs(String roleLabel) {
    return 'Signing up as $roleLabel';
  }

  @override
  String passwordResetSent(String email) {
    return 'Password reset email sent to $email';
  }

  @override
  String get pleaseEnterEmailFirst => 'Please enter your email address first';

  @override
  String get petOwner => 'Pet Owner';

  @override
  String get verifyYourEmail => 'Verify Your Email';

  @override
  String get verificationLinkSentTo => 'We sent a verification link to';

  @override
  String get clickLinkToVerify => 'Click the link to verify your account.';

  @override
  String get resendVerificationEmail => 'Resend Verification Email';

  @override
  String resendInSeconds(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get iveVerifiedMyEmail => 'I\'ve verified my email';

  @override
  String get useDifferentAccount => 'Use a different account';

  @override
  String get verificationEmailSent => 'Verification email sent!';

  @override
  String get failedToSendEmail => 'Failed to send email';

  @override
  String get bpm => 'BPM';

  @override
  String get clinicOverview => 'Clinic Overview';

  @override
  String patientsInYourCare(int count) {
    return '$count patients in your care';
  }

  @override
  String get normalStatus => 'Normal Status';

  @override
  String get needAttention => 'Need Attention';

  @override
  String get measurementsThisWeek => 'Measurements This Week';

  @override
  String get viewOnly => 'View Only';

  @override
  String ownerLabel(String name) {
    return 'Owner: $name';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get normal => 'Normal';

  @override
  String get setupPetProfile => 'Setup pet profile';

  @override
  String get tellUsAboutYourPet => 'Tell us about your pet';

  @override
  String get medicalInfoDescription =>
      'This helps us provide more accurate monitoring recommendations.';

  @override
  String get note => 'Note:';

  @override
  String get diagnosisNote =>
      'This information is used to set appropriate monitoring thresholds and is shared only with your care circle.';

  @override
  String get inviteYourCareCircle => 'Invite Your Care Circle';

  @override
  String get inviteCareCircleDescription =>
      'Invite family members, pet sitters, and veterinarians to collaborate.';

  @override
  String invitationSentTo(String email, String role) {
    return 'Invitation sent to $email as $role';
  }

  @override
  String get pleaseEnterEmailAddress => 'Please enter an email address';

  @override
  String get duration15s => '15s';

  @override
  String get duration30s => '30s';

  @override
  String get duration60s => '60s';

  @override
  String get visionRRModeDescription =>
      'Use your camera to detect subtle chest motion while your pet sleeps. This mode is hands-free and designed for accurate SRR tracking.';

  @override
  String get measureRespiratoryRate => 'Measure respiratory rate';

  @override
  String unreadNotifications(int count) {
    return '$count unread';
  }

  @override
  String get elevatedRespiratoryRate => 'Elevated Respiratory Rate';

  @override
  String medicationDue(String name) {
    return 'Medication Due: $name';
  }

  @override
  String get careCircleInvitationAccepted => 'Care Circle Invitation Accepted';

  @override
  String get weeklyHealthReportReady => 'Weekly Health Report Ready';

  @override
  String get measurementReminder => 'Measurement Reminder';

  @override
  String get careCircleInvitationPending => 'Care Circle Invitation Pending';

  @override
  String get autoExportComplete => 'Auto-Export Complete';

  @override
  String get averageSrr => 'Average SRR';

  @override
  String get sevenDayTrend => '7-Day Trend';

  @override
  String get bpmChange => 'BPM change';

  @override
  String get activeTreatments => 'Active treatments';

  @override
  String get srrOverTime => 'Sleeping Respiratory Rate (SRR) Over Time';

  @override
  String get medicationTimeline => 'Medication Timeline';

  @override
  String get noMedicationsRecorded => 'No Medications Recorded';

  @override
  String get clinicalRecordInformation => 'Clinical Record Information';

  @override
  String get addNewMedication => 'Add New Medication';

  @override
  String get medicationNameRequired => 'Medication Name *';

  @override
  String get dosageRequired => 'Dosage *';

  @override
  String get frequencyRequired => 'Frequency *';

  @override
  String get startDateRequired => 'Start Date *';

  @override
  String get endDateOptional => 'End Date (Optional)';

  @override
  String get prescribedBy => 'Prescribed By';

  @override
  String get purposeCondition => 'Purpose / Condition';

  @override
  String get medicationReminders => 'Medication Reminders';

  @override
  String get medicationRemindersDesc => 'Notify care circle when doses are due';

  @override
  String get csvPreview => 'CSV Preview:';

  @override
  String get downloadCsv => 'Download CSV';

  @override
  String get medicationLogExported => 'Medication log exported successfully';

  @override
  String get exportLabel => 'Export';

  @override
  String get last24Hours => 'Last 24 hours';

  @override
  String get last3Days => 'Last 3 days';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get last90Days => 'Last 90 days';

  @override
  String get customRange => 'Custom range';

  @override
  String get range => 'Range';

  @override
  String get minMax => 'Min-Max';

  @override
  String get trend => 'Trend';

  @override
  String get status => 'Status';

  @override
  String get latestReading => 'Latest Reading';

  @override
  String get lastMeasured => 'Last Measured';

  @override
  String get viewGraph => 'View Graph';

  @override
  String get clinicalNotes => 'Clinical Notes';

  @override
  String get addClinicalNoteHint => 'Add a clinical note...';

  @override
  String get addNote => 'Add Note';

  @override
  String get noClinicalNotesYet => 'No clinical notes yet';

  @override
  String get clinicalNoteAdded => 'Clinical note added';

  @override
  String get termsOfServiceContent =>
      'By using Pet Circle, you agree to our terms of service. This application is intended for tracking and monitoring pet respiratory rates. All data is stored locally and shared only with members of your care circle. We are not liable for medical decisions made based on this data. Always consult with a licensed veterinarian for medical advice.\n\nLast updated: January 2026';

  @override
  String get privacyPolicyContent =>
      'Pet Circle values your privacy. We collect minimal data necessary to provide our services.\n\n• Personal Information: Name, email, and pet health data are stored securely.\n• Data Sharing: Your data is only shared with care circle members you explicitly invite.\n• Data Storage: Health records are stored locally on your device and optionally synced to our secure cloud.\n• Third Parties: We do not sell or share your data with third parties.\n• Data Deletion: You can export and delete all your data at any time from Settings.\n\nLast updated: January 2026';

  @override
  String get helpAndSupportContent =>
      'Need help? Here are some resources:\n\n• FAQ: Visit our website at petcircle.app/faq\n• Email Support: support@petcircle.app\n• Response Time: We typically respond within 24 hours\n\nCommon Questions:\n• How to measure SRR: Use the Manual Mode tap counter or VisionRR camera mode.\n• Adding care circle members: Go to Settings > Care Circle > Invite.\n• Understanding alerts: Alerts trigger when BPM exceeds your configured thresholds.\n\nApp Version: 1.0.0';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get reset => 'Reset';
}
