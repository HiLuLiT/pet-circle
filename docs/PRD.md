# Pet Circle — Product Requirements Document

**Version:** 2.0
**Date:** March 6, 2026
**Status:** Phase 1 Complete

---

## 1. Product Overview

**Pet Circle** is a collaborative canine respiratory monitoring app built with Flutter. It enables pet owners and veterinarians to track Sleeping Respiratory Rate (SRR) for early detection of heart disease progression in dogs.

SRR is a clinically validated metric: sustained readings above 30 breaths per minute during sleep can indicate worsening congestive heart failure. Pet Circle makes this monitoring accessible, collaborative, and actionable through a care circle sharing model.

### 1.1 Vision

A single platform where every member of a pet's care team — owners, family members, pet sitters, and veterinarians — can monitor respiratory health, share observations, and respond early to changes.

### 1.2 Target Users

**App-Level Roles** (selected at sign-in):

| Role | Description |
|------|-------------|
| **Pet Owner** | Creates pet profiles, takes measurements, manages care circles, and coordinates monitoring |
| **Veterinarian** | Monitors patients remotely, reviews trends, and adds clinical notes |

**Care Circle Roles** (per-pet, assigned via invite):

| Role | Permissions |
|------|------------|
| **Admin** | Full control: edit pet, manage circle, delete pet, measure, view all |
| **Member** | Measure, view history/trends, add notes. Cannot edit pet or manage circle |
| **Viewer** | View all data, add clinical notes. Cannot measure or edit |

Pet owners who create a pet are automatically assigned the Admin role. When they invite others, they choose Member or Viewer. This enables multi-household sharing — invited users see the shared pet in their dashboard with role-appropriate permissions.

---

## 2. Current State Summary

### 2.1 What Has Been Built

Pet Circle Phase 1 is complete, delivering a fully functional prototype with 50+ user stories implemented:

- Two-role authentication flow (owner and vet) with Firebase feature flag
- 4-step pet onboarding with searchable breed dropdown, persistent state, and Back/Next navigation
- Owner dashboard with pet cards, Add Pet, long-press delete, and empty state
- Vet dashboard with clinic overview, patient grid, and real stats from stores
- Manual SRR measurement with tap-to-count, configurable timers, and haptic feedback
- Unified health trends view with SRR chart, stat cards, time-range filtering, and measurement history
- Standalone medication management screen (add, edit, list, export)
- Pet detail with edit (admin-only), measurement history, clinical notes, and care circle
- Care circle role system (Admin/Member/Viewer) with permissions enforcement
- Multi-pet support: global pet switcher in header, add/edit/delete pets
- User profile management (edit name/photo from settings)
- Sign out from settings drawer
- Notifications drawer (bell icon) with categorized alerts
- Settings drawer with appearance, notification, measurement, data, and about sections
- Internationalization (English and Hebrew) with RTL support
- Full dark mode support
- Centralized design system with enforced token usage

### 2.2 Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart SDK ^3.10.4) |
| State | `ChangeNotifier` stores (global singletons) + `ValueNotifier` (locale, dark mode) |
| Backend | Firebase Auth + Firestore (feature-flagged off, `kEnableFirebase = false`) |
| Charts | Syncfusion Flutter Charts |
| Assets | flutter_svg, google_fonts (Inter) |
| Images | Local placeholders (pet photos), UI Avatars API (user avatars) |

### 2.3 Platform Targets

- Web (Chrome) — primary development target
- iOS
- Android
- macOS Desktop

---

## 3. Information Architecture

### 3.1 Screen Map

```
Welcome Screen
├── Role Selection (Owner / Vet)
│   ├── [Firebase ON] → Auth Screen → Verify Email → Dashboard
│   └── [Firebase OFF] → Main Shell (bypasses auth)
│
Main Shell (Header + Bottom Nav + Content)
├── Home Tab (index 0)
│   ├── Owner Dashboard (pet cards with quick actions)
│   └── Vet Dashboard (patient grid with stats)
├── Trends Tab (index 1)
│   └── Health Trends (unified: stats, chart, history, export)
├── Measure Tab (index 2)
│   └── Measurement Screen (manual tap + VisionRR placeholder)
├── Medication Tab (index 3)
│   └── Medication Screen (add, edit, list, export)
├── [Header avatar] → Settings Drawer
├── [Header bell] → Notifications Drawer
├── [Header pet chip] → Pet Switcher (bottom sheet)
└── Pet Card tap → Pet Detail Screen
    ├── Edit pet (admin-only, bottom sheet)
    ├── Latest reading + status
    ├── Measurement history chart
    ├── Clinical notes (all roles can add)
    └── Care circle members
```

