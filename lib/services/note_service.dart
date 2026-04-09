import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_circle/models/clinical_note.dart';

class NoteService {
  static final _petsCollection =
      FirebaseFirestore.instance.collection('pets');

  static CollectionReference _ref(String petId) =>
      _petsCollection.doc(petId).collection('notes');

  static Future<void> add(String petId, ClinicalNote note) async {
    await _ref(petId).add(note.toFirestore());
  }

  static Stream<List<ClinicalNote>> stream(String petId) {
    return _ref(petId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ClinicalNote.fromFirestore(doc)).toList());
  }
}
