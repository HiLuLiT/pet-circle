import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_circle/models/care_circle_member.dart';

enum InvitationStatus { pending, accepted, expired, cancelled }

enum InvitationType { careCircle, vet }

class Invitation {
  const Invitation({
    required this.id,
    required this.petId,
    required this.petName,
    required this.invitedEmail,
    required this.role,
    required this.invitedByUid,
    required this.invitedByName,
    required this.createdAt,
    required this.expiresAt,
    this.status = InvitationStatus.pending,
    this.type = InvitationType.careCircle,
  });

  final String id;
  final String petId;
  final String petName;
  final String invitedEmail;
  final CareCircleRole role;
  final String invitedByUid;
  final String invitedByName;
  final DateTime createdAt;
  final DateTime expiresAt;
  final InvitationStatus status;
  final InvitationType type;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == InvitationStatus.pending && !isExpired;

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'petName': petName,
      'invitedEmail': invitedEmail.toLowerCase(),
      'role': role.name,
      'invitedByUid': invitedByUid,
      'invitedByName': invitedByName,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': status.name,
      'type': type.name,
    };
  }

  factory Invitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Invitation(
      id: doc.id,
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      invitedEmail: data['invitedEmail'] ?? '',
      role: CareCirclePermissions.fromString(data['role'] ?? 'viewer'),
      invitedByUid: data['invitedByUid'] ?? '',
      invitedByName: data['invitedByName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      status: _parseStatus(data['status']),
      type: _parseType(data['type']),
    );
  }

  static InvitationStatus _parseStatus(String? value) {
    switch (value) {
      case 'accepted':
        return InvitationStatus.accepted;
      case 'expired':
        return InvitationStatus.expired;
      case 'cancelled':
        return InvitationStatus.cancelled;
      default:
        return InvitationStatus.pending;
    }
  }

  static InvitationType _parseType(String? value) {
    switch (value) {
      case 'vet':
        return InvitationType.vet;
      default:
        return InvitationType.careCircle;
    }
  }
}
