# Medication Supply Tracking — Predictive Restock Reminders

**Date:** 2026-05-30
**Status:** Approved (design)
**Branch:** feat/push-notifications

## Problem

Today, medication supply tracking depends on the user manually tapping **"Mark dose taken"**
to decrement a stored `currentSupply`. When supply crosses a doses-based threshold, the app
shows an **in-app SnackBar only** — there is no OS notification, nothing scheduled, and nothing
written to the in-app notification list. This is both a UX burden (manual tapping) and a gap
versus the original spec (low-supply *push notifications*).

## Goal

Remove the manual dose button. Derive consumption automatically from the medication's
**frequency** (doses/day) and elapsed time, **predict the run-out date**, and fire a **real OS
local notification** ahead of time so the owner can reorder. The reminder also appears in the
in-app notification list.

## Design Decisions (locked)

1. **Supply is computed from a refill anchor**, not a stored counter. No drift, stateless math.
2. **Reminder fires N days before predicted run-out** (`restockLeadDays`, default 5). Replaces the
   doses-based `lowSupplyThreshold`.
3. **"As needed" medications get no supply tracking** (no predictable rate). The manual
   "Mark dose taken" button is removed entirely.
4. **OS notification + in-app list entry.** Scheduled local notification fires even when the app
   is closed; the in-app entry is reconciled when the app next runs.

---

## 1. Data model — `lib/models/medication.dart`

**Remove:** `currentSupply`, `lowSupplyThreshold`, `isLowSupply`.
**Add:** `supplyStartDate` (DateTime?), `restockLeadDays` (int?).
**Keep:** `totalSupply` (doses in the current batch).

Computed getters (no stored state to drift):

```dart
/// Doses consumed per day, derived from frequency. null => not trackable.
int? get dosesPerDay => switch (frequency) {
      'Once daily' => 1,
      'Twice daily' => 2,
      _ => null, // 'As needed'
    };

bool get hasSupplyTracking =>
    totalSupply != null && supplyStartDate != null && dosesPerDay != null;

/// Whole days elapsed since the batch started (>= 0).
int get _daysElapsed {
  final d = DateTime.now().difference(supplyStartDate!).inDays;
  return d < 0 ? 0 : d;
}

/// Remaining doses, clamped to [0, totalSupply].
int get remainingDoses {
  if (!hasSupplyTracking) return 0;
  final used = dosesPerDay! * _daysElapsed;
  return (totalSupply! - used).clamp(0, totalSupply!);
}

/// Date the batch is predicted to run out.
DateTime get runOutDate =>
    supplyStartDate!.add(Duration(days: (totalSupply! / dosesPerDay!).ceil()));

/// Date the restock reminder should fire (runOut minus lead time).
DateTime get restockDate =>
    runOutDate.subtract(Duration(days: restockLeadDays ?? 5));

/// True once we are within the restock lead window.
bool get needsRestock =>
    hasSupplyTracking && !DateTime.now().isBefore(restockDate);
```

`toFirestore` writes `totalSupply`, `supplyStartDate` (Timestamp), `restockLeadDays`.
`fromFirestore` is **back-compatible**: if `supplyStartDate` is absent it falls back to
`startDate`; old `currentSupply` / `lowSupplyThreshold` keys are ignored. `copyWith` gains
`supplyStartDate` / `restockLeadDays` (+ `clearSupplyStartDate` / `clearRestockLeadDays`) and
drops the removed fields.

---

## 2. Notification scheduling — reminder services

Add to `AbstractReminderService` (and concrete + web stub):

```dart
Future<void> scheduleRestockReminder(
  Medication med, { required String title, required String body });
Future<void> cancelRestockReminder(String medicationId);
```

- **Concrete (`reminder_service.dart`):** one-shot `zonedSchedule` at `med.restockDate`
  (no `matchDateTimeComponents`, so it fires once). If `restockDate` is already in the past
  (small batch), schedule for `now + 1 minute` so it still fires. Only schedule when
  `med.hasSupplyTracking && med.isActive` and `endDate` is null/future.
- **Notification ID namespace:** `_medRestockId(medId) = 0x40000000 | (_stableHash(medId) & 0x3FFFFFFF)`
  — a dedicated high-bit namespace that cannot collide with medication morning/evening IDs
  (`_stableHash*2` / `*2+1`) or measurement IDs (`900000 + day`).
