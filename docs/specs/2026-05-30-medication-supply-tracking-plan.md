# Predictive Medication Restock Reminders — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace manual "Mark dose taken" supply tracking with automatic depletion computed from dosing frequency, and fire a real OS local notification (plus an in-app entry) ahead of the predicted run-out date.

**Architecture:** Supply becomes stateless math derived from a refill anchor (`totalSupply` + `supplyStartDate` + `dosesPerDay`). A one-shot local notification is scheduled at `runOutDate − restockLeadDays`. When the app next runs, a reconciliation pass writes the matching in-app notification. The manual dose button and `currentSupply`/`lowSupplyThreshold` are removed.

**Tech Stack:** Flutter/Dart, `flutter_local_notifications`, `timezone`, Firestore, ChangeNotifier stores, `flutter gen-l10n` (en + he).

**Spec:** `docs/specs/2026-05-30-medication-supply-tracking-design.md`

---

## File Structure

| File | Responsibility | Action |
|------|----------------|--------|
| `lib/models/medication.dart` | New fields + computed supply getters; Firestore/copyWith | Modify |
| `test/models/medication_test.dart` | Supply suite rewrite | Modify |
| `lib/stores/medication_store.dart` | Drop `markDoseTaken`; add `getMedicationsNeedingRestock` | Modify |
| `test/stores/medication_store_test.dart` | Store test (create if absent) | Create/Modify |
| `lib/services/abstract_reminder_service.dart` | Add restock method signatures | Modify |
| `lib/services/reminder_service.dart` | Implement restock scheduling + ID namespace | Modify |
| `lib/services/web_reminder_service.dart` | No-op restock stubs | Modify |
| `lib/stores/notification_store.dart` | `reconcileRestockNotifications` | Modify |
| `test/stores/notification_store_test.dart` | Reconciliation dedup test (create if absent) | Create/Modify |
| `lib/l10n/app_en.arb` / `app_he.arb` | Restock strings; remove low-supply strings | Modify |
| `lib/screens/medication/medication_form_widgets.dart` | Supply fields (total doses, lead days) | Modify |
| `lib/screens/medication/add_medication_sheet.dart` | Hide for "As needed"; wire scheduling | Modify |
| `lib/screens/medication/medication_screen.dart` | Remove dose button; supply status + Restock dialog | Modify |
| `lib/main.dart` | Reconcile on startup | Modify |

---

## Task 1: Medication model — new fields + computed getters

**Files:**
- Modify: `lib/models/medication.dart`
- Test: `test/models/medication_test.dart`

- [ ] **Step 1: Write the failing tests** — replace the entire `group('Medication supply tracking', ...)` block (currently ~line 339 to the end of that group) with:

