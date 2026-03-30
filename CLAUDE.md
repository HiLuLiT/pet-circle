# Pet Circle — Claude Code Instructions

## Project Overview

Flutter app for collaborative canine respiratory monitoring (Sleeping Respiratory Rate / SRR).
Roles: Pet Owner and Veterinarian at the app level; Admin / Member / Viewer per-pet via care circles.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Dart / Flutter (SDK ^3.10.4) |
| Backend | Firebase (Auth, Firestore, Deep Links) |
| Auth | Firebase Auth + Google Sign-In + Sign in with Apple |
| Charts | Syncfusion Flutter Charts |
| Notifications | flutter_local_notifications + timezone |
| Localisation | flutter_localizations — `en` and `he` supported |
| State | `ChangeNotifier` stores (global singletons) |

## Architecture

**Global store singletons** — all live in `lib/stores/`:
- `petStore` — pets, care circle membership, access control
- `measurementStore`, `medicationStore`, `noteStore` — per-pet Firestore subscriptions
- `userStore`, `settingsStore`, `notificationStore` — user/app-level state

Stores expose `subscribeForUser(uid)` / `cancelSubscription()` Firestore streams.
When `kEnableFirebase = false` (in `lib/main.dart`), stores are seeded from `lib/data/mock_data.dart` instead.

**Services** (`lib/services/`) — thin Firestore/Firebase wrappers.
**Models** (`lib/models/`) — immutable data classes with `copyWith`.
**Screens** (`lib/screens/`) — organised by feature: `auth/`, `dashboard/`, `measurement/`, etc.
**Widgets** (`lib/widgets/`) — shared UI: `NeumorphicCard`, `PrimaryButton`, `StatusBadge`, etc.

## Key Entry Points

- **App entry**: `lib/main.dart` → `PetCircleApp`
- **Routes**: `lib/app_routes.dart`
- **Auth gate**: `lib/screens/auth/auth_gate.dart`
- **Theme**: `lib/theme/app_theme.dart`
- **Localisation**: `lib/l10n/` (generated from ARB files via `flutter gen-l10n`)

## Code Conventions

- Models are **immutable** — always use `copyWith`, never mutate in-place.
- Stores mutate their own private lists then call `notifyListeners()`.
- All user-visible strings go through `AppLocalizations` (no hardcoded EN strings in widgets).
- File naming: `snake_case.dart` for all Dart files.
- Feature flag: `const bool kEnableFirebase = true` in `main.dart` — toggle for mock-data dev.

## Common Commands

```bash
# Run on a connected device / simulator
flutter run

# Run tests
flutter test

# Analyse (lint)
flutter analyze

# Generate localisation files
flutter gen-l10n

# Get dependencies
flutter pub get
```

## Project Structure

```
lib/
  main.dart            # App entry, kEnableFirebase flag, mock seeding
  app_routes.dart      # Named route constants
  firebase_options.dart
  data/mock_data.dart  # Dev-mode seed data
  models/              # Immutable data classes
  stores/              # ChangeNotifier global singletons
  services/            # Firestore / Firebase service layer
  screens/             # Feature screens (auth, dashboard, measurement, …)
  widgets/             # Shared UI components
  theme/               # AppTheme, AppAssets
  l10n/                # Localisation (en + he)
assets/figma/          # Design assets
docs/                  # PRD, bug log, firebase status, future features
```

## Where to Look

| Task | Location |
|------|---------|
| Add a screen | `lib/screens/<feature>/`, register in `lib/app_routes.dart` + `main.dart` |
| Add a model field | `lib/models/<model>.dart` — add to constructor + `copyWith` |
| Add Firestore logic | `lib/services/pet_service.dart` or relevant service |
| Change store state | `lib/stores/<store>.dart` — mutate private field, call `notifyListeners()` |
| Add a localised string | `lib/l10n/app_en.arb` + `app_he.arb`, then `flutter gen-l10n` |
| Track a bug | `docs/bug-log.md` |
| Review future features | `docs/future-features.md` |

## Current Status

- **Phase:** Phase 2 — active feature development (Phase 1 complete: Firebase wiring, auth, stores, basic screens)
- **Known bugs:** See `docs/bug-log.md`
- **Planned features:** See `docs/future-features.md`

### Important constraints
- Do not change Firestore document schema without also updating `firestore.rules`
- `kEnableFirebase = true` in production; use `false` only for widget test dev
- All new user-visible strings require entries in both `app_en.arb` and `app_he.arb`

## Testing

- Test files live in `test/` matching the source path.
- Run with `flutter test`.
- When `kEnableFirebase = false`, all stores work from mock data — useful for widget tests.
