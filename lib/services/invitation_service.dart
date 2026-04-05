import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/invitation.dart';

class InvitationService {
  static final _firestore = FirebaseFirestore.instance;
  static final _invitationsCollection = _firestore.collection('invitations');
  static final _petsCollection = _firestore.collection('pets');

  static const int maxInvitesPerDay = 5;

  static String _generateToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static Map<String, dynamic> _pendingInviteData(Invitation invitation) {
    return {
      'invitedEmail': invitation.invitedEmail.toLowerCase(),
      'role': 'member',
      'expiresAt': Timestamp.fromDate(invitation.expiresAt),
      'createdAt': Timestamp.fromDate(invitation.createdAt),
    };
  }

  /// Create a new invitation and return the token.
  /// All invitees join as members — no role selection needed.
  static Future<String> createInvitation({
    required String petId,
    required String petName,
    required String invitedEmail,
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
      invitedByUid: invitedByUid,
      invitedByName: invitedByName,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 7)),
    );

    final batch = _firestore.batch();
    batch.set(_invitationsCollection.doc(token), invitation.toFirestore());
    batch.update(_petsCollection.doc(petId), {
      'pendingInvites.$token': _pendingInviteData(invitation),
    });
    await batch.commit();
    return token;
  }

  /// Retrieve an invitation by its token.
  static Future<Invitation?> getInvitation(String token) async {
    final doc = await _invitationsCollection.doc(token).get();
    if (!doc.exists) return null;
    return Invitation.fromFirestore(doc);
  }

  /// Accept an invitation: validate, add user to care circle as member,
  /// mark as accepted.
  static Future<AcceptResult> acceptInvitation({
    required String token,
    required String uid,
    required String email,
    required String displayName,
    required String avatarUrl,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final invitationRef = _invitationsCollection.doc(token);

    try {
      return await _firestore.runTransaction((transaction) async {
        final invitationDoc = await transaction.get(invitationRef);
        if (!invitationDoc.exists) {
          return AcceptResult(success: false, errorCode: 'invitationNotFound');
        }

        final invitation = Invitation.fromFirestore(invitationDoc);
        if (!invitation.isPending) {
          return AcceptResult(
            success: false,
            errorCode: invitation.isExpired
                ? 'invitationExpired'
                : 'invitationAlreadyUsed',
          );
        }
        if (invitation.invitedEmail.toLowerCase() != normalizedEmail) {
          return AcceptResult(success: false, errorCode: 'invitationNotAuthorized');
        }

        final petRef = _petsCollection.doc(invitation.petId);
        final petDoc = await transaction.get(petRef);
        if (!petDoc.exists) {
          return AcceptResult(success: false, errorCode: 'invitationNotFound');
        }

        final petData = petDoc.data() as Map<String, dynamic>;
        final pendingInvites =
            Map<String, dynamic>.from(petData['pendingInvites'] as Map? ?? const {});
        final pendingInvite =
            Map<String, dynamic>.from(pendingInvites[token] as Map? ?? const {});
        if (pendingInvite.isEmpty) {
          return AcceptResult(success: false, errorCode: 'invitationNoLongerValid');
        }

        final pendingEmail =
            (pendingInvite['invitedEmail'] as String? ?? '').trim().toLowerCase();
        if (pendingEmail != normalizedEmail) {
          return AcceptResult(success: false, errorCode: 'invitationNotAuthorized');
        }

        final expiresAt = (pendingInvite['expiresAt'] as Timestamp?)?.toDate();
        if (expiresAt == null || !expiresAt.isAfter(DateTime.now())) {
          return AcceptResult(success: false, errorCode: 'invitationExpired');
        }

        final memberUids = List<String>.from(
          (petData['memberUids'] as List<dynamic>? ?? const []).whereType<String>(),
        );
        final careCircle =
            Map<String, dynamic>.from(petData['careCircle'] as Map? ?? const {});

        if (!memberUids.contains(uid)) {
          memberUids.add(uid);
          careCircle[uid] = CareCircleMember(
            uid: uid,
            name: displayName,
            avatarUrl: avatarUrl,
            role: CareCircleRole.member,
          ).toFirestore();
        }

        pendingInvites.remove(token);

        transaction.update(petRef, {
          'careCircle': careCircle,
          'memberUids': memberUids,
          'pendingInvites': pendingInvites,
          'lastAcceptedInvitationToken': token,
        });
        transaction.update(invitationRef, {
          'status': InvitationStatus.accepted.name,
        });

        return AcceptResult(success: true, petId: invitation.petId);
      });
    } on FirebaseException {
      return AcceptResult(success: false, errorCode: 'invitationAcceptFailed');
    } catch (_) {
      return AcceptResult(success: false, errorCode: 'invitationAcceptFailed');
    }
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
  /// Uses a single-field query + client-side filtering to avoid composite indexes.
  static Future<bool> hasDuplicateInvitation({
    required String petId,
    required String email,
  }) async {
    final normalizedEmail = email.toLowerCase();
    final snapshot = await _invitationsCollection
        .where('petId', isEqualTo: petId)
        .get();
    return snapshot.docs.any((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['invitedEmail'] == normalizedEmail &&
          data['status'] == InvitationStatus.pending.name;
    });
  }

  /// Count how many invitations a user has sent in the last 24 hours.
  /// Uses a single-field query + client-side filtering to avoid composite indexes.
  static Future<int> invitesSentToday(String uid) async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final snapshot = await _invitationsCollection
        .where('invitedByUid', isEqualTo: uid)
        .get();
    return snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      return createdAt != null && createdAt.isAfter(cutoff);
    }).length;
  }

  /// Validate that an invitation can be created. Returns null if valid,
  /// or an error key string suitable for localisation lookup.
  static Future<String?> validateInvitation({
    required String petId,
    required String email,
    required String invitedByUid,
  }) async {
    if (await hasDuplicateInvitation(petId: petId, email: email)) {
      return 'alreadyInvited';
    }
    if (await invitesSentToday(invitedByUid) >= maxInvitesPerDay) {
      return 'dailyInviteLimitReached';
    }
    return null;
  }

  /// Cancel an invitation.
  static Future<void> cancelInvitation(String token) async {
    final invitation = await getInvitation(token);
    if (invitation == null) return;

    final batch = _firestore.batch();
    batch.update(_invitationsCollection.doc(token), {
      'status': InvitationStatus.cancelled.name,
    });
    batch.update(_petsCollection.doc(invitation.petId), {
      'pendingInvites.$token': FieldValue.delete(),
    });
    await batch.commit();
  }
}

class AcceptResult {
  final bool success;
  final String? errorCode;
  final String? petId;

  AcceptResult({required this.success, this.errorCode, this.petId});
}