- **Payload:** `{ "type": "medication", "route": "/shell?tab=4", "medicationId": <id> }`
  (reuses the existing whitelisted medication route).
- **Localized strings:** callers pass `title`/`body`. Callers with a `BuildContext` use
  `AppLocalizations.of(context)`; context-free callers (store, app-open reconciliation) use
  `lookupAppLocalizations(appLocale.value)`.
- **Web stub (`web_reminder_service.dart`):** no-op, matching the existing pattern.

---

## 3. In-app reconciliation — notification store

A scheduled OS notification can fire while the app is closed, so the in-app list entry is
created when the app next runs.

- Add `medicationStore.getMedicationsNeedingRestock()` (replaces `getLowSupplyMedications`):
  returns active, tracked meds where `needsRestock` is true.
- Add `notificationStore.reconcileRestockNotifications(List<Medication>)`: for each med needing
  restock, add an `AppNotification` (via `addLocal`) unless one already exists for the current
  batch.
- **Dedup key:** `AppNotification.id = "restock-${med.id}-${runOutDate day-epoch}"`. A new batch
  (new `supplyStartDate` → new `runOutDate`) yields a new id; the same cycle never duplicates.
- **Type:** reuse `NotificationType.medication` (avoids enum/icon/test churn).
- **Where invoked:** from `main.dart` after stores are seeded/subscribed, and again after
  medication add/update/restock.

---

## 4. UI — medication card (`lib/screens/medication/medication_screen.dart`)

- **Remove** the "Mark dose taken" `TextButton` and its SnackBar logic (current lines ~400–448).
- When `med.hasSupplyTracking`, show a **supply status row**:
  `≈{remainingDoses} doses left · runs out {date}` — rendered in `c.error` when `needsRestock`,
  otherwise `c.textPrimary`.
- Add a **"Restock"** `TextButton` (design-system pill style, `c.primary`) that opens a restock
  dialog: a numeric "total doses" input. On confirm:
  `med.copyWith(totalSupply: n, supplyStartDate: DateTime.now())` →
  `medicationStore.updateMedication(...)` → reschedule the restock reminder.

---

## 5. Form — `add_medication_sheet.dart` + `medication_form_widgets.dart`

- The supply-tracking section is shown **only when** `_frequency != 'As needed'`.
- Replace the "Current supply" and "Low supply threshold" fields with:
  - **Total doses** → `totalSupply`
  - **Remind me before running out (days)** → `restockLeadDays`, default `5`
- `supplyStartDate` is set to `startDate` on create; the **Restock** flow resets it to "today".
- On save: schedule/cancel the restock reminder alongside the existing medication-reminder logic.
- Remove the `currentSupply` controller and field.

---

## 6. Localization — `app_en.arb` + `app_he.arb` (then `flutter gen-l10n`)

**Remove/repurpose:** `lowSupplyThreshold`, `lowSupplyAlertTitle`, `lowSupplyAlertBody`,
`doseTakenConfirmation`, `markDoseTaken`.
**Add (en + he):** `totalDoses`, `restockLeadDaysLabel`, `restockButton`, `restockDialogTitle`,
`restockDialogHint`, `supplyStatus(count, date)`, `restockNotificationTitle(name)`,
`restockNotificationBody(name, days)`.

---

## Testing (TDD)

`test/models/medication_test.dart` — rewrite the supply suite:
- `dosesPerDay` for each frequency; `hasSupplyTracking` false for "As needed".
- `remainingDoses` computation and clamp to 0 after run-out.
- `runOutDate` for once- vs twice-daily.
- `restockDate = runOutDate - restockLeadDays`.
- `needsRestock` true/false around the boundary.
- `fromFirestore` back-compat (missing `supplyStartDate` → `startDate`).
- Remove `markDoseTaken` / `isLowSupply` tests.

`test/stores/` — reconciliation dedup: same batch added once; new batch adds a fresh entry.

## Verification

`flutter gen-l10n` → `flutter analyze` → `flutter test` → `/pc-phase` →
live emulator test: create a twice-daily med with a small batch so `restockDate` is in the
near past → restock notification fires within ~1 minute and appears in the in-app list.

## Out of scope

- Server-side (FCM) restock reminders — local scheduling covers the requirement.
- Variable dosing schedules beyond once/twice daily.
- Partial-dose accounting (each "dose" is one supply unit).
