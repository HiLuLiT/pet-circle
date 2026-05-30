import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_circle/models/medication.dart';

class MedicationService {
  static final _usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// Medications are private per user: users/{uid}/medications.
  static CollectionReference _ref(String uid) =>
      _usersCollection.doc(uid).collection('medications');

  static Future<void> add(String uid, Medication med) async {
    await _ref(uid).add(med.toFirestore());
  }

  static Future<void> update(
    String uid,
    String medicationId,
    Map<String, dynamic> data,
  ) async {
    await _ref(uid).doc(medicationId).update(data);
  }

  static Future<void> delete(String uid, String medicationId) async {
    await _ref(uid).doc(medicationId).delete();
  }

  /// Fetch all of the current user's medications (one-time read).
  static Future<List<Medication>> fetchForUser(String uid) async {
    final snapshot =
        await _ref(uid).orderBy('startDate', descending: true).get();
    return snapshot.docs.map((doc) => Medication.fromFirestore(doc)).toList();
  }
}