### 3.2 Routes

| Route | Screen | Access |
|-------|--------|--------|
| `/` | Welcome | All |
| `/role-selection` | Role Selection | All |
| `/auth` | Auth (sign in/up) | All |
| `/verify-email` | Email Verification | All |
| `/onboarding` | Pet Onboarding (4 steps) | Owner |
| `/main-shell` | Main Shell | Authenticated |
| `/owner-dashboard` | Owner Dashboard | Owner |
| `/vet-dashboard` | Vet Dashboard | Vet |
| `/pet-detail` | Pet Detail | All roles |
| `/measurement` | SRR Measurement | Owner |
| `/trends` | Health Trends | All roles |
| `/settings` | Settings Drawer | All roles |
| `/messages` | Notifications (standalone) | All roles |

---

## 4. Feature Specifications

### 4.1 Authentication & Onboarding

#### Auth Flow
- **Email/password** sign-up and sign-in
- **Google Sign-In** and **Apple Sign-In** (social auth)
- **Password reset** via email
- **Email verification** with polling and resend capability
- **Role selection** (Veterinarian or Pet Owner) determines downstream flow
- **Sign out** from settings drawer with confirmation dialog
- Firebase auth is feature-flagged; when disabled, role selection navigates directly to the main shell with mock data

#### Pet Onboarding (Owner Only)
A 4-step guided flow with visible Back/Next buttons and persistent state across steps:

| Step | Content |
|------|---------|
| Step 1 | Pet name, searchable breed dropdown (148 breeds with live filter), age, photo URL |
| Step 2 | Heart condition/diagnosis dropdown (saved to `Pet.diagnosis`) |
| Step 3 | Target SRR rate selection (30/35/custom BPM, saved to `settingsStore`) |
| Step 4 | Care circle invitations (email + role: Member/Viewer) |

### 4.2 Owner Dashboard

- Displays pet cards for all owned pets from `petStore`
- Each card shows: pet photo, name, breed/age, latest SRR reading (from `measurementStore`), care circle avatars
- Quick action buttons per pet: **Measure** and **Trends**
- Tapping a card navigates to Pet Detail
- **Long-press** a card to delete pet (admin-only, with confirmation)
- **"Add Pet"** button at bottom navigates to onboarding flow
- Empty state with CTA when no pets exist

### 4.3 Vet Dashboard

- "Clinic Overview" heading with patient count
- Grid layout of all clinic patients (from `petStore.allClinicPets`)
- Summary statistics: Normal count, Need Attention count, Measurements This Week (from stores)
- Each patient card shows pet info, status badge, owner name, and "View Only" badge
- Tapping a card navigates to Pet Detail

### 4.4 Pet Detail Screen

- **SliverAppBar** with pet image, gradient overlay, name, breed, status badge
- **Edit button** (admin-only): opens bottom sheet with name, searchable breed dropdown, and photo URL
- **Latest reading**: BPM value and time ago from `measurementStore`
- **Measurement history**: bar chart of recent readings with "View Graph" link to trends
- **Clinical notes**: add notes (all roles), persisted via `noteStore`; list with author avatars
- **Care circle**: member list with role badges (Admin/Member/Viewer)

### 4.5 SRR Measurement

#### Manual Mode
- Tap-to-count interface for breath counting
- Configurable timer durations: 15s, 30s, 60s
- Real-time BPM calculation during counting
- Haptic feedback on each tap
- Results dialog with BPM, "Measure Again", and "Add to Graph"
- Saves to `measurementStore` for the active pet (selected via header pet switcher)
- Reset button during active measurement

#### VisionRR Mode (Placeholder)
- Camera-based AI-assisted measurement
- Currently a placeholder UI — Phase 3 feature

#### Status Classification

| Status | SRR Range | Color |
|--------|-----------|-------|
| Normal | < 30 BPM | Light Blue |
| Elevated | 30–40 BPM | Light Yellow |
| Critical | > 40 BPM | Cherry |

### 4.6 Health Trends

