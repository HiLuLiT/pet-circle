# Component Inventory Map

> **Step 1 of design-system alignment.** A complete map of every UI component currently in use across all screens — what exists, where, and how often. This is a **pure inventory**: no design-system mapping yet (that's step 2, which will use this map to map each current component to a design-system component).

**Scope:** all 33 `.dart` files under `lib/screens/` + the 22 shared widgets in `lib/widgets/`.

**Three component tiers** (used throughout this doc):
- **Tier 1 — Global shared widgets:** reusable classes in `lib/widgets/`.
- **Tier 2 — Feature-local components:** widget classes (public or private `_`-prefixed) defined inside screen/feature files.
- **Tier 3 — Inline-styled raw widgets:** hand-styled `Container`/`GestureDetector`/`InkWell`/`TextButton` acting as a button, card, chip, badge, pill, dropdown, or list row.

Pure layout primitives (`Column`, `Row`, `Padding`, `SizedBox`, `Expanded`, `Center`, `Stack`, `SingleChildScrollView`) are omitted unless used *as* a component.

---

## Section A — Design-system catalog (Tier 1, the target vocabulary)

The 22 global shared widgets in `lib/widgets/`. Step 2 maps current components onto these.

| Widget | File | Purpose |
|---|---|---|
| `PrimaryButton` | `primary_button.dart` | Pill button — `filled`/`secondary` are purple/purple-tile filled; `outlined`/`tertiary` is transparent + 1px ink border (never a white/hairline surface), per Figma DS node 402-1191. |
| `RoundIconButton` | `round_icon_button.dart` | Circular 54px icon button — `primary` / `ghost`. |
| `SocialButton` | `social_button.dart` | Google/Apple auth button — borderless white, h52, radius `pcField` (12), per Figma DS node 402-1191. |
| `AppCard` | `app_card.dart` | Flat surface/tile card, radius 18 (PC v3). |
| `NeumorphicCard` | `neumorphic_card.dart` | Card w/ small elevation; `inner` = recessed flat. Legacy name, still used. |
| `StatusBadge` | `status_badge.dart` | Status pill (normal/elevated/alert/active) w/ leading dot. |
| `AppFilterChip` | `filter_chip.dart` | Toggleable filter pill (selected = periwinkle chip). |
| `RadioCard` | `radio_card.dart` | Selectable option card with ring + filled dot. |
| `NotificationCard` | `notification_card.dart` | Notification row — unread (surface + dot) / read (recessed). |
| `AppToggle` | `app_toggle.dart` | 46×28 on/off switch with animated knob. |
| `TogglePill` | `toggle_pill.dart` | **Segmented** two-option pill toggle (distinct from `AppToggle`). |
| `AppSegmentedControl` | `segmented_control.dart` | Multi-segment pill control (active = surface). |
| `AppDropdown` | `app_dropdown.dart` | Tap-to-open dropdown, field radius 14. |
| `LabeledTextField` | `labeled_text_field.dart` | Labeled text input, radius `pcField` (12), **borderless** on idle (2px purple focus ring). Uses shared `appInputDecoration()` helper (`app_input_decoration.dart`). |
| `BreedSearchField` | `breed_search_field.dart` | Autocomplete breed search field. |
| `appInputDecoration()` | `app_input_decoration.dart` | Shared `InputDecoration` builder (not a widget) — white fill, radius `pcField`, borderless idle, 2px purple focus ring. Use for any hand-rolled `TextField`/`TextFormField` instead of a bordered `InputDecoration`. |
| `AppHeader` | `app_header.dart` | Top app header (pet name, avatar, bell). |
| `BottomNavBar` | `bottom_nav_bar.dart` | 5-tab bottom nav, translucent + blur. |
| `OnboardingShell` | `onboarding_shell.dart` | Onboarding step scaffold (title, progress, footer). |
| `SettingsRow` | `settings_row.dart` | Settings list row. |
| `UserAvatar` | `user_avatar.dart` | Circular user avatar with white ring. |
| `DogPhoto` | `dog_photo.dart` | Pet photo with fallback. |
| `AppImage` | `app_image.dart` | Network image with placeholder/fallback. |
| `Mascot` | `mascot.dart` | Recolorable SVG dog mascot (5 breeds). |

---

## Section B — Feature-local component catalog (Tier 2)

Widget classes defined **inside** screen/feature files (not in `lib/widgets/`). These are candidates either for promotion to `lib/widgets/` or replacement by a Tier-1 widget in step 2.

### Public feature-local components

| Class | File:line | Purpose |
|---|---|---|
| `DropdownField` | `medication/medication_form_widgets.dart:110` | Frequency dropdown wrapper (Container + `DropdownButton`). |
| `ValidatedTextArea` | `medication/medication_form_widgets.dart:161` | Multiline validated text field. |
| `ReminderCard` | `medication/medication_form_widgets.dart:204` | Reminder toggle card (primaryLight bg). |
| `DatePickerField` | `medication/medication_form_widgets.dart:58` | Date-picker-backed field. |
| `ValidatedFormField` | `medication/medication_form_widgets.dart:8` | Validated single-line text field. |
| `InviteButton` | `settings/settings_care_circle_widgets.dart:11` | Container styled as invite action button. |
| `ConfigureRow` | `settings/settings_care_circle_widgets.dart:167` | Settings row with config icon button. |
| `CareCircleItem` | `settings/settings_care_circle_widgets.dart:48` | Care-circle member row w/ role/status badges. |
| `LanguageRow` | `settings/settings_widgets.dart:161` | Language picker row (opens modal). |
| `SettingsCard` | `settings/settings_widgets.dart:19` | Settings section card container. |
| `ActionRow` | `settings/settings_widgets.dart:262` | Tappable settings action row. |
| `SimpleRow` | `settings/settings_widgets.dart:329` | Simple settings label row. |
| `SettingsToggleRow` | `settings/settings_widgets.dart:86` | Settings row w/ `TogglePill`. |
| `InfoTile` | `pet_detail/pet_detail_widgets.dart:11` | Icon + value + label stat tile. |
| `NoteCard` | `pet_detail/pet_detail_widgets.dart:64` | Clinical note card. |
| `MemberTile` | `pet_detail/pet_detail_widgets.dart:111` | Care-circle member row. |
| `RoleBadge` | `pet_detail/pet_detail_widgets.dart:152` | Inline role badge (Container pill). |
| `PetInfoSection` | `pet_detail/pet_detail_sections.dart:17` | Pet info section (uses `InfoTile`). |
| `PetMeasurementHistory` | `pet_detail/pet_detail_sections.dart:67` | Inline bar-chart measurement history. |
| `PetClinicalNotes` | `pet_detail/pet_detail_sections.dart:171` | Notes section + inline note input. |
| `PetCareCircle` | `pet_detail/pet_detail_sections.dart:281` | Care-circle section. |

### Private feature-local components (`_`-prefixed)

| Class | File:line | Kind |
|---|---|---|
| `_SocialButton` | `auth/login_screen.dart:324` · `auth/create_account_screen.dart:348` | Social-auth button (**duplicated**) |
| `_RoleButton` | `auth/role_selection_screen.dart:99` | Role selection card |
| `_EmptyNoPet` / `_EmptyCircle` | `circle/circle_screen.dart:48` / `:271` | Empty-state blocks |
| `_CircleContent` | `circle/circle_screen.dart:71` | Circle content layout |
| `_MemberTile` | `circle/circle_screen.dart:326` | Member row card |
| `_PendingInviteTile` | `circle/circle_screen.dart:406` | Pending-invite card |
| `_InviteSheet` | `circle/circle_screen.dart:473` | Invite modal sheet |
| `_InviteSuccess` | `circle/circle_screen.dart:664` | Invite success card |
| `_PetCard` | `dashboard/owner_dashboard.dart:259` · `dashboard/vet_dashboard.dart:338` · `dashboard/care_circle_dashboard.dart:92` | Pet card (**3× variants**) |
| `_AddPetIcon` | `dashboard/owner_dashboard.dart:238` | Circular add-pet icon button |
| `_InfoRow` | `dashboard/owner_dashboard.dart:417` | Bordered info row |
| `_AvatarStack` | `dashboard/owner_dashboard.dart:467` · `dashboard/care_circle_dashboard.dart:202` | Overlapping avatars (**dup**) |
| `_AvatarCircle` | `dashboard/owner_dashboard.dart:502` | Circular avatar w/ border |
| `_SummaryCard` | `dashboard/vet_dashboard.dart:516` · `dashboard/care_circle_dashboard.dart:244` | Stat summary card (**dup**) |
| `_ResponsiveGrid` | `dashboard/vet_dashboard.dart:569` · `dashboard/care_circle_dashboard.dart:308` | Responsive grid (**dup**) |
| `_PendingRequestsSection` | `dashboard/vet_dashboard.dart:207` | Pending requests section |
| `_TabSelector` / `_TabButton` | `measurement/measurement_screen.dart:117` / `:156` | Custom segmented tab control |
| `_ManualMode` / `_VisionMode` | `measurement/measurement_screen.dart:204` / `:664` | Measurement mode panels |
| `_DurationChip` | `measurement/measurement_screen.dart:627` | Selectable duration chip |
| `_ActiveMedicationsList` | `medication/medication_screen.dart:264` | Medication list |
| `_SectionCard` | `medication/medication_screen.dart:381` · `trends/trends_screen.dart:415` | Section card wrapper (**dup**) |
| `_AppNotificationCard` | `messages/messages_screen.dart:174` | Notification card (mirrors Tier-1 `NotificationCard`) |
| `_TargetOption` | `onboarding/onboarding_step3.dart:162` | Radio/selection option card |
| `_VetInviteRow` / `_InviteRow` | `onboarding/onboarding_step4.dart:526` / `:665` | Invite list rows |
| `_VetEmailInput` | `onboarding/onboarding_step4.dart:588` | Email input + action button row |
| `_InputRow` | `onboarding/onboarding_step4.dart:722` | Labeled input row (mirrors `LabeledTextField`) |
| `_SelectRow` | `onboarding/onboarding_step4.dart:773` | Custom dropdown row |
| `_Badge` | `settings/settings_care_circle_widgets.dart:136` | Inline role/status badge |
| `_MeasurementReminderFrequencyRow` | `settings/settings_content.dart:407` | Frequency `SegmentedButton` row |
| `_MedicationTimeRow` / `_MeasurementReminderTimeRow` | `settings/settings_content.dart:461` / `:503` | Time-picker rows |
| `_StatGrid` | `trends/trends_screen.dart:359` | Stat grid |
| `_LegendBadge` | `trends/trends_screen.dart:465` | Chart legend badge |
| `_StatCard` | `trends/trends_screen.dart:492` | Stat display card |
| `_StatusCard` / `_StatusPill` | `trends/trends_screen.dart:525` / `:564` | Status summary card + pill |
| `_BadgeRow` / `_BadgeRowSecond` | `trends/trends_screen.dart:434` / `:454` | Legend badge rows |
| `_SrrChart` | `trends/trends_screen.dart:587` | fl_chart line chart wrapper |

---

## Section C — By-screen inventory (Tier-by-tier per file)

### lib/screens/welcome_screen.dart
- **Purpose:** Barrel/export file (re-exports `LandingScreen` + `CreateAccountScreen`) — not a rendered screen.
- **Components:** none.

### lib/screens/landing_screen.dart
- **Purpose:** Marketing landing page — title, tagline, SVG illustration, "Get Started" CTA.
- **Shared (T1):** none.
- **Feature-local (T2):** none.
- **Raw UI (T3):** `TextButton` (styled w/ `StadiumBorder` as branded CTA).
- **Inline candidates:** `TextButton` @ ~62 — branded CTA, should be `PrimaryButton`.

### lib/screens/main_shell.dart
- **Purpose:** Nav shell — bottom nav (mobile) / `NavigationRail` (tablet), header, `IndexedStack` tabs, pet-switcher sheet.
- **Shared (T1):** `AppHeader`, `DogPhoto`, `BottomNavBar`.
- **Raw UI (T3):** `NavigationRail`, `NavigationRailDestination`, `ListTile` (pet switcher), `showModalBottomSheet`, `VerticalDivider`.
- **Inline candidates:** drag-handle `Container` @ ~79 — sheet grab handle; `ListTile` per pet @ ~91.

### lib/screens/auth/auth_gate.dart
- **Purpose:** Auth routing gate (loading spinner during auth check).
- **Raw UI (T3):** `CircularProgressIndicator`.
- **Inline candidates:** none.

### lib/screens/auth/login_screen.dart
- **Purpose:** Email login — email field, login button, social auth, sign-up link.
- **Feature-local (T2):** `_SocialButton` @ 324.
- **Raw UI (T3):** `TextFormField`, `ElevatedButton`, `OutlinedButton`, `TextButton`, `Divider`, `Image.asset`, `CircularProgressIndicator`.
- **Inline candidates:** circular icon badge `Container` @ ~162; `_SocialButton` (dup w/ create_account).

### lib/screens/auth/create_account_screen.dart
- **Purpose:** Account creation — name/email fields, send-code, social auth, login link.
- **Feature-local (T2):** `_SocialButton` @ 348.
- **Raw UI (T3):** `TextFormField`, `ElevatedButton`, `OutlinedButton`, `TextButton`, `Divider`, `Image.asset`.
- **Inline candidates:** circular icon badge `Container` @ ~135; `_SocialButton` (dup w/ login).

### lib/screens/auth/role_selection_screen.dart
- **Purpose:** Role selection (Vet vs Pet Owner).
- **Feature-local (T2):** `_RoleButton` @ 99.
- **Raw UI (T3):** `TextButton` (inside `_RoleButton`).
- **Inline candidates:** `_RoleButton` — role card built on styled `TextButton`.

### lib/screens/auth/verify_otp_screen.dart
- **Purpose:** OTP entry — 6 digit fields, resend timer.
- **Raw UI (T3):** `AppBar`, `IconButton`, `TextFormField` (per digit), `ElevatedButton`, `TextButton`, `KeyboardListener`.
- **Inline candidates:** OTP digit field `Container`+`TextFormField` @ ~264; circular icon badge `Container` @ ~209.

### lib/screens/onboarding/onboarding_flow.dart
- **Purpose:** 3-step onboarding `PageView` container; pet-creation state.
- **Raw UI (T3):** `PageView` (non-scrollable).
- **Inline candidates:** none.

### lib/screens/onboarding/onboarding_step1.dart
- **Purpose:** Pet profile — name, breed, age, photo.
- **Shared (T1):** `LabeledTextField`, `BreedSearchField`, `OnboardingShell`.
- **Inline candidates:** none.

### lib/screens/onboarding/onboarding_step2.dart
- **Purpose:** Medical info — diagnosis dropdown w/ open/close animation.
- **Shared (T1):** `OnboardingShell`.
- **Raw UI (T3):** `GestureDetector`+`Container` dropdown, `RotationTransition` chevron.
- **Inline candidates:** custom dropdown trigger @ ~92 (dup pattern); dropdown items @ ~131; note/info box `Container` @ ~179.

### lib/screens/onboarding/onboarding_step3.dart
- **Purpose:** Target SRR — preset/custom rate options w/ radio selection.
- **Shared (T1):** `OnboardingShell`.
- **Feature-local (T2):** `_TargetOption` @ 162.
- **Raw UI (T3):** `TextField`, `InkWell`+`Container` option cards.
- **Inline candidates:** `_TargetOption` — radio selection card (→ `RadioCard`); custom circular radio indicator @ ~197.

### lib/screens/onboarding/onboarding_step4.dart
- **Purpose:** Care circle + vet invites — lookup, role select, add members.
- **Shared (T1):** `OnboardingShell`.
- **Feature-local (T2):** `_VetInviteRow` @ 526, `_VetEmailInput` @ 588, `_InviteRow` @ 665, `_InputRow` @ 722, `_SelectRow` @ 773.
- **Raw UI (T3):** `TextField`, `ElevatedButton`, `CircleAvatar`, `Divider`, `RotationTransition`.
- **Inline candidates:** custom dropdown in `_SelectRow` @ ~797 (dup of step2); dropdown items @ ~442; feedback/alert `Container`s @ ~240/285/337; `_InputRow` (mirrors `LabeledTextField`).

### lib/screens/invite/invite_screen.dart
- **Purpose:** Invite acceptance (loading + error states).
- **Raw UI (T3):** `CircularProgressIndicator`, `ElevatedButton`.
- **Inline candidates:** none.

### lib/screens/circle/circle_screen.dart
- **Purpose:** Care-circle management — members, pending invites, invite button.
- **Shared (T1):** `PrimaryButton`, `UserAvatar`.
- **Feature-local (T2):** `_EmptyNoPet` @ 48, `_CircleContent` @ 71, `_EmptyCircle` @ 271, `_MemberTile` @ 326, `_PendingInviteTile` @ 406, `_InviteSheet` @ 473, `_InviteSuccess` @ 664.
- **Raw UI (T3):** `ListView`, `CircleAvatar`, `TextButton`, `AlertDialog`/`showDialog`, `showModalBottomSheet`, `TextField`, `IconButton`, `Divider`.
- **Inline candidates:** member-count badge `Container` @ ~106; `_MemberTile`/`_PendingInviteTile`/`_InviteSuccess` cards; `_InviteSheet` modal.

### lib/screens/dashboard/owner_dashboard.dart
- **Purpose:** Owner home — pet cards (BPM + care circle) in grid.
- **Shared (T1):** `DogPhoto`, `PrimaryButton`.
- **Feature-local (T2):** `_AddPetIcon` @ 238, `_PetCard` @ 259, `_InfoRow` @ 417, `_AvatarStack` @ 467, `_AvatarCircle` @ 502.
- **Raw UI (T3):** `GridView.count`, `RefreshIndicator`, `AlertDialog`/`showDialog`, `SnackBar`, `ClipOval`, `Image.network`.
- **Inline candidates:** `_AddPetIcon` circular button @ 238; `_PetCard` card @ 259; `_InfoRow` bordered row @ 417; `_AvatarCircle` @ 502.

### lib/screens/dashboard/vet_dashboard.dart
- **Purpose:** Vet dashboard — patient cards, pending requests, summary stats.
- **Shared (T1):** `DogPhoto`, `NeumorphicCard`, `StatusBadge`.
- **Feature-local (T2):** `_PendingRequestsSection` @ 207, `_PetCard` @ 338, `_SummaryCard` @ 516, `_ResponsiveGrid` @ 569.
- **Raw UI (T3):** `GridView.count`, `TextButton`, `ElevatedButton`, `SnackBar`, `ClipRRect`, `LinearGradient`.
- **Inline candidates:** icon-badge `Container` @ ~252; view-only badge overlay @ ~389; `_SummaryCard` stat card.

### lib/screens/dashboard/care_circle_dashboard.dart
- **Purpose:** Care-circle member view — shared pets + overview stats.
- **Shared (T1):** `DogPhoto`, `NeumorphicCard`, `StatusBadge`.
- **Feature-local (T2):** `_PetCard` @ 92, `_AvatarStack` @ 202, `_SummaryCard` @ 244, `_ResponsiveGrid` @ 308.
- **Raw UI (T3):** `GridView.count`, `ClipOval`, `ClipRRect`, `Image.network`.
- **Inline candidates:** summary icon-badge `Container` @ ~265; `_AvatarStack` overlapping avatars.

### lib/screens/pet_detail/pet_detail_screen.dart
- **Purpose:** Single-pet detail — photo header, info, measurements, notes, circle.
- **Shared (T1):** `DogPhoto`, `StatusBadge`, `BreedSearchField`.
- **Raw UI (T3):** `CustomScrollView`/`SliverAppBar`, `FlexibleSpaceBar`, `RefreshIndicator`, `TextField`, `IconButton`, `showModalBottomSheet`, `showDialog`, `SnackBar`, `LinearGradient`.
- **Inline candidates:** edit-pet modal sheet `Container` @ ~47; sheet-header `Container` @ ~53; app-bar gradient overlay @ ~224.

### lib/screens/pet_detail/pet_detail_sections.dart
- **Purpose:** Pet-detail sections — info, measurement history, notes, care circle.
- **Shared (T1):** `NeumorphicCard`.
- **Feature-local (T2):** `PetInfoSection` @ 17, `PetMeasurementHistory` @ 67, `PetClinicalNotes` @ 171, `PetCareCircle` @ 281.
- **Raw UI (T3):** `TextField`, `ElevatedButton`/`.icon`, `TextButton`/`.icon`, `CircleAvatar`, `Divider`, `LinearGradient`.
- **Inline candidates:** inline bar-chart `Container`s @ ~131; note-input box `Container`+`TextField` @ ~207; role badge `Container` @ ~172.

### lib/screens/pet_detail/pet_detail_widgets.dart
- **Purpose:** Pet-detail helper components.
- **Feature-local (T2):** `InfoTile` @ 11, `NoteCard` @ 64, `MemberTile` @ 111, `RoleBadge` @ 152.
- **Raw UI (T3):** `CircleAvatar`+`NetworkImage`, `ClipOval`.
- **Inline candidates:** `InfoTile` icon-bg stat tile @ 11; `RoleBadge` pill @ 152.

### lib/screens/trends/trends_screen.dart
- **Purpose:** BPM trends — line chart, stat grid, history w/ swipe-to-delete.
- **Shared (T1):** none.
- **Feature-local (T2):** `_StatGrid` @ 359, `_SectionCard` @ 415, `_BadgeRow` @ 434, `_BadgeRowSecond` @ 454, `_LegendBadge` @ 465, `_StatCard` @ 492, `_StatusCard` @ 525, `_StatusPill` @ 564, `_SrrChart` @ 587.
- **Raw UI (T3):** `DropdownButton`/`DropdownButtonHideUnderline`, `AlertDialog`/`Dialog`/`showDialog`, `Dismissible` (swipe-to-delete), `SnackBar`, `AnimatedContainer`, **fl_chart** (`LineChart` etc.).
- **Inline candidates:** dropdown wrapper `Container` @ ~213; export button `GestureDetector`+`Container` @ ~239; status pill `Container` @ ~326; `_StatCard`/`_StatusCard`/`_StatusPill`/`_LegendBadge`/`_SectionCard`.

### lib/screens/measurement/measurement_screen.dart
- **Purpose:** Measurement input — manual tap BPM counter + (flagged) Vision RR camera mode.
- **Shared (T1):** none.
- **Feature-local (T2):** `_TabSelector` @ 117, `_TabButton` @ 156, `_ManualMode` @ 204, `_DurationChip` @ 627, `_VisionMode` @ 664.
- **Raw UI (T3):** `Dialog`/`showDialog`, `SnackBar`, `AnimatedContainer`/`AnimatedBuilder`/`Transform.scale`, `TextButton.icon`, `HapticFeedback`, `CircularProgressIndicator`.
- **Inline candidates:** `_TabSelector`/`_TabButton` segmented control (→ `AppSegmentedControl`); `_DurationChip` (→ `AppFilterChip`); large circular tap button `GestureDetector`+`Container` @ ~565; progress bar `Stack` @ ~536; dialog action buttons @ ~290/342/406.

### lib/screens/medication/medication_screen.dart
- **Purpose:** Medication list — add/edit/view, CSV export.
- **Shared (T1):** `TogglePill`.
- **Feature-local (T2):** `_ActiveMedicationsList` @ 264, `_SectionCard` @ 381.
- **Raw UI (T3):** `showModalBottomSheet`, `AlertDialog` (export preview), `TextButton`/`.icon`, `RefreshIndicator`, `SnackBar`.
- **Inline candidates:** medication card `GestureDetector`+`Container` @ ~309; CSV code-preview box `Container` @ ~87; status badge `Container` @ ~347 (→ `StatusBadge`); circular icon `Container` @ ~205/282.

### lib/screens/medication/add_medication_sheet.dart
- **Purpose:** Add/edit medication modal — form (name, dosage, frequency, dates, notes, reminder).
- **Shared (T1):** `TogglePill`.
- **Feature-local (T2):** `ValidatedFormField`, `DatePickerField`, `DropdownField`, `ValidatedTextArea`, `ReminderCard` (all from `medication_form_widgets.dart`).
- **Raw UI (T3):** `showDatePicker`, `showDialog`/`AlertDialog` (delete confirm), `TextButton`, `Form`, `IconButton`, `SnackBar`.
- **Inline candidates:** sheet-shell `Container` @ ~256; cancel/save `TextButton`s @ ~387/398 (→ `PrimaryButton`).

### lib/screens/medication/medication_form_widgets.dart
- **Purpose:** Reusable medication form fields.
- **Feature-local (T2):** `ValidatedFormField` @ 8, `DatePickerField` @ 58, `DropdownField` @ 110, `ValidatedTextArea` @ 161, `ReminderCard` @ 204.
- **Raw UI (T3):** `TextFormField`, `OutlineInputBorder`, `DropdownButton`/`DropdownMenuItem`, `GestureDetector`.
- **Inline candidates:** dropdown wrapper `Container` @ ~133 (→ `AppDropdown`); `ReminderCard` `Container` @ ~218.

### lib/screens/settings/settings_screen.dart
- **Purpose:** Settings entry — drawer (modal) + standalone modes.
- **Shared (T1):** `BottomNavBar`.
- **Feature-local (T2):** `SettingsDrawer` @ 15, `SettingsScreen` @ 38.
- **Raw UI (T3):** `DraggableScrollableSheet`, `ClipRRect`.
- **Inline candidates:** none (structural/routing).

### lib/screens/settings/settings_content.dart
- **Purpose:** Core settings — appearance, care circle, notifications, reminder times, thresholds, data/privacy, about, sign-out.
- **Feature-local (T2):** `ActionRow`, `SettingsCard`, `SettingsToggleRow`, `LanguageRow`, `CareCircleItem`, `InviteButton`, `ConfigureRow` (used); `_MeasurementReminderFrequencyRow` @ 407, `_MedicationTimeRow` @ 461, `_MeasurementReminderTimeRow` @ 503 (defined).
- **Raw UI (T3):** `SegmentedButton`/`ButtonSegment`, `TextButton`, `showTimePicker`, `Divider`, `ListenableBuilder`.
- **Inline candidates:** sign-out `Container` @ ~372 (→ danger button); close-drawer icon `GestureDetector`+`Container` @ ~95; "Coming Soon" badge `Container` @ ~281.

### lib/screens/settings/settings_widgets.dart
- **Purpose:** Shared settings UI components.
- **Shared (T1):** `TogglePill`.
- **Feature-local (T2):** `SettingsCard` @ 19, `SettingsToggleRow` @ 86, `LanguageRow` @ 161, `ActionRow` @ 262, `SimpleRow` @ 329.
- **Raw UI (T3):** `Container` (card/row shells), `GestureDetector`, `SvgPicture.asset`, `showModalBottomSheet` (language picker), `ListTile`.
- **Inline candidates:** language display badge `Container` @ ~198 (these row/card containers ARE the local design components).

### lib/screens/settings/settings_care_circle_widgets.dart
- **Purpose:** Care-circle settings components.
- **Feature-local (T2):** `InviteButton` @ 11, `CareCircleItem` @ 48, `_Badge` @ 136, `ConfigureRow` @ 167.
- **Raw UI (T3):** `Container` (card shells), `GestureDetector`, `SvgPicture.asset`.
- **Inline candidates:** `_Badge` @ 136 (→ `StatusBadge`); `InviteButton` `Container` @ 22 (→ `PrimaryButton`); `ConfigureRow` button `Container` @ ~211 (→ `PrimaryButton`).

### lib/screens/settings/settings_dialogs.dart
- **Purpose:** Settings dialogs/sheets — sign-out, edit profile, invite, export, share-with-vet (lookup), thresholds, info.
- **Raw UI (T3):** `showDialog`/`AlertDialog`, `showModalBottomSheet`, `TextField`, `OutlineInputBorder`, `StatefulBuilder`, `ElevatedButton` (vet lookup), `CircularProgressIndicator`, `CircleAvatar`.
- **Inline candidates:** alert/feedback `Container`s @ ~446/478/497/516; vet-lookup `ElevatedButton` @ ~395 (→ `PrimaryButton`); verified-vet `CircleAvatar` @ ~454; close button `Container` @ ~284.

### lib/screens/diary/diary_screen.dart
- **Purpose:** Diary placeholder ("Coming Soon").
- **Raw UI (T3):** `Icon`, `Text` only.
- **Inline candidates:** none (placeholder).

### lib/screens/messages/messages_screen.dart
- **Purpose:** Notifications — modal drawer (`NotificationsDrawer`) + standalone (`MessagesScreen`).
- **Feature-local (T2):** `NotificationsDrawer` @ 16, `MessagesScreen` @ 105, `_AppNotificationCard` @ 174.
- **Raw UI (T3):** `DraggableScrollableSheet`, `ClipRRect`, `GestureDetector`, `RefreshIndicator`, `ListenableBuilder`.
- **Inline candidates:** notification card `Container` @ ~219 (→ Tier-1 `NotificationCard`); icon-circle `Container` @ ~231; unread-dot `Container` @ ~259.

---

## Section D — Deduplicated component-type catalog (cross-cutting)

The view that powers step 2: distinct UI **types**, every occurrence, and the tier(s) each currently lives in. **⚠ = duplication hotspot.**

### Buttons
| Type | Occurrences | Tier(s) |
|---|---|---|
| Primary/CTA button | `PrimaryButton` (T1, used in circle, owner_dashboard); landing CTA `TextButton` @ landing:62; sheet save/cancel @ add_medication_sheet:387/398; vet-lookup `ElevatedButton` @ settings_dialogs:395; auth login/send `ElevatedButton` | T1 + **inline (⚠ many bypass `PrimaryButton`)** |
| ⚠ Social-auth button | `_SocialButton` @ login:324 **+** create_account:348 (duplicated) | T2 |
| Icon button | `RoundIconButton` (T1); `_AddPetIcon` @ owner_dashboard:238; close buttons @ settings_content:95, settings_dialogs:284; `IconButton` @ verify_otp, pet_detail | T1 + feature-local + inline |
| Danger/sign-out button | sign-out `Container` @ settings_content:372 | inline |
| Role/option-select button | `_RoleButton` @ role_selection:99; `_TargetOption` @ onboarding_step3:162 | T2 |
| Large tap-action button | tap counter `GestureDetector`+`Container` @ measurement:565 | inline |
| Export/action button | `GestureDetector`+`Container` @ trends:239; `TextButton.icon` @ medication/measurement | inline |

### Cards
| Type | Occurrences | Tier(s) |
|---|---|---|
| Surface/section card | `AppCard` + `NeumorphicCard` (T1); `_SectionCard` @ trends:415 **+** medication:381 (⚠); `SettingsCard` @ settings_widgets:19 | T1 + T2 |
| ⚠ Pet card | `_PetCard` @ owner_dashboard:259 **+** vet_dashboard:338 **+** care_circle_dashboard:92 (3 variants) | T2 |
| Stat/info tile | `InfoTile` @ pet_detail_widgets:11; `_StatCard` @ trends:492; `_SummaryCard` @ vet_dashboard:516 + care_circle:244 (⚠) | T2 |
| Notification card | `NotificationCard` (T1) **vs** `_AppNotificationCard` @ messages:174 (⚠ local reimplementation) | T1 + T2 |
| Member/invite row card | `MemberTile` @ pet_detail_widgets:111; `_MemberTile` @ circle:326; `_PendingInviteTile` @ circle:406; `_VetInviteRow`/`_InviteRow` @ onboarding_step4 | T2 |
| Feedback/alert box | `Container`s @ onboarding_step4:240/285/337, settings_dialogs:446/478/497/516, circle:664, onboarding_step2:179 | inline |
| Medication card | `GestureDetector`+`Container` @ medication:309; `ReminderCard` @ medication_form_widgets:204 | T2 + inline |

### Chips / pills / badges
| Type | Occurrences | Tier(s) |
|---|---|---|
| Status pill | `StatusBadge` (T1, vet/care_circle/pet_detail); `_StatusPill` @ trends:564; status `Container` @ trends:326, medication:347 | T1 + T2 + inline |
| Role/generic badge | `RoleBadge` @ pet_detail_widgets:152; `_Badge` @ settings_care_circle:136; view-only overlay @ vet_dashboard:389; "Coming Soon" @ settings_content:281 | T2 + inline |
| Filter / duration chip | `AppFilterChip` (T1, unused in screens); `_DurationChip` @ measurement:627 | T1 + T2 |
| Legend badge | `_LegendBadge` @ trends:465 | T2 |
| Count badge | member-count `Container` @ circle:106; language badge @ settings_widgets:198 | inline |
| Icon badge (circular) | circular icon `Container`s @ login:162, create_account:135, verify_otp:209, vet_dashboard:252, care_circle:265, messages:231 (⚠ recurring) | inline |
| Unread dot | `Container` @ messages:259 | inline |

### Inputs
| Type | Occurrences | Tier(s) |
|---|---|---|
| Labeled text field | `LabeledTextField` (T1, onboarding_step1); `_InputRow` @ onboarding_step4:722 (⚠ reimpl); `ValidatedFormField` @ medication_form_widgets:8 | T1 + T2 |
| Breed search | `BreedSearchField` (T1, onboarding_step1, pet_detail) | T1 |
| Textarea | `ValidatedTextArea` @ medication_form_widgets:161; note input `Container`+`TextField` @ pet_detail_sections:207 | T2 + inline |
| Date/time field | `DatePickerField` @ medication_form_widgets:58; `showTimePicker` rows @ settings_content:461/503 | T2 + inline |
| OTP digit field | `TextFormField`+`Container` @ verify_otp:264 | inline |
| Raw dialog/sheet `TextField` | circle:_InviteSheet, settings_dialogs, pet_detail | inline |

### Selectors
| Type | Occurrences | Tier(s) |
|---|---|---|
| ⚠ Custom dropdown | `AppDropdown` (T1, unused in screens); custom @ onboarding_step2:92 **+** onboarding_step4(`_SelectRow`):773 **+** `DropdownField` @ medication_form_widgets:110 **+** `DropdownButton` @ trends:213 | T1 + T2 + inline |
| Segmented / tab control | `AppSegmentedControl` + `TogglePill` (T1); `_TabSelector`/`_TabButton` @ measurement:117/156; `SegmentedButton` @ settings_content:407 | T1 + T2 + inline |
| Radio / selection card | `RadioCard` (T1, unused in screens); `_TargetOption` @ onboarding_step3:162 | T1 + T2 |
| Language picker | `LanguageRow` @ settings_widgets:161 + `ListTile` modal | T2 |

### Navigation / shell
| Type | Occurrences | Tier(s) |
|---|---|---|
| Bottom nav | `BottomNavBar` (T1, main_shell, settings) | T1 |
| Nav rail | `NavigationRail` @ main_shell | inline |
| App header | `AppHeader` (T1, main_shell) | T1 |
| Onboarding shell | `OnboardingShell` (T1, steps 1–4) | T1 |
| Sliver app bar | `SliverAppBar`/`FlexibleSpaceBar` @ pet_detail_screen | inline |
| Drag handle | `Container` @ main_shell:79 | inline |
| Modal sheet shell | sheet `Container`s @ pet_detail_screen:47, add_medication_sheet:256, circle:_InviteSheet; `DraggableScrollableSheet` @ settings_screen, messages | inline |

### Avatars
| Type | Occurrences | Tier(s) |
|---|---|---|
| User avatar | `UserAvatar` (T1, circle); `CircleAvatar` @ circle, pet_detail_sections, settings_dialogs, onboarding_step4 | T1 + inline |
| Pet photo | `DogPhoto` (T1, dashboards, pet_detail) | T1 |
| ⚠ Avatar stack | `_AvatarStack` @ owner_dashboard:467 **+** care_circle:202 | T2 |
| Avatar circle | `_AvatarCircle` @ owner_dashboard:502; `ClipOval`+`Image.network` @ dashboards | T2 + inline |

### Dialogs / sheets / charts / lists
| Type | Occurrences | Tier(s) |
|---|---|---|
| Alert dialog | `showDialog`/`AlertDialog` @ owner_dashboard, circle, trends, medication, add_medication_sheet, settings_dialogs, pet_detail | inline |
| Bottom sheet | `showModalBottomSheet` @ main_shell, circle, pet_detail, medication, settings_widgets, settings_dialogs | inline |
| Draggable sheet | `DraggableScrollableSheet` @ settings_screen, messages | inline |
| Line chart | `_SrrChart` @ trends:587 (fl_chart) | T2 |
| Inline bar chart | `Container` bars @ pet_detail_sections:131 | inline |
| Swipe-to-delete row | `Dismissible` @ trends:304 | inline |
| Responsive grid | `_ResponsiveGrid` @ vet_dashboard:569 + care_circle:308 (⚠); `GridView.count` @ owner_dashboard | T2 + inline |

---

## Duplication hotspots (priority candidates for step 2)

1. **Custom dropdown** — 4 separate implementations (onboarding_step2, onboarding_step4 `_SelectRow`, medication `DropdownField`, trends `DropdownButton`) while Tier-1 `AppDropdown` goes unused in screens.
2. **`_PetCard`** — 3 divergent copies across the three dashboards.
3. **Social-auth button** (`_SocialButton`) — duplicated verbatim in login + create_account.
4. **Circular icon badge** — recurring inline `Container` in 6+ places (auth screens, dashboards, messages).
5. **Notification card** — `_AppNotificationCard` (messages) reimplements Tier-1 `NotificationCard`.
6. **`_SummaryCard` / `_ResponsiveGrid` / `_AvatarStack`** — duplicated across vet + care-circle dashboards.
7. **Status pill / badge** — `StatusBadge` (T1) coexists with `_StatusPill`, `_Badge`, and several inline status `Container`s.
8. **Tier-1 widgets unused in any screen:** `AppCard`, `AppDropdown`, `AppFilterChip`, `RadioCard`, `AppToggle`, `AppSegmentedControl`, `RoundIconButton`, `SettingsRow`, `Mascot` — built during the PC v3 migration but not yet adopted by screens (prime step-2 targets).

---

# Figma design-system mapping

> **The map.** Anchored on the real PC v3 design system in Figma — node `402:1191`, file `ApTk87wJXejOTzVtEnFJMw` ([dev link](https://www.figma.com/design/ApTk87wJXejOTzVtEnFJMw/Pet-circle?node-id=402-1191&m=dev)). For each Figma component: the Flutter widget that implements it (if any) and where the app uses it / which inline or feature-local copies should converge onto it.

**Status legend**
- ✅ **implemented & used** — Flutter widget exists and is adopted in ≥1 screen
- 🟡 **widget exists, not adopted** — Flutter widget exists but **0** screen usages (screens still use inline/feature-local versions)
- 🟠 **partial / variant gap / divergent** — widget exists but is missing this variant, lives only as a feature-local class, or has multiple divergent copies
- 🔴 **no Flutter widget** — only inline/raw implementations exist
- ⚪ **DS-only / no app need** — no current app surface

Screen-adoption counts below are from a `grep` of each widget across `lib/screens/` (see "Adoption audit" at the end of this section).

## Section E — Figma DS → Flutter → App map

### Buttons — Figma set `442:8188`
| Figma component (node) | Flutter widget | App usage / inline to converge | Status |
|---|---|---|---|
| Primary `442:8187` | `PrimaryButton` (filled) | Adopted: circle, owner_dashboard (2 screens). Converge inline CTAs: landing `TextButton`:62, vet-lookup `ElevatedButton` settings_dialogs:395, save `TextButton` add_medication_sheet:398, auth `ElevatedButton`s | ✅ |
| Secondary `442:8186` | `PrimaryButton` (secondary variant) | Variant of the adopted widget; audit which CTAs should be secondary | 🟠 |
| Tertiary `442:8185` | `PrimaryButton` (outlined variant) | Variant of the adopted widget; audit outlined usages | 🟠 |
| Link `442:8683` | — (raw `TextButton`) | Text links inline: login/create_account "sign-up/login" `TextButton`s | 🔴 |
| Mini Primary `474:2550` | — (smaller 44px button) | No dedicated widget; small CTAs hand-built | 🔴 |
| Icon `442:8184` | `RoundIconButton` | **0 screens.** Converge `_AddPetIcon` owner_dashboard:238, close buttons settings_content:95 / settings_dialogs:284, raw `IconButton`s | 🟡 |
| Chevron `442:8183` | — (circular chevron button) | No dedicated widget; could be a `RoundIconButton` variant | 🔴 |

### Inputs — Figma set `465:3730`
| Figma component (node) | Flutter widget | App usage / inline to converge | Status |
|---|---|---|---|
| Text input `465:3731` | `LabeledTextField` | Adopted: onboarding_step1 (1 screen). Converge `_InputRow` onboarding_step4:722, raw `TextField`s (otp, dialogs, notes) | ✅ |
| Text input w/ icon `465:3736` | `LabeledTextField` (prefix/suffix) | Variant gap — confirm icon slot support | 🟠 |
| Dropdown closed `465:3739` | `AppDropdown` | **0 screens.** Converge 4 custom dropdowns: onboarding_step2:92, onboarding_step4 `_SelectRow`:773, medication `DropdownField`:110, trends `DropdownButton`:213 | 🟡 |
| Dropdown open `510:1220` | `AppDropdown` (open state) | Same as above | 🟡 |
| Language `474:972` | `LanguageRow` (feature-local, settings_widgets:161) | Feature-local; promote to `lib/widgets/` if reused | 🟠 |

### Content cards — Figma set `465:4260`
| Figma component (node) | Flutter widget | App usage / inline to converge | Status |
|---|---|---|---|
| icon-text-date `465:3752` | `InfoTile` (pet_detail_widgets:11) | Measurement/stat rows; feature-local | 🟠 |
| two-icons `504:1547` | — | Measurement row + action icon (medication:309); no dedicated widget | 🔴 |
| note `442:8369` | — | Inline note/info boxes: onboarding_step2:179, settings_dialogs alert boxes | 🔴 |
| icon-text-icon `442:8398` | `_RoleButton` (role_selection:99) | Role/nav rows; feature-local | 🟠 |
| members `442:8935` | `MemberTile` (pet_detail_widgets:111) | Also `_MemberTile` circle:326, `_AvatarStack` ×2 — converge | 🟠 |
| notification-new `465:4434` | `NotificationCard` | **0 screens.** Converge `_AppNotificationCard` messages:174 (unread state) | 🟡 |
| notification-read `465:4454` | `NotificationCard` (read state) | Same — `_AppNotificationCard` read state | 🟡 |
| icon-toggle `474:939` | `SettingsToggleRow` (settings_widgets:86) + `AppToggle` | `SettingsToggleRow` now renders `AppToggle` for binary on/off settings | ✅ |
| reminder `469:982` | `ReminderCard` (medication_form_widgets:204) | Feature-local; also medication time rows | 🟠 |
| icon-text-status `465:3733` | — | Medication rows in `_ActiveMedicationsList`/`_SectionCard` medication:264/381 | 🔴 |
| text-status `474:1815` | `_Badge` (settings_care_circle:136) | Guest/member status rows; feature-local | 🟠 |

### Pills (chips & status) — Figma set `465:3618`
| Figma component (node) | Flutter widget | App usage / inline to converge | Status |
|---|---|---|---|
| Normal `465:3619` | `StatusBadge` | Adopted: vet_dashboard, care_circle_dashboard, pet_detail (3 screens) | ✅ |
| Elevated `465:3622` | `StatusBadge` | Same | ✅ |
| Alert `465:3625` | `StatusBadge` | Same | ✅ |
| Active `465:3628` | `StatusBadge` | Same; also medication "Active" status @ medication:347 (inline — converge) | ✅ |
| Invited `465:3630` | `StatusBadge` (invited variant) | Variant gap — "invited" currently via `_Badge`/text-status rows | 🟠 |
| Filter `465:3632` | `AppFilterChip` | **0 screens.** Converge filter pills (trends legend, measurement) | 🟡 |

### Standalone components
| Figma component (node) | Flutter widget | App usage / inline to converge | Status |
|---|---|---|---|
| Toggle `465:3781` (On/Off) | `AppToggle` | Adopted in settings via `SettingsToggleRow`. `TogglePill` (segmented) remains for the medication reminder card | ✅ |
| Tag Button `465:3786` | `AppFilterChip` / — | `_DurationChip` measurement:627; selectable tag | 🟠 |
| Selection Card `465:3765` | `RadioCard` | **0 screens.** Converge `_TargetOption` onboarding_step3:162, `_RoleButton` role_selection:99 | 🟡 |
| Pet Card `442:8872` | — (3 divergent copies) | `_PetCard` owner:259 / vet:338 / care_circle:92 — converge to one widget | 🟠 |
| Tab Bar `465:3372` | `BottomNavBar` | Adopted: main_shell, settings (2 screens) | ✅ |
| Segmented Control `464:847` | `AppSegmentedControl` | **0 screens.** Converge `_TabSelector`/`_TabButton` measurement:117/156 | 🟡 |
| Progress Bars `469:813` | — | Inline progress `Stack` measurement:536; no widget | 🔴 |

### Mascots (5 SVG breeds)
| Figma component | Flutter widget | App usage | Status |
|---|---|---|---|
| Floppy / Perky / Fluffy / Snout / Whiskers | `Mascot` (`mascot.dart`, 1:1 with breeds) | **0 screens** — widget exists, not yet placed in any screen | 🟡 |

**Row count:** 7 buttons + 5 inputs + 11 cards + 6 pills + 7 standalone + 5 mascots = **41 mapped**.

## Section F — Gap analysis (two directions)

**🔴 DS components with no Flutter widget** (need building, or accept as raw):
- Buttons: **Link**, **Mini Primary**, **Chevron**
- Content cards: **two-icons**, **note**, **icon-text-status** (no first-class widget)
- **Progress Bars**

**🟡 Flutter widgets built but unadopted by any screen** (0 usages — adopt these first, cheapest parity win):
`RoundIconButton`, `AppCard`, `AppFilterChip`, `RadioCard`, `AppToggle`, `AppSegmentedControl`, `AppDropdown`, `SettingsRow`, `Mascot`, `AppImage` (used only via other widgets), `NotificationCard`.

**🟠 App components diverging from a single DS source** (consolidate):
- `_PetCard` ×3 (owner/vet/care_circle) → one Pet Card
- `_SummaryCard` ×2, `_ResponsiveGrid` ×2, `_AvatarStack` ×2 (vet + care_circle)
- `_SocialButton` ×2 (login + create_account)
- 4× custom dropdown → `AppDropdown`
- `_AppNotificationCard` vs `NotificationCard`
- `_StatusPill` / `_Badge` / `RoleBadge` / inline status `Container`s → `StatusBadge`
- Button variants (Secondary/Tertiary) under-audited; many inline CTAs bypass `PrimaryButton`

## Section G — Convergence shortlist (ranked by occurrences × divergence)

Highest-value adoptions to reach DS parity. **Descriptive only — actual refactors are a later step.**

1. **Custom dropdown → `AppDropdown`** — 4 implementations, widget already built. Biggest single win.
2. **`_PetCard` ×3 → one Pet Card widget** (Figma `442:8872`) — core surface, 3 divergent copies.
3. **Status pills → `StatusBadge`** — unify `_StatusPill`, `_Badge`, `RoleBadge`, inline `Container`s; add "Invited" variant.
4. **Notification card → `NotificationCard`** — replace `_AppNotificationCard` (messages).
5. **Icon buttons → `RoundIconButton`** — replace `_AddPetIcon` + inline close `IconButton`s.
6. **Selection cards → `RadioCard`** — replace `_TargetOption`, `_RoleButton`.
7. **Segmented control → `AppSegmentedControl`** — replace measurement `_TabSelector`.
8. **Place `Mascot`** in onboarding/empty-states (currently built but never shown).

## Adoption audit (grep of `lib/screens/`)

✅ used: `PrimaryButton` (2), `NeumorphicCard` (3), `StatusBadge` (3), `TogglePill` (2), `LabeledTextField` (1), `BreedSearchField` (2), `AppHeader` (1), `BottomNavBar` (2), `OnboardingShell` (4), `UserAvatar` (1), `DogPhoto` (5).

🟡 zero screen usage: `RoundIconButton`, `AppCard`, `AppFilterChip`, `RadioCard`, `NotificationCard`, `AppToggle`, `AppSegmentedControl`, `AppDropdown`, `SettingsRow`, `AppImage`, `Mascot`.
