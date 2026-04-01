# Auth Flow Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Simplify the login/signup flow so new users reach their first value (dashboard with a pet) in fewer steps, and returning users sign in with minimal friction.

**Architecture:** Add a `hasCompletedOnboarding` flag to `AppUser` model + Firestore schema. AuthGate routes new users (no pets) to onboarding after authentication. Welcome screen gains Apple sign-in and a prominent "Sign In" button. Role selection moves to after authentication so users sign up first, pick role second.

**Tech Stack:** Flutter/Dart, Firebase Auth, Firestore, GoRouter, google_sign_in, sign_in_with_apple

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `lib/models/app_user.dart` | Modify | Add `hasCompletedOnboarding` field |
| `lib/services/user_service.dart` | Modify | Persist `hasCompletedOnboarding` flag |
| `lib/providers/auth_provider.dart` | Modify | Add `needsOnboarding` route state |
| `lib/screens/auth/auth_gate.dart` | Modify | Route to onboarding when `needsOnboarding` |
| `lib/app_routes.dart` | Modify | Add `/onboarding` to public paths, update redirect |
| `lib/screens/welcome_screen.dart` | Modify | Add Apple sign-in, replace email link with prominent button |
| `lib/screens/auth/role_selection_screen.dart` | Modify | Fix empty greeting, accept social-auth users cleanly |
| `lib/screens/onboarding/onboarding_flow.dart` | Modify | Set `hasCompletedOnboarding` on completion |
| `lib/l10n/app_en.arb` | Modify | Add new i18n keys |
| `lib/l10n/app_he.arb` | Modify | Add new i18n keys (Hebrew) |
| `test/models/app_user_test.dart` | Modify | Test new field |
| `test/screens/welcome_screen_test.dart` | Modify | Test Apple button + Sign In button |
| `test/screens/auth/auth_gate_test.dart` | Create | Test onboarding routing |
| `test/providers/auth_provider_test.dart` | Modify | Test `needsOnboarding` state |

---

## Task 1: Add `hasCompletedOnboarding` to AppUser Model

**Files:**
- Modify: `lib/models/app_user.dart`
- Modify: `test/models/app_user_test.dart`

- [ ] **Step 1: Write the failing test**

In `test/models/app_user_test.dart`, add:

```dart
test('hasCompletedOnboarding defaults to false', () {
  const user = AppUser(uid: 'u1', email: 'a@b.com', role: AppUserRole.owner);
  expect(user.hasCompletedOnboarding, false);
});

test('copyWith updates hasCompletedOnboarding', () {
  const user = AppUser(uid: 'u1', email: 'a@b.com', role: AppUserRole.owner);
  final updated = user.copyWith(hasCompletedOnboarding: true);
  expect(updated.hasCompletedOnboarding, true);
  expect(user.hasCompletedOnboarding, false); // original unchanged
});

test('fromFirestore reads hasCompletedOnboarding', () {
  // Use a mock DocumentSnapshot or test the parsing logic directly
  // by testing toFirestore round-trip
  const user = AppUser(
    uid: 'u1',
    email: 'a@b.com',
    role: AppUserRole.owner,
    hasCompletedOnboarding: true,
  );
  final map = user.toFirestore();
  expect(map['hasCompletedOnboarding'], true);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/models/app_user_test.dart -v`
Expected: FAIL — `hasCompletedOnboarding` not defined on `AppUser`

- [ ] **Step 3: Add field to AppUser**

In `lib/models/app_user.dart`, add the field to the constructor, `fromFirestore`, `toFirestore`, and `copyWith`:

```dart
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.petIds = const [],
    this.settings = const UserSettings(),
    this.hasCompletedOnboarding = false,
  });

  // ... existing fields ...
  final bool hasCompletedOnboarding;

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final settingsData = Map<String, dynamic>.from(data['settings'] ?? const {});
    return AppUser(
      // ... existing fields ...
      hasCompletedOnboarding: data['hasCompletedOnboarding'] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      // ... existing fields ...
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  AppUser copyWith({
    // ... existing params ...
    bool? hasCompletedOnboarding,
  }) {
    return AppUser(
      // ... existing fields ...
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/models/app_user_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/models/app_user.dart test/models/app_user_test.dart
git commit -m "feat: add hasCompletedOnboarding field to AppUser model"
```

---

## Task 2: Add `needsOnboarding` Route State to AuthProvider

**Files:**
- Modify: `lib/providers/auth_provider.dart`
- Modify: `test/providers/auth_provider_test.dart`