Single unified view (no tabs) with:
- **Title** with pet name and recording count
- **Time-range filter**: dropdown (24h, 3d, 7d, 30d, 90d, custom) that filters all data
- **Export** button: CSV preview dialog with measurement data
- **Stat cards** (2×2 grid): Average SRR, Range (min-max), 7-day Trend, Status distribution (normal/elevated/critical pills)
- **SRR chart**: Syncfusion area chart with threshold plot bands (30 BPM normal, 40 BPM alert)
- **Legend badges**: Normal (<30), Elevated (30-40), Alert (>40)
- **Measurement history list**: each entry shows BPM, date/time, status badge; swipe-to-delete with confirmation
- Empty state when no measurements exist

### 4.7 Medication Management

Standalone screen in bottom nav (index 3):
- **Header** with title, pet name, active treatment count, and "Add Medication" button
- **Medication list**: each card shows name, dosage, frequency, start date, active/done status
- **Tap to edit**: opens pre-filled bottom sheet with medication details
- **Add medication**: bottom sheet with name, dosage, frequency dropdown, start/end dates, prescribed by, purpose, notes, reminder toggle
- **Export**: CSV preview dialog with medication log
- **Clinical record info**: disclaimer card with export button

### 4.8 Notifications

- **Notifications drawer**: `DraggableScrollableSheet` accessible from the bell icon in the header
- Categorized alerts: measurement, medication, care circle, report
- Tap to mark read with type-specific actions
- Unread count badge on bell icon
- No dedicated tab — notifications are drawer-only

### 4.9 Settings

Slide-up drawer (opened by tapping the user avatar):

| Section | Options |
|---------|---------|
| Edit Profile | Edit display name and profile photo URL |
| Appearance | Dark mode toggle, Language selection (EN/HE) |
| Care Circle | View members with role badges, invite (Member/Viewer), remove with confirmation |
| Notifications | Push notification toggle, Emergency alerts toggle |
| Measurement | VisionRR toggle (Coming Soon), SRR thresholds configuration |
| Data & Privacy | Auto-export toggle, Export all data, Share with vet |
| About | Terms of Service, Privacy Policy, Help & Support |
| Sign Out | Confirmation dialog, navigates to welcome screen |

### 4.10 Multi-Pet Support

- **Global pet switcher**: header pet chip opens bottom sheet to switch active pet (when 2+ pets)
- Active pet stored in `petStore.activePetIndex` — shared across all screens
- All data-driven screens (trends, measurement, medication) read from `petStore.activePet`
- Add additional pets via "Add Pet" button on owner dashboard → onboarding flow

### 4.11 Internationalization

- Supported locales: English (en), Hebrew (he)
- Locale switching via settings
- RTL layout support for Hebrew
- All user-facing strings localized via `AppLocalizations`
- Enforced by cursor rule: no hardcoded strings in widgets

### 4.12 Dark Mode

- Full dark mode support via `AppColorsTheme` (ThemeExtension)
- Toggle in settings persisted via `ValueNotifier`
- All screens and widgets adapt to light/dark theme

---

## 5. Design System

Centralized in `lib/theme/app_theme.dart`. Enforced by always-apply cursor rule (`design-system-enforcement.mdc`).

### 5.1 Color Palette

| Token | Value | Usage |
|-------|-------|-------|
| `white` | #FFFFFF | Backgrounds, card surfaces |
| `offWhite` | #F8F1E7 | Warm background, scaffold |
| `lightYellow` | #FFECB7 | Accent highlights |
| `chocolate` | #402A24 | Primary text, buttons |
| `pink` | #FFC2B5 | Soft accent, decorative |
| `cherry` | #E64E60 | Alerts, warnings, errors |
| `lightBlue` | #75ACFF | Normal status, info |
| `blue` | #146FD9 | Links, interactive elements |
| `black` | #000000 | Rare, inverted contexts |

### 5.2 Typography

- **Font family**: Inter (via Google Fonts)
- **Scale**: heading1 (28px), heading2 (24px), heading3 (18px), body (14px), caption (12px), badge (12px bold), button (16px bold)

### 5.3 Spacing — `AppSpacing`

| Token | Value |
|-------|-------|
| `xs` | 4px |
| `sm` | 8px |
| `md` | 16px |
| `lg` | 24px |
| `xl` | 32px |

### 5.4 Border Radii — `AppRadii`

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Progress bars, small indicators |
| `sm` | 8px | Chips, small containers |
| `small` | 12px | Cards, input containers |
| `medium` | 16px | Section cards, settings cards |
| `large` | 20px | Large containers, tab selectors |
| `full` | 100px | Circular elements (avatars) |
| `pill` | 999px | Buttons, toggles |

