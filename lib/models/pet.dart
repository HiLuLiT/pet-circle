import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/measurement.dart';

class Pet {
  const Pet({
    this.id,
    required this.name,
    required this.breedAndAge,
    required this.imageUrl,
    required this.statusLabel,
    required this.statusColorHex,
    required this.latestMeasurement,
    required this.careCircle,
    this.diagnosis,
    this.ownerId,
  });

  final String? id;
  final String name;
  final String breedAndAge;
  final String imageUrl;
  final String statusLabel;
  final int statusColorHex;
  final Measurement latestMeasurement;
  final List<CareCircleMember> careCircle;
  final String? diagnosis;
  final String? ownerId;

  Map<String, dynamic> toFirestore() {
    final careCircleMap = <String, dynamic>{};
    for (final member in careCircle) {
      final key = member.uid ?? member.name;
      careCircleMap[key] = member.toFirestore();
    }
    return {
      'name': name,
      'breedAndAge': breedAndAge,
      'imageUrl': imageUrl,
      'statusLabel': statusLabel,
      'statusColorHex': statusColorHex,
      'diagnosis': diagnosis,
      'ownerId': ownerId,
      'careCircle': careCircleMap,
      'latestMeasurement': {
        'bpm': latestMeasurement.bpm,
        'recordedAt': Timestamp.fromDate(latestMeasurement.recordedAt),
      },
      'memberUids': careCircle
          .where((m) => m.uid != null)
          .map((m) => m.uid!)
          .toList(),
    };
  }

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final careCircleData = data['careCircle'] as Map<String, dynamic>? ?? {};
    final careCircle = careCircleData.entries
        .map((e) => CareCircleMember.fromFirestore(e.key, e.value as Map<String, dynamic>))
        .toList();

    final measurementData = data['latestMeasurement'] as Map<String, dynamic>?;
    final latestMeasurement = measurementData != null
        ? Measurement(
            bpm: measurementData['bpm'] ?? 0,
            recordedAt: (measurementData['recordedAt'] as Timestamp).toDate(),
          )
        : Measurement(bpm: 0, recordedAt: DateTime.now());

    return Pet(
      id: doc.id,
      name: data['name'] ?? '',
      breedAndAge: data['breedAndAge'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      statusLabel: data['statusLabel'] ?? 'Normal',
      statusColorHex: data['statusColorHex'] ?? 0xFF75ACFF,
      latestMeasurement: latestMeasurement,
      careCircle: careCircle,
      diagnosis: data['diagnosis'],
      ownerId: data['ownerId'],
    );
  }

  Pet copyWith({
    String? id,
    String? name,
    String? breedAndAge,
    String? imageUrl,
    String? statusLabel,
    int? statusColorHex,
    Measurement? latestMeasurement,
    List<CareCircleMember>? careCircle,
    String? diagnosis,
    String? ownerId,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breedAndAge: breedAndAge ?? this.breedAndAge,
      imageUrl: imageUrl ?? this.imageUrl,
      statusLabel: statusLabel ?? this.statusLabel,
      statusColorHex: statusColorHex ?? this.statusColorHex,
      latestMeasurement: latestMeasurement ?? this.latestMeasurement,
      careCircle: careCircle ?? this.careCircle,
      diagnosis: diagnosis ?? this.diagnosis,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
