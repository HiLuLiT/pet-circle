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

**Update (Phase 2 audit):** the privilege-escalation aspect of this exception is now closed — see BUG-040. `canAcceptPendingInvite` previously let the invitee assign themselves `role: 'admin'`, which mapped to `CareCircleRole.owner`; self-join may now only grant `member`. The remaining limitation is narrower than originally written: the invitee still writes their own care-circle entry, so the `canAcceptPendingInvite` clause cannot be deleted outright. Moving acceptance into a callable Cloud Function that uses the Admin SDK would remove the clause entirely, and would also be the natural place to maintain the invitee's `petIds` — which nothing does today. Status stays **Known limitation** pending that change.

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

## BUG-028: Settings dialogs rendered field labels twice ("Display Name" shown twice)

**Found during:** Automated test suite run after migrating settings dialogs' text inputs to the shared `appInputDecoration()` helper (design-system reconciliation pass)
**Severity:** Medium (visual duplication, no functional break, but confusing)
**Status:** Fixed

**Symptom:** In `showEditProfileDialog`, the "Display Name" and "Profile Photo URL" fields rendered their label text twice — once as the Material floating `labelText` and once as the `hintText` placeholder inside the field, since both were set to the same string.

**Root cause:** `appInputDecoration(context, hintText: ...)` required a non-null `hintText`. When adopting it for fields that use a floating `labelText` instead of a placeholder (via `.copyWith(labelText: ...)`), the same string was passed as both `hintText` and `labelText`, so Flutter's `InputDecoration` displayed both simultaneously.

**Fix:** Made `hintText` an optional named parameter on `appInputDecoration()` (default `null`) so `labelText`-only call sites can omit it. Updated the two affected fields in `showEditProfileDialog` to call `appInputDecoration(context).copyWith(labelText: ...)`.

**Files changed:**
- `lib/widgets/app_input_decoration.dart`
- `lib/screens/settings/settings_dialogs.dart`

---

## BUG-029: New reminder sometimes deleted/reverted instead of the intended one

**Found during:** Manual testing of the new Reminders feature (home screen redesign) — user reported "when I add a reminder and then click on it it sometimes gets removed/deleted"
**Severity:** High (data integrity — a delete can silently no-op on the real record while removing the wrong local entry; an edit can silently fail and revert)
**Status:** Fixed

**Symptom:** After adding a reminder and immediately tapping it to edit or delete, the action sometimes appeared to succeed locally but didn't actually affect the intended Firestore document — deletes could leave the real document intact (reappearing on next refresh) while removing the item from the local list, and edits could silently revert.

**Root cause:** `AddReminderSheet._save()` builds a new `Reminder` with a client-generated placeholder ID (`'rem-<timestamp>'`) and passes it to `ReminderStore.addReminder()`. That method calls `PetService.addReminder()`, which writes to Firestore via `.add()` — Firestore ignores the client-supplied ID and assigns its own document ID. The store's local list entry was never updated with the real ID, so it permanently kept the placeholder ID. Any subsequent update/delete on that entry addressed Firestore by the wrong (placeholder) ID:
- `.update()` on a nonexistent doc ID throws `NOT_FOUND`, which was silently swallowed by the store's rollback (and never surfaced to the user, since the sheet's save call is fire-and-forget) — the edit appeared to succeed then reverted.
- `.delete()` on a nonexistent doc ID is a Firestore no-op that succeeds without error — the item vanished from the local list, but the real document was never deleted and would reappear on the next fetch.

**Fix:** `PetService.addReminder()` now returns the server-assigned document ID instead of `void`. `ReminderStore.addReminder()` patches the local list entry with the real ID (via `copyWith(id: realId)`) once the Firestore write resolves, so a subsequent update/delete addresses the document that actually exists.

**Files changed:**
- `lib/services/pet_service.dart`
- `lib/stores/reminder_store.dart`

**Known limitation:** There remains a narrow race window if a user opens the edit/delete sheet for a just-added reminder *before* the Firestore write resolves — the sheet still holds the stale placeholder-ID object at that instant. This window is now milliseconds (one Firestore round-trip) rather than indefinite, and self-corrects on the next rebuild once the ID patch lands. No automated regression test covers the success path, since the project has no Firestore mocking library to simulate a resolved write in unit tests.

---

## BUG-030: Settings toggles have a ~1 second delay before visually flipping

**Found during:** Manual testing of the Settings screen (In-app notification, Emergency alerts, Measurement Reminders toggles)
**Severity:** Medium (feels broken/unresponsive, no data loss)
**Status:** Fixed

**Symptom:** Tapping a toggle switch in Settings (push notifications, emergency alerts, measurement reminders, VisionRR, weekly summary) visually lagged by roughly a second before flipping.

**Root cause:** `SettingsContent`'s `ListenableBuilder` only listened to `petStore`, not `settingsStore`. Each toggle's `onChanged` handler called `await settingsStore.toggleX()` (which mutates state and calls `notifyListeners()` synchronously, then awaits a Firestore persist + any side-effect callback) and only rebuilt the row via a manual `setState(() {})` placed *after* that full await chain. So the switch's visual state didn't change until the entire persist round-trip completed, even though the underlying store had already flipped and notified instantly.

**Fix:** Merged `settingsStore` into the screen's `ListenableBuilder` listenable, so the row rebuilds the instant `notifyListeners()` fires. Simplified the five affected `onChanged` handlers to call the store's toggle method directly, removing the now-redundant manual `setState`/`mounted` dance.

**Files changed:**
- `lib/screens/settings/settings_content.dart`
- `test/screens/settings/settings_screen_test.dart` (new regression test)

---

## BUG-031: Export button shifts down when the Trends period dropdown opens

**Found during:** Manual testing of the Trends screen's period filter
**Severity:** Low (visual only)
**Status:** Fixed

**Symptom:** Opening the "Custom range" (period) dropdown on the Trends screen visually pushed the adjacent Export button downward instead of leaving it in place.

**Root cause:** `AppDropdown` renders its open option list inline (growing its own height), not as an overlay. The `Row` containing the dropdown and the Export button used `crossAxisAlignment: CrossAxisAlignment.center`, so when the dropdown's column grew taller, the fixed-height Export button re-centered within the now-taller row and appeared to move down.

**Fix:** Changed the Row's `crossAxisAlignment` to `CrossAxisAlignment.start` so both children stay top-aligned regardless of how tall the dropdown's open list grows.

**Files changed:**
- `lib/screens/trends/trends_screen.dart`

---

## BUG-032: New pet doesn't appear in the pet switcher after onboarding

**Found during:** Manual testing — user added a new pet via onboarding and it did not appear in the header's pet-switcher dropdown
**Severity:** High (core flow: a newly created pet is invisible everywhere `petStore.ownerPets` drives the UI — dashboard, pet switcher, tab content — until the next full refetch, e.g. an app restart)
**Status:** Fixed

**Symptom:** After completing onboarding to add a new pet, the pet was created successfully (visible in Firestore / on next app restart) but did not show up in the app immediately — not in the header's pet switcher, not on the home dashboard.

