# Pet Circle — Product Requirements Document (Update)

**Version:** 1.1
**Date:** March 5, 2026
**Status:** In Progress

---

## 1. Product Overview

**Pet Circle** is a multi-caregiver canine respiratory monitoring app built with Flutter. It enables pet owners, caregivers, and veterinarians to collaboratively track Sleeping Respiratory Rate (SRR) for early detection of heart disease progression in dogs.

SRR is a clinically validated metric: sustained readings above 30 breaths per minute during sleep can indicate worsening congestive heart failure. Pet Circle aims to make this monitoring accessible, collaborative, and actionable.

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

Pet owners who create a pet are automatically assigned the Admin role. When they invite others, they choose Member or Viewer. This enables multi-household sharing -- invited users see the shared pet in their dashboard with role-appropriate permissions.

---

## 2. Current State Summary

### 2.1 What Has Been Built

Pet Circle has progressed through 28 development iterations, delivering a functional prototype with the following capabilities:

- Role-based authentication flow (owner and vet paths)
- 4-step pet onboarding (breed, diagnosis, measurement target, care circle invites)
- Dual dashboards (owner and vet views)
- Manual SRR measurement with tap-to-count and configurable timers
- Trends visualization with SRR charting (Syncfusion)
- Notifications system with drawer-based UI
- Settings drawer with appearance, notification, and measurement preferences
- Internationalization (English and Hebrew)
- Dark mode support
- Figma-driven design system with centralized tokens

### 2.2 Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart SDK ^3.10.4) |
| State | StatefulWidget + ValueNotifier (locale, dark mode) |
| Backend | Firebase Auth + Firestore (feature-flagged off, `kEnableFirebase = false`) |
| Charts | Syncfusion Flutter Charts |
| Assets | flutter_svg, google_fonts (Inter) |
| Images | Dog CEO API (pet photos), UI Avatars (user avatars) |
| Camera | image_picker (for pet profile photos) |

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
├── Role Selection
│   ├── [Firebase ON] → Auth Screen → Verify Email → Dashboard
│   └── [Firebase OFF] → Main Shell (bypasses auth)
│
Main Shell (Header + Bottom Nav + Content)
├── Home Tab
│   ├── Owner Dashboard (pet cards with quick actions)
│   └── Vet Dashboard (patient grid with stats)
├── Trends Tab
│   └── Trends Screen (SRR chart, medication, history, export)
├── Measure Tab
│   └── Measurement Screen (manual tap + VisionRR placeholder)
├── Messages Tab
│   └── Messages Screen (notification list)
├── [Avatar tap] → Settings Drawer
├── [Bell tap] → Notifications Drawer
└── Pet Card tap → Pet Detail Screen
    ├── Latest reading + status
    ├── Measurement history chart
    ├── Clinical notes (vet-writable)
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
| `/measurement` | SRR Measurement | Owner, Caregiver |
| `/trends` | Trends & Analytics | All roles |
| `/messages` | Notifications | All roles |
| `/settings` | Settings Drawer | All roles |

---

## 4. Feature Specifications

### 4.1 Authentication & Onboarding

#### Auth Flow
- **Email/password** sign-up and sign-in
- **Google Sign-In** and **Apple Sign-In** (social auth)
- **Password reset** via email
- **Email verification** with polling and resend capability
- **Role selection** (Veterinarian or Pet Owner) determines downstream flow
- Firebase auth is feature-flagged; when disabled, role selection navigates directly to the main shell with mock data

#### Pet Onboarding (Owner Only)
A 4-step guided flow for setting up a pet profile:

| Step | Content |
|------|---------|
| Step 1 | Pet name, breed (searchable dropdown via Dog CEO API or hardcoded list), age, photo upload |
| Step 2 | Heart condition/diagnosis entry |
| Step 3 | Target SRR range and measurement frequency |
| Step 4 | Care circle invitations (email-based) |

### 4.2 Owner Dashboard

- Displays pet cards for all owned pets
- Each card shows: pet photo, name, breed/age, latest SRR reading, status badge
- Quick action buttons per pet: **Measure** and **Trends**
- Tapping a card navigates to Pet Detail

### 4.3 Vet Dashboard

- Grid layout of all clinic patients
- Summary statistics: count of Normal, Elevated, and total measurements
- Each patient card shows pet info and status
- Tapping a card navigates to Pet Detail

### 4.4 Pet Detail Screen

- **Pet profile header**: photo, name, breed/age, status badge
- **Latest reading**: most recent SRR value with timestamp
- **Measurement history chart**: visual SRR trend over time
- **Clinical notes**: list of vet-authored observations; vets can add new notes
- **Care circle**: list of team members with roles and avatars

### 4.5 SRR Measurement

#### Manual Mode
- Tap-to-count interface for breath counting
- Configurable timer durations: 15s, 30s, 60s
- Real-time BPM calculation during counting
- Haptic feedback on each tap
- Results display with status classification

#### VisionRR Mode (Placeholder)
- Camera-based AI-assisted measurement
- Currently a placeholder UI — not yet functional

#### Status Classification