```dart
  group('Medication supply tracking', () {
    Medication makeMed({
      String frequency = 'Twice daily',
      int? totalSupply = 60,
      DateTime? supplyStartDate,
      int? restockLeadDays = 5,
    }) {
      return Medication(
        id: 'm1',
        name: 'Furosemide',
        dosage: '12.5mg',
        frequency: frequency,
        startDate: DateTime(2026, 1, 1),
        totalSupply: totalSupply,
        supplyStartDate: supplyStartDate,
        restockLeadDays: restockLeadDays,
      );
    }

    test('dosesPerDay maps frequency', () {
      expect(makeMed(frequency: 'Once daily').dosesPerDay, 1);
      expect(makeMed(frequency: 'Twice daily').dosesPerDay, 2);
      expect(makeMed(frequency: 'As needed').dosesPerDay, isNull);
    });

    test('hasSupplyTracking requires total, start date, and a daily rate', () {
      expect(makeMed(supplyStartDate: DateTime(2026, 1, 1)).hasSupplyTracking, isTrue);
      expect(makeMed(supplyStartDate: null).hasSupplyTracking, isFalse);
      expect(makeMed(totalSupply: null, supplyStartDate: DateTime(2026, 1, 1)).hasSupplyTracking, isFalse);
      expect(makeMed(frequency: 'As needed', supplyStartDate: DateTime(2026, 1, 1)).hasSupplyTracking, isFalse);
    });

    test('remainingDoses decreases with elapsed days and clamps at 0', () {
      final start = DateTime.now().subtract(const Duration(days: 5));
      // twice daily, 60 doses, 5 days elapsed => 60 - 10 = 50
      expect(makeMed(totalSupply: 60, supplyStartDate: start).remainingDoses, 50);
      // fully depleted clamps to 0
      final old = DateTime.now().subtract(const Duration(days: 100));
      expect(makeMed(totalSupply: 60, supplyStartDate: old).remainingDoses, 0);
    });

    test('runOutDate = start + ceil(total / dosesPerDay) days', () {
      final start = DateTime(2026, 1, 1);
      // 60 / 2 = 30 days
      expect(makeMed(totalSupply: 60, supplyStartDate: start).runOutDate,
          DateTime(2026, 1, 31));
      // 5 / 2 = 2.5 -> ceil 3 days
      expect(makeMed(totalSupply: 5, supplyStartDate: start).runOutDate,
          DateTime(2026, 1, 4));
    });

    test('restockDate = runOutDate - restockLeadDays', () {
      final start = DateTime(2026, 1, 1);
      final med = makeMed(totalSupply: 60, supplyStartDate: start, restockLeadDays: 5);
      expect(med.restockDate, DateTime(2026, 1, 26));
    });

    test('needsRestock true once within the lead window', () {
      final soon = DateTime.now().subtract(const Duration(days: 28));
      // twice daily, 60 doses -> runs out in ~2 days, lead 5 -> already in window
      expect(makeMed(totalSupply: 60, supplyStartDate: soon).needsRestock, isTrue);
      final fresh = DateTime.now();
      expect(makeMed(totalSupply: 60, supplyStartDate: fresh).needsRestock, isFalse);
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/models/medication_test.dart`
Expected: FAIL — `supplyStartDate`/`restockLeadDays` named params and the new getters don't exist.

- [ ] **Step 3: Edit the model fields.** In `lib/models/medication.dart`, in the constructor replace `this.currentSupply,` and `this.lowSupplyThreshold,` with:

```dart
    this.supplyStartDate,
    this.restockLeadDays,
```

Replace the field declarations (currently `currentSupply` / `lowSupplyThreshold`, lines ~36-40) with:

```dart
  /// When the current batch (of [totalSupply] doses) started.
  final DateTime? supplyStartDate;

  /// Fire the restock reminder this many days before predicted run-out.
  final int? restockLeadDays;
```

- [ ] **Step 4: Replace the getters.** Replace `hasSupplyTracking` and `isLowSupply` (lines ~42-48) with:

```dart
  /// Doses consumed per day, derived from frequency. null => not trackable.
  int? get dosesPerDay => switch (frequency) {
        'Once daily' => 1,
        'Twice daily' => 2,
        _ => null,
      };

  bool get hasSupplyTracking =>
      totalSupply != null && supplyStartDate != null && dosesPerDay != null;

  int get _daysElapsed {
    final d = DateTime.now().difference(supplyStartDate!).inDays;
    return d < 0 ? 0 : d;
  }

  /// Remaining doses, clamped to [0, totalSupply].
  int get remainingDoses {
    if (!hasSupplyTracking) return 0;
    final used = dosesPerDay! * _daysElapsed;
    return (totalSupply! - used).clamp(0, totalSupply!).toInt();
  }

  /// Predicted date the batch runs out.
  DateTime get runOutDate => supplyStartDate!
      .add(Duration(days: (totalSupply! / dosesPerDay!).ceil()));

  /// When the restock reminder should fire.
  DateTime get restockDate =>
      runOutDate.subtract(Duration(days: restockLeadDays ?? 5));

  /// True once within the restock lead window.
  bool get needsRestock =>
      hasSupplyTracking && !DateTime.now().isBefore(restockDate);
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/models/medication_test.dart`
Expected: the new supply tests PASS. (Firestore/copyWith tests still fail — fixed in Task 2.)

