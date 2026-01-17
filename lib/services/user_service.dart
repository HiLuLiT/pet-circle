import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_circle/models/app_user.dart';

class UserService {
  static final _firestore = FirebaseFirestore.instance;
  static final _usersCollection = _firestore.collection('users');

  /// Get user document by UID
  static Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// Create a new user document
  static Future<AppUser> createUser({
    required String uid,
    required String email,
    required AppUserRole role,
    String? displayName,
    String? photoUrl,
  }) async {
    final user = AppUser(
      uid: uid,
      email: email,
      role: role,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );

    await _usersCollection.doc(uid).set(user.toFirestore());
    return user;
  }

  /// Update user document
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersCollection.doc(uid).update(data);
  }

  /// Check if user exists
  static Future<bool> userExists(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    return doc.exists;
  }

  /// Add pet to user's pet list
  static Future<void> addPetToUser(String uid, String petId) async {
    await _usersCollection.doc(uid).update({
      'petIds': FieldValue.arrayUnion([petId]),
    });
  }

  /// Remove pet from user's pet list
  static Future<void> removePetFromUser(String uid, String petId) async {
    await _usersCollection.doc(uid).update({
      'petIds': FieldValue.arrayRemove([petId]),
    });
  }

  /// Stream user document for real-time updates
  static Stream<AppUser?> streamUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }
}
