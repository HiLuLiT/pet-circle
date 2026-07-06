import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/reminder.dart';
import 'package:pet_circle/stores/reminder_store.dart';

Reminder _makeReminder({
  String id = 'rem-1',
  String petId = 'pet-1',
  DateTime? date,
  String title = 'Vet visit',
  String? detail,
}) {
  return Reminder(
    id: id,
    petId: petId,
    date: date ?? DateTime(2026, 4, 1),
    title: title,
    detail: detail,
  );
}

void main() {
  late ReminderStore store;

  setUp(() {
    store = ReminderStore();
  });

  group('ReminderStore seed', () {
    test('seed() populates reminders', () {
      store.seed({
        'pet-1': [_makeReminder(), _makeReminder(id: 'rem-2', title: 'Grooming')],
        'pet-2': [_makeReminder(id: 'rem-3', title: 'Nail trim')],
      });

      expect(store.getReminders('pet-1').length, 2);
      expect(store.getReminders('pet-2').length, 1);
      expect(store.getReminders('pet-3'), isEmpty);
    });

    test('seed() notifies listeners', () {
      int callCount = 0;
      store.addListener(() => callCount++);

      store.seed({'pet-1': [_makeReminder()]});
      expect(callCount, 1);
    });

    test('re-seeding replaces previous data', () {
      store.seed({'pet-1': [_makeReminder(), _makeReminder(id: 'rem-2')]});
      expect(store.getReminders('pet-1').length, 2);

      store.seed({'pet-2': [_makeReminder(id: 'rem-3')]});
      expect(store.getReminders('pet-1'), isEmpty);
      expect(store.getReminders('pet-2').length, 1);
    });
  });

  group('ReminderStore getReminders', () {
    test('returns empty list for unknown pet id', () {
      store.seed({'pet-1': [_makeReminder()]});
      expect(store.getReminders('unknown-pet'), isEmpty);
    });

    test('returns unmodifiable list', () {
      store.seed({'pet-1': [_makeReminder()]});

      final list = store.getReminders('pet-1');
      expect(
        () => list.add(_makeReminder(id: 'extra')),
        throwsUnsupportedError,
      );
    });
  });

  group('ReminderStore addReminder', () {
    // addReminder optimistically inserts before attempting the Firestore
    // write. kEnableFirebase=true in this project and reminder_store.dart's
    // addReminder does not gate the Firestore call on a signed-in uid (unlike
    // medication_store.dart's addMedication), so in a unit test environment
    // (no Firebase.initializeApp()) the write always throws a
    // FirebaseException synchronously, which addReminder catches, rolls back
    // the optimistic insert, and rethrows. We assert the optimistic insert is
    // visible synchronously (before the await completes) and that state is
    // rolled back once the Future completes with an error.
    test('optimistically inserts and is visible via getReminders immediately',
        () {
      final reminder = _makeReminder();

      // Do not await: the synchronous portion of addReminder (the optimistic
      // mutation) runs before the first `await`, so it is visible right away.
      final future = store.addReminder('pet-1', reminder);

      expect(store.getReminders('pet-1').map((r) => r.id), ['rem-1']);

      // Swallow the expected Firestore failure so it doesn't leak as an
      // unhandled async error into the test framework.
      expect(future, throwsA(anything));
    });

    test('rolls back the optimistic insert when the Firestore write fails',
        () async {
      final reminder = _makeReminder();

      await expectLater(
        store.addReminder('pet-1', reminder),
        throwsA(anything),
      );

      expect(store.getReminders('pet-1'), isEmpty);
    });
  });

  group('ReminderStore updateReminder', () {
    test('updateReminder with unknown pet id returns early — no throw', () async {
      store.seed({'pet-1': [_makeReminder(id: 'rem-1')]});

      final updated = _makeReminder(id: 'rem-1', title: 'Changed');
      await store.updateReminder('pet-does-not-exist', 'rem-1', updated);

      expect(store.getReminders('pet-1').first.title, 'Vet visit');
    });

    test('updateReminder with unknown reminder id returns early — no throw',
        () async {
      store.seed({'pet-1': [_makeReminder(id: 'rem-1')]});

      final updated = _makeReminder(id: 'nonexistent', title: 'Changed');
      await store.updateReminder('pet-1', 'nonexistent', updated);

      expect(store.getReminders('pet-1').first.title, 'Vet visit');
    });

    test('replaces the entry optimistically, then rolls back on failure',
        () async {
      store.seed({'pet-1': [_makeReminder(id: 'rem-1', title: 'Original')]});
      final updated = _makeReminder(id: 'rem-1', title: 'Updated');

      final future = store.updateReminder('pet-1', 'rem-1', updated);
      expect(store.getReminders('pet-1').first.title, 'Updated');

      await expectLater(future, throwsA(anything));

      // Rolled back to the original after the Firestore call fails.
      expect(store.getReminders('pet-1').first.title, 'Original');
    });
  });

  group('ReminderStore removeReminder', () {
    // NOTE: unlike updateReminder, removeReminder has no early-return guard
    // for an unknown petId/reminderId — it always proceeds to call
    // PetService.deleteReminder when kEnableFirebase is true (see
    // lib/stores/reminder_store.dart removeReminder). In this unit test
    // environment that call throws because Firebase isn't initialised, so
    // these "no-op" cases still throw. This is flagged as a potential
    // implementation inconsistency in the report; the test asserts actual
    // behavior rather than the originally-assumed early-return.
    test('removeReminder with unknown pet id still attempts the Firestore '
        'delete and throws (no early-return guard), local state unaffected',
        () async {
      store.seed({'pet-1': [_makeReminder(id: 'rem-1')]});

      await expectLater(
        store.removeReminder('pet-does-not-exist', 'rem-1'),
        throwsA(anything),
      );

      expect(store.getReminders('pet-1').length, 1);
    });

    test('removeReminder with unknown reminder id still attempts the '
        'Firestore delete and throws (no early-return guard), local state '
        'unaffected', () async {
      store.seed({'pet-1': [_makeReminder(id: 'rem-1')]});

      await expectLater(
        store.removeReminder('pet-1', 'nonexistent'),
        throwsA(anything),
      );

      expect(store.getReminders('pet-1').length, 1);
    });

    test('removes optimistically, then rolls back (re-inserts) on failure',
        () async {
      store.seed({'pet-1': [_makeReminder(id: 'rem-1')]});

      final future = store.removeReminder('pet-1', 'rem-1');
      expect(store.getReminders('pet-1'), isEmpty);

      await expectLater(future, throwsA(anything));

      // Rolled back: the reminder is re-inserted after the failed delete.
      expect(store.getReminders('pet-1').length, 1);
      expect(store.getReminders('pet-1').first.id, 'rem-1');
    });
  });

  group('ReminderStore clearData', () {
    test('clearData empties all buckets and notifies', () {
      store.seed({
        'pet-1': [_makeReminder()],
        'pet-2': [_makeReminder(id: 'rem-2')],
      });
      int calls = 0;
      store.addListener(() => calls++);

      store.clearData();

      expect(store.getReminders('pet-1'), isEmpty);
      expect(store.getReminders('pet-2'), isEmpty);
      expect(calls, 1);
    });

    test('clearData completes without throwing when already empty', () {
      expect(() => store.clearData(), returnsNormally);
    });
  });
}
