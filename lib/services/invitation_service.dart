import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/invitation.dart';
import 'package:pet_circle/services/pet_service.dart';

class InvitationService {
  static final _firestore = FirebaseFirestore.instance;
  static final _invitationsCollection = _firestore.collection('invitations');

  static const int maxVetsPerPet = 2;
  static const int maxInvitesPerDay = 5;

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
    InvitationType type = InvitationType.careCircle,
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
      type: type,
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

  /// Check if a pending invitation already exists for this pet + email combo.
  static Future<bool> hasDuplicateInvitation({
    required String petId,
    required String email,
  }) async {
    final snapshot = await _invitationsCollection
        .where('petId', isEqualTo: petId)
        .where('invitedEmail', isEqualTo: email.toLowerCase())
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Count pending + accepted vet invitations for a given pet.
  static Future<int> vetCountForPet(String petId) async {
    final snapshot = await _invitationsCollection
        .where('petId', isEqualTo: petId)
        .where('type', isEqualTo: InvitationType.vet.name)
        .get();
    return snapshot.docs
        .map((doc) => Invitation.fromFirestore(doc))
        .where((inv) => inv.status == InvitationStatus.pending || inv.status == InvitationStatus.accepted)
        .length;
  }

  /// Count how many invitations a user has sent in the last 24 hours.
  static Future<int> invitesSentToday(String uid) async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final snapshot = await _invitationsCollection
        .where('invitedByUid', isEqualTo: uid)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoff))
        .get();
    return snapshot.docs.length;
  }

  /// Validate that a vet invitation can be created. Returns null if valid,
  /// or an error key string suitable for localisation lookup.
  static Future<String?> validateVetInvitation({
    required String petId,
    required String email,
    required String invitedByUid,
  }) async {
    if (await hasDuplicateInvitation(petId: petId, email: email)) {
      return 'vetAlreadyInvited';
    }
    if (await vetCountForPet(petId) >= maxVetsPerPet) {
      return 'maxVetsReached';
    }
    if (await invitesSentToday(invitedByUid) >= maxInvitesPerDay) {
      return 'dailyInviteLimitReached';
    }
    return null;
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