**Root cause:** `PetStore.createPetWithFirestore()` has two branches. The mock-mode (`else`, `kEnableFirebase == false`) branch calls `addPet(pet)`, which appends to `_ownerPets` and calls `notifyListeners()`. The Firebase branch (`kEnableFirebase == true`, which is always true in production per this repo's convention) wrote the pet to Firestore and returned the created `Pet` object, but never added it to the in-memory `_ownerPets` list and never called `notifyListeners()`. The onboarding flow's `createdPet` return value was discarded (flagged by a pre-existing `unused_local_variable` analyzer lint at `onboarding_flow.dart:69` that had been dismissed as a pre-existing/unrelated warning during prior work). The UI only reflects `petStore.ownerPets`, which stayed stale until the next `PetStore.fetchForUser()` (e.g. a cold app restart).

**Fix:** The Firebase branch of `createPetWithFirestore()` now appends the created pet (with its real Firestore-assigned ID) to `_ownerPets` and calls `notifyListeners()` immediately after the write succeeds, matching the pattern already used by `removePetWithFirestore()`. Deliberately does **not** reuse `addPet()` wholesale, since that helper also mirrors into `_clinicPets` — a list populated from a separate vet/clinic-membership query in Firebase mode, where blindly mirroring a newly created pet into it would misrepresent that query's result.

**Files changed:**
- `lib/stores/pet_store.dart`

**Known limitation:** No automated regression test covers this success path — like the Reminders fix in BUG-029, exercising the Firebase branch in a unit test requires a Firestore mock this project doesn't have; a real call to `PetService.createPet()` throws (no Firebase app initialized) before ever reaching the new code. Verified by code inspection and by comparing against the already-correct `removePetWithFirestore()` sibling.

---

## BUG-033: "Last reading" on the Measure screen never updates

**Found during:** Manual testing / feature request — "add last reading to measure view"
**Severity:** High (the metric card silently freezes on its first-build value forever, for the lifetime of the screen)
**Status:** Fixed

**Symptom:** The "Last reading" card on the Measure screen showed "—" (or a stale value) and never updated, even after saving a new measurement or switching the active pet.

**Root cause:** Two independent bugs, both required to fully fix the symptom:
1. `MeasurementScreen`'s outer `ListenableBuilder` only merged `petStore` and `userStore`, not `measurementStore`. Saving a measurement (`_saveMeasurement` → `measurementStore.addMeasurement`) only calls `measurementStore.notifyListeners()`, which nothing in this screen was listening to — same pattern as BUG-030.
2. Even after fixing (1), the card still didn't update. The actual metric-row widget (`_MetricsRow`) was instantiated at its call site as `const _MetricsRow()` with a const, zero-argument constructor, but its `build()` reads `petStore`/`measurementStore` globals directly rather than receiving data via constructor parameters. Dart canonicalizes `const _MetricsRow()` to the exact same object instance on every call. Flutter's element reconciliation (`Element.updateChild`) checks `child.widget == newWidget` (identity) as a fast path and, when true, skips calling `build()` again entirely — so this widget's `build()` only ever ran once, at first mount, regardless of how many times its ancestor `ListenableBuilder` rebuilt.

**Fix:**
- Merged `measurementStore` into `MeasurementScreen`'s `ListenableBuilder` listenable.
- Removed `const` from both the `_MetricsRow()` call site and its constructor declaration (the constructor is intentionally *not* const now — a class whose `build()` reads ambient global state should not offer a const constructor, since that invites exactly this regression if `const` is ever re-added at a call site).

**Files changed:**
- `lib/screens/measurement/measurement_screen.dart`
- `test/screens/measurement/measurement_screen_test.dart` (new regression test; uses `measurementStore.seed()` rather than `addMeasurement()` to avoid the unrelated Firestore-write-fails-in-tests flakiness described in BUG-029)

**Broader note:** This `const` + global-read-in-`build()` pattern is a general Flutter footgun, not specific to this widget. A codebase sweep was run to check for other occurrences of the same shape (private const-constructed StatelessWidget with no constructor params, reading a global store directly in `build()`, with at least one `const` call site). No other active instances found; one latent risk (`_ActiveMedicationsList` in `lib/screens/medication/medication_screen.dart`, const constructor + global reads, not currently called with `const`) was preventively hardened the same way.

---

## BUG-034: Measure screen content vertically centered instead of starting from the top

**Found during:** Manual testing / UX feedback on the Measure screen
**Severity:** Low (visual only)
**Status:** Fixed

**Symptom:** The Measure screen's content (heading, Target/Last-reading cards, timer card) appeared vertically centered in the middle of the screen, with large empty gaps above and below, instead of starting from the top like every other screen.

**Root cause:** The content was wrapped in `Center(child: ConstrainedBox(...))`. `Center` centers its child in BOTH axes; since the content column is shorter than the viewport on most phones, this visibly centered the whole stack vertically. The `ConstrainedBox`'s `maxWidth` (via `responsiveMaxWidth`) was only needed to cap width on wide/tablet screens, not to center vertically.

**Fix:** Changed the wrapper from `Center` to `Align(alignment: Alignment.topCenter, ...)`, which still horizontally centers the width-capped content on wide screens but no longer centers vertically.

**Files changed:**
- `lib/screens/measurement/measurement_screen.dart`

---

## BUG-035: "Add New Medication" / "Add reminder" bottom sheets stop partway down the screen instead of reaching the top

**Found during:** Manual testing / UX feedback — screenshot showed the medication sheet stopping mid-screen with the underlying screen's header still visible above it
**Severity:** Low (visual only)
**Status:** Fixed

**Symptom:** Opening the "Add New Medication" (or "Add reminder") bottom sheet only grew tall enough to fit its form content, leaving the sheet's top edge partway down the screen instead of reaching close to the top like a full-height drawer.

**Root cause:** `showModalBottomSheet` was called with `isScrollControlled: true`, which allows the sheet to exceed the default ~50% height cap, but the sheet's own `Container` had no minimum-height constraint — so it still only sized itself to its (shorter-than-full-screen) form content.

**Fix:** Added `constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.9)` to the sheet's outer `Container` in both `AddMedicationSheet` and `AddReminderSheet` (which share the identical shell). This pins the sheet's top edge near the screen top regardless of content length, while still allowing it to grow further (and scroll) if content ever exceeds that.

**Files changed:**
- `lib/screens/medication/add_medication_sheet.dart`
- `lib/screens/dashboard/add_reminder_sheet.dart`

---

## BUG-036: Reminders fail to save — undeployed Firestore rule + silent error

**Found during:** Manual testing of Add Reminder on the Home screen
**Severity:** Critical
**Status:** Fixed

**Symptom:** User fills in a reminder, taps "Add reminder", sees "Reminder added" snackbar and the sheet closes — but the reminder never persists. On reload it is gone.

**Root cause:** Two independent issues:
1. The Firestore security rule for `/pets/{petId}/reminders` was added in commit `1d55cc0` on `feat/home-redesign-figma-402-1978` but never deployed to production (not on `main`). Live rules fall through to the catch-all `allow read, write: if false`, causing PERMISSION_DENIED on every reminder write.
2. `AddReminderSheet._save()` called `reminderStore.addReminder()` without `await`, popped the sheet, and showed a success snackbar synchronously. The store's optimistic insert was silently rolled back on Firestore failure, and the rethrown error became an uncaught zone error. `_confirmDelete()` awaited but had no try/catch — errors crashed unhandled.

**Fix:**
- Client: converted `_save()` to async, added `_isSaving` guard, wrapped store calls in try/catch. On failure: sheet stays open, error snackbar shown, user can retry. Added `isLoading` prop to `PrimaryButton` for a spinner during save. Same try/catch pattern applied to `_confirmDelete()`. Two new l10n keys (`failedToSaveReminder`, `failedToDeleteReminder`).
- Server: deploy `firestore.rules` from this branch (which already contains the correct reminders block) via `firebase deploy --only firestore:rules`.

**Files changed:**
- `lib/widgets/primary_button.dart`
- `lib/screens/dashboard/add_reminder_sheet.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_he.arb`
- `test/screens/dashboard/add_reminder_sheet_test.dart`
- `docs/bug-log.md`

---

## BUG-037: "Medication ending today" notification shows medication name as pet name + mark-as-read reverts

**Found during:** Manual testing of in-app notifications drawer
**Severity:** High
**Status:** Fixed

**Symptom:**
1. Notification body reads "[med name]'s medication course ends today" (e.g. "test med's medication course ends today") instead of the pet's name.
2. Tapping a notification to mark it as read briefly shows it as read, then ~1 second later it snaps back to unread.

**Root cause:**
1. `notification_store.dart:reconcileMedicationEndNotifications` set `petName: med.name` and `args: [med.name]` — both used the medication name in the pet-name slot. The caller in `main.dart` also passed `l10n.medicationEndingBody(med.name)` with one placeholder, matching the single-arg `{name}` template.
2. `NotificationService.addNotification` persisted with Firestore `.add()`, which assigns an auto-generated doc id and ignores the client's `notification.id`. `markRead` then called `_notificationsRef(uid).doc(notificationId).update(...)` using the **client id** — pointing at a nonexistent document. Firestore threw `not-found`, the store's catch block rolled back the optimistic read → unread flip, and `rethrew`. The ~1 s delay was the network round-trip for the failed update. Worse, `reconcileMedicationEndNotifications` only inserted notifications locally (never persisted to Firestore), so `markRead` could never find a matching document.

**Fix:**
- `lib/l10n/app_en.arb` + `app_he.arb`: changed `medicationEndingBody` from one placeholder (`{name}`) to two (`{petName}` and `{medName}`). EN: `"{petName}'s "{medName}" course ends today"`, HE: `"מהלך הטיפול "{medName}" של {petName} מסתיים היום"`.
- `lib/utils/notification_localizer.dart`: updated `medicationEndingBody` case to pass two args `(args[0], args[1])` guarded by `args.length >= 2`.
- `lib/stores/notification_store.dart`: added `String? petName` param to `reconcileMedicationEndNotifications`; made it `async`; corrected `petName`/`petId`/`args` fields; persists each new notification to Firestore immediately after local insert (wrapped in try/catch).
- `lib/services/notification_service.dart`: switched `addNotification` from `.add(...)` to `.doc(notification.id).set(...)` so the Firestore doc id matches the client id — `markRead`'s `.update()` now finds the correct document.
- `lib/main.dart`: resolves `petStore.getPetById(med.petId)?.name` and passes it as `petName` and the first arg of `medicationEndingBody`.
- `lib/screens/medication/add_medication_sheet.dart`: updated two `scheduleMedicationReminder` calls to use the two-arg `medicationEndingBody` with the active pet's name.

**Files changed:**
- `lib/l10n/app_en.arb`
- `lib/l10n/app_he.arb`
- `lib/utils/notification_localizer.dart`
- `lib/stores/notification_store.dart`
- `lib/services/notification_service.dart`
- `lib/main.dart`
- `lib/screens/medication/add_medication_sheet.dart`
- `test/utils/notification_localizer_test.dart`

---

## BUG-038: Push notifications flash "read" then revert — server/client notification ID mismatch

**Found during:** Phase 2 audit of the shipped FCM push path (code review, not manual testing — the app cannot be built in the audit environment).
**Severity:** High
**Status:** Fixed

**Symptom:** A notification delivered by push cannot be marked read. Tapping it in the notifications drawer flips it to read, then it reverts to unread a moment later, with no error shown. The unread badge count comes back too.

**Root cause:** Exactly the same root-cause class as BUG-037, reintroduced on the server side. `writeInAppNotification` in `functions/src/fcm-utils.ts` persisted the notification with `.add()`, letting Firestore assign an auto-ID, while the client's foreground handler stored the same notification in `notificationStore` under `message.messageId`. `NotificationStore.markRead` optimistically flips `isRead`, then calls `NotificationService.markRead`, which does `.doc(notificationId).update(...)` — against an ID that never existed. The write threw `not-found`, the `catch` rolled the optimistic flip back, and because the call site in `messages_screen.dart` is unawaited and uncaught, the `rethrow` became an unhandled zone error rather than a visible message.

**Fix:** Three coordinated changes plus one class-level hardening.
- `functions/src/fcm-utils.ts`: `writeInAppNotification` now generates the document reference locally with `.doc()`, writes with `.set()`, and returns the document ID (`Promise<string | null>`). The catch returns `null` explicitly, which `noImplicitReturns` requires under the new return type.
- `functions/src/invitation-notification.ts`: the in-app write and the push are no longer run under `Promise.all`. The write happens first so its document ID can travel in the FCM `data` payload as `notificationId`. This ordering is a correctness requirement, not a style choice: `.doc()` generates the ID without a round trip, so parallel execution would still yield a stable ID, but a push tapped before the Firestore write landed would reproduce the same `not-found` rollback intermittently. A comment records this so it is not "optimized" back.
- `lib/services/push_notification_service.dart`: `_handleForegroundMessage` prefers `data['notificationId']` for `AppNotification.id`, validating its shape via `_validNotificationId` before it is used to build a Firestore document path, and keeping `message.messageId` as a fallback for payloads from an older function version.
- `lib/stores/notification_store.dart`: `markRead` now treats `FirebaseException` with code `not-found` as terminal success — it logs and **keeps** the optimistic flip instead of reverting and rethrowing. This is the durable fix for the whole "flashes read then reverts" family, and it is the correct behaviour for rows that only ever existed in memory. Read state for such rows simply does not survive a restart, which is strictly better than reverting a second later.

**Files changed:**
- `functions/src/fcm-utils.ts`
- `functions/src/invitation-notification.ts`
- `lib/services/push_notification_service.dart`
- `lib/stores/notification_store.dart`
- `test/stores/notification_store_test.dart`

---

## BUG-039: Server-generated notifications always render in English

**Found during:** Phase 2 audit of the shipped FCM push path.
**Severity:** Medium
**Status:** Fixed

**Symptom:** A Hebrew-locale user who receives a care-circle notification sees English text in the in-app notifications drawer, while every locally-generated notification is correctly translated.

**Root cause:** `AppNotification` supports render-time localization through `titleKey` / `bodyKey` / `args`, resolved by `lib/utils/notification_localizer.dart`. `writeInAppNotification` never wrote those three fields, so server-created notifications only carried the frozen English `title` / `body` and the localizer had nothing to resolve. The ARB keys `inviteAcceptedTitle` and `inviteAcceptedBody` already existed in both `app_en.arb` and `app_he.arb` — added in anticipation of this work, and documented in the `onInvitationStatusChanged` docstring — but had zero call sites.

**Fix:**
- `functions/src/fcm-utils.ts`: `InAppNotification` gained `titleKey` / `bodyKey` / `args`, persisted alongside the frozen text. Empty `args` are omitted, matching `AppNotification.toFirestore`'s own `if (args.isNotEmpty)` shape.
- `functions/src/invitation-notification.ts`: sends `titleKey: 'inviteAcceptedTitle'`, `bodyKey: 'inviteAcceptedBody'`, and `args: [displayEmail, petName]` in the Firestore document, and the same values JSON-stringified in the FCM `data` map (FCM data values must be strings). The truncated `displayEmail` is passed rather than the raw address so the localized row and the OS banner agree for long addresses. A comment pins the frozen English fallback strings to the EN ARB values and their placeholder order, since nothing automated ties them together.
- `lib/utils/notification_localizer.dart`: `_resolveTitle` now takes `args`, because for this pair the **title** is the templated string (`inviteAcceptedTitle(email, petName)`) and the body is static. Guarded with `args.length >= 2`, matching the existing `medicationEndingBody` case, so a malformed payload falls back to the frozen title rather than throwing.
- `lib/services/push_notification_service.dart`: reads `titleKey` / `bodyKey` from `message.data` and decodes `args` from JSON through a guarded helper.

No ARB or generated-localization changes were needed.

**Known limitation (accepted):** when the app is in the background, the OS builds the push banner directly from the FCM payload with no Dart involved, so that banner stays English regardless of the reader's locale. Fixing it requires the Cloud Function to look up the recipient's locale from their user document and localize server-side. The **foreground** banner is localized (see below), so the inconsistency is limited to background delivery.

**Files changed:**
- `functions/src/fcm-utils.ts`
- `functions/src/invitation-notification.ts`
- `lib/utils/notification_localizer.dart`
- `lib/services/push_notification_service.dart`
- `test/utils/notification_localizer_test.dart`

---

## BUG-040: Invitee can grant themselves the owner role when accepting an invitation

**Found during:** Phase 2 security audit of `firestore.rules`.
**Severity:** High
**Status:** Fixed

**Symptom:** No symptom in normal use — this is a privilege-escalation hole reachable only by a modified client.

**Root cause:** `canAcceptPendingInvite()` in `firestore.rules` accepted `'member'`, `'viewer'`, or `'admin'` as the role an accepting invitee writes for themselves, for legacy compatibility. `CareCirclePermissions.fromString` maps `'admin'` to `CareCircleRole.owner`, which grants `canEditPet`, `canManageCircle`, and `canDeletePet`. A client that wrote `role: 'admin'` while accepting a legitimate invitation would therefore be treated as a pet owner. Actual Firestore writes to the pet document remain gated on `ownerId`, so the blast radius was the client-side permission affordances rather than direct data loss.

**Fix:** `firestore.rules` now requires the self-assigned role to be exactly `'member'` on the accept path. This is behaviour-preserving for the real client: `InvitationService._pendingInviteData` hardcodes `role: 'member'`, and the accept transaction writes `CareCircleMember(role: CareCircleRole.member)`.

**Files changed:**
- `firestore.rules`

---

## BUG-041: HTML injection into outbound invitation emails

**Found during:** Phase 2 security audit of the Cloud Functions email path.
**Severity:** High
**Status:** Fixed

**Symptom:** No symptom in normal use. A user who sets their display name to markup causes that markup to be rendered inside the invitation email delivered to a third party.

**Root cause:** `functions/src/email-templates.ts` interpolated `inviterName` and `petName` straight into the email HTML. Both originate from client-controlled Firestore fields — `invitedByName` is the sender's own display name, taken from `userStore.currentUserDisplayName`. Because the recipient's address is also attacker-chosen, this was a content/link injection vector in mail that legitimately originates from the project's sending domain: a phishing primitive rather than a browser XSS. The invitation link was interpolated unescaped into an `href` as well, and the invitation token forming part of that link is a client-chosen Firestore document ID. Separately, the email subject interpolated the same unescaped values, so a display name containing CR/LF could inject additional mail headers.

Escaping alone turned out to be insufficient. The first pass at this fix escaped the HTML part only, on the reasoning that a plain-text body has nothing to escape. A security review caught that this misses **line-structure forging**: the `text/plain` alternative interpolated the same raw values, and mail clients auto-linkify bare URLs in plain text. A display name containing newlines could therefore forge an extra `Join the circle: https://evil.example/...` line above the real one — reintroducing exactly the attacker-planted link that HTML escaping removes, in a message signed by the project's sending domain, rendered by every text-only client and every preview pane preferring `text/plain`.

**Fix:**
- `functions/src/email-templates.ts`: added `sanitiseInline`, which collapses CR/LF/tabs and whitespace runs to single spaces and caps length at 100 characters. It is applied to `inviterName` and `petName` in **both** the HTML and the plain-text template — escaping is layered on top of it for the HTML part, never instead of it. Also added `escapeHtml`, applied to `inviterName`, `petName`, and `inviteLink` at every HTML interpolation site.
- `functions/src/email.ts`: the subject line now interpolates `sanitiseInline`-processed names rather than stripping CR/LF from the assembled string, which additionally caps their length.
- `functions/src/invitation-email.ts`: the token is now `encodeURIComponent`-encoded when building the invite link.
- `firestore.rules`: `canCreateInvitation()` now requires `invitedByName` and `petName` to be strings of at most 200 characters, bounding the payload the email trigger can be handed at the server. The templates truncate independently; this is the outer ceiling.

**Related, not fixed here:** invitation creation has no server-side rate limit — `InvitationService.maxInvitesPerDay` is enforced only on the client, so direct Firestore writes bypass it and every create fires an outbound email to an arbitrary address. That is what makes this injection surface weaponisable at scale. Tracked as FB-004, raised to High.

**Files changed:**
- `functions/src/email-templates.ts`
- `functions/src/email.ts`
- `functions/src/invitation-email.ts`
- `firestore.rules`

---

## BUG-042: Firestore composite indexes were never deployed

**Found during:** Phase 2 audit of Firebase configuration.
**Severity:** Low
**Status:** Fixed

**Symptom:** Latent. Any query needing one of the declared composite indexes would fail at runtime with a `failed-precondition` "requires an index" error, despite the index being defined in the repo.

**Root cause:** `firestore.indexes.json` declares two composite indexes on the `invitations` collection, but the `firestore` block in `firebase.json` referenced only `rules`. The Firebase CLI therefore never shipped the index definitions. The current `InvitationService` queries happen to be served by automatic single-field indexes, which is why this had not surfaced.

**Fix:** Added `"indexes": "firestore.indexes.json"` to the `firestore` block in `firebase.json`.

**Files changed:**
- `firebase.json`

---

## BUG-043: Landing screen overflowed by 16px on short viewports

- **Found during:** running the app in the browser (`flutter run` web, 656x442 viewport) and inspecting the console.
- **Severity:** Medium (visual only — content clipped, app still usable)
- **Status:** Fixed
- **Symptom:** On startup the console logged `A RenderFlex overflowed by 16 pixels on the bottom.` from `landing_screen.dart:28`, followed by `[AppErrorHandler] FlutterError` and an `Uncaught (in promise)` assertion. In debug builds the bottom of the CTA area showed the yellow/black overflow stripes. Only reproduced on short/landscape viewports; a 375x812 phone viewport was fine.
- **Root cause:** `LandingScreen`'s body was a plain `Column` inside `SafeArea` mixing fixed-height and flexible children: `Spacer(flex: 5)`, a fixed 280x280 hero circle, `Spacer(flex: 4)`, the text + CTA block, and a fixed 32px bottom gap. The `Spacer`s can collapse to zero under pressure, but the fixed children cannot shrink, so once `280 + textBlock + 32` exceeded the available height the flex overflowed. There was no scrollable fallback. `test/widget_test.dart` masked it with `suppressOverflowErrors()`, so no test ever failed.
- **Fix:** Wrapped the body in the scroll-when-tight pattern — `LayoutBuilder` -> `SingleChildScrollView` -> `ConstrainedBox(minHeight: constraints.maxHeight)` -> `IntrinsicHeight` -> `Column`. `IntrinsicHeight` bounds the column height so `Spacer` stays legal inside the scroll view; `minHeight` keeps the spacers expanding when there is room, and the content scrolls when there is not. Removed `suppressOverflowErrors()` from the test and added a 393x442 regression test asserting no exception. (Landed alongside the Figma 402:1682 redesign, which also replaced the fixed 280x280 hero with the exported 194.69x173.15 illustration.)
- **Files changed:**
  - `lib/screens/landing_screen.dart`
  - `test/widget_test.dart`

## BUG-044: All Bold/SemiBold/Medium text rendered at Regular weight (variable-font `wght` axis never set)

- **Found during:** comparing the landing screen against Figma node `594-2405` — the design title read distinctly bolder than the app's.
- **Severity:** High (app-wide typography mismatch against the design system; every emphasised run of text was affected)
- **Status:** Fixed
- **Symptom:** Text rendered in the correct typeface at the correct size and line height, but visibly lighter than Figma everywhere weight was supposed to carry emphasis — titles, headings, button labels, badges, bold labels. Because size and family were right, it read as a vague "fonts don't match the design" rather than an obvious bug, and it had been present since the fonts were bundled.
- **Root cause:** `assets/fonts/InstrumentSans-{Regular,Medium,SemiBold,Bold}.ttf` are four copies of the *same variable font* — byte-identical, md5 `73e3eb26e68e0c36091ac63b5f97efb7`, each carrying an `fvar` table with axes `wght` 400–700 (**default instance 400**) and `wdth` 75–100 (default 100). `pubspec.yaml` declares them as `weight: 500 / 600 / 700` static faces, so Flutter used `fontWeight` to select a font *file* and dutifully loaded the one named `-Bold.ttf` — but Flutter never sets a variation axis on its own, so the font rendered its default `wght 400` instance. Every `FontWeight.w500/w600/w700` in `AppTypography` was therefore decorative: it changed which identical file was picked and nothing else. The pre-existing comment in `pubspec.yaml` blamed a google_fonts network-fallback path, which is a different mechanism and was not what was happening — the bundled font loaded fine, just at the wrong weight.
- **Fix:** Added explicit `fontVariations` to all 65 styles in `lib/theme/tokens/typography.dart` via four shared const axis lists (`axesRegular`/`axesMedium`/`axesSemibold`/`axesBold`), each pairing the matching `wght` with `wdth: 100` — the same `wdth` Figma specifies via `fontVariationSettings: "'wdth' 100"`. `fontWeight` is kept alongside so file selection and platform-font fallback still resolve correctly. Because `AppSemanticTextStyles` derives every style from `AppTypography` with `copyWith`, this corrected the whole app from one file. Second half of the fix: once a style carries `fontVariations`, a later `copyWith(fontWeight: ...)` is silently ignored (the axis wins), so the 20 call sites doing exactly that were migrated to a new `TextStyle.withWeight()` extension on `AppSemanticTextStyles`, which moves the weight and the axis together.
- **Files changed:**
  - `lib/theme/tokens/typography.dart` (axis tokens + all 65 styles)
  - `lib/theme/semantic/text_theme.dart` (`withWeight` extension)
  - `lib/widgets/status_badge.dart` (hand-built `TextStyle` on the bundled family)
  - `lib/screens/main_shell.dart`, `lib/screens/circle/circle_screen.dart`, `lib/screens/dashboard/vet_dashboard.dart`, `lib/screens/medication/medication_screen.dart`, `lib/screens/pet_detail/pet_detail_sections.dart`, `lib/screens/pet_detail/pet_detail_widgets.dart`, `lib/screens/settings/settings_content.dart`, `lib/screens/settings/settings_dialogs.dart`
  - `lib/widgets/app_header.dart`, `lib/widgets/bottom_nav_bar.dart`, `lib/widgets/segmented_control.dart`, `lib/widgets/settings_row.dart`
- **Known remaining gap:** the raw `const TextStyle`s inside `buildAppTheme()` / `buildDarkTheme()` (`lib/theme/app_theme.dart`) declare no `fontFamily`, so they are Material fallback styles rather than Instrument Sans and were left untouched.

## BUG-045: Animated hero's heart layer rendered as a broken-image icon (corrupt source PNG)

- **Found during:** first browser run of the new animated welcome hero (`PoundingHeartHero`) after importing the Claude Design project "Heart animation for dog".
- **Severity:** High (the hero's focal element was missing on the app's first screen)
- **Status:** Fixed
- **Symptom:** The dog layer painted correctly, but where the heart should have been the app drew Flutter's grey broken-image fallback icon (`AppImage`'s `fallbackIcon`). No Dart exception and no console error — `AppImage` swallows the decode failure by design, so the only signal was the visual. The same asset renders fine in Chrome and in the design preview, which is what made it look like a Flutter bug rather than a bad file.
- **Root cause:** `assets/figma/welcome_heart.png` was corrupt **at the source**. Its `IDAT` chunk failed its CRC32, and the zlib stream's trailing adler32 was also wrong (`zlib: incorrect data check`). Re-fetching the asset from the design project via `DesignSync get_file` returned **byte-identical** content, proving the damage is in the design project's stored asset, not in the download. Browsers deliberately ignore PNG chunk CRCs and truncated checksums and render what they can, so Chrome (and therefore the design preview) showed the heart normally — Skia's decoder is strict and rejects the image outright. `welcome_dog.png`, fetched in the same batch, was clean, which ruled out the transport. Worth noting: this exact zlib error surfaced earlier in the session during an asset sanity check and was dismissed as noise, which cost a full build-and-verify cycle before it was taken seriously.
- **Fix:** Repaired the file locally rather than waiting on a re-export. The pixel data itself was intact — only the checksums were wrong — so inflating the `IDAT` payload as a **raw deflate stream** (`zlib.decompressobj(-15)` over `idat[2:]`, which skips both the zlib header and the trailing adler32 the standard decompressor validates) recovered **7439 / 7439 bytes, 100%, no pixels lost**. The recovered scanlines were re-encoded as a fresh 43x43 RGBA PNG with valid chunk CRCs (3794 bytes, 62% transparent), which Skia accepts. Both hero layers now verify clean (`badCRC=none`, `zlib=ok`).
- **Files changed:**
  - `assets/figma/welcome_heart.png` (re-encoded)
