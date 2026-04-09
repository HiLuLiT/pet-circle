import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/services/user_service.dart';

abstract class UserRepository {
  Future<AppUser?> getUser(String uid);
  Future<AppUser> createUser({
    required String uid,
    required String email,
    required AppUserRole role,
    String? displayName,
    String? photoUrl,
  });
  Future<void> updateUser(String uid, Map<String, dynamic> data);
  Future<void> updateOnboardingStatus(String uid, bool completed);
  Future<void> addPetToUser(String uid, String petId);
  Future<void> removePetFromUser(String uid, String petId);
  Stream<AppUser?> streamUser(String uid);
  Future<AppUser?> findUserByEmail(String email);
  Future<AppUser?> findVetByEmail(String email);
}

class FirestoreUserRepository implements UserRepository {
  @override
  Future<AppUser?> getUser(String uid) => UserService.getUser(uid);

  @override
  Future<AppUser> createUser({
    required String uid,
    required String email,
    required AppUserRole role,
    String? displayName,
    String? photoUrl,
  }) =>
      UserService.createUser(
        uid: uid,
        email: email,
        role: role,
        displayName: displayName,
        photoUrl: photoUrl,
      );

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      UserService.updateUser(uid, data);

  @override
  Future<void> updateOnboardingStatus(String uid, bool completed) =>
      UserService.updateOnboardingStatus(uid, completed);

  @override
  Future<void> addPetToUser(String uid, String petId) =>
      UserService.addPetToUser(uid, petId);

  @override
  Future<void> removePetFromUser(String uid, String petId) =>
      UserService.removePetFromUser(uid, petId);

  @override
  Stream<AppUser?> streamUser(String uid) => UserService.streamUser(uid);

  @override
  Future<AppUser?> findUserByEmail(String email) =>
      UserService.findUserByEmail(email);

  @override
  Future<AppUser?> findVetByEmail(String email) =>
      UserService.findVetByEmail(email);
}

final UserRepository userRepository = FirestoreUserRepository();
