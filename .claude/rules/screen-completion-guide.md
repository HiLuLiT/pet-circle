# Pet Circle -- Screen Completion Guide

> Screen-by-screen guide for Pet Circle. Phase 1 complete, Phase 2 in progress. Tracks navigation, role system, auth flow, remaining work, and feature backlog.

## Phase Status: Phase 1 COMPLETE, Phase 2 IN PROGRESS

Phase 2 adds Firebase Auth, Firestore persistence, and the full dual-layer role architecture.

## Navigation Structure

```
Auth flow (kEnableFirebase = true):
  /auth-gate --> /welcome --> /role-selection --> /auth --> /verify-email --> /auth-gate --> /onboarding or /main-shell

Auth flow (kEnableFirebase = false):
  / (welcome) --> /role-selection --> /main-shell

Bottom Nav: Home(0) | Trends(1) | Measure(2) | Medication(3)
Trends: single unified view (stats + chart + history, no tabs)
Notifications: bell icon drawer only (no dedicated tab)
Medication: standalone screen at lib/screens/medication/medication_screen.dart
Active pet: global via petStore.activePetIndex, switched from header pet chip
```

## Auth Screens

| Screen | File | Purpose |
|--------|------|---------|
| AuthGate | `lib/screens/auth/auth_gate.dart` | Routes based on `AuthProvider.routeState`. Handles deep link invitation acceptance. |
| WelcomeScreen | `lib/screens/welcome_screen.dart` | Sign Up / Sign In entry point |
| RoleSelectionScreen | `lib/screens/auth/role_selection_screen.dart` | Vet / Pet Owner. Creates Firestore profile if user already authenticated. |
| AuthScreen | `lib/screens/auth/auth_screen.dart` | Email/password + Google/Apple sign-in |
| VerifyEmailScreen | `lib/screens/auth/verify_email_screen.dart` | Polls for verification, calls `authProvider.refresh()` |

## Role System (Dual-Layer Architecture)

**Layer 1 -- App-Level Roles** (selected at sign-up, stored in Firestore `/users/{uid}`):
- **Owner**: Creates pets, manages care circles, takes measurements
- **Vet**: Views vet dashboard, adds clinical notes, cannot create pets

**Layer 2 -- Care Circle Roles** (per-pet, stored in `/pets/{petId}/careCircle`):
- **Admin**: Full control (edit, delete, measure, manage circle). Auto-assigned to pet creator.
- **Member**: Can measure, view, add notes. Cannot edit pet or manage circle.
- **Viewer**: Read-only. Can view data and add notes. Cannot measure or edit.

**Permission enforcement:**
- `CareCirclePermissions` extension: `canMeasure`, `canEditPet`, `canManageCircle`, `canAddNotes`, `canDeletePet`
- `PetStore.currentUserRoleFor(petName)` resolves user's role (matches on uid first, falls back to name)
- Pet detail edit button: admin-only
- Dashboard delete (long-press): admin-only
- Dashboard measure button: hidden for viewers
- Measurement screen: lock screen for viewers
- Settings invite/remove: admin-only
- Invite flow: offers Admin/Member/Viewer role selection

## Shared Widgets

| Widget | File | Used In |
|--------|------|---------|
| `BreedSearchField` | `lib/widgets/breed_search_field.dart` | Onboarding Step 1, Pet Detail edit sheet |
| `OnboardingShell` | `lib/widgets/onboarding_shell.dart` | All 4 onboarding steps (Back/Next buttons) |
| `BottomNavBar` | `lib/widgets/bottom_nav_bar.dart` | MainShell (Home, Trends, Measure, Medication) |

## Remaining Work