- **Follow-up (not a bug, but related):** the two layers are 1x only (`welcome_dog.png` 195x174, `welcome_heart.png` 43x43), whereas the hero they replaced (`welcome_hero.png`) was 488x434 (~2.5x). The hero is therefore softer on retina until 2x/3x re-exports are requested from the design project. The corrupt source asset should also be fixed there, since anything stricter than a browser will reject it.

---


### Correction (2026-08-21, later the same session)

The root cause above is **wrong**, and the correction matters more than the original entry.

Both versions of `heart.png` stored in the design project were re-extracted straight from this
session's transcript (so the bytes never passed through a retyping step) and validated: every
chunk CRC32 is correct and the zlib stream's adler32 is valid in **both**. The source asset was
never damaged.

What actually happened: the base64 returned by `DesignSync get_file` was transcribed by the agent
into a file, and that transcription dropped/altered bytes. The resulting local file was corrupt,
the `zlib: incorrect data check` was real — but it was self-inflicted in transit, and the
"re-fetch returned byte-identical content" claim was a mis-comparison that appeared to exonerate
the pipeline and indict the source. The same retyping failure recurred later in the session and
failed loudly with `binascii.Error: Incorrect padding`, which is what exposed the original
misdiagnosis.

Consequences:
- The "repair" re-encoded an asset that was already fine, and the re-encode was then kept in
  preference to the design's newer artwork — shipping a visibly wrong heart (pale `#E5A1A3`,
  49% opaque coverage, instead of the redrawn saturated `#D8696C` at 65%). Fixed separately.