---

## Task 2: Medication model — Firestore + copyWith (with back-compat)

**Files:**
- Modify: `lib/models/medication.dart`
- Test: `test/models/medication_test.dart`

- [ ] **Step 1: Write the failing test.** Add inside the `Medication fromFirestore` group:

```dart
    test('fromFirestore falls back to startDate when supplyStartDate missing', () {
      final doc = _FakeDoc('m1', {
        'name': 'Med',
        'dosage': '1mg',
        'frequency': 'Once daily',
        'startDate': Timestamp.fromDate(DateTime(2026, 2, 1)),
        'totalSupply': 30,
        // no supplyStartDate, plus legacy fields that must be ignored
        'currentSupply': 12,
        'lowSupplyThreshold': 7,
      });
      final med = Medication.fromFirestore(doc);
      expect(med.totalSupply, 30);
      expect(med.supplyStartDate, DateTime(2026, 2, 1));
      expect(med.restockLeadDays, isNull);
    });
```

> If `test/models/medication_test.dart` lacks a `_FakeDoc` helper, reuse the existing fake/mock the file already uses for `fromFirestore` tests (the current `fromFirestore` group constructs documents — copy that exact pattern).

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/models/medication_test.dart`
Expected: FAIL — `supplyStartDate` not populated / compile error in `toFirestore`/`copyWith` still referencing old fields.

- [ ] **Step 3: Update `toFirestore`.** Replace the three supply lines (currently `totalSupply`/`currentSupply`/`lowSupplyThreshold`) with:

```dart
      if (totalSupply != null) 'totalSupply': totalSupply,
      if (supplyStartDate != null)
        'supplyStartDate': Timestamp.fromDate(supplyStartDate!),
      if (restockLeadDays != null) 'restockLeadDays': restockLeadDays,
