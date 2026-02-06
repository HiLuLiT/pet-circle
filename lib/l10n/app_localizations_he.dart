// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'מעגל חיות מחמד';

  @override
  String get signUp => 'הרשמה';

  @override
  String get signIn => 'כניסה';

  @override
  String get signInWithGoogle => 'כניסה עם גוגל';

  @override
  String hiUser(String name) {
    return 'היי $name!';
  }

  @override
  String get imAVeterinarian => 'אני וטרינר/ית';

  @override
  String get imAPetOwner => 'אני בעל/ת חיית מחמד';

  @override
  String onboardingStep(int current, int total) {
    return 'שלב $current מתוך $total';
  }

  @override
  String get petName => 'שם חיית המחמד';

  @override
  String get breed => 'גזע';

  @override
  String get age => 'גיל';

  @override
  String get ageYears => 'גיל (שנים)';

  @override
  String get photoUrl => 'כתובת תמונה (אופציונלי)';

  @override
  String get medicalInformation => 'מידע רפואי';

  @override
  String get diagnosis => 'אבחנה';

  @override
  String get diagnosisOptional => 'אבחנה (אופציונלי)';

  @override
  String get selectDiagnosis => 'בחר אבחנה';

  @override
  String get additionalNotes => 'הערות נוספות';

  @override
  String get targetRespiratoryRate => 'הגדרת קצב נשימה יעד';

  @override
  String get targetRateDescription => 'נתריע כאשר המדידות חורגות מסף זה.';

  @override
  String get normalRange => 'טווח תקין';

  @override
  String get normalRangeLabel => '30 BPM (סטנדרטי)';

  @override
  String get standardRateDescription => 'מומלץ לרוב הכלבים';

  @override
  String get elevatedRange => 'טווח מוגבר';

  @override
  String get elevatedRangeLabel => '35 BPM';

  @override
  String get elevatedRateDescription => 'לחיות מחמד עם מצבים קלים';

  @override
  String get customRate => 'קצב מותאם אישית';

  @override
  String get enterBpm => 'הכנס BPM';

  @override
  String get careCircle => 'מעגל טיפול';

  @override
  String get emailAddress => 'כתובת אימייל';

  @override
  String get role => 'תפקיד';

  @override
  String get addToCareCircle => 'הוספה למעגל הטיפול';

  @override
  String get addAnotherPetCircle => '+ הוספת מעגל חיית מחמד נוסף';

  @override
  String get myPets => 'חיות המחמד שלי';

  @override
  String get welcomeBack => 'ברוך שובך,';

  @override
  String get measure => 'מדידה';

  @override
  String get trends => 'מגמות';

  @override
  String get settings => 'הגדרות';

  @override
  String get managePreferences => 'ניהול העדפות PetBreath';

  @override
  String get appearance => 'מראה';

  @override
  String get customizeLookAndFeel => 'התאמה אישית של המראה';

  @override
  String get darkMode => 'מצב כהה';

  @override
  String get language => 'שפה';

  @override
  String get english => 'אנגלית';

  @override
  String get hebrew => 'עברית';

  @override
  String get manageCaregivers => 'ניהול מטפלים, וטרינרים ושומרי חיות';

  @override
  String get invite => 'הזמנה';

  @override
  String get notifications => 'התראות';

  @override
  String get manageAlerts => 'ניהול התראות ותזכורות';

  @override
  String get pushNotifications => 'התראות פוש';

  @override
  String get pushNotificationsDesc => 'קבלת התראות עבור מדידות';

  @override
  String get emergencyAlerts => 'התראות חירום';

  @override
  String get emergencyAlertsDesc => 'התראות קריטיות כאשר SRR חורג מהסף';

  @override
  String get measurementSettings => 'הגדרות מדידה';

  @override
  String get configureModes => 'הגדרת מצבי מדידה וסף';

  @override
  String get visionRRCameraMode => 'מצב מצלמת VisionRR';

  @override
  String get visionRRDesc => 'מדידה מבוססת מצלמה בינה מלאכותית';

  @override
  String get comingSoon => 'בקרוב';

  @override
  String get alertThresholds => 'ספי התראה';

  @override
  String get customizeBpmRanges => 'התאמה אישית של טווחי BPM להתראות';

  @override
  String get configure => 'הגדרה';

  @override
  String get dataAndPrivacy => 'נתונים ופרטיות';

  @override
  String get exportAndManage => 'ייצוא נתונים וניהול הגדרות פרטיות';

  @override
  String get autoExportData => 'ייצוא נתונים אוטומטי';

  @override
  String get autoExportDesc => 'ייצוא CSV שבועי למייל';

  @override
  String get exportAllData => 'ייצוא כל הנתונים';

  @override
  String get exportAllDataDesc => 'הורדת רשומות בריאות מלאות';

  @override
  String get shareWithVet => 'שיתוף עם וטרינר';

  @override
  String get shareWithVetDesc => 'יצירת קישור לדוח לשיתוף';

  @override
  String get about => 'אודות';

  @override
  String get appInfoAndSupport => 'מידע על האפליקציה ותמיכה';

  @override
  String get termsOfService => 'תנאי שימוש';

  @override
  String get privacyPolicy => 'מדיניות פרטיות';

  @override
  String get helpAndSupport => 'עזרה ותמיכה';

  @override
  String get manualMode => 'מצב ידני';

  @override
  String get visionRRMode => 'מצב VisionRR';

  @override
  String get timerDuration => 'משך טיימר';

  @override
  String get tapToBegin => 'הקש להתחלה';

  @override
  String get tapToStop => 'הקש לעצירה';

  @override
  String get measurementComplete => 'המדידה הושלמה';

  @override
  String get breathsPerMinute => 'נשימות לדקה';

  @override
  String breathCountMessage(int taps, int seconds) {
    return 'ספרת $taps נשימות ב-$seconds שניות.';
  }

  @override
  String get done => 'סיום';

  @override
  String get addToGraph => 'הוסף לגרף';

  @override
  String get measureAgain => 'מדוד שוב';

  @override
  String get healthTrends => 'מגמות בריאות';

  @override
  String get measurementHistory => 'היסטוריית מדידות';

  @override
  String get medicationManagement => 'ניהול תרופות';

  @override
  String get addMedication => 'הוספת תרופה';

  @override
  String get exportMedicationLog => 'ייצוא יומן תרופות';

  @override
  String get messagesComingSoon => 'הודעות בקרוב';

  @override
  String get trendsComingSoon => 'מגמות בקרוב';

  @override
  String get cancel => 'ביטול';

  @override
  String get save => 'שמירה';

  @override
  String get close => 'סגירה';

  @override
  String get active => 'פעיל';

  @override
  String get pending => 'ממתין';

  @override
  String get owner => 'בעלים';

  @override
  String get veterinarian => 'וטרינר';

  @override
  String get caregiver => 'מטפל';

  @override
  String get viewer => 'צופה';

  @override
  String get normalThresholdBpm => 'סף תקין (BPM)';

  @override
  String get alertThresholdBpm => 'סף התראה (BPM)';

  @override
  String get thresholdsUpdated => 'הספים עודכנו';

  @override
  String get configureAlertThresholds => 'הגדרת ספי התראה';

  @override
  String get configureAlertThresholdsDesc =>
      'הגדרת טווחי BPM מותאמים אישית להתראות קצב הנשימה של חיית המחמד שלך.';

  @override
  String get createAccount => 'יצירת חשבון';

  @override
  String get email => 'אימייל';

  @override
  String get enterYourEmail => 'הכנס את האימייל שלך';

  @override
  String get pleaseEnterEmail => 'נא להזין אימייל';

  @override
  String get pleaseEnterValidEmail => 'נא להזין אימייל תקין';

  @override
  String get password => 'סיסמה';

  @override
  String get enterYourPassword => 'הכנס את הסיסמה שלך';

  @override
  String get pleaseEnterPassword => 'נא להזין סיסמה';

  @override
  String get passwordMinLength => 'הסיסמה חייבת להכיל לפחות 6 תווים';

  @override
  String get confirmPassword => 'אימות סיסמה';

  @override
  String get confirmYourPassword => 'אמת את הסיסמה שלך';

  @override
  String get passwordsDoNotMatch => 'הסיסמאות אינן תואמות';

  @override
  String get forgotPassword => 'שכחת סיסמה?';

  @override
  String get orContinueWith => 'או המשך עם';

  @override
  String get google => 'גוגל';

  @override
  String get apple => 'אפל';

  @override
  String get alreadyHaveAccount => 'כבר יש לך חשבון?';

  @override
  String get dontHaveAccount => 'אין לך חשבון?';

  @override
  String get fullName => 'שם מלא';

  @override
  String get enterYourName => 'הכנס את שמך';

  @override
  String get pleaseEnterName => 'נא להזין שם';

  @override
  String signingUpAs(String roleLabel) {
    return 'הרשמה כ$roleLabel';
  }

  @override
  String passwordResetSent(String email) {
    return 'אימייל לאיפוס סיסמה נשלח ל-$email';
  }

  @override
  String get pleaseEnterEmailFirst => 'נא להזין כתובת אימייל תחילה';

  @override
  String get petOwner => 'בעל חיית מחמד';

  @override
  String get verifyYourEmail => 'אמת את האימייל שלך';

  @override
  String get verificationLinkSentTo => 'שלחנו קישור אימות אל';

  @override
  String get clickLinkToVerify => 'לחץ על הקישור כדי לאמת את החשבון שלך.';

  @override
  String get resendVerificationEmail => 'שלח מחדש אימייל אימות';

  @override
  String resendInSeconds(int seconds) {
    return 'שלח מחדש בעוד $seconds שניות';
  }

  @override
  String get iveVerifiedMyEmail => 'אימתתי את האימייל שלי';

  @override
  String get useDifferentAccount => 'שימוש בחשבון אחר';

  @override
  String get verificationEmailSent => 'אימייל אימות נשלח!';

  @override
  String get failedToSendEmail => 'שליחת האימייל נכשלה';

  @override
  String get bpm => 'BPM';

  @override
  String get clinicOverview => 'סקירת מרפאה';

  @override
  String patientsInYourCare(int count) {
    return '$count מטופלים בטיפולך';
  }

  @override
  String get normalStatus => 'מצב תקין';

  @override
  String get needAttention => 'דורש תשומת לב';

  @override
  String get measurementsThisWeek => 'מדידות השבוע';

  @override
  String get viewOnly => 'צפייה בלבד';

  @override
  String ownerLabel(String name) {
    return 'בעלים: $name';
  }

  @override
  String get unknown => 'לא ידוע';

  @override
  String get normal => 'תקין';

  @override
  String get setupPetProfile => 'הגדרת פרופיל חיית מחמד';

  @override
  String get tellUsAboutYourPet => 'ספר/י לנו על חיית המחמד שלך';

  @override
  String get medicalInfoDescription =>
      'מידע זה עוזר לנו לספק המלצות ניטור מדויקות יותר.';

  @override
  String get note => 'הערה:';

  @override
  String get diagnosisNote =>
      'מידע זה משמש להגדרת ספי ניטור מתאימים ומשותף רק עם מעגל הטיפול שלך.';

  @override
  String get inviteYourCareCircle => 'הזמן את מעגל הטיפול שלך';

  @override
  String get inviteCareCircleDescription =>
      'הזמן בני משפחה, שומרי חיות מחמד ווטרינרים לשתף פעולה.';

  @override
  String invitationSentTo(String email, String role) {
    return 'הזמנה נשלחה ל-$email כ$role';
  }

  @override
  String get pleaseEnterEmailAddress => 'נא להזין כתובת אימייל';

  @override
  String get duration15s => '15 שנ׳';

  @override
  String get duration30s => '30 שנ׳';

  @override
  String get duration60s => '60 שנ׳';

  @override
  String get visionRRModeDescription =>
      'השתמש במצלמה שלך כדי לזהות תנועת חזה עדינה בזמן שחיית המחמד שלך ישנה. מצב זה ללא ידיים ומיועד למעקב מדויק אחר SRR.';

  @override
  String get measureRespiratoryRate => 'מדידת קצב נשימה';

  @override
  String unreadNotifications(int count) {
    return '$count שלא נקראו';
  }

  @override
  String get elevatedRespiratoryRate => 'קצב נשימה מוגבר';

  @override
  String medicationDue(String name) {
    return 'תרופה: $name';
  }

  @override
  String get careCircleInvitationAccepted => 'הזמנה למעגל הטיפול התקבלה';

  @override
  String get weeklyHealthReportReady => 'דוח בריאות שבועי מוכן';

  @override
  String get measurementReminder => 'תזכורת מדידה';

  @override
  String get careCircleInvitationPending => 'הזמנה למעגל הטיפול ממתינה';

  @override
  String get autoExportComplete => 'ייצוא אוטומטי הושלם';

  @override
  String get averageSrr => 'ממוצע SRR';

  @override
  String get sevenDayTrend => 'מגמת 7 ימים';

  @override
  String get bpmChange => 'שינוי BPM';

  @override
  String get activeTreatments => 'טיפולים פעילים';

  @override
  String get srrOverTime => 'קצב נשימה בשינה (SRR) לאורך זמן';

  @override
  String get medicationTimeline => 'ציר זמן תרופות';

  @override
  String get noMedicationsRecorded => 'לא נרשמו תרופות';

  @override
  String get clinicalRecordInformation => 'מידע רשומה קלינית';

  @override
  String get addNewMedication => 'הוספת תרופה חדשה';

  @override
  String get medicationNameRequired => 'שם התרופה *';

  @override
  String get dosageRequired => 'מינון *';

  @override
  String get frequencyRequired => 'תדירות *';

  @override
  String get startDateRequired => 'תאריך התחלה *';

  @override
  String get endDateOptional => 'תאריך סיום (אופציונלי)';

  @override
  String get prescribedBy => 'נרשם על ידי';

  @override
  String get purposeCondition => 'מטרה / מצב';

  @override
  String get medicationReminders => 'תזכורות תרופות';

  @override
  String get medicationRemindersDesc => 'הודע למעגל הטיפול כאשר מינונים מגיעים';

  @override
  String get csvPreview => 'תצוגה מקדימה של CSV:';

  @override
  String get downloadCsv => 'הורד CSV';

  @override
  String get medicationLogExported => 'יומן התרופות יוצא בהצלחה';

  @override
  String get exportLabel => 'ייצוא';

  @override
  String get last24Hours => '24 שעות אחרונות';

  @override
  String get last3Days => '3 ימים אחרונים';

  @override
  String get last7Days => '7 ימים אחרונים';

  @override
  String get last30Days => '30 ימים אחרונים';

  @override
  String get last90Days => '90 ימים אחרונים';

  @override
  String get customRange => 'טווח מותאם אישית';

  @override
  String get range => 'טווח';

  @override
  String get minMax => 'מינ׳-מקס׳';

  @override
  String get trend => 'מגמה';

  @override
  String get status => 'סטטוס';

  @override
  String get latestReading => 'קריאה אחרונה';

  @override
  String get lastMeasured => 'מדידה אחרונה';

  @override
  String get viewGraph => 'צפה בגרף';

  @override
  String get clinicalNotes => 'הערות קליניות';

  @override
  String get addClinicalNoteHint => 'הוסף הערה קלינית...';

  @override
  String get addNote => 'הוסף הערה';

  @override
  String get noClinicalNotesYet => 'אין עדיין הערות קליניות';

  @override
  String get clinicalNoteAdded => 'הערה קלינית נוספה';

  @override
  String get termsOfServiceContent =>
      'באמצעות השימוש ב-Pet Circle, אתה מסכים לתנאי השימוש שלנו. אפליקציה זו מיועדת למעקב וניטור קצבי נשימה של חיות מחמד. כל הנתונים מאוחסנים באופן מקומי ומשותפים רק עם חברי מעגל הטיפול שלך. אנו לא אחראים להחלטות רפואיות שנעשו על בסיס נתונים אלה. תמיד התייעץ עם וטרינר מורשה לקבלת ייעוץ רפואי.\n\nעדכון אחרון: ינואר 2026';

  @override
  String get privacyPolicyContent =>
      'Pet Circle מעריכה את פרטיותך. אנו אוספים מינימום נתונים הנדרשים לספק את שירותינו.\n\n• מידע אישי: שם, אימייל ונתוני בריאות חיות מחמד מאוחסנים בצורה מאובטחת.\n• שיתוף נתונים: הנתונים שלך משותפים רק עם חברי מעגל הטיפול שהזמנת במפורש.\n• אחסון נתונים: רשומות בריאות מאוחסנות באופן מקומי במכשיר שלך ובאופן אופציונלי מסונכרנות לענן המאובטח שלנו.\n• צדדים שלישיים: אנו לא מוכרים או משתפים את הנתונים שלך עם צדדים שלישיים.\n• מחיקת נתונים: ניתן לייצא ולמחוק את כל הנתונים שלך בכל עת מההגדרות.\n\nעדכון אחרון: ינואר 2026';

  @override
  String get helpAndSupportContent =>
      'צריך עזרה? הנה כמה משאבים:\n\n• שאלות נפוצות: בקר באתר שלנו ב-petcircle.app/faq\n• תמיכה באימייל: support@petcircle.app\n• זמן תגובה: אנו בדרך כלל מגיבים תוך 24 שעות\n\nשאלות נפוצות:\n• כיצד למדוד SRR: השתמש במונה הקשות במצב ידני או במצב מצלמת VisionRR.\n• הוספת חברי מעגל טיפול: עבור להגדרות > מעגל טיפול > הזמנה.\n• הבנת התראות: התראות מופעלות כאשר BPM חורג מהספים שהגדרת.\n\nגרסת האפליקציה: 1.0.0';

  @override
  String get selectLanguage => 'בחר שפה';
}
