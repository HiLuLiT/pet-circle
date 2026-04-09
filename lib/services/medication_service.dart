import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_circle/models/medication.dart';

class MedicationService {
  static final _petsCollection =
      FirebaseFirestore.instance.collection('pets');

  static CollectionReference _ref(String petId) =>
      _petsCollection.doc(petId).collection('medications');

  static Future<void> add(String petId, Medication med) async {
    await _ref(petId).add(med.toFirestore());
  }

  static Future<void> update(
    String petId,
    String medicationId,
    Map<String, dynamic> data,
  ) async {
    await _ref(petId).doc(medicationId).update(data);
  }

  static Future<void> delete(String petId, String medicationId) async {
    await _ref(petId).doc(medicationId).delete();
  }

  static Stream<List<Medication>> stream(String petId) {
    return _ref(petId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Medication.fromFirestore(doc)).toList());
  }
}