```

- [ ] **Step 4: Update `fromFirestore`.** Replace the `currentSupply`/`lowSupplyThreshold` reads with:

```dart
      totalSupply: data['totalSupply'] as int?,
      supplyStartDate: data['supplyStartDate'] != null
          ? (data['supplyStartDate'] as Timestamp).toDate()
          : (data['totalSupply'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : null),
      restockLeadDays: data['restockLeadDays'] as int?,
```

- [ ] **Step 5: Update `copyWith`.** Replace the `currentSupply`/`lowSupplyThreshold` params and bodies. New params:

```dart
    DateTime? supplyStartDate,
    bool clearSupplyStartDate = false,
    int? restockLeadDays,
    bool clearRestockLeadDays = false,
```

New body lines (replacing the old `currentSupply`/`lowSupplyThreshold` assignments):

```dart
      supplyStartDate: clearSupplyStartDate
          ? null
          : (supplyStartDate ?? this.supplyStartDate),
      restockLeadDays: clearRestockLeadDays
          ? null
          : (restockLeadDays ?? this.restockLeadDays),
```

Keep `totalSupply` + `clearTotalSupply` as-is.

- [ ] **Step 6: Run the full model test file**

Run: `flutter test test/models/medication_test.dart`
Expected: PASS. (If older tests still reference `currentSupply`/`lowSupplyThreshold`/`isLowSupply`, delete or update those specific tests now — they describe removed behavior.)

- [ ] **Step 7: Commit**

```bash
git add lib/models/medication.dart test/models/medication_test.dart
git commit -m "feat: compute medication supply from refill anchor"
```

---

## Task 3: medication_store — restock query, remove dose button logic

**Files:**
- Modify: `lib/stores/medication_store.dart`
- Test: `test/stores/medication_store_test.dart`

- [ ] **Step 1: Write the failing test.** Create/append `test/stores/medication_store_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/stores/medication_store.dart';

void main() {
  test('getMedicationsNeedingRestock returns only active, due, tracked meds', () {
    final store = MedicationStore();
    final due = Medication(
      id: 'due', name: 'A', dosage: '1mg', frequency: 'Twice daily',
      startDate: DateTime(2026, 1, 1),
      totalSupply: 60,
      supplyStartDate: DateTime.now().subtract(const Duration(days: 28)),
      restockLeadDays: 5,
    );
    final fresh = Medication(
      id: 'fresh', name: 'B', dosage: '1mg', frequency: 'Once daily',
      startDate: DateTime(2026, 1, 1),
      totalSupply: 90,
      supplyStartDate: DateTime.now(),
      restockLeadDays: 5,
    );
    final inactive = due.copyWith(id: 'inactive', isActive: false);
    store.seed({'p1': [due, fresh, inactive]});

    final result = store.getMedicationsNeedingRestock();
    expect(result.map((m) => m.id), ['due']);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/stores/medication_store_test.dart`
Expected: FAIL — `getMedicationsNeedingRestock` undefined.

- [ ] **Step 3: Edit the store.** In `lib/stores/medication_store.dart`:
  - Delete the entire `markDoseTaken(...)` method (lines ~139-171).
  - Replace `getLowSupplyMedications()` (lines ~174-184) with:

```dart
  /// Active medications across all pets that are within their restock window.
  List<Medication> getMedicationsNeedingRestock() {
    final result = <Medication>[];
    for (final meds in _medications.values) {
      for (final med in meds) {
        if (med.isActive && med.needsRestock) result.add(med);
      }
    }
    return List.unmodifiable(result);
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/stores/medication_store_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/stores/medication_store.dart test/stores/medication_store_test.dart
git commit -m "feat: medication store restock query, drop manual dose decrement"
```

---

## Task 4: Reminder service interface + web stub

**Files:**
- Modify: `lib/services/abstract_reminder_service.dart`
- Modify: `lib/services/web_reminder_service.dart`

- [ ] **Step 1: Add abstract signatures.** In `abstract_reminder_service.dart`, after `cancelMedicationReminder(...)` (line 13) add:

```dart

  /// Schedule a one-shot restock reminder for [med] at its restock date.
  Future<void> scheduleRestockReminder(
    Medication med, {
    required String title,
    required String body,
  });

  /// Cancel a scheduled restock reminder.
  Future<void> cancelRestockReminder(String medicationId);
```

- [ ] **Step 2: Add web no-op stubs.** In `web_reminder_service.dart`, after the `cancelMedicationReminder` override add:

```dart
  @override
  Future<void> scheduleRestockReminder(
    Medication med, {
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelRestockReminder(String medicationId) async {}
```

> `web_reminder_service.dart` must import `package:pet_circle/models/medication.dart` if it does not already (it implements methods taking `Medication`, so it likely does).

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze --no-pub lib/services/abstract_reminder_service.dart lib/services/web_reminder_service.dart`
Expected: no `error •` lines. (The concrete `ReminderService` will report a missing-override error until Task 5 — that is expected and fixed next.)

---

## Task 5: Reminder service — implement restock scheduling

**Files:**
- Modify: `lib/services/reminder_service.dart`

- [ ] **Step 1: Add the restock ID helper.** Next to `_medMorningId`/`_medEveningId` (lines ~137-138) add:

```dart
  /// Dedicated namespace; high bit set so it can't collide with med
  /// morning/evening IDs (_stableHash*2 / *2+1) or measurement IDs.
  int _medRestockId(String medId) => 0x40000000 | _stableHash(medId);
```

- [ ] **Step 2: Implement the methods.** After `cancelMedicationReminder` (line ~235) add:

```dart
  @override
  Future<void> scheduleRestockReminder(
    Medication med, {
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    final permitted = await requestPermission();
    if (!permitted) return;

    await cancelRestockReminder(med.id);

    if (!med.hasSupplyTracking || !med.isActive) return;
    if (med.endDate != null && med.endDate!.isBefore(DateTime.now())) return;

    // If the restock date already passed, fire shortly so it isn't lost.
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime.from(med.restockDate, tz.local);
    if (!when.isAfter(now)) {
      when = now.add(const Duration(minutes: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders for scheduled pet medications',
      importance: Importance.high,
      priority: Priority.high,
      groupKey: 'medication',
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final payload = json.encode({
      'type': 'medication',
      'route': '/shell?tab=4',
      'medicationId': med.id,
    });

    await _plugin.zonedSchedule(
      _medRestockId(med.id),
      title,
      body,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  @override
  Future<void> cancelRestockReminder(String medicationId) async {
    await _plugin.cancel(_medRestockId(medicationId));
  }
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze --no-pub lib/services/reminder_service.dart`
Expected: no `error •` lines.

- [ ] **Step 4: Commit**

```bash
git add lib/services/abstract_reminder_service.dart lib/services/web_reminder_service.dart lib/services/reminder_service.dart
git commit -m "feat: schedule one-shot restock reminders"
```

---

## Task 6: notification_store — in-app reconciliation

**Files:**
- Modify: `lib/stores/notification_store.dart`
- Test: `test/stores/notification_store_test.dart`

- [ ] **Step 1: Write the failing test.** Create/append `test/stores/notification_store_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/stores/notification_store.dart';

void main() {
  Medication dueMed(String id) => Medication(
        id: id, name: 'Furosemide', dosage: '12.5mg', frequency: 'Twice daily',
        startDate: DateTime(2026, 1, 1),
        totalSupply: 60,
        supplyStartDate: DateTime.now().subtract(const Duration(days: 28)),
        restockLeadDays: 5,
      );

  test('reconcile adds one entry per due med and is idempotent', () {
    final store = NotificationStore();
    store.seed([]);
    store.reconcileRestockNotifications(
      [dueMed('m1')],
      title: 'Time to restock',
      body: 'Order a refill',
    );
    store.reconcileRestockNotifications(
      [dueMed('m1')],
      title: 'Time to restock',
      body: 'Order a refill',
    );
    expect(store.notifications.where((n) => n.id.startsWith('restock-m1-')).length, 1);
  });
}
```

> If the store's list getter is named differently than `notifications`, use the actual getter name from `notification_store.dart`.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/stores/notification_store_test.dart`
Expected: FAIL — `reconcileRestockNotifications` undefined.

- [ ] **Step 3: Implement it.** In `lib/stores/notification_store.dart` add (ensure imports for `Medication` and `AppNotification`/`NotificationType`):

```dart
  /// Add an in-app restock notification for each due medication, once per batch.
  void reconcileRestockNotifications(
    List<Medication> dueMeds, {
    required String title,
    required String body,
  }) {
    var changed = false;
    for (final med in dueMeds) {
      final dayEpoch = med.runOutDate.millisecondsSinceEpoch ~/ 86400000;
      final id = 'restock-${med.id}-$dayEpoch';
      if (_notifications.any((n) => n.id == id)) continue;
      _notifications.insert(
        0,
        AppNotification(
          id: id,
          title: title,
          body: body,
          type: NotificationType.medication,
          createdAt: DateTime.now(),
          petName: med.name,
        ),
      );
      changed = true;
    }
    if (changed) notifyListeners();
  }
```

> Match the private list field name (`_notifications`) and `AppNotification` constructor to the actual definitions in the file/model. If `addLocal` already encapsulates insert+notify, prefer calling it per new entry instead of touching `_notifications` directly.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/stores/notification_store_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/stores/notification_store.dart test/stores/notification_store_test.dart
git commit -m "feat: reconcile in-app restock notifications"
```

---

## Task 7: Localization — ARB keys

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_he.arb`

- [ ] **Step 1: Edit `app_en.arb`.** Remove `lowSupplyThreshold`, `lowSupplyAlertTitle`, `lowSupplyAlertBody`, `markDoseTaken`, `doseTakenConfirmation` (and their `@`-metadata). Add:

```json
  "totalDoses": "Total doses",
  "restockLeadDaysLabel": "Remind me before running out (days)",
  "restockButton": "Restock",
  "restockDialogTitle": "Restock {name}",
  "@restockDialogTitle": { "placeholders": { "name": { "type": "String" } } },
  "restockDialogHint": "New total doses",
  "supplyStatus": "≈{count} doses left · runs out {date}",
  "@supplyStatus": { "placeholders": { "count": { "type": "int" }, "date": { "type": "String" } } },
  "restockNotificationTitle": "Time to restock {name}",
  "@restockNotificationTitle": { "placeholders": { "name": { "type": "String" } } },
  "restockNotificationBody": "{name} runs out in about {days} days — order a refill",
  "@restockNotificationBody": { "placeholders": { "name": { "type": "String" }, "days": { "type": "int" } } }
```

- [ ] **Step 2: Edit `app_he.arb`.** Remove the same five keys. Add (Hebrew):

```json
  "totalDoses": "מספר מנות כולל",
  "restockLeadDaysLabel": "תזכורת לפני שייגמר (ימים)",
  "restockButton": "חידוש מלאי",
  "restockDialogTitle": "חידוש מלאי עבור {name}",
  "@restockDialogTitle": { "placeholders": { "name": { "type": "String" } } },
  "restockDialogHint": "מספר מנות חדש",
  "supplyStatus": "≈{count} מנות נותרו · ייגמר ב-{date}",
  "@supplyStatus": { "placeholders": { "count": { "type": "int" }, "date": { "type": "String" } } },
  "restockNotificationTitle": "הגיע הזמן לחדש מלאי של {name}",
  "@restockNotificationTitle": { "placeholders": { "name": { "type": "String" } } },
  "restockNotificationBody": "{name} ייגמר בעוד כ-{days} ימים — הזמינו מלאי נוסף",
  "@restockNotificationBody": { "placeholders": { "name": { "type": "String" }, "days": { "type": "int" } } }
```

- [ ] **Step 3: Regenerate + verify**

Run: `flutter gen-l10n && flutter analyze --no-pub 2>&1 | grep -c "error •"`
Expected: prints `0` after Tasks 8-9 update call sites. Right now it surfaces compile errors at the old `markDoseTaken`/`lowSupply*` call sites — that's expected; fixed in the next tasks. Do NOT commit l10n alone if the app doesn't compile; commit together with Task 8/9.

---

## Task 8: Add/Edit medication form

**Files:**
- Modify: `lib/screens/medication/medication_form_widgets.dart`
- Modify: `lib/screens/medication/add_medication_sheet.dart`

- [ ] **Step 1: Form widget fields.** In `medication_form_widgets.dart`, in the supply-section widget, replace the "Current supply" and "Low supply threshold" inputs with two inputs bound to:
  - `totalSupplyController` → label `l10n.totalDoses`
  - `restockLeadDaysController` → label `l10n.restockLeadDaysLabel`

  Rename the widget's `lowSupplyThresholdController` parameter to `restockLeadDaysController` and delete the `currentSupplyController` parameter. (Keep the existing `TextField`/styling pattern used by the other inputs.)

- [ ] **Step 2: Edit `add_medication_sheet.dart` controllers.** 
  - Rename `_lowSupplyThresholdController` → `_restockLeadDaysController`; its init default text becomes `med?.restockLeadDays?.toString() ?? '5'`.
  - Delete `_currentSupplyController` and its `dispose()` line.

- [ ] **Step 3: Gate the supply section on frequency.** Wrap the supply-tracking section so it only renders when `_frequency != 'As needed'`. When the section is hidden, treat supply tracking as disabled in `_save`.

- [ ] **Step 4: Update `_save()`** (lines ~145-200). Replace the supply locals with:

```dart
    final trackSupply = _supplyTrackingEnabled && _frequency != 'As needed';
    final totalSupply =
        trackSupply ? int.tryParse(_totalSupplyController.text.trim()) : null;
    final restockLeadDays = trackSupply
        ? int.tryParse(_restockLeadDaysController.text.trim()) ?? 5
        : null;
    final supplyStartDate = trackSupply ? startDate : null;
```

  In both the create and edit `Medication(...)` / `copyWith(...)` calls, replace the
  `currentSupply` / `lowSupplyThreshold` args with:

```dart
        totalSupply: totalSupply,
        clearTotalSupply: !trackSupply,
        supplyStartDate: supplyStartDate,
        clearSupplyStartDate: !trackSupply,
        restockLeadDays: restockLeadDays,
        clearRestockLeadDays: !trackSupply,
```

  (For the create path, omit the `clear*` flags — just pass the values.)

- [ ] **Step 5: Schedule the restock reminder.** After the existing medication-reminder scheduling block in `_save`, add (web-guarded like the existing calls):

```dart
      if (!kIsWeb) {
        if (trackSupply) {
          ReminderService.instance.scheduleRestockReminder(
            updated, // or newMed in the create branch
            title: l10n.restockNotificationTitle(name),
            body: l10n.restockNotificationBody(name, restockLeadDays ?? 5),
          );
        } else {
          ReminderService.instance.cancelRestockReminder(
            _isEditing ? widget.medication!.id : newMed.id,
          );
        }
      }
```

- [ ] **Step 6: Verify**

Run: `flutter analyze --no-pub lib/screens/medication/`
Expected: no `error •` lines in the form files.

---

## Task 9: Medication card — remove dose button, add status + Restock

**Files:**
- Modify: `lib/screens/medication/medication_screen.dart`

- [ ] **Step 1: Remove the dose button.** Delete the "Mark dose taken" `TextButton` widget and its `onPressed` (the `markDoseTaken` call + both SnackBars, current lines ~400-448). Remove now-unused references to `l10n.markDoseTaken`, `l10n.doseTakenConfirmation`, `l10n.lowSupplyAlertBody`.

- [ ] **Step 2: Add the supply status row.** Where the button was, render (only when `medication.hasSupplyTracking`):

```dart
Text(
  l10n.supplyStatus(
    medication.remainingDoses,
    _formatDate(medication.runOutDate),
  ),
  style: AppSemanticTextStyles.caption.copyWith(
    color: medication.needsRestock ? c.error : c.textSecondary,
    fontWeight: FontWeight.w600,
  ),
),
```

  Reuse the screen's existing date formatter; if none, format inline as `'${d.day}/${d.month}/${d.year}'`.

- [ ] **Step 3: Add the Restock action + dialog.** Add a `TextButton` labeled `l10n.restockButton` (design-system pill, `c.primary`, mirroring the removed button's style). Its `onPressed` shows a dialog with a numeric `TextField` (hint `l10n.restockDialogHint`, title `l10n.restockDialogTitle(medication.name)`). On confirm with a parsed int `n > 0`:

```dart
final restocked = medication.copyWith(
  totalSupply: n,
  supplyStartDate: DateTime.now(),
);
await medicationStore.updateMedication(petId, medication.id, restocked);
if (!kIsWeb) {
  await ReminderService.instance.scheduleRestockReminder(
    restocked,
    title: l10n.restockNotificationTitle(restocked.name),
    body: l10n.restockNotificationBody(
        restocked.name, restocked.restockLeadDays ?? 5),
  );
}
```

- [ ] **Step 4: Verify**

Run: `flutter analyze --no-pub lib/screens/medication/medication_screen.dart`
Expected: no `error •` lines.

- [ ] **Step 5: Commit (Tasks 7-9 together — app compiles now)**

```bash
flutter gen-l10n
git add lib/l10n/app_en.arb lib/l10n/app_he.arb lib/l10n/ lib/screens/medication/
git commit -m "feat: restock-based supply UI and localization"
```

---

## Task 10: Wire reconciliation on app startup

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Add a reconcile call.** In `main()` (mock branch and the Firebase branch, after stores are seeded/subscribed and the router is built), add a helper invocation that runs after the first frame:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  final l10n = lookupAppLocalizations(appLocale.value);
  final due = medicationStore.getMedicationsNeedingRestock();
  if (due.isNotEmpty) {
    notificationStore.reconcileRestockNotifications(
      due,
      title: l10n.restockNotificationTitle(due.first.name),
      body: l10n.restockNotificationBody(
          due.first.name, due.first.restockLeadDays ?? 5),
    );
  }
});
```

> `lookupAppLocalizations` comes from `package:pet_circle/l10n/app_localizations.dart` (already imported in main.dart). `appLocale` is the existing `ValueListenable<Locale>` in main.dart. The per-med title/body is acceptable for the in-app list; each entry's `petName` already carries the med name.

> Note: for a tracked med, the in-app title/body should reflect that med — if multiple meds are due, prefer iterating and building strings per med inside the store call. If that requires per-med strings, change `reconcileRestockNotifications` to accept a `String Function(Medication) title/body` builder. Keep it simple: a builder closure is cleaner than first-med strings. Implement the builder variant if more than one med is commonly due; otherwise the first-med form is acceptable for v1.

- [ ] **Step 2: Verify**

Run: `flutter analyze --no-pub lib/main.dart`
Expected: no `error •` lines.

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: reconcile restock notifications on startup"
```

---

## Task 11: Full gate

- [ ] **Step 1: Regenerate + analyze + test**

Run:
```bash
flutter gen-l10n
flutter analyze --no-pub
flutter test
```
Expected: 0 `error •` lines; all tests pass. Fix any remaining references to removed symbols (`markDoseTaken`, `currentSupply`, `lowSupplyThreshold`, `isLowSupply`, `getLowSupplyMedications`) across `lib/` and `test/` — grep:
```bash
grep -rn "markDoseTaken\|currentSupply\|lowSupplyThreshold\|isLowSupply\|getLowSupplyMedications" lib test
```
Expected: no matches.

- [ ] **Step 2: Run /pc-phase**

Run `/pc-phase --phase "Medication restock reminders"` and address any HIGH findings; stop on CRITICAL.

- [ ] **Step 3: Commit any fixes**

```bash
git add -A && git commit -m "fix: address review findings for restock reminders"
```

---

## Task 12: Live emulator verification

- [ ] **Step 1** — `flutter run -d emulator-5554`.
- [ ] **Step 2** — Create a **Twice daily** med, **Total doses = 4**, **Remind me = 1 day**. Predicted run-out ≈ 2 days; restock date ≈ 1 day out.
- [ ] **Step 3 (fast path)** — To see the OS notification immediately, create a med whose `restockDate` is already past (e.g. Total doses = 2, twice daily → runs out in 1 day, lead 5 → restock date in the past): the reminder fires within ~1 minute.
- [ ] **Step 4** — Background the app; confirm the OS notification appears in the tray.
- [ ] **Step 5** — Reopen the app; confirm a matching entry appears in the in-app notification list (bell icon), exactly once.
- [ ] **Step 6** — Tap "Restock", enter a new total; confirm the status row updates and a new reminder is scheduled.

---

## Self-Review

- **Spec coverage:** §1 model → Tasks 1-2; §2 scheduling → Tasks 4-5; §3 reconciliation → Tasks 3,6,10; §4 card UI → Task 9; §5 form → Task 8; §6 l10n → Task 7; testing → Tasks 1-3,6; verification → Tasks 11-12. All sections covered.
- **Placeholders:** none — every code step shows code; ambiguous store/model member names are flagged to match-the-existing-definition, not left blank.
- **Type consistency:** `supplyStartDate`/`restockLeadDays`/`dosesPerDay`/`remainingDoses`/`runOutDate`/`restockDate`/`needsRestock`, `scheduleRestockReminder(title,body)`, `cancelRestockReminder(id)`, `getMedicationsNeedingRestock()`, `reconcileRestockNotifications(list,title,body)` used consistently across tasks.
