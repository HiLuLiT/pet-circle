import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/medication.dart';
import 'package:pet_circle/models/pet.dart';

class PetService {
  static final _firestore = FirebaseFirestore.instance;
  static final _petsCollection = _firestore.collection('pets');

  static Future<Pet> createPet(Pet pet) async {
    final doc = await _petsCollection.add(pet.toFirestore());
    return pet.copyWith(id: doc.id);
  }

  static Future<void> updatePet(String petId, Map<String, dynamic> data) async {
    await _petsCollection.doc(petId).update(data);
  }

  static Future<void> deletePet(String petId) async {
    await _petsCollection.doc(petId).delete();
  }

  static Future<Pet?> getPet(String petId) async {
    final doc = await _petsCollection.doc(petId).get();
    if (!doc.exists) return null;
    return Pet.fromFirestore(doc);
  }

  /// Stream all pets where the given user is in the care circle.
  /// Uses the `memberUids` array field for efficient querying.
  static Stream<List<Pet>> streamPetsForUser(String uid) {
    return _petsCollection
        .where('memberUids', arrayContains: uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList());
  }

  /// Stream all pets owned by a specific user.
  static Stream<List<Pet>> streamOwnedPets(String uid) {
    return _petsCollection
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList());
  }

  /// Add a member to a pet's care circle.
  ///
  /// Uses a transaction with a full map rewrite because the member key
  /// may contain dots (e.g. an email), and Firestore's dot-notation
  /// would misinterpret them as nested field paths.
  static Future<void> addCareCircleMember(
    String petId,
    String memberKey,
    CareCircleMember member,
  ) async {
    final docRef = _petsCollection.doc(petId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final careCircle =
          Map<String, dynamic>.from(data['careCircle'] as Map? ?? {});
      final memberUids =
          List<String>.from(data['memberUids'] as List? ?? []);

      careCircle[memberKey] = member.toFirestore();
      if (!memberUids.contains(memberKey)) {
        memberUids.add(memberKey);
      }

      transaction.update(docRef, {
        'careCircle': careCircle,
        'memberUids': memberUids,
      });
    });
  }

  /// Remove a member from a pet's care circle.
  ///
  /// Uses a transaction with a full map rewrite because the member key
  /// may contain dots (e.g. an email like `user@example.com`), and
  /// Firestore's dot-notation in field paths would interpret those dots
  /// as nested fields, corrupting the document.
  static Future<void> removeCareCircleMember(
    String petId,
    String memberKey,
  ) async {
    final docRef = _petsCollection.doc(petId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final careCircle =
          Map<String, dynamic>.from(data['careCircle'] as Map? ?? {});
      final memberUids =
          List<String>.from(data['memberUids'] as List? ?? []);

      careCircle.remove(memberKey);
      memberUids.remove(memberKey);

      transaction.update(docRef, {
        'careCircle': careCircle,
        'memberUids': memberUids,
      });
    });
  }

  // --- Measurements subcollection ---

  static CollectionReference _measurementsRef(String petId) =>
      _petsCollection.doc(petId).collection('measurements');

  static Future<void> addMeasurement(String petId, Measurement m) async {
    await _measurementsRef(petId).add(m.toFirestore());
    unawaited(_updateLatestMeasurement(petId, m));
  }

  static Stream<List<Measurement>> streamMeasurements(String petId) {
    return _measurementsRef(petId)
        .orderBy('recordedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final measurements = <Measurement>[];
          for (final doc in snapshot.docs) {
            try {
              measurements.add(Measurement.fromFirestore(doc));
            } catch (e) {
              debugPrint('Skipping malformed measurement ${doc.id}: $e');
            }
          }
          return measurements;
        });
  }

  static Future<void> deleteMeasurement(String petId, String measurementId) async {
    await _measurementsRef(petId).doc(measurementId).delete();
    await _syncLatestMeasurement(petId);
  }

  /// Write the known latest measurement directly onto the pet doc (no re-query).
  static Future<void> _updateLatestMeasurement(
    String petId,
    Measurement m,
  ) async {
    await _petsCollection.doc(petId).update({
      'latestMeasurement': {
        'bpm': m.bpm,
        'recordedAt': Timestamp.fromDate(m.recordedAt),
      },
    });
  }

  /// Re-query the subcollection to find the true latest (used by delete).
  static Future<void> _syncLatestMeasurement(String petId) async {
    final latestSnapshot = await _measurementsRef(petId)
        .orderBy('recordedAt', descending: true)
        .limit(1)
        .get();

    if (latestSnapshot.docs.isEmpty) {
      await _petsCollection.doc(petId).update({
        'latestMeasurement': FieldValue.delete(),
      });
      return;
    }

    final latestMeasurement =
        Measurement.fromFirestore(latestSnapshot.docs.first);
    await _petsCollection.doc(petId).update({
      'latestMeasurement': {
        'bpm': latestMeasurement.bpm,
        'recordedAt': Timestamp.fromDate(latestMeasurement.recordedAt),
      },
    });
  }

  // --- Notes subcollection ---

  static CollectionReference _notesRef(String petId) =>
      _petsCollection.doc(petId).collection('notes');

  static Future<void> addNote(String petId, ClinicalNote note) async {
    await _notesRef(petId).add(note.toFirestore());
  }

  static Stream<List<ClinicalNote>> streamNotes(String petId) {
    return _notesRef(petId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ClinicalNote.fromFirestore(doc)).toList());
  }

  // --- Medications subcollection ---

  static CollectionReference _medicationsRef(String petId) =>
      _petsCollection.doc(petId).collection('medications');

  static Future<void> addMedication(String petId, Medication med) async {
    await _medicationsRef(petId).add(med.toFirestore());
  }

  static Future<void> updateMedication(
    String petId,
    String medicationId,
    Map<String, dynamic> data,
  ) async {
    await _medicationsRef(petId).doc(medicationId).update(data);
  }

  static Future<void> deleteMedication(String petId, String medicationId) async {
    await _medicationsRef(petId).doc(medicationId).delete();
  }

  static Stream<List<Medication>> streamMedications(String petId) {
    return _medicationsRef(petId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Medication.fromFirestore(doc)).toList());
  }
}