- **Rule:** never transcribe binary out of a tool result. Extract it programmatically from the
  transcript, or have the tool write to disk. Compare **pixels, not byte counts or dimensions**,
  before concluding two assets are the same image.
- `test/assets/asset_integrity_test.dart` still earns its place: it catches a corrupt asset
  however it got that way, which is what a guard should do.


## BUG-046: `welcome_illustration.png` is an SVG with a `.png` extension

- **Found during:** the new `test/assets/asset_integrity_test.dart` guard added after BUG-045 — it failed on its first run.
- **Severity:** Low
- **Status:** Fixed
- **Symptom:** No user-visible symptom today, because nothing references the file. Any future
  `Image.asset('assets/figma/welcome_illustration.png')` would have thrown
  `Exception: Invalid image data`, or shown a silent fallback via `AppImage`.
- **Root cause:** The file was committed in April with PNG naming but SVG content (`<svg
  preserveAspectRatio=...`). `pubspec.yaml` registers `assets/figma/` as a whole *directory*, so
  the 12 KB orphan is bundled into every build regardless of the misnaming.
- **Fix:** `git mv` to `welcome_illustration.svg`. Left in place rather than deleted — it is
  unreferenced dead weight, but removing a design asset is the owner's call.
- **Files changed:** `assets/figma/welcome_illustration.png` -> `assets/figma/welcome_illustration.svg`
- **Follow-up:** The file is unreferenced in `lib/` and `test/`. Delete it, or wire it up.

