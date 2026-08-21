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

<!-- AUTO-GENERATED from pubspec.yaml and firebase-status.md -->
| Command | Description |
|---------|-------------|
| `flutter run` | Run on connected device / simulator |
| `flutter test` | Run all tests |
| `flutter test --coverage` | Run tests with coverage report |
| `flutter analyze` | Lint and static analysis |
| `flutter gen-l10n` | Regenerate localisation files from ARB |
| `flutter pub get` | Install/update dependencies |
| `flutter pub outdated` | Check for outdated packages |
| `flutter build apk` | Build Android release APK |
| `flutter build ios` | Build iOS release |
| `flutterfire configure --project=pet-circle-app` | Regenerate Firebase config files |
| `firebase deploy --only firestore:rules --project pet-circle-app` | Deploy Firestore security rules |
<!-- END AUTO-GENERATED -->

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
- Shared test helpers in `test/helpers/` (`test_app.dart`, `mock_stores.dart`).
- Coverage target: **80%+** line coverage.

### Cloud Functions tests

- Tests live in `functions/test/` as CommonJS `*.test.js`, using the built-in `node:test`
  runner against the compiled output in `functions/lib/` — so they exercise exactly what
  deploys, with no extra test dependency.
- Run with `npm --prefix functions test` (builds first). Typecheck with
  `npm --prefix functions run typecheck`. Requires Node 20+.
- CI does **not** run either yet — see `docs/firebase-status.md` → "Next Firebase Priorities".

---

## Figma Design System Rules

### Figma Sources

- **Design system (source of truth)**: https://www.figma.com/design/ApTk87wJXejOTzVtEnFJMw/Pet-circle?node-id=402-1191 — canonical components, tokens, type scale, colors, radii. Consult this FIRST for every design-alignment task.
- **Design system (legacy page)**: https://www.figma.com/design/ApTk87wJXejOTzVtEnFJMw/Pet-circle?node-id=264-1093
- **Views**: https://www.figma.com/design/ApTk87wJXejOTzVtEnFJMw/Pet-circle?node-id=167-107
- **Conflict rule**: If design system and views disagree, **follow the views**.
- **Migration mapping**: See `docs/design-system-migration.md` for complete token tables.

### Required Figma-to-Code Flow (component-first)

0. **Consult the design-system source of truth first** (`node-id=402-1191`): fetch `get_design_context`/`get_metadata` for the canonical component or token this screen uses. If the app's shared component or token diverges from the DS spec, **update the component/token to match the DS before touching the screen**.
1. Run `get_design_context` with the Figma node for the component/screen
2. Run `get_screenshot` for a visual reference
3. Download any assets from the Figma MCP asset endpoint
4. Translate Figma output (React + Tailwind) into Flutter/Dart using project conventions
5. Build/update the screen using the (now-reconciled) shared components and tokens — never hand-roll a one-off that duplicates an existing widget
6. Use the project's semantic token classes — **never hardcode hex values**
7. Validate against the Figma screenshot for 1:1 visual parity

### Design Token Architecture (3 layers)

```
lib/theme/
  tokens/
    colors.dart       # Primitive palette (AppPrimitives) — raw hex values
    typography.dart   # Font definitions (AppTypography) — sizes, weights, line heights
    spacing.dart      # Spacing + radius scales (AppSpacingTokens, AppRadiiTokens)
    shadows.dart      # Shadow definitions (AppShadowTokens)
  semantic/
    color_scheme.dart # Semantic ThemeExtension (AppSemanticColors) — light + dark
    text_theme.dart   # Semantic text styles (AppSemanticTextStyles)
  app_theme.dart      # buildAppTheme() / buildDarkTheme() — wires everything
  app_assets.dart     # Asset path registry
```

### Color System

**Palette categories (PC v3):** Ink (grays), Sky (backgrounds), Primary/purple, plus the candy
accents — periwinkle, butter, blush, mint — and the red/green/yellow/blue feedback families.

