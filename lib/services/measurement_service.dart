import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:pet_circle/models/measurement.dart';

class MeasurementService {
  static final _firestore = FirebaseFirestore.instance;
  static final _petsCollection = _firestore.collection('pets');

  static CollectionReference _ref(String petId) =>
      _petsCollection.doc(petId).collection('measurements');

  static Future<void> add(String petId, Measurement m) async {
    await _ref(petId).add(m.toFirestore());
    unawaited(_updateLatest(petId, m));
  }

  static Stream<List<Measurement>> stream(String petId) {
    return _ref(petId)
        .orderBy('recordedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = <Measurement>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(Measurement.fromFirestore(doc));
        } catch (e) {
          debugPrint('Skipping malformed measurement ${doc.id}: $e');
        }
      }
      return list;
    });
  }

  static Future<void> delete(String petId, String measurementId) async {
    await _ref(petId).doc(measurementId).delete();
    await _syncLatest(petId);
  }

  static Future<void> _updateLatest(String petId, Measurement m) async {
    await _petsCollection.doc(petId).update({
      'latestMeasurement': {
        'bpm': m.bpm,
        'recordedAt': Timestamp.fromDate(m.recordedAt),
      },
    });
  }

  static Future<void> _syncLatest(String petId) async {
    final snapshot = await _ref(petId)
        .orderBy('recordedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      await _petsCollection.doc(petId).update({
        'latestMeasurement': FieldValue.delete(),
      });
      return;
    }

    final latest = Measurement.fromFirestore(snapshot.docs.first);
    await _petsCollection.doc(petId).update({
      'latestMeasurement': {
        'bpm': latest.bpm,
        'recordedAt': Timestamp.fromDate(latest.recordedAt),
      },
    });
  }
}
