# Design System Migration Mapping — v1 → v2

Figma design system: https://www.figma.com/design/ApTk87wJXejOTzVtEnFJMw/Pet-circle?node-id=264-1093
Figma views: https://www.figma.com/design/ApTk87wJXejOTzVtEnFJMw/Pet-circle?node-id=167-107
Rule: if mismatches between design system and views, **follow views**.

---

## Color Tokens

### Ink (Text/UI)

| Scale | Hex | Semantic role |
|-------|-----|---------------|
| Ink/Lighter | #72777A | Disabled text, placeholders |
| Ink/Light | #6C7072 | Secondary text, muted labels, inactive tabs |
| Ink/Base | #404446 | Body text |
| Ink/Dark | #303437 | Emphasized text |
| Ink/Darker | #202325 | Strong headings |
| Ink/Darkest | #090A0A | Primary text, titles |

### Sky (Backgrounds/Borders)

| Scale | Hex | Semantic role |
|-------|-----|---------------|
| Sky/White | #FFFFFF | Page background |
| Sky/Lightest | #F7F9FA | Subtle background |
| Sky/Lighter | #F2F4F5 | Card hover, input fill, code examples bg |
| Sky/Light | #E3E5E5 | Borders, dividers, icon button bg |
| Sky/Base | #CDCFD0 | Disabled background |
| Sky/Dark | #979C9E | Placeholder text |

### Primary / Brand (Purple)

| Scale | Hex | Semantic role |
|-------|-----|---------------|
| Primary/Lightest | #E7E7FF | Card bg, highlight bg, timer circle |
| Primary/Lighter | #C6C4FF | Accent background |
| Primary/Light | #9990FF | Secondary accent |
| Primary/Base | #6B4EFF | Primary action, active tab, filled buttons |
| Primary/Dark | #5538EE | Primary hover/pressed |

### Red (Error/Danger)

| Scale | Hex |
|-------|-----|
| Red/Lightest | #FFE5E5 |
| Red/Lighter | #FF9898 |
| Red/Light | #FF6D6D |
| Red/Base | #FF5247 |
| Red/Darkest | #D3180C |

### Green (Success)

| Scale | Hex |
|-------|-----|
| Green/Lightest | #ECFCE5 |
| Green/Lighter | #7DDE86 |
| Green/Light | #4CD471 |
| Green/Base | #23C16B |
| Green/Darkest | #198155 |

### Yellow (Warning)

| Scale | Hex |
|-------|-----|
| Yellow/Lightest | #FFEFD7 |
| Yellow/Lighter | #FFD188 |
| Yellow/Light | #FFC462 |
| Yellow/Base | #FFB323 |
| Yellow/Darkest | #A05E03 |

### Blue (Info)

| Scale | Hex |
|-------|-----|
| Blue/Lightest | #C9F0FF |
| Blue/Lighter | #9BDCFD |
| Blue/Light | #6EC2FB |
| Blue/Base | #48A7F8 |
| Blue/Darkest | #0065D0 |

### 3rd Party

| Name | Hex |
|------|-----|
| Facebook/Base | #0078FF |
| Facebook/Dark | #0067DB |
| Twitter/Base | #1DA1F2 |
| Twitter/Dark | #0C90E1 |

### Old → New Color Mapping

| Old token | Old hex | New token | New hex |
|-----------|---------|-----------|---------|
| `white` | #FFFFFF | `Sky/White` | #FFFFFF |
| `offWhite` | #F8F1E7 | `Sky/Lightest` or `Primary/Lightest` | #F7F9FA or #E7E7FF |
| `lightYellow` | #FFECB7 | `Yellow/Lightest` | #FFEFD7 |
| `chocolate` | #402A24 | `Ink/Darkest` (text) or `Primary/Base` (UI) | #090A0A or #6B4EFF |
| `pink` | #FFC2B5 | `Primary/Lighter` | #C6C4FF |
| `cherry` | #E64E60 | `Red/Base` | #FF5247 |
| `lightBlue` | #75ACFF | `Primary/Light` or `Blue/Light` | #9990FF or #6EC2FB |
| `blue` | #146FD9 | `Primary/Dark` or `Blue/Base` | #5538EE or #48A7F8 |
| `black` | #000000 | `Ink/Darkest` | #090A0A |

