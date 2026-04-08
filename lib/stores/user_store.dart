import 'package:flutter/foundation.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/user.dart';

final userStore = UserStore();

class UserStore extends ChangeNotifier {
  User? _currentUser;
  AppUser? _appUser;
  AppUserRole _role = AppUserRole.owner;

  User? get currentUser => _currentUser;
  AppUser? get appUser => _appUser;
  AppUserRole get role => _role;
  bool get isVet => _role == AppUserRole.vet;
  bool get isOwner => _role == AppUserRole.owner;

  String? get currentUserUid => _appUser?.uid ?? _currentUser?.id;
  String? get currentUserEmail => _appUser?.email ?? _currentUser?.email;
  String? get currentUserDisplayName =>
      _appUser?.displayName ?? _currentUser?.name;
  String? get currentUserAvatarUrl =>
      _appUser?.photoUrl ?? _currentUser?.avatarUrl;

  /// Seed from mock User (when kEnableFirebase == false).
  void seed(User user) {
    _currentUser = user;
    _role = user.role == UserRole.vet ? AppUserRole.vet : AppUserRole.owner;
    notifyListeners();
  }

  /// Seed from Firestore AppUser (when kEnableFirebase == true).
  void seedFromAppUser(AppUser appUser) {
    _appUser = appUser;
    _role = appUser.role;
    _currentUser = User(
      id: appUser.uid,
      name: appUser.displayName ?? '',
      email: appUser.email,
      role: appUser.isVet ? UserRole.vet : UserRole.owner,
      avatarUrl: appUser.photoUrl ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(appUser.displayName ?? appUser.email)}&background=E8B4B8&color=5B2C3F',
    );
    notifyListeners();
  }

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void setRole(AppUserRole role) {
    _role = role;
    notifyListeners();
  }

  /// Clear all user data on sign-out.
  void reset() {
    _currentUser = null;
    _appUser = null;
    _role = AppUserRole.owner;
    notifyListeners();
  }
}