## BUG-047: Hero heartbeat snapped back to rest once per loop

- **Found during:** manual review of the landing screen after the animation's `tempo` was retuned in the Claude Design source; reported as "the loop is cut in a jumpy place".
- **Severity:** Medium
- **Status:** Fixed
- **Symptom:** Every 4.2s the heart jumped — mid-swell it snapped instantly back to its resting
  size and position, then began a fresh beat. The motion itself was correct; only the seam was wrong.
- **Root cause:** One `AnimationController` drove the beat, the drift and the dog's breath from a
  single 4.2s clock. That was chosen because 4.2s is exactly three 1.4s beats — but `tempo` scales
  the beat and nothing else, so at the authored `tempo = 0.7` a beat lasts `1.4 / 0.7` = 2.0s and
  4.2s is **2.1** beats. The restart therefore landed at beat phase 0.0995 — 89% of the way up the
  first thump — discarding a `+7%` scale and `-4.4px` lift in one frame. The 6.2s drift, which does
  not divide 4.2s either, snapped a further 2.6px. Sampled at 16ms, the worst single-frame jump was
  4.5px against 0.3px for ordinary motion.
  The stale premise was asserted in a code comment that was written when `tempo` was 1 and never
  rechecked when the tuned value landed.
- **Fix:** Gave each rhythm its own repeating controller instead of a shared scene clock. The beat
  controller's period is `1.4 / tempo`, so it always wraps at phase 1.0 where both thumps have
  ended (they finish at 0.4) and the heart is at rest. The slow controller runs 130.2s — the LCM of
  the 6.2s drift and 4.2s breath — so those complete 21 and 31 whole cycles. `tempo` changes
  re-period the beat via `didUpdateWidget`. This required `TickerProviderStateMixin` in place of
  `SingleTickerProviderStateMixin`; keeping the latter threw
  "multiple tickers were created" and failed to build the widget at all.