### Phase 2 -- Remaining Firebase/Data Work
| Item | Details |
|------|---------|
| Push notification localization | FCM push is integrated. Remaining gap: an OS-rendered banner while the app is backgrounded is built from the FCM payload with no Dart involved, so it stays English. Needs server-side locale lookup from the recipient's user doc |
| Push trigger coverage | Only invite-accepted sends a push today. Candidates: SRR threshold alerts, measurements recorded by another circle member, medication ending |
| Functions CI | `.github/workflows/ci.yml` runs Flutter jobs only — no `tsc --noEmit` for `functions/`, so TypeScript breakage there ships unnoticed |
| Firestore security rules | Repo-managed `firestore.rules` and `firestore.indexes.json` are both deployed, and invitation acceptance requires a trusted pet-side `pendingInvites` entry that the rules can verify. Self-join may only grant `member` (BUG-040) |
| Invitee-side invitation decline | `vet_dashboard.dart`'s decline calls `cancelInvitation`, which the rules deny twice over: it requires `invitedByUid == request.auth.uid` (false for the invitee) and writes `pets/{petId}.pendingInvites`, which only the owner may touch. Needs a rules clause for the invited email setting `status: 'declined'` plus a trigger that clears `pendingInvites` with the Admin SDK |
| Invitation accept still needs a rules exception | BUG-019. `canAcceptPendingInvite` lets the invitee write their own care-circle entry. Moving accept into a callable function would let that clause be deleted, and is the natural place to maintain the invitee's `petIds` (nothing does today) |

### Polish (Optional)
| Item | Details |
|------|---------|
| VisionRR placeholder | `measurement_screen.dart` -- Phase 3 feature |
| Care circle role change | Can remove members but can't change existing roles |
| Care circle pending invites | Displayed on `circle_screen.dart` with owner-only cancel; the invitee-side decline on `vet_dashboard.dart` is still denied by the rules (see above) |
| Reminders fire no notification | `Reminder` (vet visit, grooming) persists to `pets/{petId}/reminders` but schedules no local notification and sends no push. `ReminderService` has ID namespaces for medication/measurement/weekly but none for reminders |
| Dead settings | `emergencyAlerts` and the medication morning/evening times persist to Firestore but drive no behaviour |
| Dead code | `onboarding_step4.dart` is unreferenced outside its own test (`onboarding_flow.dart` wires only steps 1-3), and the `PetService` medication methods target `pets/{petId}/medications`, which has no rule and so is denied |
| CSV file download | Export dialogs show preview but don't write actual files |

## Feature Backlog