---

## Typography Tokens

### Font Family

**Old:** Inter (google_fonts)
**New:** Instrument Sans (variable font, `fontVariationSettings: "'wdth' 100"`)

### Complete Type Scale

Font: Instrument Sans. Each size has 3 line-height variants (None, Tight, Normal) × 3 weights (Bold 700, Medium 500, Regular 400).

| Category | Size | None (lh) | Tight (lh) | Normal (lh) |
|----------|------|-----------|------------|-------------|
| **Title 1** | 48px | — | — | 56px (Bold only) |
| **Title 2** | 32px | — | — | 36px (Bold only) |
| **Title 3** | 24px | — | — | 32px (Bold only) |
| **Large** | 18px | 18px | 20px | 24px |
| **Regular** | 16px | 16px | 20px | 24px |
| **Small** | 14px | 14px | 16px | 20px |
| **Tiny** | 12px | 12px | 14px | 16px |

### Old → New Typography Mapping

| Old style | Old spec | New style | New spec |
|-----------|---------|-----------|---------|
| `heading1` | Inter 28px/w600/lh1.2 | `Title2` | Instrument Sans 32px/w700/lh36 |
| `heading2` | Inter 24px/w600/lh1.2 | `Title3` | Instrument Sans 24px/w700/lh32 |
| `heading3` | Inter 18px/w600/lh1.2 | `Large/None/Bold` | Instrument Sans 18px/w700/lh18 |
| `body` | Inter 14px/w400/lh1.4 | `Regular/Normal/Regular` | Instrument Sans 16px/w400/lh24 |
| `bodyMuted` | Inter 14px/w400/lh1.4 (reduced opacity) | `Regular/Normal/Regular` + Ink/Light | Instrument Sans 16px/w400/lh24 |
| `caption` | Inter 12px/w400/lh1.2 | `Tiny/None/Regular` | Instrument Sans 12px/w400/lh12 |
| `badge` | Inter 12px/w600/white | `Tiny/None/Bold` | Instrument Sans 12px/w700/lh12 |
| `button` | Inter 16px/w600/white | `Regular/None/Medium` | Instrument Sans 16px/w500/lh16 |

---

## Shadow Tokens

| Name | Values | Replaces |
|------|--------|----------|
| Shadow/Small | `0 0 1px rgba(20,20,20,0.04)` + `0 0 8px rgba(20,20,20,0.08)` | `neumorphicOuter` |
| Shadow/Medium | `0 0 1px rgba(20,20,20,0.08)` + `0 1px 8px 2px rgba(20,20,20,0.08)` | — (new) |
| Shadow/Large | `0 1px 24px 8px rgba(20,20,20,0.08)` | — (new) |

Neumorphic shadows (`neumorphicOuter`, `neumorphicInner`) are **fully removed**.

---

## Spacing (unchanged)

| Token | Value |
|-------|-------|
| xs | 4px |
| sm | 8px |
| md | 16px |
| lg | 24px |
| xl | 32px |

Additional values seen in designs: 12px (rows), 48px (button radius).

---

## Border Radius

| Usage | Old | New |
|-------|-----|-----|
| Cards | 16px (`medium`) | 16px (same) |
| Buttons | 172px | 48px |
| Icon buttons | 100px (`full`) | 1000px |
| Inputs | 4px (`xs`) | 16px |
| Badges | — | 100px |

---

## Component Mapping

