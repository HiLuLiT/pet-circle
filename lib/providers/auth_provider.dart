import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/services/auth_service.dart';
import 'package:pet_circle/services/deep_link_service.dart';
import 'package:pet_circle/services/user_service.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/stores/user_store.dart';

enum AuthRouteState {
  loading,
  unauthenticated,
  needsEmailVerification,
  needsOnboarding,
  authenticated,
}

final authProvider = AuthProvider();

class AuthProvider extends ChangeNotifier {
  User? _firebaseUser;
  AppUser? _appUser;
  bool _isLoading = true;
  bool _isCreatingUser = false;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUser?>? _userSubscription;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;
  bool get hasUserProfile => _appUser != null;

  AuthRouteState get routeState {
    if (_isLoading || _isCreatingUser) return AuthRouteState.loading;
    if (_firebaseUser == null) return AuthRouteState.unauthenticated;
    if (!isEmailVerified) return AuthRouteState.needsEmailVerification;
    if (_appUser == null) return AuthRouteState.loading;
    // Skip onboarding if user has a pending invitation — they'll join a shared pet
    if (!_appUser!.hasCompletedOnboarding &&
        deepLinkService.pendingInvitationToken == null) {
      return AuthRouteState.needsOnboarding;
    }
    return AuthRouteState.authenticated;
  }

  void init() {
    if (_authSubscription != null) return;
    _authSubscription = AuthService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;

    await _userSubscription?.cancel();
    _userSubscription = null;

    if (user == null) {
      _appUser = null;
      _isLoading = false;
      _isCreatingUser = false;
      petStore.cancelSubscription();
      notificationStore.cancelSubscription();
      notificationStore.reset();
      settingsStore.reset();
      notifyListeners();
      return;
    }

    _appUser = null;
    _isLoading = true;
    notifyListeners();

    _userSubscription = UserService.streamUser(user.uid).listen((appUser) async {
      if (appUser == null && !_isCreatingUser) {
        // No user doc in Firestore — auto-create with owner role.
        _isCreatingUser = true;
        notifyListeners();
        try {
          await UserService.createUser(
            uid: user.uid,
            email: user.email ?? '',
            role: AppUserRole.owner,
            displayName: user.displayName,
            photoUrl: user.photoURL,
          );
        } catch (_) {
          _isCreatingUser = false;
          _isLoading = false;
          notifyListeners();
        }
        // The stream will fire again with the new doc.
        return;
      }

      _appUser = appUser;
      _isCreatingUser = false;
      if (appUser != null) {
        userStore.seedFromAppUser(appUser);
        settingsStore.seedFromAppUser(appUser);
      } else {
        settingsStore.reset();
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    await AuthService.reloadUser();
    _firebaseUser = AuthService.currentUser;
    if (_firebaseUser != null) {
      _appUser = await UserService.getUser(_firebaseUser!.uid);
      if (_appUser != null) {
        settingsStore.seedFromAppUser(_appUser!);
      }
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await AuthService.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
