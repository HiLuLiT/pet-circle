import 'package:pet_circle/models/invitation.dart';
import 'package:pet_circle/services/invitation_service.dart';

abstract class InvitationRepository {
  Future<String> createInvitation({
    required String petId,
    required String petName,
    required String invitedEmail,
    required String invitedByUid,
    required String invitedByName,
  });

  Future<AcceptResult> acceptInvitation({
    required String token,
    required String uid,
    required String email,
    required String displayName,
    required String avatarUrl,
  });

  Future<List<Invitation>> getPendingInvitationsForEmail(String email);

  Future<String?> validateInvitation({
    required String petId,
    required String email,
    required String invitedByUid,
  });

  Future<void> cancelInvitation(String token);
}

class FirestoreInvitationRepository implements InvitationRepository {
  @override
  Future<String> createInvitation({
    required String petId,
    required String petName,
    required String invitedEmail,
    required String invitedByUid,
    required String invitedByName,
  }) =>
      InvitationService.createInvitation(
        petId: petId,
        petName: petName,
        invitedEmail: invitedEmail,
        invitedByUid: invitedByUid,
        invitedByName: invitedByName,
      );

  @override
  Future<AcceptResult> acceptInvitation({
    required String token,
    required String uid,
    required String email,
    required String displayName,
    required String avatarUrl,
  }) =>
      InvitationService.acceptInvitation(
        token: token,
        uid: uid,
        email: email,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );

  @override
  Future<List<Invitation>> getPendingInvitationsForEmail(String email) =>
      InvitationService.getPendingInvitationsForEmail(email);

  @override
  Future<String?> validateInvitation({
    required String petId,
    required String email,
    required String invitedByUid,
  }) =>
      InvitationService.validateInvitation(
        petId: petId,
        email: email,
        invitedByUid: invitedByUid,
      );

  @override
  Future<void> cancelInvitation(String token) =>
      InvitationService.cancelInvitation(token);
}

final InvitationRepository invitationRepository =
    FirestoreInvitationRepository();
