# Pet Circle Bug Log

Tracks all bugs discovered during development and testing. Each entry includes context, root cause, fix status, and the affected files.

---

## BUG-001: Email verification loop

**Found during:** Test 1 — Pet Owner sign-up flow
**Severity:** Critical (blocks onboarding)
**Status:** Fixed

**Symptom:** After clicking the email verification link and tapping "I've verified my email", the app loops on the Verify Email screen indefinitely instead of navigating forward.

**Root cause:** `AuthProvider.refresh()` called `AuthService.reloadUser()` (which updates the Firebase user object) but never re-assigned `_firebaseUser` from `AuthService.currentUser`. The `isEmailVerified` getter continued reading the stale `_firebaseUser` reference, always returning `false`.

**Fix:** Updated `AuthProvider.refresh()` to set `_firebaseUser = AuthService.currentUser` after reload. Updated `VerifyEmailScreen._checkVerification()` to call `authProvider.refresh()` instead of `AuthService.reloadUser()` directly.

**Files changed:**
- `lib/providers/auth_provider.dart`
- `lib/screens/auth/verify_email_screen.dart`

---

## BUG-002: Role Selection shown again for returning users

**Found during:** Test 1 — Pet Owner sign-up flow
**Severity:** High (confusing UX for returning users)
**Status:** Fixed

**Symptom:** After logging in with an existing account, the user sees the Role Selection screen again ("I'm a Vet / I'm a Pet Owner") even though they already chose a role during sign-up.

**Root cause:** Two issues combined:
1. The user signed up before Firestore was provisioned, so `UserService.createUser()` silently failed and the Firestore user document was never created.
2. `AuthGate` detects "authenticated but no Firestore profile" (`_appUser == null`) and routes to `/role-selection`. But `RoleSelectionScreen._handleRoleSelect()` always pushed to the Auth screen when Firebase was enabled, even though the user was already authenticated.

**Fix:** Updated `RoleSelectionScreen._handleRoleSelect()` to check if `authProvider.firebaseUser` is already non-null. If so, create the Firestore user document directly via `UserService.createUser()` and navigate back to `AuthGate`, skipping re-authentication.

**Files changed:**
- `lib/screens/auth/role_selection_screen.dart`

---

## BUG-003: Verification email lands in spam

**Found during:** Test 1 — Pet Owner sign-up flow
**Severity:** Medium (usability issue, not a code bug)
**Status:** Fixed

**Symptom:** Firebase verification emails sent from `noreply@pet-circle-app.firebaseapp.com` are flagged as spam by Gmail and other providers.

**Root cause:** Firebase's default email sender domain is not trusted by spam filters. This is a platform limitation, not a code bug.

**Workaround:** In Firebase Console > Authentication > Templates, customize the sender name to "Pet Circle". For production, configure a custom SMTP server with a verified domain.

**Files changed:** None (Firebase Console configuration)

---

## BUG-004: "I've verified my email" button not prominent enough

**Found during:** Test 1 — Pet Owner sign-up flow
**Severity:** Low (UX polish)
**Status:** Fixed

**Symptom:** The "I've verified my email" action was a small `TextButton.icon` with a refresh icon, easily overlooked.

**Fix:** Replaced with a prominent `PrimaryButton` using `Icons.check_circle_outline` and the app's `lightBlue` color, making it the clear primary action on the screen.

**Files changed:**
- `lib/screens/auth/verify_email_screen.dart`

---

## BUG-005: Hardcoded "Guest 01" shown in onboarding step 4 before any invites

**Found during:** Test 1 -- Pet Owner onboarding flow
**Severity:** Medium (confusing UX)
**Status:** Fixed

**Symptom:** On the care circle invite step (onboarding step 4), a hardcoded "Guest 01" row with "Status: invited" badge is shown before the user has invited anyone.

**Root cause:** `_invites` was a hardcoded `const` list containing `_InviteStatus(name: 'Guest 01', status: 'Status: invited')` -- placeholder data that was never replaced with dynamic behavior.

**Fix:** Changed `_invites` to an empty mutable list. Invited emails are now added dynamically when the user taps "Add to Care Circle". Each row shows the actual email and the selected role.

