# Pet Circle — Design System (PC v3 / Claude-Design)

> Current-state knowledge base for the Pet Circle design system — token layer + full shared-widget catalog. Enforces reuse and correct token usage for every code change.

Single source of truth for design tokens and shared components. The PC v3 migration (see `docs/component-inventory.md` and `docs/design-system-migration.md`) fully replaced the old neumorphic/chocolate-palette system — **do not reintroduce it**.

## Token Layer (3-tier: primitives → semantic → theme)

### Colors
- ALWAYS use `final c = AppSemanticColors.of(context);`
- NEVER use `AppColorsTheme.of(context)` — **removed**, does not exist anymore.
- NEVER hardcode hex (`Color(0xFF...)`, `Colors.white`, etc.) or the old v2 names (`chocolate`, `cherry`, `pink`, `offWhite`, `lightBlue`, `burgundy`).
- Key fields on `AppSemanticColors`:
  - Core: `primary`, `onPrimary`, `primaryLight`, `primaryLightest`, `primaryGhost`, `surface`, `onSurface`, `background`, `onBackground`, `surfaceRecessed`, `hairline`, `divider`, `disabled`
  - Text: `textPrimary`, `textSecondary`, `textTertiary`, `textDisabled`
  - Feedback: `error`, `onError`, `success`, `warning`, `info`
  - Accents (each has a base + `*Tile` wash; purple also has `*Chip`/`*Ghost`): `accentPurple`/`accentPurpleTile`, `accentPeriwinkle`/`accentPeriwinkleTile`/`accentPeriwinkleChip`, `accentButter`/`accentButterTile`/`accentButterCream`, `accentBlush`/`accentBlushTile`, `accentMint`/`accentMintTile`
  - Status pills (bg/dot/text triplets — see `StatusBadgeStatus`): `statusNormal*`, `statusElevated*`, `statusAlert*`, `statusActive*`, `statusInvited*` (no dot for invited/active)
- For opacity use `.withValues(alpha: 0.5)` — NEVER the deprecated `.withOpacity()`.