- **Files changed:** `lib/widgets/pounding_heart_hero.dart`, `test/widget_test.dart`
- **Regression test:** `animated hero loops without a visible jump` sweeps 5s at 16ms steps and
  asserts no single frame moves the heart more than 1.0px. Replaying the old formula at the same
  sampling yields 4.5px, so the test discriminates.
- **Note:** The design preview has the same seam — it restarts a shared 4.2s scene clock. Divergence
  is deliberate: an infinite loop should be continuous, and only the app loops forever.

## BUG-048: A device set to dark mode still opened the app in light

**Found during:** the dark-theme redesign audit (researching why dark mode "felt off").
**Severity:** Medium
**Status:** Fixed

**Symptom:** With macOS/iOS/Android set to dark, Pet Circle always launched in light mode. The
only way to get a dark UI was to find the toggle in Settings. There was also no dark status bar:
on the (rare) dark screens the status-bar glyphs stayed dark-on-dark and were unreadable.

**Root cause:** `main.dart` assigned the dark theme to `MaterialApp.router`'s **`theme:`** slot and
never set `darkTheme:` or `themeMode:`. `theme:` is the *light* slot, so Flutter had no dark theme
to fall back to and `ThemeMode.system` could not work even in principle. Nothing anywhere in
`lib/` read `MediaQuery.platformBrightnessOf` or `platformBrightness`. Separately, no
`SystemUiOverlayStyle` was set anywhere in the app, so the OS chrome never followed the theme.

**Fix:** Wired `theme: buildAppTheme()`, `darkTheme: buildDarkTheme()` and `themeMode: _themeMode`
properly, with `ThemeMode.system` as the new default. Added an `AnnotatedRegion<SystemUiOverlayStyle>`
around the app so status-bar and navigation-bar glyphs follow the resolved brightness, plus a
`WidgetsBindingObserver.didChangePlatformBrightness` hook to keep that correct when the OS flips
while the app is following `system`. The existing 300 ms overlay crossfade was preserved and is now
driven by `ThemeMode` rather than a bool; it skips the fade when source and target resolve to the
same brightness, and fades through the destination canvas token instead of pure black/white.

**Files changed:**
- `lib/main.dart`
- `lib/config/app_config.dart`

**Regression test:** `test/stores/settings_store_test.dart` → `themeMode` group; the store/notifier
lockstep assertion is what guarantees MaterialApp and the persisted value cannot disagree.

---

## BUG-049: Dark mode reset to light on every cold start

**Severity:** Medium
**Status:** Fixed
**Found during:** same audit as BUG-048.

**Symptom:** Turning on dark mode in Settings worked for the session, but the app came back in
light mode after every full restart. The Settings toggle could also go stale — it showed the wrong
position if the theme changed from anywhere other than the toggle itself.

**Root cause:** Two parts. (1) `appDarkMode` was a bare `ValueNotifier<bool>(false)` in
`app_config.dart` with no persistence, and `UserSettings` had no theme field at all, so the choice
lived only in memory. (2) `settings_content.dart` sampled `appDarkMode.value` directly in `build`
and paired the mutation with a local `setState`, so the row only re-rendered for its own taps.

**Fix:** Widened the notifier to `ValueNotifier<ThemeMode>` (needed for BUG-048 regardless) and
added a `themeMode` field to `UserSettings`, serialised as `'system'`/`'light'`/`'dark'` with a
tolerant parse so the ~all documents written before this field existed deserialise to `system`
rather than throwing. `settingsStore.setThemeMode()` persists through the existing `_persist()`
path to `/users/{uid}.settings` and is seeded back in `seedFromAppUser`; a private `_setThemeMode`
keeps the store field and the global notifier in lockstep. The Settings row now sits in a
`ValueListenableBuilder`. Toggling it is treated as an explicit choice, so it resolves to
`light`/`dark` and leaves `system` behind.

No `firestore.rules` change was needed — the rules never enumerate keys inside the `settings` map.

**Files changed:**
- `lib/models/user_settings.dart`
- `lib/config/app_config.dart`
- `lib/stores/settings_store.dart`
- `lib/screens/settings/settings_content.dart`
- `lib/main.dart`

**Regression test:** `test/models/user_settings_test.dart` → `themeMode` group (round-trip for every
value, plus the legacy-document and malformed-input fallbacks);
`test/stores/settings_store_test.dart` → `seedFromAppUser restores a persisted mode on cold start`.

## BUG-050: Deleting a pet could delete the wrong one, reported false success, and orphaned its data

**Found during:** Auditing pet deletion after it was reported as missing functionality (it was not
missing -- it was unreachable, which is BUG-051).
**Severity:** High
**Status:** Fixed

