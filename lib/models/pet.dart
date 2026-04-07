import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/measurement.dart';

class PendingInvite {
  const PendingInvite({
    required this.token,
    required this.invitedEmail,
    required this.expiresAt,
  });

  final String token;
  final String invitedEmail;
  final DateTime expiresAt;

  factory PendingInvite.fromFirestore(String token, Map<String, dynamic> data) {
    return PendingInvite(
      token: token,
      invitedEmail: (data['invitedEmail'] as String? ?? '').toLowerCase(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

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
    this.pendingInvites = const [],
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
  final List<PendingInvite> pendingInvites;

  Map<String, dynamic> toFirestore() {
    // Only serialize members with a valid UID. Members without UIDs
    // (e.g. mock data) are skipped — using names/emails as Firestore
    // map keys causes dot-notation corruption when the key contains dots.
    final careCircleMap = <String, dynamic>{};
    for (final member in careCircle) {
      if (member.hasFirestoreKey) {
        careCircleMap[member.firestoreKey!] = member.toFirestore();
      }
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
          .where((m) => m.hasFirestoreKey)
          .map((m) => m.firestoreKey!)
          .toList(),
    };
  }

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    final careCircleRaw = data['careCircle'];
    final careCircleData = careCircleRaw is Map
        ? Map<String, dynamic>.from(careCircleRaw)
        : <String, dynamic>{};
    final careCircle = careCircleData.entries
        .map((e) => CareCircleMember.fromFirestore(
              e.key,
              e.value is Map ? Map<String, dynamic>.from(e.value as Map) : <String, dynamic>{}))
        .toList();

    final measurementRaw = data['latestMeasurement'];
    final measurementData = measurementRaw is Map ? Map<String, dynamic>.from(measurementRaw) : null;
    final latestMeasurement = measurementData != null
        ? Measurement(
            bpm: measurementData['bpm'] ?? 0,
            recordedAt: (measurementData['recordedAt'] as Timestamp).toDate(),
          )
        : Measurement(
            bpm: 0,
            recordedAt: DateTime.fromMillisecondsSinceEpoch(0),
          );

    final pendingInvitesRaw = data['pendingInvites'];
    final pendingInvitesData = pendingInvitesRaw is Map
        ? Map<String, dynamic>.from(pendingInvitesRaw)
        : <String, dynamic>{};
    final pendingInvites = pendingInvitesData.entries
        .map((e) {
          final value = e.value is Map
              ? Map<String, dynamic>.from(e.value as Map)
              : <String, dynamic>{};
          return PendingInvite.fromFirestore(e.key, value);
        })
        .where((inv) => inv.expiresAt.isAfter(DateTime.now()))
        .toList();

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
      pendingInvites: pendingInvites,
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
    List<PendingInvite>? pendingInvites,
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
      pendingInvites: pendingInvites ?? this.pendingInvites,
    );
  }
}
