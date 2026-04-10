# Graph Report - .  (2026-04-10)

## Corpus Check
- 228 files · ~127,414 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 422 nodes · 633 edges · 42 communities detected
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 50 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## God Nodes (most connected - your core abstractions)
1. `AppSemanticColors` - 18 edges
2. `testApp helper` - 15 edges
3. `petStore (global)` - 13 edges
4. `Pet Model` - 13 edges
5. `SettingsContent` - 12 edges
6. `AppSemanticTextStyles` - 11 edges
7. `PetStore` - 11 edges
8. `AppSemanticColors` - 11 edges
9. `PetStore` - 10 edges
10. `AppPrimitives` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Pet Circle Claude Code Instructions` --references--> `Future Features Backlog`  [EXTRACTED]
  CLAUDE.md → docs/future-features.md
- `Pet Circle Claude Code Instructions` --references--> `Design System Migration v1 to v2`  [EXTRACTED]
  CLAUDE.md → docs/design-system-migration.md
- `Pet Circle Product Requirements Document v2.0` --references--> `ChangeNotifier Global Singleton Stores`  [EXTRACTED]
  docs/PRD.md → CLAUDE.md
- `Auth Flow Redesign Plan` --references--> `AppRoutes and GoRouter Config`  [EXTRACTED]
  docs/superpowers/plans/2026-04-01-auth-flow-redesign.md → lib/app_routes.dart
- `AppRoutes and GoRouter Config` --implements--> `Role System (Owner/Vet + Admin/Member/Viewer)`  [INFERRED]
  lib/app_routes.dart → docs/PRD.md

## Hyperedges (group relationships)
- **Authentication and Onboarding Flow** — app_routes, concept_has_completed_onboarding, concept_otp_auth, plan_auth_flow_redesign, plan_email_otp_refactor, concept_invitation_flow [EXTRACTED 0.90]
- **Cloud Functions + Resend Email Delivery System** — concept_cloud_functions, concept_resend_email, plan_circle_invitations_email, plan_email_otp_refactor, concept_otp_auth, concept_invitation_flow [EXTRACTED 0.85]
- **Design Token and Figma Pipeline** — concept_design_token_architecture, concept_figma_to_code_flow, design_system_migration, rationale_design_migration [EXTRACTED 0.90]
- **Authentication Flow** — welcome_screen_WelcomeScreen, login_screen_LoginScreen, verify_otp_screen_VerifyOtpScreen, auth_gate_AuthGate, role_selection_screen_RoleSelectionScreen, auth_provider_AuthProvider [EXTRACTED 0.95]
- **Immutable Firestore Domain Models** — app_user_AppUser, pet_Pet, measurement_Measurement, medication_Medication, clinical_note_ClinicalNote, invitation_Invitation, app_notification_AppNotification [EXTRACTED 0.90]
- **Repository Pattern Implementation** — user_repository_UserRepository, user_repository_FirestoreUserRepository, invitation_repository_InvitationRepository, invitation_repository_FirestoreInvitationRepository [EXTRACTED 1.00]
- **Onboarding Wizard Steps** — onboarding_flow_OnboardingFlow, onboarding_step1_OnboardingStep1, onboarding_step2_OnboardingStep2, onboarding_step3_OnboardingStep3, onboarding_step4_OnboardingStep4 [EXTRACTED 1.00]
- **Dashboard Screen Variants** — owner_dashboard_OwnerDashboard, vet_dashboard_VetDashboard, care_circle_dashboard_CareCircleDashboard [INFERRED 0.80]
- **Pet Detail Page Composition** — pet_detail_screen_PetDetailScreen, pet_detail_sections_PetInfoSection, pet_detail_sections_PetMeasurementHistory, pet_detail_sections_PetClinicalNotes, pet_detail_sections_PetCareCircle, pet_detail_widgets_InfoTile, pet_detail_widgets_NoteCard, pet_detail_widgets_MemberTile [EXTRACTED 1.00]
- **Settings Module** — settings_screen_SettingsScreen, settings_screen_SettingsDrawer, settings_content_SettingsContent, settings_dialogs_SettingsDialogsMixin, settings_widgets_SettingsCard, settings_widgets_SettingsToggleRow, settings_widgets_LanguageRow, settings_care_circle_widgets_InviteButton, settings_care_circle_widgets_CareCircleItem, settings_care_circle_widgets_ConfigureRow [EXTRACTED 1.00]
- **Medication Feature** — medication_screen_MedicationScreen, add_medication_sheet_AddMedicationSheet, medication_form_widgets_ValidatedFormField, medication_form_widgets_DropdownField, medication_form_widgets_ReminderCard [EXTRACTED 1.00]
- **Invitation Processing Flow** — invite_screen_InviteScreen, circle_screen_CircleScreen, vet_dashboard_VetDashboard, store_invitation_store [INFERRED 0.80]
- **Screens Consuming petStore** — circle_screen_CircleScreen, care_circle_dashboard_CareCircleDashboard, owner_dashboard_OwnerDashboard, vet_dashboard_VetDashboard, measurement_screen_MeasurementScreen, medication_screen_MedicationScreen, pet_detail_screen_PetDetailScreen, settings_content_SettingsContent, onboarding_flow_OnboardingFlow [EXTRACTED 1.00]
- **Authentication Flow Screens** — welcome_screen_WelcomeScreen, invite_screen_InviteScreen, onboarding_flow_OnboardingFlow [INFERRED 0.75]
- **Store-Service delegation pattern** — MeasurementStore, MeasurementService, MedicationStore, MedicationService, NoteStore, NoteService, NotificationStore, NotificationService, PetStore, PetService [EXTRACTED 1.00]
- **PetStore orchestrates child store subscriptions** — PetStore, MeasurementStore, MedicationStore, NoteStore [EXTRACTED 1.00]
- **Platform-conditional reminder implementation** — AbstractReminderService, ReminderService, WebReminderService [EXTRACTED 1.00]
- **3-layer design token architecture (primitives -> semantic -> theme)** — AppPrimitives, AppTypography, AppShadowTokens, AppSpacingTokens, AppRadiiTokens, AppSemanticColors, AppSemanticTextStyles, buildAppTheme, buildDarkTheme [EXTRACTED 1.00]
- **Platform-conditional CSV export (native via share_plus, web via dart:html)** — exportCsv, exportCsvImpl_native, exportCsvImpl_web, PlatformCapabilities [EXTRACTED 0.90]
- **Cross-cutting utility layer (error handling, formatting, platform detection, responsiveness)** — AppErrorHandler, formatters, PlatformCapabilities, ResponsiveLayout, ResponsiveContext [INFERRED 0.70]
- **All widgets consume the 3-layer design token architecture** — AppSemanticColors, AppSemanticTextStyles, AppPrimitives, AppSpacingTokens, AppRadiiTokens, AppShadowTokens [EXTRACTED 1.00]
- **Shared reusable widget library in lib/widgets/** — AppDropdown, AppHeader, AppImage, BottomNavBar, BreedSearchField, DogPhoto, LabeledTextField, NeumorphicCard, OnboardingShell, PrimaryButton, RoundIconButton, SettingsRow, StatusBadge, TogglePill, UserAvatar [EXTRACTED 1.00]
- **Test infrastructure: mock stores, HTTP overrides, test app wrapper, fake snapshots** — seedAllStores, resetAllStores, testApp, MockHttpOverrides, FakeDocumentSnapshot, suppressOverflowErrors [EXTRACTED 1.00]
- **Immutable model contract** — lib/models/app_user.dart, lib/models/pet.dart, lib/models/user.dart, lib/models/measurement.dart, lib/models/care_circle_member.dart [EXTRACTED 1.00]
- **Authentication flow screens** — lib/screens/welcome_screen.dart, lib/screens/auth/login_screen.dart, lib/screens/auth/verify_otp_screen.dart, lib/screens/auth/role_selection_screen.dart, lib/screens/auth/auth_gate.dart [INFERRED 0.85]
- **Shared test infrastructure** — test/helpers/mock_stores.dart, test/helpers/test_app.dart, test/helpers/fake_document_snapshot.dart, test/helpers/ignore_overflow_errors.dart, test/helpers/test_http_overrides.dart [EXTRACTED 1.00]
- **3-Step Onboarding PageView Flow** — lib/screens/onboarding/onboarding_flow.dart, lib/screens/onboarding/onboarding_step1.dart, lib/screens/onboarding/onboarding_step2.dart, lib/screens/onboarding/onboarding_step3.dart, lib/widgets/onboarding_shell.dart [EXTRACTED 1.00]
- **Settings Screen Composition** — lib/screens/settings/settings_screen.dart, lib/screens/settings/settings_content.dart, lib/screens/settings/settings_widgets.dart, lib/screens/settings/settings_care_circle_widgets.dart, lib/screens/settings/settings_dialogs.dart [INFERRED 0.90]
- **PetDetail Section Composition** — lib/screens/pet_detail/pet_detail_screen.dart, lib/screens/pet_detail/pet_detail_sections.dart, lib/screens/pet_detail/pet_detail_widgets.dart, lib/stores/measurement_store.dart, lib/stores/note_store.dart [EXTRACTED 1.00]
- **Store Test Suite using Seed Simulation Pattern** — test/stores/measurement_store_test.dart, test/stores/medication_store_test.dart, test/stores/note_store_test.dart, test/stores/notification_store_test.dart, test/stores/pet_store_test.dart, test/stores/pet_store_circle_test.dart, test/stores/settings_store_test.dart, test/stores/user_store_test.dart, concept:seed_simulation_pattern [EXTRACTED 1.00]
- **Design Token System (3-layer architecture)** — lib/theme/tokens/colors.dart, lib/theme/tokens/shadows.dart, lib/theme/tokens/spacing.dart, lib/theme/tokens/typography.dart, lib/theme/semantic/color_scheme.dart, lib/theme/app_theme.dart, test/theme/tokens_test.dart, test/theme/color_scheme_test.dart, test/theme/app_theme_test.dart [EXTRACTED 1.00]
- **Utility Test Suite (formatters, platform, responsive, error, csv)** — test/utils/csv_export_helper_test.dart, test/utils/error_handler_test.dart, test/utils/formatters_test.dart, test/utils/platform_utils_test.dart, test/utils/responsive_utils_test.dart [EXTRACTED 1.00]
- **Widget Test Suite** — test:app_dropdown_test, test:app_header_test, test:app_image_test, test:bottom_nav_bar_test, test:breed_search_field_test, test:dog_photo_test, test:labeled_text_field_test, test:neumorphic_card_test, test:onboarding_shell_test, test:primary_button_test, test:responsive_layout_test, test:round_icon_button_test, test:settings_row_test, test:status_badge_test, test:toggle_pill_test, test:user_avatar_test [INFERRED 0.90]
- **Design Token Consumer Widgets** — widget:AppDropdown, widget:BottomNavBar, widget:PrimaryButton, widget:NeumorphicCard, widget:StatusBadge, widget:TogglePill, widget:UserAvatar, widget:SettingsRow, widget:OnboardingShell [EXTRACTED 1.00]
- **Form Input Widgets** — widget:AppDropdown, widget:BreedSearchField, widget:LabeledTextField [INFERRED 0.80]

## Communities

### Community 0 - "App Screens & Navigation"
Cohesion: 0.07
Nodes (52): AddMedicationSheet, AppRoutes, CareCircleDashboard, CircleScreen, InviteScreen, MeasurementScreen, DropdownField, ReminderCard (+44 more)

### Community 1 - "Domain Enums & Access Control"
Cohesion: 0.09
Nodes (41): CareCirclePermissions, CareCircleRole Enum, InvitationStatus Enum, PendingInvite Model, PetAccessSource Enum, UserRole Enum, Access Control Resolution (ownerId > UID > email > name), SRR Threshold Classification (Normal/Elevated/Critical) (+33 more)

### Community 2 - "Project Docs & Architecture"
Cohesion: 0.07
Nodes (38): AppConfig (kEnableFirebase, appLocale, appDarkMode), AppRoutes and GoRouter Config, Pet Circle Bug Log, Pet Circle Claude Code Instructions, Care Circle Sharing Model, ChangeNotifier Global Singleton Stores, Firebase Cloud Functions Backend, Design Token Architecture (3 layers) (+30 more)

### Community 3 - "Shared Widget Library"
Cohesion: 0.09
Nodes (38): AppDropdown widget, AppHeader widget, AppImage widget, AppLocalizations (i18n), AppPrimitives, AppRadiiTokens, AppSemanticColors, AppSemanticTextStyles (+30 more)

### Community 4 - "Widget Test Suite"
Cohesion: 0.11
Nodes (38): PrimaryButtonVariant, testApp helper, AppDropdown Test, AppHeader Test, AppImage Test, BottomNavBar Test, BreedSearchField Test, DogPhoto Test (+30 more)

### Community 5 - "Services & Data Layer"
Cohesion: 0.11
Nodes (31): AbstractReminderService, AppConfig (kEnableFirebase), AppNotification, AppUser, AuthService, CareCircleMember, ClinicalNote, CsvExportHelper (+23 more)

### Community 6 - "Auth Flow & Routing"
Cohesion: 0.1
Nodes (28): AuthRouteState Enum, AppRoutes, AuthProvider, AuthGate Screen, LoginScreen, RoleSelectionScreen, VerifyOtpScreen, MainShell Screen (+20 more)

### Community 7 - "Store Test Patterns"
Cohesion: 0.16
Nodes (21): Seed Simulation Test Pattern, Unmodifiable List Pattern, ClinicalNote Model, Medication Model, MedicationScreen, PetDetailScreen, PetDetailSections, PetDetailWidgets (+13 more)

### Community 8 - "Auth Models & Providers"
Cohesion: 0.17
Nodes (16): AppUser Model, AppUserRole Enum, AuthGate Screen, AuthProvider, AuthRouteState Enum, LoginScreen, MainShell Screen, RoleSelectionScreen (+8 more)

### Community 9 - "Settings & Medication UI"
Cohesion: 0.23
Nodes (13): MedicationFormWidgets, SettingsCareCircleWidgets, SettingsContent, SettingsDialogs, SettingsScreen, SettingsWidgets, TogglePill Widget, MedicationFormWidgets Tests (+5 more)

### Community 10 - "Invitation & Circle Models"
Cohesion: 0.18
Nodes (12): NotificationType Enum, CareCircleMember Model, CareCircleRole Enum, Invitation Model, FirestoreInvitationRepository, InvitationRepository Interface, Measurement Model, Medication Model (+4 more)

### Community 11 - "Test Infrastructure"
Cohesion: 0.2
Nodes (12): FakeDocumentSnapshot test helper, MockData seed data, Test helpers barrel export, measurementStore global singleton, medicationStore global singleton, noteStore global singleton, notificationStore global singleton, petStore global singleton (+4 more)

### Community 12 - "Onboarding Wizard"
Cohesion: 0.4
Nodes (10): OnboardingFlow, OnboardingStep1, OnboardingStep2, OnboardingStep3, OnboardingStep4, OnboardingShell Widget, OnboardingFlow Tests, OnboardingStep2 Tests (+2 more)

### Community 13 - "Notifications & Formatting"
Cohesion: 0.33
Nodes (9): NotificationType Enum, AppNotification Model, MessagesScreen, NotificationStore, Formatters, AppNotification Test, MessagesScreen Tests, NotificationStore Test (+1 more)

### Community 14 - "Design Token System"
Cohesion: 0.33
Nodes (9): AppTheme, AppSemanticColors, AppPrimitives Colors, AppShadowTokens, AppSpacingTokens, AppTypography, AppTheme Test, ColorScheme Test (+1 more)

### Community 15 - "Deep Link & Invitations"
Cohesion: 0.29
Nodes (7): AcceptResult, DeepLinkService, AppLinks (web stub), Invitation, InvitationRepository, InvitationService, InvitationStore

### Community 16 - "CSV Export Platform Split"
Cohesion: 0.4
Nodes (5): PlatformCapabilities, exportCsv, exportCsvImpl (native), exportCsvImpl (web), share_plus package

### Community 17 - "Responsive Layout"
Cohesion: 0.5
Nodes (4): ResponsiveLayout Test, kDesktopBreakpoint, kTabletBreakpoint, ResponsiveLayout

### Community 18 - "Localization (en/he)"
Cohesion: 0.67
Nodes (3): AppLocalizations (i18n), English Localizations, Hebrew Localizations

### Community 19 - "Error Handling & Crashlytics"
Cohesion: 0.67
Nodes (3): AppErrorHandler, FirebaseCrashlytics, kEnableFirebase

### Community 20 - "OTP Auth Service"
Cohesion: 1.0
Nodes (3): OTP Authentication Flow, OtpService, OtpService Test

### Community 21 - "Responsive Utils"
Cohesion: 1.0
Nodes (3): Responsive Breakpoints (600/960/1200), ResponsiveLayout, ResponsiveUtils Test

### Community 22 - "Future Features Concepts"
Cohesion: 1.0
Nodes (2): AI Chat Assistant (Future), Responsive Design (Future)

### Community 23 - "Responsive Components"
Cohesion: 1.0
Nodes (2): ResponsiveContext extension, ResponsiveLayout

### Community 24 - "Invite Screen Tests"
Cohesion: 2.0
Nodes (2): InviteScreen, InviteScreen Tests

### Community 25 - "Measurement Screen Tests"
Cohesion: 1.0
Nodes (2): MeasurementScreen, MeasurementScreen Tests

### Community 26 - "Diary Screen Tests"
Cohesion: 1.0
Nodes (2): DiaryScreen, DiaryScreen Tests

### Community 27 - "Medication Sheet Tests"
Cohesion: 1.0
Nodes (2): AddMedicationSheet, AddMedicationSheet Tests

### Community 28 - "AppNotification Model"
Cohesion: 1.0
Nodes (1): AppNotification Model

### Community 29 - "ClinicalNote Model"
Cohesion: 1.0
Nodes (1): ClinicalNote Model

### Community 30 - "InvitationStatus Enum"
Cohesion: 1.0
Nodes (1): InvitationStatus Enum

### Community 31 - "PetAccessSource Enum"
Cohesion: 1.0
Nodes (1): PetAccessSource Enum

### Community 32 - "Diary Screen"
Cohesion: 1.0
Nodes (1): DiaryScreen

### Community 33 - "Auth Result Type"
Cohesion: 1.0
Nodes (1): AuthResult

### Community 34 - "OTP Result Type"
Cohesion: 1.0
Nodes (1): OtpResult

### Community 35 - "OTP Verify Result"
Cohesion: 1.0
Nodes (1): OtpVerifyResult

### Community 36 - "App Assets Registry"
Cohesion: 1.0
Nodes (1): AppAssets

### Community 37 - "Formatters Util"
Cohesion: 1.0
Nodes (1): formatters

### Community 38 - "AppUserRole Enum"
Cohesion: 1.0
Nodes (1): AppUserRole Enum

### Community 39 - "Primary Button Widget"
Cohesion: 1.0
Nodes (1): PrimaryButton Widget

### Community 40 - "Test Helpers Barrel"
Cohesion: 1.0
Nodes (1): Helpers Barrel

### Community 41 - "CSV Export Tests"
Cohesion: 1.0
Nodes (1): CsvExportHelper Test

## Knowledge Gaps
- **114 isolated node(s):** `Pet Circle README`, `DefaultFirebaseOptions`, `English Localizations`, `Hebrew Localizations`, `Figma-to-Code Workflow` (+109 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Future Features Concepts`** (2 nodes): `AI Chat Assistant (Future)`, `Responsive Design (Future)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Responsive Components`** (2 nodes): `ResponsiveContext extension`, `ResponsiveLayout`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Invite Screen Tests`** (2 nodes): `InviteScreen`, `InviteScreen Tests`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Measurement Screen Tests`** (2 nodes): `MeasurementScreen`, `MeasurementScreen Tests`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Diary Screen Tests`** (2 nodes): `DiaryScreen`, `DiaryScreen Tests`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Medication Sheet Tests`** (2 nodes): `AddMedicationSheet`, `AddMedicationSheet Tests`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `AppNotification Model`** (1 nodes): `AppNotification Model`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `ClinicalNote Model`** (1 nodes): `ClinicalNote Model`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `InvitationStatus Enum`** (1 nodes): `InvitationStatus Enum`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `PetAccessSource Enum`** (1 nodes): `PetAccessSource Enum`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Diary Screen`** (1 nodes): `DiaryScreen`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Auth Result Type`** (1 nodes): `AuthResult`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `OTP Result Type`** (1 nodes): `OtpResult`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `OTP Verify Result`** (1 nodes): `OtpVerifyResult`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `App Assets Registry`** (1 nodes): `AppAssets`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Formatters Util`** (1 nodes): `formatters`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `AppUserRole Enum`** (1 nodes): `AppUserRole Enum`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Primary Button Widget`** (1 nodes): `PrimaryButton Widget`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Test Helpers Barrel`** (1 nodes): `Helpers Barrel`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `CSV Export Tests`** (1 nodes): `CsvExportHelper Test`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `MainShell Test` connect `Auth Flow & Routing` to `Domain Enums & Access Control`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Why does `Measurement Model` connect `Domain Enums & Access Control` to `Store Test Patterns`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **Why does `AppRoutes` connect `App Screens & Navigation` to `Auth Models & Providers`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Pet Model` (e.g. with `PetAccess Model` and `CircleScreen`) actually correct?**
  _`Pet Model` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Pet Circle README`, `DefaultFirebaseOptions`, `English Localizations` to the rest of the system?**
  _114 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App Screens & Navigation` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._
- **Should `Domain Enums & Access Control` be split into smaller, more focused modules?**
  _Cohesion score 0.09 - nodes in this community are weakly interconnected._