**Files changed:**
- `lib/screens/onboarding/onboarding_step4.dart`

---

## BUG-006: Misleading "Add another Pet Circle" button in onboarding step 4

**Found during:** Test 1 -- Pet Owner onboarding flow
**Severity:** Low (confusing UX)
**Status:** Fixed

**Symptom:** A button labeled "Add another Pet Circle" appeared below the invite form. It only reset the form fields, which is confusing since the user can simply type another email after the first invite.

**Root cause:** The button and its `_resetInvite` handler were leftover from an earlier design that assumed a single-invite-per-step flow.

**Fix:** Removed the button and the `_resetInvite` method entirely. Users can now invite multiple people by typing an email, selecting a role, tapping "Add to Care Circle", and repeating.

**Files changed:**
- `lib/screens/onboarding/onboarding_step4.dart`

---

## BUG-007: Adding a care circle invite during onboarding immediately completed onboarding

**Found during:** Test 1 -- Pet Owner onboarding flow
**Severity:** High (skips user's ability to invite multiple people)
**Status:** Fixed

**Symptom:** After typing an email and tapping "Add to Care Circle" on onboarding step 4, the app immediately navigated to the dashboard instead of staying on the invite screen to allow adding more people.

**Root cause:** `_addToCareCircle()` called `widget.onComplete?.call()` after adding the email, which triggered the parent `OnboardingFlow._onComplete()` and completed the entire onboarding. The "Add to Care Circle" action should only add the invite to the local list, NOT trigger onboarding completion.

**Fix:** Removed `widget.onComplete?.call()` from `_addToCareCircle()`. The "Complete" button in the `OnboardingShell` footer (handled separately via `onNext`) is the only way to finish onboarding. Also improved `_InviteRow` to show "Pending" status text below the email and a mail icon, making the invited state clearer.

**Files changed:**
- `lib/screens/onboarding/onboarding_step4.dart`

---

## BUG-008: Pet card on Owner Dashboard navigates to Pet Detail (vet-oriented screen)

**Found during:** Test 1 -- Pet Owner dashboard review
**Severity:** Low (UX mismatch, not broken)
**Status:** Fixed

**Symptom:** Tapping a pet card on the Owner Dashboard opened the Pet Detail screen, which is a clinical view with "Add Note" and care circle info -- more relevant for vets. Owners already have Measure and Trends buttons directly on each card.

**Root cause:** The `onTap` handler on `_PetCard` navigated to `/pet-detail` for both owner and vet dashboards. The Pet Detail screen was designed primarily for the vet workflow.

**Fix:** Removed the `onTap` navigation from pet cards on the Owner Dashboard. Cards are no longer tappable (long-press for delete still works for admins). Owners use the Measure/Trends action buttons on the card instead. The Vet Dashboard retains card tap → Pet Detail navigation.

**Files changed:**
- `lib/screens/dashboard/owner_dashboard.dart`

---

## BUG-009: Pet selector visible on Home tab and chevron shows with only 1 pet

**Found during:** Test 1 -- Pet Owner dashboard review
**Severity:** Low (UX polish)
**Status:** Fixed

**Symptom:** The pet selector chip (with pet name and dropdown chevron) appeared in the header on the Home tab, which is redundant since the dashboard already shows all pets. The dropdown chevron also appeared even with only 1 pet, suggesting a switcher that doesn't exist.

**Root cause:** `MainShell` always passed `pet?.name` and `pet?.imageUrl` to `AppHeader` regardless of which tab was active. `AppHeader` always rendered the chevron icon regardless of whether `onPetSelectorTap` was null.

**Fix:** In `MainShell`, pass `null` for `petName`/`petImageUrl` when on the Home tab (index 0), hiding the selector entirely. In `AppHeader`, only render the chevron when `onPetSelectorTap` is non-null (i.e., there are 2+ pets and we're not on Home).

**Files changed:**
- `lib/screens/main_shell.dart`
- `lib/widgets/app_header.dart`

---

## BUG-010: Welcome screen "Sign In" button goes to Role Selection instead of sign-in

**Found during:** Test 1 -- returning user sign-in flow
**Severity:** High (returning users forced through sign-up flow)
**Status:** Fixed

**Symptom:** Tapping "Sign In" on the Welcome screen navigated to the Role Selection screen, same as "Sign Up". A returning user who already has an account should go directly to the sign-in form.

**Root cause:** Both buttons on `WelcomeScreen` navigated to `AppRoutes.roleSelection`. There was no distinct sign-in path.

**Fix:** The "Sign In" button now navigates directly to `AppRoutes.auth` with `{'signIn': true}`. `AuthScreen` now accepts optional `role` (null for sign-in) and `startWithSignIn` flag. The role badge ("Signing up as...") only shows when a role is provided. The route handler in `main.dart` parses both the legacy `AppUserRole` argument and the new `Map` argument format.

**Files changed:**
- `lib/screens/welcome_screen.dart`
- `lib/screens/auth/auth_screen.dart`
- `lib/main.dart`

---

## BUG-011: Onboarding invites don't create Firestore invitations

**Found during:** Vet-pet integration audit
**Severity:** High (invited users never see the shared pet)
**Status:** Fixed

**Symptom:** When an owner invites someone during onboarding step 4, the email is stored in the pet's `careCircle` as a name-only placeholder without a UID. No Firestore invitation is created, so the invited person has no way to accept and the pet never appears on their dashboard.

**Root cause:** `OnboardingFlow._onComplete()` created `CareCircleMember` objects from emails but never called `InvitationService.createInvitation()`. Also, `onEmailAdded` only passed the email string, not the selected role.

**Fix:** Changed `OnboardingStep4` callback from `onEmailAdded(String)` to `onInviteAdded(String email, String role)`. Updated `OnboardingFlow` to store email+role pairs. After pet creation, loops through all invites and calls `InvitationService.createInvitation()` for each, creating real Firestore invitation tokens. The invited member's selected role (Admin/Member/Viewer) is now correctly preserved.

**Files changed:**
- `lib/screens/onboarding/onboarding_step4.dart`
- `lib/screens/onboarding/onboarding_flow.dart`

---

## BUG-012: Share with Vet dialog is UI-only (no backend)

**Found during:** Vet-pet integration audit
**Severity:** High (vets cannot be associated with pets)
**Status:** Fixed

**Symptom:** Tapping "Share with Vet" in Settings > Data & Privacy, entering a vet email, and tapping the share button only showed a snackbar. No invitation was created in Firestore, so the vet never received access to the pet.

**Root cause:** `_showShareWithVetDialog` was a UI stub that popped the sheet and showed a snackbar without calling any backend service.

**Fix:** Wired the dialog to call `InvitationService.createInvitation()` with role `CareCircleRole.viewer` (the default vet permission level). The invite link is copied to clipboard. Added a loading spinner during the async operation. Falls back to snackbar-only in mock mode.

**Files changed:**
- `lib/screens/settings/settings_screen.dart`

---

## BUG-013: Sign-in redirects to Role Selection instead of Home

**Found during:** Test 1 -- returning user sign-in
**Severity:** Critical (blocks sign-in flow for returning users)
**Status:** Fixed

**Symptom:** After signing in with an existing account, the app shows the Role Selection screen instead of the dashboard.

**Root cause:** Race condition in `AuthProvider._onAuthStateChanged()`. When a new user signs in, `_isLoading` was already `false` from a previous auth state change (e.g., the initial unauthenticated state). The Firestore stream for the user profile hadn't fired yet, so `_appUser` was null. `routeState` returned `needsRole` instead of `loading`, causing `AuthGate` to navigate to Role Selection before the profile loaded.

**Fix:** In `_onAuthStateChanged`, when a non-null user is received, reset `_appUser = null` and `_isLoading = true` before starting the Firestore stream. This ensures `routeState` returns `loading` until the user profile is fetched, preventing premature navigation.

**Files changed:**
- `lib/providers/auth_provider.dart`

---

## BUG-014: Sign-in with Google routes to onboarding instead of dashboard

**Found during:** Test 1 -- returning user sign-in with Google
**Severity:** Critical (blocks returning users from reaching their dashboard)
**Status:** Fixed

**Symptom:** Signing in with Google shows the "add pet" onboarding form instead of the owner dashboard, even though the user already has a pet.

**Root cause:** `AuthGate._handleAuthenticated()` checked `appUser.hasPets` (based on `petIds` array on the Firestore user doc) to decide between onboarding and dashboard. The `petIds` array was empty because the pet was created in a session before `UserService.addPetToUser()` was wired up. This caused all returning owners to be wrongly redirected to onboarding.

**Fix:** Removed the `appUser.hasPets` check from `AuthGate._handleAuthenticated()` entirely. All authenticated owners now route directly to Main Shell. The Owner Dashboard already handles the empty state with a "No pets yet -- Get Started" CTA that navigates to onboarding, so first-time users are handled gracefully without fragile routing logic.

**Design principle:** AuthGate should only care about auth state (authenticated/unauthenticated/needs role/needs verification), not business logic like pet count.

**Files changed:**
- `lib/screens/auth/auth_gate.dart`

---

## BUG-015: Pet created twice when tapping Complete in onboarding

**Found during:** Test 1 -- Pet Owner onboarding flow
**Severity:** High (duplicate data in Firestore)
**Status:** Fixed

**Symptom:** After completing onboarding, the pet appears twice on the owner dashboard.

**Root cause:** The "Complete" button in `OnboardingShell` calls `_onComplete()` which is async (writes to Firestore). While waiting for the Firestore write, the button remains enabled, allowing a second tap that creates a duplicate pet document.

**Fix:** Added `_isSubmitting` flag to `_OnboardingFlowState`. `_onComplete()` returns immediately if already submitting. The Complete button is disabled (`onComplete: null`) while submission is in progress.

**Files changed:**
- `lib/screens/onboarding/onboarding_flow.dart`

---

## BUG-016: Deleting one pet removes all pets with the same name from the UI

**Found during:** Test 1 -- deleting duplicate pet
**Severity:** High (data loss perception)
**Status:** Fixed

**Symptom:** When two duplicate pets existed (same name), deleting one removed both from the dashboard.

**Root cause:** `removePetWithFirestore()` deleted one Firestore document but then ran `_ownerPets.removeWhere((p) => p.name == name)` which removed ALL local pets matching that name. When Firebase is enabled, the local removal is unnecessary because the Firestore stream automatically updates the local list.

**Fix:** When `kEnableFirebase` is true, only perform the Firestore deletion and let the stream handle the local state update. The `removeWhere` local cleanup now only runs in mock mode. Same fix applied to `removeCareCircleMemberWithFirestore`.

**Files changed:**
- `lib/stores/pet_store.dart`

---

## BUG-017: Pet permissions drift across screens and can show owner as viewer

**Found during:** Returning owner sign-in and pet action flow
**Severity:** High (incorrect permissions and confusing blocked actions)
**Status:** Fixed

**Symptom:** After signing in, an owner could see viewer-level restrictions on their own pet. In particular, tapping Measure/heart from a pet card could open a shared tab that treated the user as a viewer instead of an admin/member.

**Root cause:** Pet permissions were reconstructed in multiple screens using `currentUserRoleFor(...) ?? viewer`, while shared tabs relied on `petStore.activePet`. The Owner Dashboard navigated to shared tabs without first selecting the clicked pet, and several screens used inconsistent pet sources (`activePet`, `pets.first`, or pet name lookups). This fragmented logic let screens drift and fall back to viewer too easily. A separate local edit path in `PetDetailScreen` also rebuilt `Pet` without preserving identity fields, which could strip `ownerId` in memory.

**Fix:** Added a centralized `PetAccess` resolver in `PetStore` that derives a concrete per-pet persona from `ownerId`, care-circle UID matches, and legacy fallbacks. Updated dashboards and shared screens to use `accessForPet(...)` / `accessForActivePet()` instead of local viewer fallbacks, switched Settings and Medication to `activePet`, set the clicked pet active before opening shared tabs, and preserved `id`/`ownerId` when editing a pet locally.

**Files changed:**
- `lib/models/pet_access.dart`
- `lib/stores/pet_store.dart`
- `lib/screens/dashboard/owner_dashboard.dart`
- `lib/screens/measurement/measurement_screen.dart`
- `lib/screens/pet_detail/pet_detail_screen.dart`
- `lib/screens/settings/settings_screen.dart`
- `lib/screens/trends/trends_screen.dart`
- `lib/screens/medication/medication_screen.dart`

---

## BUG-018: Pet latest measurement snapshot gets stale after Firestore subcollection writes

**Found during:** Firestore subcollection wiring audit
**Severity:** Medium (some screens show outdated summary data)
**Status:** Fixed

**Symptom:** After adding or deleting measurements, the measurement history and trends update from the `measurements` subcollection, but some pet summary surfaces can still show an outdated latest BPM/time. In particular, `Pet.latestMeasurement` on the parent `/pets/{petId}` document is not kept in sync.

**Root cause:** `PetService.addMeasurement()` and `deleteMeasurement()` only write to `/pets/{petId}/measurements`. They do not also update the parent pet document's `latestMeasurement` field. Several screens still read summary values from `Pet.latestMeasurement` on the parent pet document.

**Fix:** Updated `PetService.addMeasurement()` and `deleteMeasurement()` to resync the parent `/pets/{petId}.latestMeasurement` field after each subcollection write. Also updated owner, vet, care-circle, and pet-detail summary surfaces to prefer live values from `measurementStore` and show empty-state placeholders when no measurements exist.

**Files changed:**
- `lib/services/pet_service.dart`
- `lib/models/pet.dart`
- `lib/screens/pet_detail/pet_detail_screen.dart`
- `lib/screens/dashboard/owner_dashboard.dart`
- `lib/screens/dashboard/vet_dashboard.dart`
- `lib/screens/dashboard/care_circle_dashboard.dart`

---

## BUG-019: Invitation acceptance still requires a self-join exception in Firestore rules

**Found during:** Firestore security rules design
**Severity:** High (security hardening gap)
**Status:** Known limitation

**Symptom:** Strict Firestore rules cannot fully validate invitation acceptance, because the app currently accepts invitations client-side by reading an invitation document and then directly updating the pet's `careCircle` / `memberUids` fields.

**Root cause:** Firestore rules for `/pets/{petId}` can see the pet document being updated, but they cannot validate an arbitrary invitation token unless the pet update itself carries trusted invitation state. The current data model stores invitations in `/invitations/{token}` and performs acceptance purely from the client, so production rules need a narrow self-join exception to keep the current flow working.

**Fix:** Invitation creation now writes a trusted `pendingInvites.{token}` entry onto the pet document, and invitation acceptance removes that entry in the same transaction that adds the authenticated member to `careCircle` / `memberUids`. Firestore rules now verify the accepted token against the pet's trusted pending-invite state instead of relying on a broad self-join exception. The updated rules were deployed to Firebase after the repo changes landed.

**Files changed:**
- `lib/screens/onboarding/onboarding_flow.dart`
- `lib/screens/auth/auth_gate.dart`
- `lib/screens/dashboard/vet_dashboard.dart`
- `firestore.rules`
- `lib/services/invitation_service.dart`

---

## BUG-020: Medication form only saves name, dosage, and frequency — other fields ignored

**Found during:** Manual testing — adding a medication with all fields filled
**Severity:** High (data loss — user input silently discarded)
**Status:** Fixed

**Symptom:** When filling out the Add Medication form (start date, end date, prescribed by, purpose/condition, additional notes, and reminders toggle), only medication name, dosage, and frequency were saved. All other fields were silently discarded. Start date was always hardcoded to `DateTime.now()` regardless of user input.

**Root cause:** Three compounding issues:
1. The `Medication` model only had 5 fields (`name`, `dosage`, `frequency`, `startDate`, `isActive`), missing `endDate`, `prescribedBy`, `purpose`, `notes`, and `remindersEnabled`.
2. The `_AddMedicationSheet` only created `TextEditingController`s for `name` and `dosage`. The start/end date, prescribed by, purpose, and notes fields had no controllers and were purely visual.
3. The save handler only read `_nameController.text`, `_dosageController.text`, and `_frequency`, ignoring all other form input.

**Fix:**
- Expanded `Medication` model with 5 new fields: `endDate` (`DateTime?`), `prescribedBy` (`String?`), `purpose` (`String?`), `notes` (`String?`), and `remindersEnabled` (`bool`). Updated `toFirestore()`, `fromFirestore()`, and `copyWith()`.
- Added `TextEditingController`s for all form fields. Replaced free-text date fields with date-picker-backed read-only fields (`showDatePicker`).
- Replaced `TextField` with `TextFormField` and added a `Form` with `GlobalKey<FormState>` for validation (required fields: name, dosage, start date).
- Updated the save handler to include all fields when creating or editing a medication.

**Files changed:**
- `lib/models/medication.dart`
- `lib/screens/medication/medication_screen.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_he.arb`

---

## BUG-021: Medication export is a UI placeholder — does not actually download a file

**Found during:** Manual testing — tapping "Download CSV" in Export Medication Log dialog
**Severity:** High (feature does not work as advertised)
**Status:** Fixed

**Symptom:** Tapping "Download CSV" in the export dialog only closes the dialog and shows a success snackbar. No file is actually saved or shared.

**Root cause:** `_exportMedicationLog()` built a CSV string and displayed it in an `AlertDialog` preview, but the "Download CSV" button handler only called `Navigator.pop()` + showed a snackbar. No file I/O or share sheet invocation existed.

**Fix:** Added `share_plus` and `path_provider` dependencies. The "Download CSV" button now writes the CSV to a temporary file via `path_provider`, then invokes the native OS share sheet via `SharePlus.instance.share()` (iOS: `UIActivityViewController`, Android: `ACTION_SEND` intent). Also expanded the CSV to include all new medication fields (end date, prescribed by, purpose, notes).

**Files changed:**
- `lib/screens/medication/medication_screen.dart`
- `pubspec.yaml`

---

## BUG-022: Medication reminders toggle is UI-only — no native notifications scheduled

**Found during:** Manual testing — enabling medication reminders and checking device notifications
**Severity:** High (feature does not work as advertised)
**Status:** Fixed

**Symptom:** Toggling "Medication Reminders" on in the Add Medication sheet has no effect. No native device notifications are scheduled. The toggle only controls a local boolean state that is discarded on save.

**Root cause:** The `_remindersEnabled` state variable existed in the sheet widget but was never persisted to the `Medication` model (which lacked the field) and no notification scheduling service existed.

**Fix:** Added `flutter_local_notifications` and `timezone` dependencies. Created `ReminderService` (`lib/services/reminder_service.dart`) with platform-native notification scheduling (iOS: `UNUserNotificationCenter`, Android: `NotificationManager`). Reminders are scheduled as daily recurring notifications at 9:00 AM (once daily) or 9:00 AM + 9:00 PM (twice daily). The `remindersEnabled` field is now persisted on the `Medication` model and drives scheduling/cancellation in the save flow. Configured iOS `Info.plist` and Android `AndroidManifest.xml` with required notification permissions and boot receivers.

**Files changed:**
- `lib/services/reminder_service.dart` (new)
- `lib/models/medication.dart`
- `lib/screens/medication/medication_screen.dart`
- `lib/stores/medication_store.dart`
- `lib/main.dart`
- `pubspec.yaml`
- `ios/Runner/Info.plist`
- `android/app/src/main/AndroidManifest.xml`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_he.arb`

---

## BUG-023: "Add to graph" button freezes UI while awaiting sequential Firestore operations

**Found during:** Manual testing — completing a measurement and tapping "Add to graph"
**Severity:** High (confusing/broken — app appears frozen for several seconds)
**Status:** Fixed

**Symptom:** After tapping "Add to graph" the dialog stays open and the UI is unresponsive for several seconds before finally closing and showing the success snackbar.

**Root cause:** The `onTap` handler awaited 4 sequential Firestore operations before touching the UI: (1) write measurement subcollection doc, (2) query the latest measurement back, (3) update the pet document's denormalized `latestMeasurement` field, (4) write a notification doc to the user's notifications collection. On a slow connection this chain could take multiple seconds. Additionally, `MeasurementStore.addMeasurement` did not update the local in-memory list when Firebase was enabled — it relied entirely on the Firestore stream listener to refresh, adding even more perceived delay.

**Fix:** Made the save flow optimistic: `MeasurementStore.addMeasurement` now inserts the measurement into the local list and calls `notifyListeners()` immediately (with rollback on error). `PetService.addMeasurement` eliminates the redundant re-query by writing the known latest measurement directly onto the pet doc, and that write is fire-and-forget (`unawaited`). The button handler no longer awaits either the measurement or notification store calls — the dialog closes and the snackbar appears instantly. Also replaced a hardcoded `Color(0xFF75ACFF)` in the snackbar with `c.lightBlue` per design system rules.

**Files changed:**
- `lib/stores/measurement_store.dart`
- `lib/services/pet_service.dart`
- `lib/screens/measurement/measurement_screen.dart`

---

## BUG-024: "Add to graph" button allows double-tap, creating duplicate measurements

**Found during:** Manual testing — tapping "Add to graph" after completing a measurement
**Severity:** High (data corruption — duplicate entries skew averages and counts)
**Status:** Fixed

**Symptom:** Two identical measurement entries appear in Measurement History with the same BPM and timestamp, inflating averages and status counts.

**Root cause:** The "Add to graph" `GestureDetector` had no re-entry guard. Before the BUG-023 optimistic fix, the dialog stayed open for several seconds while awaiting Firestore, allowing the user to tap the button multiple times. Each tap triggered a separate `addMeasurement` call, creating a duplicate Firestore document.

**Fix:** Added an `_isSaving` boolean flag to `_ManualModeState`. The flag is set to `true` at the start of the `onTap` handler and checked at entry — subsequent taps are ignored. The flag never needs resetting because `Navigator.pop` dismisses the dialog immediately after.

**Files changed:**
- `lib/screens/measurement/measurement_screen.dart`

---

## BUG-025: Health Trends status counts do not update after a new measurement

**Found during:** Manual testing — adding a measurement and checking the Status card on the Trends screen
**Severity:** Medium (stale data until manual refresh)
**Status:** Fixed

**Symptom:** The Status card (Normal / Elevated / Critical counts) in Health Trends does not reflect a newly added measurement. The counts only update after navigating away and back or refreshing the screen.

**Root cause:** `_StatusCard` was instantiated as `const _StatusCard()` inside `_StatGrid`. Because `const` produces an identical widget instance across rebuilds, Flutter's reconciliation skips calling `build()` on it, so the status counts computed inside `build()` become stale. Additionally, `_StatusCard` read directly from `measurementStore` without respecting the selected time period filter, inconsistent with the other stat cards.

**Fix:** Changed `_StatusCard` to accept a `List<Measurement> measurements` parameter. Removed `const` from both call sites so the widget rebuilds when data changes. The measurements list now comes from the same `filtered` data used by Average, Range, and Trend cards, so status counts respect the selected time period.

**Files changed:**
- `lib/screens/trends/trends_screen.dart`

---

## BUG-026: All Firestore-backed mutations block the UI until the network round-trip completes

**Found during:** Manual testing — updating medication data and observing multi-second UI freeze
**Severity:** High (app feels stuck on every save/delete/toggle action)
**Status:** Fixed

**Symptom:** Any mutation across the app (adding/editing/deleting medications, deleting measurements, editing pet profiles, adding clinical notes, marking notifications read, removing care circle members, saving thresholds, deleting pets) causes the UI to freeze for the duration of the Firestore write. Dialogs stay open, sheets don't close, and snackbars don't appear until the network round-trip finishes.

**Root cause:** Every store mutation method (except `MeasurementStore.addMeasurement` fixed in BUG-023 and `SettingsStore` toggles) awaited the Firestore service call before updating local state or calling `notifyListeners()`. Screen-level handlers then `await`ed these store methods before closing dialogs or showing feedback. This created a chain: user tap -> await Firestore write -> only then update UI.

**Fix:** Applied the same optimistic pattern across all 5 stores (12 methods total) and 6 screens (8 handlers):

**Stores** — Each mutation now updates local state and calls `notifyListeners()` immediately, then fires the Firestore write in the background. On error, the local change is rolled back and listeners are notified again. Affected methods:
- `MeasurementStore.removeMeasurement`
- `MedicationStore.addMedication`, `removeMedication`, `updateMedication`, `toggleMedication`
- `NoteStore.addNote`
- `NotificationStore.addNotification`, `markRead`, `markAllRead`
- `PetStore.updatePetWithFirestore`, `removePetWithFirestore`, `removeCareCircleMemberWithFirestore`

**Screens** — Removed `await` from all store mutation calls in event handlers so dialogs close and snackbars show instantly:
- `medication_screen.dart` `_save()`
- `trends_screen.dart` delete confirmation
- `pet_detail_screen.dart` edit pet dialog and `_addNote()`
- `messages_screen.dart` notification tap
- `owner_dashboard.dart` delete pet dialog
- `settings_screen.dart` remove care circle member and threshold save

**Files changed:**
- `lib/stores/measurement_store.dart`
- `lib/stores/medication_store.dart`
- `lib/stores/note_store.dart`
- `lib/stores/notification_store.dart`
- `lib/stores/pet_store.dart`
- `lib/screens/medication/medication_screen.dart`
- `lib/screens/trends/trends_screen.dart`
- `lib/screens/pet_detail/pet_detail_screen.dart`
- `lib/screens/messages/messages_screen.dart`
- `lib/screens/dashboard/owner_dashboard.dart`
- `lib/screens/settings/settings_screen.dart`

---

## BUG-027: Edit medication Save and Close buttons do nothing

**Found during:** Manual testing — editing an existing medication and tapping Save or the X close button
**Severity:** Critical (blocks medication editing flow entirely)
**Status:** Fixed

**Symptom:** After tapping a medication to edit it, the bottom sheet opens with pre-filled data, but tapping Save or the X close button has no visible effect — the sheet stays open and no snackbar appears.

**Root cause:** The BUG-026 optimistic-update refactor removed all `await` calls from `_save()` but left the method as `Future<void> _save() async`. With no remaining `await` expressions, the entire method body ran synchronously, yet exceptions were still silently caught by the async mechanism and turned into unhandled `Future` errors that were discarded (since `onPressed: _save` treats the return as `void`). Specifically, after `Navigator.of(context).pop()` started dismissing the sheet, the subsequent `ScaffoldMessenger.of(context).showSnackBar(...)` called `of(context)` on the now-deactivating widget context, throwing a `FlutterError`. This exception was swallowed by the async wrapper, preventing the pop from visually completing. Additionally, unlike the settings and pet-detail screens (which pre-captured `Navigator` and `ScaffoldMessenger` references before mutations), the medication screen called `Navigator.of(context)` and `ScaffoldMessenger.of(context)` directly after store mutations that trigger `notifyListeners()`.

**Fix:** Changed `_save()` from `Future<void> _save() async` to `void _save()` so exceptions propagate normally instead of being silently swallowed. Pre-captured `Navigator.of(context)` and `ScaffoldMessenger.of(context)` at the top of the method (before any store mutations or navigation), matching the pattern already used in `settings_screen.dart` and `pet_detail_screen.dart`. The captured references are then used for `navigator.pop()` and `messenger.showSnackBar(...)`.

**Files changed:**
- `lib/screens/medication/medication_screen.dart`

---

<!-- Template for new entries:

## BUG-XXX: [Short title]

**Found during:** [Which test or flow]
**Severity:** Critical / High / Medium / Low
**Status:** Fixed / Open / Known limitation

**Symptom:** [What the user sees]

**Root cause:** [Why it happens]

**Fix:** [What was changed]

**Files changed:**
- `path/to/file.dart`

---
-->