| Status | SRR Range | Color |
|--------|-----------|-------|
| Normal | < 30 BPM | Light Blue |
| Elevated | 30–40 BPM | Light Yellow |
| Critical | > 40 BPM | Cherry |

### 4.6 Trends & Analytics

- **SRR over time**: line chart with date range filtering
- **Medication management**: track active medications
- **Measurement history**: chronological list of all readings
- **Export**: data export capability (planned: PDF)

### 4.7 Notifications / Messages

- Notification list with categorized alerts:
  - Measurement alerts (elevated/critical readings)
  - Medication reminders
  - Care circle updates (new members, notes)
  - Report availability
- **Notifications drawer**: full-screen `DraggableScrollableSheet` accessible from the bell icon in the app header; shows unread count and dismissable cards

### 4.8 Settings

Implemented as a slide-up drawer (opened by tapping the user avatar):

| Section | Options |
|---------|---------|
| Appearance | Dark mode toggle, Language selection (EN/HE) |
| Care Circle | Manage members |
| Notifications | Push notification toggle, Emergency alerts toggle |
| Measurement | VisionRR toggle, SRR thresholds configuration |
| Data | Export data |
| About | Terms, Privacy, Feedback, App version |

### 4.9 Internationalization

- Supported locales: English (en), Hebrew (he)
- Locale switching via settings
- RTL layout support for Hebrew
- Localization implemented via `AppLocalizations`

### 4.10 Dark Mode

- Full dark mode support via `AppColorsTheme` (ThemeExtension)
- Toggle in settings persisted via `ValueNotifier`
- All screens and widgets adapt to light/dark theme

---

## 5. Design System

### 5.1 Color Palette

| Token | Light | Usage |
|-------|-------|-------|
| `white` | #FFFFFF | Backgrounds, card surfaces |
| `offWhite` | #F9F5F0 | Page backgrounds |
| `lightYellow` | #F5E6C8 | Elevated status, warm accents |
| `chocolate` | #5B2C3F | Primary actions, text emphasis |
| `pink` | #E8B4B8 | Secondary accents |
| `cherry` | #C0392B | Critical status, errors |
| `lightBlue` | #B8D4E8 | Normal status, info |
| `blue` | #5DADE2 | Links, interactive elements |
| `black` | #2C2C2C | Primary text |

### 5.2 Typography

- **Font family**: Inter (via Google Fonts)
- **Scale**: heading1, heading2, heading3, body, caption, badge, button
- **Responsive**: adapts to theme context

### 5.3 Spacing

| Token | Value |
|-------|-------|
| `xs` | 4px |
| `sm` | 8px |
| `md` | 16px |
| `lg` | 24px |
| `xl` | 32px |

### 5.4 Border Radii

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Subtle rounding |
| `sm` | 8px | Input fields, small cards |
| `small` | 12px | Cards, containers |
| `medium` | 16px | Modal sheets, larger cards |
| `large` | 20px | Prominent surfaces |
| `full` | 100px | Circular elements |
| `pill` | 172px | Pills, tags, toggle backgrounds |

### 5.5 Component Library

| Widget | Description |
|--------|-------------|
| `PrimaryButton` | Primary/secondary action button with `filled` and `outlined` variants |
| `NeumorphicCard` | Card with neumorphic outer/inner shadow treatment |
| `AppHeader` | Top bar with user avatar, active pet name, profile, and notification bell |
| `BottomNavBar` | Tab bar: Home, Trends, Measure, Messages |
| `StatusBadge` | Colored badge for Normal / Elevated / Critical status |
| `TogglePill` | Toggle switch component |
| `DogPhoto` | Pet photo display with placeholder fallback |
| `LabeledTextField` | Text input with floating label |
| `AppDropdown` | Styled dropdown trigger with label, value, and animated chevron |
| `OnboardingShell` | Consistent layout wrapper for onboarding steps |
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
| breedAndAge | String | e.g. "Cavalier King Charles, 5 years" |
| imageUrl | String | Photo URL |
| statusLabel | String | "Normal", "Elevated", "Critical" |
| statusColorHex | String | Hex color for status display |
| latestMeasurement | Measurement? | Most recent SRR reading |
| careCircle | List\<CareCircleMember\> | Team members |

**Measurement**
| Field | Type | Description |
|-------|------|-------------|
| bpm | int | Breaths per minute |
| recordedAtLabel | String | Human-readable timestamp |

**CareCircleMember**
| Field | Type | Description |
|-------|------|-------------|
| name | String | Member name |
| avatarUrl | String | Avatar image URL |
| role | String | "Owner", "Vet", "Caregiver" |

**ClinicalNote**
| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique identifier |
| authorName | String | Note author |
| authorAvatarUrl | String | Author avatar |
| content | String | Note text |
| createdAt | DateTime | Timestamp |

**User / AppUser**
| Field | Type | Description |
|-------|------|-------------|
| uid / id | String | Unique identifier |
| email | String | User email |
| role | UserRole | vet, owner, caregiver |
| displayName | String | Display name |
| photoUrl | String? | Profile photo |
| petIds | List\<String\> | Associated pet IDs (Firestore) |

