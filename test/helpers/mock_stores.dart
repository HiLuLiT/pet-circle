import 'package:pet_circle/data/mock_data.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/medication_store.dart';
import 'package:pet_circle/stores/note_store.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/stores/user_store.dart';

/// Seeds all global stores with mock data for testing.
///
/// Call in `setUp()` to get a consistent, fully-populated state
/// matching [MockData] definitions.
void seedAllStores() {
  // User store — default to owner user
  userStore.seed(MockData.currentOwnerUser);

  // Pet store — owner sees their own pets; clinic sees all
  petStore.seed(
    ownerPets: MockData.hilaPets,
    clinicPets: MockData.vetClinicPets,
  );

  // Measurement store — keyed by pet mock-id
  final princessId = petStore.ownerPets.first.id!;
  measurementStore.seed({
    princessId: MockData.princessMeasurements,
  });

  // Note store — keyed by pet mock-id
  noteStore.seed({
    princessId: MockData.princessNotes,
  });

  // Medication store — empty by default (no mock medications defined)
  medicationStore.seed({});

  // Notification store — empty by default
  notificationStore.seed([]);

  // Settings store — reset to defaults
  settingsStore.reset();
}

/// Resets all global stores to their empty / default state.
///
/// Call in `tearDown()` to prevent state leaking between tests.
void resetAllStores() {
  petStore.seed(ownerPets: [], clinicPets: []);
  measurementStore.seed({});
  medicationStore.seed({});
  noteStore.seed({});
  notificationStore.reset();
  settingsStore.reset();
}