### 5.5 Component Library

| Widget | Description |
|--------|-------------|
| `PrimaryButton` | Primary/secondary action button with filled/outlined variants |
| `NeumorphicCard` | Card with neumorphic outer/inner shadow treatment |
| `AppHeader` | Top bar with user avatar, active pet selector, and notification bell |
| `BottomNavBar` | Tab bar: Home, Trends, Measure, Medication |
| `StatusBadge` | Colored badge for Normal / Elevated / Critical status |
| `TogglePill` | Toggle switch component |
| `DogPhoto` | Pet photo display with placeholder fallback |
| `LabeledTextField` | Text input with label |
| `BreedSearchField` | Searchable breed dropdown with 148 breeds and live filtering |
| `AppDropdown` | Styled dropdown trigger with label, value, and animated chevron |
| `OnboardingShell` | Onboarding layout with progress bar, Back/Next buttons |
| `SettingsRow` | Settings list item with title, description, icon, and trailing widget |
| `AppImage` | Wrapper for image loading with error handling |
| `UserAvatar` | User avatar with fallback to UI Avatars API |
| `RoundIconButton` | Circular icon button |

---

## 6. Data Model

### 6.1 Core Entities

**Pet**

| Field | Type | Description |
|-------|------|-------------|
| name | String | Pet name |
| breedAndAge | String | e.g. "Cavalier King Charles • 5 years old" |
| imageUrl | String | Photo URL |
| statusLabel | String | "Normal", "Elevated", "Critical" |
| statusColorHex | int | Color value for status display |
| latestMeasurement | Measurement | Most recent SRR reading |
| careCircle | List\<CareCircleMember\> | Team members with roles |
| diagnosis | String? | Medical diagnosis (optional) |

**Measurement**

| Field | Type | Description |
|-------|------|-------------|
| bpm | int | Breaths per minute |
| recordedAt | DateTime | When the measurement was taken |
| recordedAtLabel | String? | Optional human-readable label |

**Medication**

| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique identifier |
| name | String | Medication name |
| dosage | String | Dosage (e.g. "5mg") |
| frequency | String | Frequency (e.g. "Once daily") |
| startDate | DateTime | Start date |
| isActive | bool | Whether currently active |

**CareCircleMember**

| Field | Type | Description |
|-------|------|-------------|
| name | String | Member name |
| avatarUrl | String | Avatar image URL |
| role | CareCircleRole | admin, member, or viewer (enum) |

**ClinicalNote**

| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique identifier |
| authorName | String | Note author |
| authorAvatarUrl | String | Author avatar |
| content | String | Note text |
| createdAt | DateTime | Timestamp |

**User**

| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique identifier |
| name | String | Display name |
| email | String | User email |
| role | UserRole | vet or owner |
| avatarUrl | String | Profile photo URL |
| pets | List\<Pet\> | Associated pets |

### 6.2 State Management (Stores)

| Store | Global Instance | Purpose |
|-------|----------------|---------|
| `PetStore` | `petStore` | Owner pets, clinic pets, active pet index, care circle operations |
| `MeasurementStore` | `measurementStore` | Per-pet measurements, add/remove/filter |
| `NoteStore` | `noteStore` | Per-pet clinical notes |
| `MedicationStore` | `medicationStore` | Per-pet medications, add/update/remove/toggle |
| `NotificationStore` | `notificationStore` | In-app notifications, mark read |
| `UserStore` | `userStore` | Current user, role |
| `SettingsStore` | `settingsStore` | Thresholds, toggles, preferences |

### 6.3 Mock Data (Demo Mode)

| Entity | Data |
|--------|------|
| Users | Dr. Smith (vet), Hila (owner) |
| Pets | Princess (Hila's admin), Max (John's), Luna (Emily's), Rocky (Mike's) |
| Care Circle | Hila (admin), Dr. Smith (viewer), Sarah (member) |
| Clinical Notes | 2 for Princess, 1 for Max |
| Measurements | 5 readings for Princess (21–25 BPM) |
| Medications | Furosemide 12.5mg, Pimobendan 2.5mg for Princess |
| Notifications | Measurement reminder, medication due, care circle update, weekly report |

---

## 7. Roadmap

