import 'package:flutter/foundation.dart';
import 'package:pet_circle/models/invitation.dart';
import 'package:pet_circle/repositories/invitation_repository.dart';
import 'package:pet_circle/services/invitation_service.dart';

final invitationStore = InvitationStore();

class InvitationStore extends ChangeNotifier {
  List<Invitation> _pendingInvitations = [];
  final Set<String> _processingTokens = {};
  bool _isLoading = false;
  String? _lastError;

  List<Invitation> get pendingInvitations =>
      List.unmodifiable(_pendingInvitations);
  Set<String> get processingTokens => Set.unmodifiable(_processingTokens);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  bool isProcessing(String token) => _processingTokens.contains(token);

  Future<void> loadPendingForEmail(String email) async {
    if (email.isEmpty) return;
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _pendingInvitations =
          await invitationRepository.getPendingInvitationsForEmail(email);
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AcceptResult> acceptInvitation({
    required String token,
    required String uid,
    required String email,
    required String displayName,
    required String avatarUrl,
  }) async {
    _processingTokens.add(token);
    notifyListeners();

    try {
      final result = await invitationRepository.acceptInvitation(
        token: token,
        uid: uid,
        email: email,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      _pendingInvitations.removeWhere((i) => i.id == token);
      notifyListeners();
      return result;
    } finally {
      _processingTokens.remove(token);
      notifyListeners();
    }
  }

  Future<void> declineInvitation(String token) async {
    _processingTokens.add(token);
    notifyListeners();

    try {
      await invitationRepository.cancelInvitation(token);
      _pendingInvitations.removeWhere((i) => i.id == token);
    } finally {
      _processingTokens.remove(token);
      notifyListeners();
    }
  }

  Future<String?> validateInvitation({
    required String petId,
    required String email,
    required String invitedByUid,
  }) {
    return invitationRepository.validateInvitation(
      petId: petId,
      email: email,
      invitedByUid: invitedByUid,
    );
  }

  Future<String> createInvitation({
    required String petId,
    required String petName,
    required String invitedEmail,
    required String invitedByUid,
    required String invitedByName,
  }) {
    return invitationRepository.createInvitation(
      petId: petId,
      petName: petName,
      invitedEmail: invitedEmail,
      invitedByUid: invitedByUid,
      invitedByName: invitedByName,
    );
  }

  void reset() {
    _pendingInvitations = [];
    _processingTokens.clear();
    _isLoading = false;
    _lastError = null;
    notifyListeners();
  }
}