**Symptom:** Five distinct failures around one action:
1. With two pets sharing a name, deleting one removed the *other*.
2. A rejected Firestore delete still showed "Pet deleted"; the pet then reappeared.
3. Deleting the active pet silently moved the header switcher onto a neighbour.
4. Deleting from the pet detail screen left the user on a detail view for a pet that no longer existed.
5. Every measurement, note, medication and reminder the pet owned survived the delete forever.

**Root cause:**
1. `PetStore.removePetWithFirestore(String name)` resolved the target with `getPetByName` and
   `indexWhere((p) => p.name == name)`. Names are not unique, so it took whichever duplicate came
   first. `removePet(String name)` had the same flaw.
2. `confirmDeletePet` called the store without `await`, then showed the success snackbar
   unconditionally. The store rethrows after rolling back on a Firestore error, so the failure
   surfaced only as an unhandled async error.
3. `_activePetIndex` was never adjusted on removal -- the `activePetIndex` getter merely clamps, so
   a removal at or before the selection slid it onto a different pet.
4. Nothing popped the route after a successful delete.
5. `PetService.deletePet` deletes only `/pets/{petId}`. Firestore does not cascade, and the security
   rules resolve subcollection access *through* the parent document, so once it is gone the
   subcollections are unreachable and undeletable by any client while still consuming storage.
   Members other than the deleter also kept a dangling `users/{uid}.petIds` entry, and invitations
   for the pet were left pointing at nothing.

**Fix:** Keyed both removal paths on the pet id (`removePetById`, `removePetWithFirestore(petId)`)
and made them bail when no local pet matches. Added `_reindexActiveAfterRemoval`, which keeps the
selection on the same pet and falls back to the previous neighbour when the active pet itself is
deleted. Made `confirmDeletePet` async: it awaits the store, shows `petDeleted` only on success and
the new `petDeleteFailed` on failure, and returns whether the delete happened so the pet detail
screen can pop. Added the `onPetDeleted` Cloud Function, which recursively deletes the pet's
subcollections with the Admin SDK, clears the petId from every care-circle member's `petIds`, and
deletes invitations still pointing at it.

**Files changed:**
- `lib/stores/pet_store.dart`
- `lib/utils/pet_delete_dialog.dart`
- `lib/screens/pet_detail/pet_detail_screen.dart`
- `lib/screens/dashboard/owner_dashboard.dart`
- `lib/l10n/app_en.arb`, `lib/l10n/app_he.arb`
- `functions/src/pet-cleanup.ts`, `functions/src/index.ts`

**Regression test:** `test/stores/pet_store_test.dart` -> "deletion is keyed on id, not name" and
"active selection survives a removal"; `functions/test/pet-cleanup.test.js`.

---

## BUG-051: Pet deletion had no discoverable entry point

**Found during:** User reported pet deletion as missing functionality.
**Severity:** Medium
**Status:** Fixed

**Symptom:** Users concluded the app could not delete a pet at all.

**Root cause:** Deletion existed but was reachable only by long-pressing the home hero pet card --
a gesture with no affordance -- or through a trash icon nested inside the pet detail *edit* sheet,
four taps deep. Neither advertises itself, and nothing in Settings or the pet switcher mentioned
deletion.

**Fix:** Added a visible owner-only "Delete Pet" button to the pet detail screen, using
`PrimaryButton` in its outlined variant tinted with `c.error`. The long-press remains as a shortcut.

**Files changed:**
- `lib/screens/pet_detail/pet_detail_screen.dart`

**Regression test:** `test/screens/pet_detail/pet_detail_screen_test.dart` -> "delete affordance"
group (owner sees the button, it opens the dialog, cancel keeps the pet, non-owners see nothing).

---

## BUG-052: Owners had no route into the pet detail screen

**Found during:** User reported the new "Delete Pet" control as still not visible after BUG-051.
**Severity:** High
**Status:** Fixed

**Symptom:** Nothing an owner could tap led to pet detail, so measurement history, clinical notes,
the care circle section and every delete affordance were unreachable from the owner's own home
screen. Deletion was only ever possible via the undiscoverable long-press on the hero card.

**Root cause:** When home moved to the Figma 402:1978 hero layout, the hero `PetCard` was given
`onLongPress` but no `onTap`. `vet_dashboard.dart` was left as the only file in the app referencing
`AppRoutes.petDetail`. The user story map still listed B6 ("Pet card tap navigates to pet detail")
as DONE, which is why the gap went unnoticed -- including by the BUG-051 fix, which placed a delete
button on a screen owners could not open.

**Fix:** Restored `onTap` on the hero pet card, pushing `AppRoutes.petDetail(pet.id)`.

**Files changed:**
- `lib/screens/dashboard/owner_dashboard.dart`

**Regression test:** `test/screens/dashboard/owner_dashboard_test.dart` -> 'hero pet card opens pet
detail' asserts the card's `onTap` is non-null.

---

---

## BUG-053: Settings icons rendered maroon/red in dark mode

**Severity:** Medium
**Status:** Fixed
**Found during:** manual dark-mode review of the Settings screen.

**Symptom:** In dark mode the Settings icons — the Dark mode moon, the Language globe, the care
circle trash, the invite glyph — stayed a dark maroon `#440206` (and bright red `#FF3034` for the
trash) sitting on the dark tile washes behind them. The moon in particular was close to invisible.

**Root cause:** Not a palette defect. Every tile colour correctly swapped to its `pcDark*Tile`
counterpart; the *icons* did not, because each was drawn with `SvgPicture.asset(...)` and **no
`colorFilter`**. The Figma exports hardcode `stroke`/`fill="#440206"` (moon, globe, chevron, share,
invite, configure, down) and `stroke="#FF3034"` (trash), so those literals rendered verbatim in both
themes. Six call sites were affected. `ActionRow` in the same file was unaffected precisely because
it uses the Material `Icon(color: c.accentPeriwinkle)` branch rather than the SVG branch.