### Phase 1 — Foundation (Complete)
- [x] Two-role authentication (owner, vet) with Firebase feature flag
- [x] 4-step pet onboarding with searchable breed, persistent state, Back/Next
- [x] Owner dashboard with pet cards, add pet, delete pet
- [x] Vet dashboard with clinic overview and real stats
- [x] Manual SRR measurement with tap-to-count and haptics
- [x] Unified health trends with chart, stats, filtering, export, measurement history
- [x] Standalone medication management (add, edit, list, export)
- [x] Pet detail with edit, notes, history, care circle
- [x] Care circle role system (Admin/Member/Viewer) with permissions
- [x] Multi-pet support with global pet switcher
- [x] User profile management (edit name/photo)
- [x] Sign out
- [x] Notifications drawer
- [x] Settings drawer (appearance, notifications, measurement, data, about)
- [x] Dark mode
- [x] i18n (English, Hebrew) — enforced, no hardcoded strings
- [x] Design system with centralized tokens — enforced via cursor rule

### Phase 2 — Backend & Persistence (Next)
- [ ] Enable Firebase Auth in production (`kEnableFirebase = true`)
- [ ] Firestore data persistence for pets, measurements, notes, medications
- [ ] Care circle as Firestore subcollection — invited users see shared pets
- [ ] Real-time sync across care circle members via Firestore streams
- [ ] Push notifications via FCM
- [ ] Invitation flow: send email, recipient joins via deep link, matched to care circle role

### Phase 3 — Intelligence & Insights
- [ ] VisionRR: AI-powered SRR measurement via device camera
- [ ] Trend analysis with anomaly detection
- [ ] Automated alerts when SRR exceeds thresholds
- [ ] Measurement reminders (configurable schedule)
- [ ] Vet-to-owner messaging within the app

### Phase 4 — Data & Reporting
- [ ] PDF report generation and export
- [ ] Actual CSV file download (currently preview-only)
- [ ] Shareable pet health summaries
- [ ] Vet clinic analytics dashboard

### Phase 5 — Platform Expansion
- [ ] Apple Watch companion app (quick measurement)
- [ ] WearOS companion app
- [ ] Native iOS and Android optimizations
- [ ] Offline mode with sync-on-reconnect

---

## 8. Technical Considerations

### 8.1 Firebase Feature Flag

Firebase integration is controlled by `kEnableFirebase` in `main.dart`. When `false`, the app runs entirely with mock data and bypasses authentication. This allows UI development and testing without backend dependencies.

### 8.2 State Management

Uses global `ChangeNotifier` stores (7 stores) instantiated as top-level singletons and seeded from mock data at startup. Screens access stores directly via imports and rebuild using `ListenableBuilder`. This pattern is documented in `state-management.mdc`.

When `kEnableFirebase` is enabled, stores will be updated to load from Firestore and listen to streams — the screen-facing API will not change.

### 8.3 Design System Enforcement

Two cursor rules enforce consistency:
- `figma-design-system.mdc` — comprehensive design token reference and Figma workflow
- `design-system-enforcement.mdc` (always-apply) — mandatory checklist: tokens, components, i18n

### 8.4 Offline-First Architecture (Phase 2)

SRR measurements should be stored locally first and synced when connectivity is available. This is critical for the use case — users may measure their sleeping pet in environments with poor connectivity.

### 8.5 Data Privacy

Pet health data and user information require:
- Encrypted storage on device
- Secure transmission (HTTPS/TLS)
- GDPR-compliant data handling
- User consent for data sharing within care circles
- Data deletion capability (pet delete and measurement delete already implemented in UI)

---

## 9. Success Metrics

| Metric | Target |
|--------|--------|
| Measurement frequency | ≥ 3 readings per pet per week |
| Care circle size | ≥ 2 members per pet |
| Vet engagement | ≥ 1 clinical note per patient per month |
| Alert response time | < 24 hours for elevated/critical readings |
| User retention (30-day) | > 60% |
| App crash rate | < 0.5% |

---

## 10. Open Questions

1. **VisionRR accuracy**: What validation is needed before releasing AI-assisted measurement to users?
2. **Multi-pet households**: How should the dashboard prioritize display when an owner has 5+ pets? (Pet switcher implemented, but dashboard shows all)
3. **Notification fatigue**: What is the right frequency for measurement reminders without causing alert fatigue?
4. **Vet onboarding**: Should vets self-register or be verified through a clinic portal?
5. **Offline sync conflicts**: How should conflicting measurements from multiple care circle members be resolved?
