import 'package:cloud_firestore/cloud_firestore.dart';

/// A minimal fake [DocumentSnapshot] for unit-testing `fromFirestore` factories
/// without a real Firestore instance.
///
/// Usage:
/// ```dart
/// final doc = FakeDocumentSnapshot('doc-id', {'name': 'Buddy'});
/// final pet = Pet.fromFirestore(doc);
/// ```
class FakeDocumentSnapshot implements DocumentSnapshot {
  FakeDocumentSnapshot(this._id, this._data);

  final String _id;
  final Map<String, dynamic> _data;

  @override
  String get id => _id;

  @override
  Object? data() => _data;

  @override
  bool get exists => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