**Fix:** Applied `colorFilter: ColorFilter.mode(<semantic token>, BlendMode.srcIn)` at every call
site, taking the colour from `AppSemanticColors.of(context)` so one asset serves both themes — the
`.svg` files themselves were deliberately left untouched. `SettingsToggleRow` and the shared
`SettingsRow` gained an optional `iconColor` parameter (defaulting to `c.accentPeriwinkle` and
`c.textPrimary` respectively) to make the colour injectable. Tokens: moon → `accentPeriwinkle`,
globe → `accentMint`, trash → `error`, invite → `onSurface` (matching the surrounding secondary
button's own foreground), `ActionRow`'s SVG branch → `textPrimary`. Measured dark contrast for the
trash icon — `pcDarkBlush #F0A0BC` on `pcDarkSurface #211F1B` — is 8.19:1, comfortably above AA.

**Files changed:**
- `lib/screens/settings/settings_widgets.dart`
- `lib/screens/settings/settings_care_circle_widgets.dart`
- `lib/screens/settings/settings_content.dart`
- `lib/widgets/settings_row.dart`

**Regression test:** `test/widgets/settings_icon_contrast_test.dart` — pumps each row under
`buildDarkTheme()` and asserts the rendered `SvgPicture.colorFilter` equals the expected semantic
colour, rather than relying on a screenshot.

---

## BUG-054: Medication reminders never fired

**Severity:** High
**Status:** Fixed
**Found during:** relocating the notification settings out of the Settings screen.

**Symptom:** No medication notification had ever been delivered. Settings offered global "Morning"
and "Evening" medication reminder times, and they persisted to Firestore, but nothing was ever
scheduled at those times or at any other time.

**Root cause:** Two independent breaks that happened to hide each other.

1. `Medication.remindersEnabled` was never set to `true` by any UI — the Add/Edit Medication sheet
   didn't collect it, and a comment in `_save()` said so explicitly. Since
   `hasEndReminder => isActive && remindersEnabled && endDate != null`, that getter was
   unconditionally false, so the one scheduling call the app did make was never reached.
2. The global Morning/Evening times were dead in a second, separate way:
   `ReminderService.scheduleMedicationReminder` never read them. It schedules a single one-shot
   notification at 09:00 on the medication's `endDate` — an end-of-course nudge, not a dose
   reminder. Nothing in `lib/` read `medicationMorningHour`/`medicationEveningHour` at all.

So the feature was mis-modelled as much as it was broken: per-medication dose times cannot come
from one app-wide pair of times, since two medications on different schedules need different ones.

**Fix:** Moved the control next to the medication it configures. `Medication` gained
`List<String> reminderTimes` (canonical `"HH:mm"`, defensive parse on read), and the Add/Edit
Medication sheet now collects both `remindersEnabled` and the dose times, deriving the row count
from the chosen frequency (`Once daily` → 1 @ 09:00, `Twice daily` → 2 @ 09:00/21:00, `As needed` →
none, since an as-needed medication has no fixed dose schedule). Changing frequency resizes the list
while preserving already-chosen times. Added
`ReminderService.scheduleMedicationDoseReminders`/`cancelMedicationDoseReminders` — recurring daily
via `matchDateTimeComponents: DateTimeComponents.time`, in a fresh notification-ID namespace
(`0x40000000 + _stableHash(medId) * 4 + slot`) that cannot collide with the existing medication-end,
measurement, or weekly-summary allocations and cannot exceed the signed-32-bit ceiling.
`MedicationStore` cancels dose reminders wherever it already cancelled end reminders. The dead
`medicationMorning*`/`medicationEvening*` fields and their Settings UI were deleted; stale keys in
existing Firestore documents are harmless because the rules never enumerate keys inside `settings`.

Measurement reminders moved the same way, from Settings to a bell in the Measure tab
(`MeasurementRemindersSheet`) — that path was already wired end to end via
`settingsStore.onMeasurementReminderChanged`, so it was a UI relocation only.

**Files changed:**
- `lib/models/medication.dart`
- `lib/models/user_settings.dart`
- `lib/stores/settings_store.dart`
- `lib/stores/medication_store.dart`
- `lib/screens/medication/add_medication_sheet.dart`
- `lib/screens/measurement/measurement_reminders_sheet.dart` (new)
- `lib/screens/measurement/measurement_screen.dart`
- `lib/screens/settings/settings_content.dart`
- `lib/widgets/reminder_time_row.dart` (new)
- `lib/services/abstract_reminder_service.dart`
- `lib/services/reminder_service.dart`
- `lib/services/web_reminder_service.dart`
- `lib/l10n/app_en.arb`, `lib/l10n/app_he.arb`

**Regression test:** `test/screens/medication/add_medication_sheet_test.dart` (dose times saved per
frequency, and preserved across a frequency change); `test/models/medication_test.dart`
(`reminderTimes` round-trip and defensive parse); `test/widgets/reminder_time_row_test.dart`;
`test/screens/measurement/measurement_reminders_sheet_test.dart` (cadence and time write through to
`settingsStore`).

---

## BUG-055: Dark-mode switches were unreadable — on and off looked identical

**Severity:** Medium
**Status:** Fixed
**Found during:** manual dark-mode review of the Settings screen.

**Symptom:** In dark mode a switch was a near-black pill on a near-black card. Worse than being
dim, the on and off states looked the same — only the knob position told you which was which.

**Root cause:** `AppToggle` read its track from the accent *tiles* — `accentPurpleTile` when on,
`accentButterCream` when off. A tile is a recessed **background wash**; in dark those resolve to
`pcDarkPurpleWash #251F33` and `pcDarkButterCream #2A2620`, both L* ~13. Measured against
`pcDarkSurface #211F1B` that is **1.04:1** and **1.09:1** — invisible — and the two states sit at
**1.06:1** from each other. In light mode the same tokens are a light lavender and a cream on a
white card, which reads fine, so the defect only ever appeared in dark.

**Fix:** A switch track is a filled *control surface*, not a background wash, so it now has its own
semantic pair — `toggleTrackOn` / `toggleTrackOff` — following the precedent already set by
`knobFill` (added for exactly this reason: `surface` inverts). Light keeps the same two primitives,
so light rendering is byte-identical and still matches Figma Toggle `465:3781`. Dark maps on to the
bright brand accent `pcDarkPurple` and off to the neutral `pcDarkDivider`, giving **7.16:1** for the
on track against a card and **5.28:1** between the two states. The off track stays deliberately
quiet (1.35:1, matching light mode’s 1.27:1) because the knob carries it at 9.85:1.

The 10 other uses of `accentPurpleTile`/`accentButterCream` are genuine backgrounds and were left
alone.

**Files changed:**
- `lib/theme/semantic/color_scheme.dart`
- `lib/widgets/app_toggle.dart`

**Regression test:** `test/widgets/app_toggle_test.dart` — asserts the dark on-track clears 4.5:1
against a card, that on/off clear 3:1 against each other, and that the knob stays legible on the off
track; `test/theme/dark_contrast_test.dart` — both new fields added to the "no dark field falls
through to its light value" sweep.

---

## BUG-056: Pet detail screen removed at user request

**Severity:** N/A (product decision, not a defect)
**Status:** Fixed
**Found during:** the user reached the screen by swiping on the home screen and reported it as a
mistake.

**Symptom:** The user swiped from the home screen, landed on the pet detail screen, did not
recognise it, and asked for it to be removed.

**Root cause:** Not a code defect. No swipe gesture reaches this screen -- there is no `PageView`,
`PageController` or `onHorizontalDrag` in the shell, the dashboard or the nav bar, and the only
entry points were a **tap** on the home hero pet card (`owner_dashboard.dart`) and a tap on a vet
patient card (`vet_dashboard.dart`). On web a two-finger swipe is browser back/forward, so a swipe
would replay a history entry created by an earlier tap. The screen itself was working as designed
and had been made reachable from Home two commits earlier (BUG-052).

The removal was raised with the user together with its cost -- it withdraws stories B6, M2 and C3,
reverts BUG-051 and BUG-052, and drops the pet edit flow -- and confirmed.

**Fix:** Deleted `lib/screens/pet_detail/` (screen, sections, widgets), the `AppRoutes.petDetail`
path builder and the `pet/:petId` sub-route, and both call sites. `_VetPetCard.onTap` is optional,
so the vet card simply stops being tappable.

Pet **delete** deliberately survives: `confirmDeletePet()` is a shared util in
`lib/utils/pet_delete_dialog.dart` that the home hero card already calls from both a trailing trash
button and a long-press, so M3 is unaffected. Pet **edit** (M2) is withdrawn -- the edit sheet lived
inside the deleted screen and had no other host.

**Files changed:**
- `lib/screens/pet_detail/` (deleted)
- `lib/app_routes.dart`
- `lib/screens/dashboard/owner_dashboard.dart`
- `lib/screens/dashboard/vet_dashboard.dart`
- `.claude/rules/user-story-map.md`, `.claude/rules/screen-completion-guide.md`

**Regression test:** `test/navigation/app_routes_test.dart` -> 'no pet detail route is declared'
(source-level, because `buildRouter()` reaches for `FirebaseAnalytics` and cannot run under
`flutter_test`); `test/screens/dashboard/owner_dashboard_test.dart` -> 'hero pet card does not
navigate anywhere', which also pins that long-press delete survived. The three pet-detail test files
were deleted with the screen.

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
