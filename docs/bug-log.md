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
**Status:** Known limitation

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
