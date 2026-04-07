import 'package:cloud_firestore/cloud_firestore.dart';

enum InvitationStatus { pending, accepted, expired, cancelled }

class Invitation {
  const Invitation({
    required this.id,
    required this.petId,
    required this.petName,
    required this.invitedEmail,
    required this.invitedByUid,
    required this.invitedByName,
    required this.createdAt,
    required this.expiresAt,
    this.status = InvitationStatus.pending,
  });

  final String id;
  final String petId;
  final String petName;
  final String invitedEmail;
  final String invitedByUid;
  final String invitedByName;
  final DateTime createdAt;
  final DateTime expiresAt;
  final InvitationStatus status;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == InvitationStatus.pending && !isExpired;

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'petName': petName,
      'invitedEmail': invitedEmail.toLowerCase(),
      'role': 'member',
      'invitedByUid': invitedByUid,
      'invitedByName': invitedByName,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': status.name,
    };
  }

  factory Invitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Invitation(
      id: doc.id,
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      invitedEmail: data['invitedEmail'] ?? '',
      invitedByUid: data['invitedByUid'] ?? '',
      invitedByName: data['invitedByName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      status: _parseStatus(data['status']),
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
}
