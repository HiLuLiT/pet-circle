# Contributing to Pet Circle

## Prerequisites

- Flutter SDK `^3.10.4` — [install guide](https://docs.flutter.dev/get-started/install)
- Dart (bundled with Flutter)
- Firebase CLI — `npm install -g firebase-tools`
- FlutterFire CLI — `dart pub global activate flutterfire_cli`
- A connected device or simulator (iOS Simulator / Android Emulator)

## First-Time Setup

1. Clone the repo and install dependencies:
   ```bash
   flutter pub get
   ```

2. Generate Firebase config files (requires access to the `pet-circle-app` Firebase project):
   ```bash
   flutterfire configure \
     --project=pet-circle-app \
     --platforms=android,ios,macos,web \
     --android-package-name=com.example.pet_circle \
     --ios-bundle-id=com.example.petCircle \
     --macos-bundle-id=com.example.petCircle
   ```
   This generates `lib/firebase_options.dart` and the platform-specific `google-services.json` / `GoogleService-Info.plist` files (gitignored).

3. Generate localisation files:
   ```bash
   flutter gen-l10n
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Development Without Firebase

Set `kEnableFirebase = false` in `lib/main.dart` to run entirely on mock data (no Firebase account required). All stores will be seeded from `lib/data/mock_data.dart`.

## Available Commands

<!-- AUTO-GENERATED from pubspec.yaml -->
| Command | Description |
|---------|-------------|
| `flutter run` | Run on connected device / simulator |
| `flutter test` | Run all tests |
| `flutter test --coverage` | Run tests with lcov coverage report |
| `flutter analyze` | Lint and static analysis |
| `flutter gen-l10n` | Regenerate localisation files from ARB |
| `flutter pub get` | Install/update dependencies |
| `flutter pub outdated` | Check for outdated packages |
| `flutter build apk` | Build Android release APK |
| `flutter build ios` | Build iOS release |
| `firebase deploy --only firestore:rules --project pet-circle-app` | Deploy Firestore security rules |
<!-- END AUTO-GENERATED -->

## Testing

- Tests live in `test/` mirroring the source path (e.g. `lib/stores/pet_store.dart` → `test/stores/pet_store_test.dart`)
- Run tests: `flutter test`
- Run with coverage: `flutter test --coverage`
- Target: **80% coverage minimum**
- Use `kEnableFirebase = false` for widget tests — all stores work from mock data

### Test structure
```
test/
  models/          # Unit tests for immutable data classes
  stores/          # Unit tests for ChangeNotifier stores
  screens/         # Widget tests for screens
  widgets/         # Widget tests for shared components
  navigation/      # Route and navigation tests
  accessibility/   # Accessibility checks
  utils/           # Utility function tests
```

## Code Conventions

- **Immutability**: Models use `copyWith` — never mutate in-place
- **Localisation**: All user-visible strings go through `AppLocalizations` — no hardcoded EN strings in widgets. Add to both `lib/l10n/app_en.arb` and `lib/l10n/app_he.arb`, then run `flutter gen-l10n`
- **File naming**: `snake_case.dart` for all Dart files
- **Store pattern**: Mutate private field → call `notifyListeners()`
- **Firestore changes**: Any schema change must be paired with an update to `firestore.rules`

## Submitting Changes

1. Run lint: `flutter analyze` — zero warnings required
2. Run tests: `flutter test` — all must pass
3. If you changed Firestore schema: deploy updated rules
4. Follow conventional commit format: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`

## Tracking Issues

- Bugs → `docs/bug-log.md`
- Future features → `docs/future-features.md`
- Firebase roadmap → `docs/firebase-status.md`