### 6.2 Mock Data (Demo Mode)

| Entity | Data |
|--------|------|
| Users | Dr. Smith (vet), Hila (owner) |
| Pets | Princess (Hila's), Max, Luna, Rocky |
| Care Circle | Hila, Dr. Smith, Sarah, John, Emily, Mike |
| Clinical Notes | 2 for Princess, 1 for Max |
| Measurements | 5 readings for Princess (22–25 BPM) |

---

## 7. Recent Changes (Current Sprint)

### 7.1 Design Token Migration

Systematic replacement of all hardcoded `BorderRadius.circular(X)` values across 22+ files with centralized `AppRadii` constants. Three new radius tokens added (`xs`, `sm`, `full`). All instances are now `const` for improved performance.

### 7.2 Notifications Drawer

New `NotificationsDrawer` widget using `DraggableScrollableSheet` — accessible from the bell icon in the app header. Displays unread count badge, dismissable notification cards, and follows the same slide-up pattern as the settings drawer.

### 7.3 PrimaryButton Variants

Added `PrimaryButtonVariant` enum with `filled` (default) and `outlined` variants. Outlined variant renders with a white background, subtle border, and chocolate text. Auto-adapts foreground color based on variant.

### 7.4 New Shared Widgets

- **AppDropdown**: Styled dropdown trigger with label, current value, and animated chevron. Used in onboarding and form screens.
- **SettingsRow**: Reusable settings list item with title, optional description, optional SVG icon, and trailing widget slot.

### 7.5 Status Color Alignment

Updated mock data to align status indicator colors with the design system: Normal uses `lightBlue` (was green), Elevated uses `cherry` (was amber).

---

## 8. Roadmap

### Phase 1 — Foundation (Complete)
- [x] Role-based authentication (owner, vet)
- [x] Pet onboarding flow (4 steps)
- [x] Owner and vet dashboards
- [x] Manual SRR measurement (tap-to-count)
- [x] Pet detail with measurement history
- [x] Clinical notes (vet-authored)
- [x] Care circle display
- [x] Notifications UI
- [x] Settings drawer
- [x] Dark mode
- [x] i18n (English, Hebrew)
- [x] Design system with centralized tokens

### Phase 2 — Backend & Persistence (Next)
- [ ] Enable Firebase Auth in production
- [ ] Firestore data persistence for pets, measurements, and notes
- [ ] Real-time sync across care circle members
- [ ] User profile management (edit name, photo)
- [ ] Care circle invitations (send/accept/decline)
- [ ] Push notifications via FCM

### Phase 3 — Intelligence & Insights
- [ ] VisionRR: AI-powered SRR measurement via device camera
- [ ] Trend analysis with anomaly detection
- [ ] Automated alerts when SRR exceeds thresholds
- [ ] Measurement reminders (configurable schedule)
- [ ] Vet-to-owner messaging within the app

### Phase 4 — Data & Reporting
- [ ] PDF report generation and export
- [ ] Measurement data CSV export
- [ ] Shareable pet health summaries
- [ ] Vet clinic analytics dashboard

### Phase 5 — Platform Expansion
- [ ] Apple Watch companion app (quick measurement)
- [ ] WearOS companion app
- [ ] Native iOS and Android optimizations
- [ ] Offline mode with sync-on-reconnect

---

## 9. Technical Considerations

### 9.1 Firebase Feature Flag

Firebase integration is controlled by `kEnableFirebase` in `main.dart`. When `false`, the app runs entirely with mock data and bypasses authentication. This allows UI development and testing without backend dependencies.

### 9.2 State Management

Currently using `StatefulWidget` with local state and `ValueNotifier` for global preferences (locale, dark mode). As backend integration proceeds, consider migrating to a more scalable solution (Provider, Riverpod, or Bloc) for managing:
- Authentication state
- Pet data across screens
- Real-time measurement updates
- Care circle membership

### 9.3 Offline-First Architecture

SRR measurements should be stored locally first and synced when connectivity is available. This is critical for the use case — users may measure their sleeping pet in environments with poor connectivity.

### 9.4 Data Privacy

Pet health data and user information require:
- Encrypted storage on device
- Secure transmission (HTTPS/TLS)
- GDPR-compliant data handling
- User consent for data sharing within care circles
- Data deletion capability

---

## 10. Success Metrics

| Metric | Target |
|--------|--------|
| Measurement frequency | ≥ 3 readings per pet per week |
| Care circle size | ≥ 2 members per pet |
| Vet engagement | ≥ 1 clinical note per patient per month |
| Alert response time | < 24 hours for elevated/critical readings |
| User retention (30-day) | > 60% |
| App crash rate | < 0.5% |

---

## 11. Open Questions

1. **VisionRR accuracy**: What validation is needed before releasing AI-assisted measurement to users?
2. **Multi-pet households**: How should the dashboard prioritize display when an owner has 5+ pets?
3. **Caregiver permissions**: Should caregivers see clinical notes, or only owners and vets?
4. **Notification fatigue**: What is the right frequency for measurement reminders without causing alert fatigue?
5. **Vet onboarding**: Should vets self-register or be verified through a clinic portal?