| ID | Feature | Details | Priority |
|----|---------|---------|----------|
| FB-001 | Pet photo upload | Replace photo URL text field with image picker + Firebase Storage upload. Affects onboarding step 1, pet detail edit sheet, and pet card display. Uses `image_picker` (already in pubspec). Requires adding `firebase_storage` dependency and a `StorageService` for upload/download URLs. | Medium |
| ~~FB-002~~ | ~~Invitation email delivery~~ | **DONE.** `onInvitationCreated` (`functions/src/invitation-email.ts`) fires on `invitations/{token}` create and sends the invite via Resend. Note: `FROM_EMAIL` must be set to a verified-domain sender — the fallback is Resend's shared sandbox address, which only delivers to the Resend account owner. | — |
| FB-003 | Pet form validation | Add proper validation to pet onboarding and edit forms: required pet name (non-empty, max length), breed selection required, age validation (numeric, reasonable range), photo URL format check. Affects `onboarding_step1.dart`, `onboarding_step2.dart`, `pet_detail_screen.dart` edit sheet. Currently no fields are validated -- user can submit empty/invalid data. | Medium |
| FB-004 | Invite abuse prevention | Add safeguards to care circle invitations: email format validation before sending, prevent duplicate invites to same email for same pet, rate-limit invitations per user (e.g., max 10 per day), cap care circle size (e.g., max 20 members per pet), show warning when re-inviting an email that already has a pending invitation. Affects `onboarding_step4.dart`, `settings_screen.dart` invite dialog, and `InvitationService`. Consider Firestore security rules for server-side enforcement. | Medium |
| FB-005 | Diary view | Pet health diary for logging daily activities. Bottom nav adds a 5th "Diary" tab. Tapping opens a category picker sheet (Poop, Meal, Water, Weight, Vomit, Grooming, Mood, Custom) with color-coded icons. Each category opens a detail form with Date, Time, category-specific fields (e.g. Consistency/Color for Poop), optional Notes, and Save/Cancel. Requires new `DiaryEntry` model, `diary_store`, Firestore subcollection, diary list/timeline screen, and bottom nav update. Figma refs: `136-888`, `137-296`, `137-772`. | Low |
| FB-006 | Verify email spam hint | Update the verify-email screen (`verify_email_screen.dart`) to inform users that the verification email may land in their spam/junk folder. Add a new l10n key (e.g. `checkSpamFolder`) to both `app_en.arb` and `app_he.arb`, and display it below the existing `clickLinkToVerify` text. | High |
| ~~FB-007~~ | ~~Push notifications (FCM)~~ | **DONE.** `firebase_messaging` is a dependency; `lib/services/push_notification_service.dart` handles device-token registration/rotation into `users/{uid}/fcmTokens`, permission prompts, foreground + background handlers, and tap routing behind a route allowlist; `functions/src/fcm-utils.ts` sends multicast pushes and prunes stale tokens; the settings toggle registers/unregisters the token. Remaining follow-ups tracked as FB-008 and FB-009 below. | — |
| FB-008 | Server-side push localization | An OS-rendered push banner while the app is backgrounded is built directly from the FCM payload with no Dart involved, so it is always English. The in-app row and the foreground banner are localized. Fix: have the Cloud Function read the recipient's locale from their user document and localize `notification.title`/`body` server-side before sending. Affects `functions/src/fcm-utils.ts` and `functions/src/invitation-notification.ts`. | Medium |
| FB-009 | Broaden push trigger coverage | Only `onInvitationStatusChanged` (invite accepted) sends a push today. Add triggers for SRR threshold alerts, measurements recorded by another care-circle member, and medication ending. Each needs an ARB key pair plus a `notification_localizer.dart` case, following the `inviteAcceptedTitle`/`inviteAcceptedBody` pattern. | Medium |

## Phase 2 Completion Checklist

- [x] Firebase Auth enabled (kEnableFirebase = true)
- [x] AuthGate routing (unauthenticated/needsRole/needsEmailVerification/authenticated)
- [x] AuthProvider global singleton with routeState
- [x] UserStore unified API (currentUserUid, seedFromAppUser, etc.)
- [x] Firestore user profiles (UserService)
- [x] Firestore pet CRUD (PetService)
- [x] PetStore streams from Firestore (subscribeForUser)
- [x] Onboarding creates pet in Firestore + adds owner as Admin
- [x] Pet deletion via Firestore
- [x] Care circle member removal via Firestore
- [x] Invitation model + InvitationService
- [x] Deep link handling (app_links)
- [x] Invitation acceptance in AuthGate
- [x] Settings invite dialog calls InvitationService
- [x] Dual-layer role architecture enforced across all screens
- [x] Shared pets visible on owner dashboard with role badge
- [x] Subcollection operations wired to Firestore (measurements, notes, medications)
- [x] Pet edit wired to Firestore
- [x] Pet latest measurement snapshot synced to parent pet doc
- [x] Settings/preferences persisted to Firestore
- [x] In-app notifications persisted to Firestore
- [x] Push notifications (FCM)
- [x] Production Firestore security rules deployed

## Phase 1 Completion Checklist

- [x] All data flows wired to stores
- [x] All buttons functional
- [x] Care circle role system (Admin/Member/Viewer)
- [x] Role-aware UI (edit/delete/measure permissions)
- [x] Multi-pet support (add, edit, delete, global switcher)
- [x] User profile management
- [x] Sign out
- [x] Measurement lifecycle (add, view, filter by period, delete)
- [x] Clinical notes persistence
- [x] Medication management (add, edit, list, export)
- [x] Unified health trends (single view, no tabs)
- [x] Searchable breed dropdown (shared widget)
- [x] Onboarding Back/Next with persistent state
- [x] Dark mode + i18n (EN/HE, enforced)
- [x] Design system tokens enforced via [design-system-enforcement.md](design-system-enforcement.md)