### Typography
- ALWAYS use `AppSemanticTextStyles.*`. Font family is **Instrument Sans** (not Inter/Google Fonts).
- NEVER use `AppTextStyles.*` — **removed**, does not exist anymore.
- Scale matches Figma DS node 402-1191 exactly: Display (`pcDisplayXxl/Xl/L`, `pcDisplay`=M), Heading (`headingH1` 24/32 -0.3, `headingH2` 20/28 -0.2, `headingXs` 16/22), Label L 15px (`labelLBold/Semibold/Regular`), Label M 14px (`pcLabelBold`, `labelMSemibold`, `pcLabel`=Medium, `pcLabelMuted`=Regular+secondary), Label S 13px (`labelSBold/Semibold/Regular`), Body 16/24 (`pcBodyBold`, `pcBodySemibold`, `pcBodyMedium`, `pcBody`=Regular, `pcBodyMuted`=Regular+secondary), Caption 12/16 (`captionBold`, `captionMedium`, `pcCaption`=Regular+secondary, `pcCaptionMuted`=Regular+tertiary), plus `pcButton` (16/22 Bold — the Button component's text style).
- Legacy aliases (`title1/2/3`, `headingLg/Md`, `body`/`bodySm`/`bodyMuted`/`bodyLg`, `label`/`labelSm`, `caption`, `button`) still work — each is retargeted onto the nearest DS-aligned style above (e.g. `title3` = exact `headingH1` match, `caption` = exact `pcCaption`-equivalent match). Prefer the DS-named styles for new code.
- Override only color/weight via `.copyWith(...)` — never build a raw `TextStyle` from scratch for body text.

### Spacing — `AppSpacingTokens`
- PC v3 scale (prefer for new/converged UI): `pcXs` 6, `pcSm` 10, `pcMd` 14, `pcLg` 18, `pcXl` 24.
- Legacy v2 scale (still present, used by not-yet-converged screens): `xs` 4, `sm` 8, `md` 16, `lg` 24, `xl` 32.
- Match whichever scale the surrounding widget/screen already uses; don't mix the two scales within one component.

### Border Radius — `AppRadiiTokens`
- PC v3 semantic radii (prefer), matching Figma DS node 402-1191: `pcField` **12** (inputs/selects/chips), `pcCard` **16** (cards), `pcTile` 30 (large rounded surfaces), `pcPill` 9999 (fully rounded).
- Convenience getters: `borderRadiusField`, `borderRadiusCard`, `borderRadiusTile`, `borderRadiusPill` (also legacy `borderRadiusSm/Md/Lg/Xl/Full`).
- NEVER `BorderRadius.circular(N)` with a raw number — always a token or getter.

### Inputs
- ALWAYS build `InputDecoration` via `appInputDecoration(context, hintText: ...)` (`lib/widgets/app_input_decoration.dart`) rather than hand-rolling a bordered decoration. Per the DS "Input" component, text fields are **borderless white** (`pcField` radius, no idle border) with a 2px `primary` focus ring — never re-add a hairline/divider border on idle. `hintText` is optional — omit it for call sites using a Material floating `labelText` instead (via `.copyWith(labelText: ...)`), since setting both to the same string renders it twice.

### Shadows
- `AppShadowTokens.small/medium/large` — flat elevation levels. The old `AppShadows.neumorphicOuter/neumorphicInner` are **gone**; don't recreate neumorphic dual-shadows for new UI.

## Component Catalog (`lib/widgets/`) — search here before writing new UI

### Buttons
| Widget | Purpose | Key API |
|---|---|---|
| `PrimaryButton` | Pill CTA button — `filled`/`secondary` are purple/purple-tile filled; `outlined`/`tertiary` is transparent + 1px ink border (never a white/hairline surface) | `variant`: `filled`/`secondary`/`outlined`/`link`/`miniPrimary`; `label`, `icon`, `trailingIcon`, `child`, `fullWidth` |
| `RoundIconButton` | Circular icon button | `variant`: `primary`/`ghost`; `icon`, `size`=54, `iconSize`=20, `semanticLabel` |
| `SocialButton` | Google/Apple auth button — borderless white, h52, radius `pcField` | `icon`, `label`, `onTap` |

### Inputs & Selection
| Widget | Purpose | Key API |
|---|---|---|
| `AppDropdown` | Labeled dropdown, inline-open option list | `label`, `value`, `onTap`, `isOpen`, `chevronController`, `options`, `onOptionSelected`, `placeholder` |
| `LabeledTextField` | Labeled text input (borderless, DS "Input" component) | `label`, `hintText`, `keyboardType`, `controller`, `onChanged` |
| `BreedSearchField` | Autocomplete breed search (recessed search box — distinct from the DS Input; keep as-is) | `label`, `initialValue`, `onChanged`, `maxHeight` |
| `AppToggle` | Binary **on/off** switch | `value`, `onChanged`, `disabled` |
| `TogglePill` | **Segmented two-option** pill (not on/off — use `AppToggle` for binary settings) | `isOn` |
| `AppSegmentedControl` | Multi-segment pill selector | `options`, `value`, `onChanged` |
| `RadioCard` | Selectable option card with radio ring | `title`, `description`, `badge`, `selected`, `onTap` |
| `AppFilterChip` | Toggleable filter pill | `label`, `selected`, `onTap` |

### Cards & Surfaces
| Widget | Purpose | Key API |
|---|---|---|
| `AppCard` | Flat PC v3 surface/tile card (radius 16) — **prefer over `NeumorphicCard` for new UI** | `variant`: `surface`/`tile`; `tileColor`, `padding`, `child` |
| `NeumorphicCard` | Legacy card, small elevation shadow; `inner:true` = flat/recessed, no shadow | `child`, `padding`, `margin`, `color`, `radius`, `inner` |
| `PetCard` | Purple-tile pet summary card (composes `StatusBadge` + `Mascot`/`DogPhoto`) | `name`, `subtitle`, `status`, `statusLabel`, `media`, `onTap`, `onLongPress`, `footer`, `trailing` |
| `NotificationCard` | Notification row (unread = surface + dot; read = recessed) | `icon`, `iconTileColor`, `title`, `body`, `time`, `unread`, `onTap` |
| `NoteCallout` | Cream info/note callout box | `title`, `body`, `icon` (default `Icons.info_outline`) |
| `SummaryCard` | Icon + value + label stat tile | `iconColor`, `icon`, `value`, `label` |

### Status
| Widget | Purpose | Key API |
|---|---|---|
| `StatusBadge` | Status pill with leading dot (no dot for active/invited) | `label`, `status`: `StatusBadgeStatus`; legacy `color` param infers status if `status` omitted — **prefer passing `status` explicitly** |

### Avatars & Media
| Widget | Purpose | Key API |
|---|---|---|
| `UserAvatar` | Circular user avatar with initials fallback | `name`, `imageUrl`, `size`=36, `onTap` |
| `AvatarStack` | Overlapping avatar group, initials fallback on image error | `avatars`, `avatarSize`, `overlap`, `alignment`: `AvatarStackAlignment`, `borderColor`, `highlightFirst`, `highlightBorderColor` |
| `DogPhoto` | Pet photo with fallback | `endpoint`, `fit` |
| `AppImage` | Image with fallback icon | `AppImage.asset(path, width, height, fit, fallbackIcon)` |
| `Mascot` | Recolorable breed mascot SVG | `breed`: `MascotBreed`, `color`, `size`=56 |

### Layout & Navigation
| Widget | Purpose | Key API |
|---|---|---|
| `AppHeader` | Top header (avatar, pet switcher, notification bell) | `userName`, `userImageUrl`, `petName`, `petImageUrl`, `onAvatarTap`, `onNotificationTap`, `onPetSelectorTap` |
| `BottomNavBar` | 5-tab bottom nav (translucent + blur) | `selectedIndex`, `onTap` |
| `OnboardingShell` | Onboarding step scaffold (title, progress, Back/Next) | `stepLabel`, `progress`, `title`, `child`, `onBack`, `onNext`, `nextLabel`, `isNextLoading`, `onClose` |
| `SettingsRow` | Settings list row | `title`, `description`, `iconAsset`, `trailing`, `onTap` |
| `ResponsiveGrid` | Responsive grid wrapper | `children`, `minItemWidth`, `maxCrossAxisCount`, `childAspectRatio` (default 0.85) |
| `ProgressBar` | Pill progress bar | `value` (0.0–1.0, clamped), `height`, `trackColor`, `fillColor` |

## Enums
- `PrimaryButtonVariant` — `filled, secondary, outlined, link, miniPrimary`
- `RoundIconButtonVariant` — `primary, ghost`
- `StatusBadgeStatus` — `normal, elevated, alert, active, invited`
- `AppCardVariant` — `surface, tile`
- `AvatarStackAlignment` — `left, right`
- `MascotBreed` — `floppy, perky, fluffy, snout, whiskers`

## Mandatory Internationalization

ALL user-facing text MUST use localized strings. No hardcoded text in widgets.

- Access via `final l10n = AppLocalizations.of(context)!;` then `l10n.keyName`
- Localization files: `lib/l10n/app_en.arb` (English) and `lib/l10n/app_he.arb` (Hebrew)
- After adding new keys to `.arb` files, run `flutter gen-l10n`
- NEVER hardcode user-facing strings like button labels, titles, descriptions, empty states, snackbar messages, or dialog text
- Hint text with example values (e.g., "e.g., 5mg") is acceptable as-is
- Data format strings (CSV headers, technical IDs) do not need localization
- Dropdown display text must be localized even if the stored value is an English key

### Adding a new l10n key
1. Add the key to `lib/l10n/app_en.arb` with English text
2. Add the same key to `lib/l10n/app_he.arb` with Hebrew translation
3. Run `flutter gen-l10n`
4. Use `l10n.newKey` in the widget

## Checklist for Every Code Change

Before completing any edit to a `.dart` file:
1. Colors from `AppSemanticColors.of(context)` — not `AppColorsTheme`, not hardcoded hex
2. Spacing from `AppSpacingTokens` (pick one scale, `pc*` or legacy, and stay consistent within the widget)
3. Border radii from `AppRadiiTokens` — no raw `BorderRadius.circular(N)`
4. Text styles from `AppSemanticTextStyles` — not `AppTextStyles`, not a raw `TextStyle`
5. Checked the Component Catalog above before hand-rolling a button/card/chip/dropdown/badge/avatar
6. ALL user-facing strings localized via `AppLocalizations`
7. New l10n keys added to BOTH `app_en.arb` and `app_he.arb`, then `flutter gen-l10n` run