| Figma component (design system) | Node ID | Current widget | Changes |
|--------------------------------|---------|---------------|---------|
| Controls / Buttons | 264:2634 | `PrimaryButton` | Purple, 48px radius |
| Controls / Buttons: Icon | 264:2500 | `RoundIconButton` | Sky/Light bg |
| Controls / Buttons: Group | 264:2597 | — (new) | Button pair |
| Controls / Buttons: Auth | 264:2607 | (in auth_screen) | Google/Apple sign-in |
| Controls / Text Fields | 264:4025 | `LabeledTextField` | Updated style |
| Controls / Text Field: Floating Label | 264:5869 | — (new variant) | Floating label |
| Controls / Switches | 264:2142 | `TogglePill` | Material-style |
| Controls / Chips: Pill | 264:2406 | — (new) | Pill chips |
| Controls / Segmented Controls | 264:2195 | — (new) | Tab-like segments |
| Controls / Steppers | 264:2159 | — (new) | +/- counter |
| Controls / Radio Buttons | 264:2230 | — (new) | Radio selection |
| Controls / Checkboxes | 264:2487 | — (new) | Checkboxes |
| Controls / Sliders | 264:2176 | — (new) | Range sliders |
| Controls / Page Controls: Dot | 264:2284 | — (new) | Pagination dots |
| Controls / Date Pickers | 264:2289 | — (new) | Date selection |
| Views / Images: Avatars | 264:1970 | `UserAvatar` | 32px + 64px sizes |
| Views / Badges: Status: Pill | 264:2016 | `StatusBadge` | Updated colors |
| Views / Badges: Notifications | 264:2025 | — (new) | Notification count |
| Views / Progress Bars | 264:2243 | — (in OnboardingShell) | Progress indicator |
| Views / Dividers | 264:1994 | — (inline) | Divider line |
| Views / Tooltips | 264:1450 | — (new) | Tooltip popups |
| Views / Snackbars | 264:1519 | — (new) | Toast messages |
| Views / Bottom Sheets | 264:2007 | (in screens) | Sheet component |
| Views / Action Sheets | 264:1939 | — (new) | Action menu |
| Views / Tables | 264:1257 | — (new) | Data tables |
| Bars / Tab Bars: Icon & Text | 264:3478 | `BottomNavBar` | **5 tabs** (was 4) |
| Bars / Nav Bars: Large | 264:3435 | `AppHeader` | Large title pattern |
| Bars / Nav Bars: Standard | 264:3343 | — (new) | Standard nav bar |
| Bars / Tabs | 264:3515 | — (new) | Inline tabs |
| Bars / Search Bars | 264:3540 | — (new) | Search input |
| Native / Status Bar | 264:3573 | (system) | iOS status bar |

### New Tab Bar (5 tabs)

**Old:** Home, Trends, Pets, Medications
**New:** Home, Trends, Diary, Mesure, Medicine

---

## Screen Mapping (views page 167:107)

| Figma frame | Node ID | Current screen |
|-------------|---------|---------------|
| Welcome | 181:789 | `welcome_screen.dart` |
| Signup | 167:197 | `auth_screen.dart` |
| Step 1 | 167:157 | `onboarding_step1.dart` |
| Step 2 | 167:208 | `onboarding_step2.dart` |
| Step 2 (dropdown) | 167:243 | `onboarding_step2.dart` (state) |
| Step 3 | 167:284 | `onboarding_step3.dart` |
| Step 4 | 167:332 | `onboarding_step4.dart` |
| Step 4 (another guest) | 167:388 | `onboarding_step4.dart` (state) |
| Profile (pet created) | 167:449 | `owner_dashboard.dart` |
| Measure | 201:6435 | `measurement_screen.dart` |
| MeasurementGraph | 232:1266 | `trends_screen.dart` |
| Add medicine | 202:1190 | `medication_screen.dart` |
| Add New Medication | 232:774 | `add_medication_sheet.dart` |
| Profile (Settings) | 201:5614 | `settings_screen.dart` |

### Missing from Figma (code-ahead — Phase 4)

- Vet dashboard
- Care circle dashboard
- Messages screen
- Invite screen
- Role selection screen
- Verify email screen
- Auth gate (loading)
- All error states
- All empty states
- Dark mode variants
- RTL (Hebrew) layouts
- Tablet responsive layouts
