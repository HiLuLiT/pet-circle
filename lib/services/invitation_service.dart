import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/invitation.dart';
import 'package:pet_circle/services/pet_service.dart';

class InvitationService {
  static final _firestore = FirebaseFirestore.instance;
  static final _invitationsCollection = _firestore.collection('invitations');

  static String _generateToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create a new invitation and return the token.
  static Future<String> createInvitation({
    required String petId,
    required String petName,
    required String invitedEmail,
    required CareCircleRole role,
    required String invitedByUid,
    required String invitedByName,
  }) async {
    final token = _generateToken();
    final now = DateTime.now();
    final invitation = Invitation(
      id: token,
      petId: petId,
      petName: petName,
      invitedEmail: invitedEmail.toLowerCase(),
      role: role,
      invitedByUid: invitedByUid,
      invitedByName: invitedByName,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 7)),
    );

    await _invitationsCollection.doc(token).set(invitation.toFirestore());
    return token;
  }

  /// Retrieve an invitation by its token.
  static Future<Invitation?> getInvitation(String token) async {
    final doc = await _invitationsCollection.doc(token).get();
    if (!doc.exists) return null;
    return Invitation.fromFirestore(doc);
  }

  /// Accept an invitation: validate, add user to care circle, mark as accepted.
  static Future<AcceptResult> acceptInvitation({
    required String token,
    required String uid,
    required String displayName,
    required String avatarUrl,
  }) async {
    final invitation = await getInvitation(token);
    if (invitation == null) {
      return AcceptResult(success: false, error: 'Invitation not found');
    }
    if (!invitation.isPending) {
      return AcceptResult(
        success: false,
        error: invitation.isExpired ? 'Invitation has expired' : 'Invitation already used',
      );
    }

    final member = CareCircleMember(
      uid: uid,
      name: displayName,
      avatarUrl: avatarUrl,
      role: invitation.role,
    );

    await PetService.addCareCircleMember(invitation.petId, uid, member);

    await _invitationsCollection.doc(token).update({
      'status': InvitationStatus.accepted.name,
    });

    return AcceptResult(success: true, petId: invitation.petId);
  }

  /// Get all pending invitations for an email address.
  static Future<List<Invitation>> getPendingInvitationsForEmail(String email) async {
    final snapshot = await _invitationsCollection
        .where('invitedEmail', isEqualTo: email.toLowerCase())
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .get();

    return snapshot.docs
        .map((doc) => Invitation.fromFirestore(doc))
        .where((inv) => inv.isPending)
        .toList();
  }

  /// Cancel an invitation.
  static Future<void> cancelInvitation(String token) async {
    await _invitationsCollection.doc(token).update({
      'status': InvitationStatus.cancelled.name,
    });
  }
}

class AcceptResult {
  final bool success;
  final String? error;
  final String? petId;

  AcceptResult({required this.success, this.error, this.petId});
}