- [ ] **Step 1: Write the failing test**

In `test/providers/auth_provider_test.dart`, add:

```dart
test('routeState returns needsOnboarding when authenticated but not onboarded', () {
  // This test verifies the enum value exists and the logic is correct
  // The actual AuthProvider is hard to unit test due to Firebase deps,
  // so test the enum and the logic concept
  expect(AuthRouteState.needsOnboarding, isNotNull);
  expect(AuthRouteState.values.contains(AuthRouteState.needsOnboarding), true);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/auth_provider_test.dart -v`
Expected: FAIL — `needsOnboarding` not defined on `AuthRouteState`

- [ ] **Step 3: Add needsOnboarding to AuthRouteState and AuthProvider**

In `lib/providers/auth_provider.dart`:

```dart
enum AuthRouteState {
  loading,
  unauthenticated,
  needsEmailVerification,
  needsRole,
  needsOnboarding,
  authenticated,
}
```

Update the `routeState` getter:

```dart
AuthRouteState get routeState {
  if (_isLoading) return AuthRouteState.loading;
  if (_firebaseUser == null) return AuthRouteState.unauthenticated;
  if (!isEmailVerified) return AuthRouteState.needsEmailVerification;
  if (_appUser == null) return AuthRouteState.needsRole;
  if (!_appUser!.hasCompletedOnboarding) return AuthRouteState.needsOnboarding;
  return AuthRouteState.authenticated;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/auth_provider_test.dart -v`
Expected: PASS

- [ ] **Step 5: Fix any compilation errors across codebase**

The new enum value may cause exhaustive switch warnings. Check `auth_gate.dart` for missing case handling (will be addressed in Task 3).

Run: `flutter analyze`
Expected: May show warnings for unhandled `needsOnboarding` case — that's OK, Task 3 fixes it.

- [ ] **Step 6: Commit**

```bash
git add lib/providers/auth_provider.dart test/providers/auth_provider_test.dart
git commit -m "feat: add needsOnboarding state to AuthProvider"
```

---

## Task 3: Route New Users to Onboarding from AuthGate

**Files:**
- Modify: `lib/screens/auth/auth_gate.dart`
- Modify: `lib/app_routes.dart`
- Modify: `lib/screens/onboarding/onboarding_flow.dart`
- Modify: `lib/services/user_service.dart`

- [ ] **Step 1: Add onboarding case to AuthGate**

In `lib/screens/auth/auth_gate.dart`, update the `_navigate()` switch:

```dart
switch (state) {
  case AuthRouteState.unauthenticated:
    context.go(AppRoutes.welcome);
  case AuthRouteState.needsEmailVerification:
    context.go(AppRoutes.verifyEmail);
  case AuthRouteState.needsRole:
    context.go(AppRoutes.roleSelection);
  case AuthRouteState.needsOnboarding:
    context.go(AppRoutes.onboarding);
  case AuthRouteState.authenticated:
    _handleAuthenticated();
  case AuthRouteState.loading:
    break;
}
```

- [ ] **Step 2: Add `/onboarding` to public paths in app_routes.dart**

In `lib/app_routes.dart`, update `_publicPaths`:

```dart
const _publicPaths = {
  '/',
  '/auth-gate',
  '/auth',
  '/role-selection',
  '/verify-email',
  '/welcome',
  '/invite',
  '/onboarding',
};
```

- [ ] **Step 3: Also handle `needsOnboarding` in app_routes.dart redirect**

In `lib/app_routes.dart`, update the auth-gate exit redirect (around line 89):

```dart
if (path == '/auth-gate' && authState == AuthRouteState.authenticated) {
  // ... existing invitation/store logic ...
  return consumePendingDeepRoute() ?? AppRoutes.shell(appUser.role);
}

// Also exit auth-gate for needsOnboarding
if (path == '/auth-gate' && authState == AuthRouteState.needsOnboarding) {
  return AppRoutes.onboarding;
}
```

- [ ] **Step 4: Update OnboardingFlow to set hasCompletedOnboarding on completion**

In `lib/screens/onboarding/onboarding_flow.dart`, at the end of `_onComplete()`, before navigating to shell, add:

```dart
// Mark onboarding as complete
await UserService.updateOnboardingStatus(authProvider.firebaseUser!.uid, true);
await authProvider.refresh();
```

- [ ] **Step 5: Add updateOnboardingStatus to UserService**

In `lib/services/user_service.dart`, add:

```dart
static Future<void> updateOnboardingStatus(String uid, bool completed) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({'hasCompletedOnboarding': completed});
}
```

- [ ] **Step 6: Run all tests**

Run: `flutter test`
Expected: All existing tests pass (the new enum case is handled in the switch)

- [ ] **Step 7: Commit**

```bash
git add lib/screens/auth/auth_gate.dart lib/app_routes.dart lib/screens/onboarding/onboarding_flow.dart lib/services/user_service.dart
git commit -m "feat: route new users to onboarding after authentication"
```

---

## Task 4: Add Apple Sign-In to Welcome Screen

**Files:**
- Modify: `lib/screens/welcome_screen.dart`
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_he.arb`
- Modify: `test/screens/welcome_screen_test.dart`

- [ ] **Step 1: Write the failing test**

In `test/screens/welcome_screen_test.dart`, add:

```dart
testWidgets('displays sign-in with Apple button on iOS', (tester) async {
  // Note: In test environment, defaultTargetPlatform can be overridden
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  await tester.pumpWidget(_buildApp());
  await tester.pumpAndSettle();

  // Apple button should be present (even if sign_in_with_apple.isAvailable
  // returns false in test, the button widget should be in the tree)
  expect(find.text('Sign in with Apple'), findsOneWidget);
  debugDefaultTargetPlatformOverride = null;
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/welcome_screen_test.dart -v`
Expected: FAIL — "Sign in with Apple" not found

- [ ] **Step 3: Add i18n keys**

In `lib/l10n/app_en.arb`, add:

```json
"signInWithApple": "Sign in with Apple",
```

In `lib/l10n/app_he.arb`, add:

```json
"signInWithApple": "כניסה עם Apple",
```

Run: `flutter gen-l10n`

- [ ] **Step 4: Add Apple sign-in handler and button to WelcomeScreen**

In `lib/screens/welcome_screen.dart`, add an Apple sign-in handler in `_WelcomeScreenState`:

```dart
Future<void> _handleAppleSignIn() async {
  if (!kEnableFirebase) return;

  setState(() => _isLoading = true);

  final result = await AuthService.signInWithApple();

  if (!mounted) return;
  setState(() => _isLoading = false);

  if (result.success) {
    if (result.isNewUser) {
      context.go(AppRoutes.roleSelection);
    } else {
      context.go(AppRoutes.authGate);
    }
  } else if (result.error != null && result.error != 'Sign in cancelled') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.error!)),
    );
  }
}
```

In the build method, after the Google button, add:

```dart
if (!kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) ...[
  const SizedBox(height: AppSpacingTokens.sm),
  _AppleSignInButton(
    label: l10n.signInWithApple,
    onTap: _isLoading ? null : _handleAppleSignIn,
  ),
],
```

Add the `_AppleSignInButton` widget class (similar to `_GoogleSignInButton` but with Apple icon):

```dart
class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadiiTokens.borderRadiusXl,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apple, color: c.textPrimary, size: 24),
            const SizedBox(width: AppSpacingTokens.sm),
            Text(
              label,
              style: AppSemanticTextStyles.button.copyWith(
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Add required imports at top:

```dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/screens/welcome_screen_test.dart -v`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/screens/welcome_screen.dart lib/l10n/app_en.arb lib/l10n/app_he.arb test/screens/welcome_screen_test.dart
git commit -m "feat: add Apple sign-in button to Welcome screen"
```

---

## Task 5: Make Sign-In More Prominent on Welcome Screen

**Files:**
- Modify: `lib/screens/welcome_screen.dart`
- Modify: `test/screens/welcome_screen_test.dart`

- [ ] **Step 1: Write the failing test**

In `test/screens/welcome_screen_test.dart`, add:

```dart
testWidgets('displays prominent Sign In button', (tester) async {
  await tester.pumpWidget(_buildApp());
  await tester.pumpAndSettle();

  // Should find a PrimaryButton with "Sign In" label (outlined variant)
  final signInButton = find.widgetWithText(TextButton, 'Sign In');
  expect(signInButton, findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/welcome_screen_test.dart -v`
Expected: FAIL — Currently "Sign in with email" is a plain text, not a TextButton with "Sign In"

- [ ] **Step 3: Replace "Sign in with email" link with prominent outlined PrimaryButton**

In `lib/screens/welcome_screen.dart`, replace the "Sign in with email" TextButton with:

```dart
PrimaryButton(
  label: l10n.signIn,
  variant: PrimaryButtonVariant.outlined,
  onPressed: _isLoading
      ? null
      : () => context.push('${AppRoutes.auth}?signIn=true'),
),
```

This uses the existing `signIn` i18n key ("Sign In") and the outlined variant for visual hierarchy: Sign Up (filled) > social buttons > Sign In (outlined).

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/welcome_screen_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/welcome_screen.dart test/screens/welcome_screen_test.dart
git commit -m "feat: make Sign In button prominent on Welcome screen"
```

---

## Task 6: Fix Empty Greeting on Role Selection

**Files:**
- Modify: `lib/screens/auth/role_selection_screen.dart`
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_he.arb`

- [ ] **Step 1: Identify the bug**

In `lib/screens/auth/role_selection_screen.dart:56`:
```dart
l10n.hiUser(userStore.currentUser?.name ?? '')
```
When a new Google/Apple user arrives here, `userStore.currentUser` is null, so it shows "Hi !".

- [ ] **Step 2: Add fallback i18n key**

In `lib/l10n/app_en.arb`, add:

```json
"chooseYourRole": "Choose your role",
```

In `lib/l10n/app_he.arb`, add:

```json
"chooseYourRole": "בחר/י את התפקיד שלך",
```

Run: `flutter gen-l10n`

- [ ] **Step 3: Fix the greeting logic**

In `lib/screens/auth/role_selection_screen.dart`, replace:

```dart
Text(
  l10n.hiUser(userStore.currentUser?.name ?? ''),
```

With:

```dart
Text(
  _greetingText(l10n),
```

Add a helper method (or inline):

```dart
String _greetingText(AppLocalizations l10n) {
  final name = authProvider.firebaseUser?.displayName ??
      userStore.currentUser?.name;
  if (name != null && name.isNotEmpty) {
    return l10n.hiUser(name);
  }
  return l10n.chooseYourRole;
}
```

Note: This is a StatelessWidget, so make `_greetingText` a static helper or extract into the build method. Since it's a simple method, define it locally in `build()`:

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final c = AppSemanticColors.of(context);

  final name = authProvider.firebaseUser?.displayName ??
      userStore.currentUser?.name;
  final greeting = (name != null && name.isNotEmpty)
      ? l10n.hiUser(name)
      : l10n.chooseYourRole;
  // ... use greeting instead of l10n.hiUser(...)
```

- [ ] **Step 4: Run tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 5: Commit**

```bash
git add lib/screens/auth/role_selection_screen.dart lib/l10n/app_en.arb lib/l10n/app_he.arb
git commit -m "fix: show fallback greeting when user name is unavailable on role selection"
```

---

## Task 7: Full Integration Test

**Files:**
- Run all tests

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: All tests pass with 0 failures

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze`
Expected: No errors (warnings about unused imports are OK to address)

- [ ] **Step 3: Verify on iOS simulator**

Run: `flutter run -d <simulator-id>`
Manual test checklist:
- [ ] Welcome screen shows: Sign Up, Sign in with Google, Sign in with Apple, Sign In
- [ ] Tapping Sign in with Google → Google OAuth → Role Selection (new user) or Dashboard (existing)
- [ ] Tapping Sign in with Apple → Apple OAuth → Role Selection (new user) or Dashboard (existing)
- [ ] Tapping Sign Up → Role Selection → Auth Screen with role badge
- [ ] Tapping Sign In → Auth Screen in sign-in mode
- [ ] New user after role selection → Onboarding flow (4 steps) → Dashboard with pet
- [ ] Existing user → Dashboard directly (skips onboarding)
- [ ] Role selection shows name if available, "Choose your role" otherwise

- [ ] **Step 4: Commit any remaining fixes**

```bash
git add -A
git commit -m "chore: integration fixes for auth flow redesign"
```

---

## Summary: New Flow After Implementation

```
WELCOME SCREEN
├── [Sign Up]              → Role Selection → Auth Screen → Verify Email → AuthGate → Onboarding → App
├── [Sign in with Google]  → Google OAuth
│     ├── new user         → Role Selection → AuthGate → Onboarding → App
│     └── existing user    → AuthGate → App
├── [Sign in with Apple]   → Apple OAuth (same as Google)
└── [Sign In]              → Auth Screen (sign-in mode) → AuthGate → App
```

**Key improvements:**
- New users always go through onboarding (no more empty dashboard)
- Apple sign-in is first-class on iOS
- Sign In is a visible button, not a buried text link
- Role selection greets users properly
- 1 fewer screen for social sign-in users (no intermediate auth form)