The live primary is **`pcPurple` #7E5CE0**, which is what semantic `primary` resolves to. The
legacy `AppPrimitives.primaryBase` (#6B4EFF) is v2 residue: it survives only inside
`status_badge.dart`'s backward-compat colour matcher and paints nothing. Do not treat it as
the primary.

**IMPORTANT rules:**
- NEVER hardcode hex colors in widgets or screens — always use semantic tokens
- Access colors via `AppSemanticColors.of(context).primary` (ThemeExtension pattern)
- Primary actions use `AppSemanticColors.of(context).primary` (= `pcPurple` #7E5CE0) — NOT `primaryBase`, NOT the old chocolate color
- Text colors use `Ink/*` tokens — NOT hardcoded black
- The app background is the single token `pcBg` (#F5F3EF), read via `c.background`; other surfaces use `Sky/*` or `primaryLightest` — NOT hardcoded white

**Dark mode ("Warm Charcoal"):** dark is a per-role transform of light, not an inversion — all 51
semantic fields resolve to a `pcDark*` primitive, and none may fall through to a light value. Its
surface ladder (`pcDarkCanvas` → `pcDarkWell` → `pcDarkSurface` → `pcDarkElevated`) carries elevation
because shadows barely register on a dark canvas. `textPrimary` has a contrast **ceiling** of 16.5:1
as well as a 14:1 floor: pure white on near-black is what made the previous dark theme feel harsh.
Never reuse a light pastel as a dark fill — use the `pcDark*Tile` washes for backgrounds and the
bright `pcDark*` accents for foregrounds. `test/theme/dark_contrast_test.dart` enforces all of this;
`.claude/rules/design-system-enforcement.md` has the full rules.

**Shadows:** use `AppShadowTokens.smallOf(context)` (and `mediumOf`/`largeOf`) in widgets — the bare
`small`/`medium`/`large` constants are the light values.

**Theme mode:** `appThemeMode` (`ValueNotifier<ThemeMode>`) in `lib/config/app_config.dart`, persisted
through `settingsStore.setThemeMode()` to `/users/{uid}.settings`. Defaults to `ThemeMode.system`.

### Typography System

**Font:** Instrument Sans — a **variable** font. Both axes must be set: `wght` (400-700)
*and* `wdth` (100). The eight bundled `.ttf` files are byte-identical, so the `weight:` keys in
`pubspec.yaml` only pick a *file* — they do not set `wght`, whose default instance is 400.
Weight comes from `fontVariations` only (see `AppTypography.axesBold` / `axesFor()`), never from
`fontWeight` alone. Using `.copyWith(fontWeight: ...)` on a semantic style silently drops back to
400; use the `withWeight()` extension instead. This was BUG-044 — see `docs/bug-log.md`.

**Scale (aligned to Figma DS node 402-1191):** Display (`pcDisplayXxl/Xl/L`, `pcDisplay`), Heading
(`headingH1` 24/32, `headingH2` 20/28, `headingXs` 16/22), Label L 15px, Label M 14px, Label S 13px,
Body 16/24, Caption 12/16, plus `pcButton` (16/22 Bold).
**Weights:** Regular 400, Medium 500, SemiBold 600, Bold 700 — applied via `fontVariations`.

Access via `AppSemanticTextStyles.pcDisplayL`, `.headingH1`, `.pcBody`, `.captionMedium`, etc.
The v2 names (`title1`/`title2`/`title3`, `body`, `label`, `caption`, ...) still resolve — each is
an alias retargeted onto the nearest DS style — but prefer the DS-named styles in new code.
Full catalog: `.claude/rules/design-system-enforcement.md`.

### Shadow System

3 elevation levels (replaces neumorphic shadows):
- `Shadow/Small` — subtle, for cards and containers
- `Shadow/Medium` — moderate, for elevated elements
- `Shadow/Large` — prominent, for modals and overlays

### Component Conventions

- Buttons: pill-shaped (`borderRadius: 48`), filled (Primary/Base bg) or outlined (Primary/Base border)
- Cards: `borderRadius: 16`, `Primary/Lightest` bg or white, Shadow/Small
- Icon buttons: circular (`borderRadius: 1000`), `Sky/Light` bg
- Tab bar: Home, Trends, Circle, Measure, Medication — the Circle tab (index 2) is gated behind `kEnableCircleTab`, so it renders **4 tabs** while that flag is false. Active tint = `c.onSurface`
- Inputs: `borderRadius: 16`, Sky/Lighter fill
- Avatars: circular, 32px (small) or 64px (large)

### Asset Handling

- IMPORTANT: If Figma MCP returns a localhost source for images/SVGs, use that directly
- DO NOT add new icon packages — all assets come from Figma payload
- Store downloaded assets in `assets/figma/`

### What NOT to Do

- NEVER use the old `AppColorsTheme.of(context)` — use `AppSemanticColors.of(context)`
- NEVER use the old `AppTextStyles.*` — use `AppSemanticTextStyles.*`
- NEVER use neumorphic shadows — use `AppShadowTokens.*`
- NEVER hardcode the old color values (chocolate, pink, cherry, offWhite, etc.)
- NEVER skip the Figma screenshot comparison step

## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- After modifying code files in this session, run `python3 -c "from graphify.watch import _rebuild_code; from pathlib import Path; _rebuild_code(Path('.'))"` to keep the graph current
