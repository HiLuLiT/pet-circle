import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/services/auth_service.dart';
import 'package:pet_circle/services/deep_link_service.dart';
import 'package:pet_circle/repositories/user_repository.dart';
import 'package:pet_circle/stores/notification_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/settings_store.dart';
import 'package:pet_circle/stores/user_store.dart';

enum AuthRouteState {
  loading,
  unauthenticated,
  needsOnboarding,
  authenticated,
}

final authProvider = AuthProvider();

class AuthProvider extends ChangeNotifier {
  User? _firebaseUser;
  AppUser? _appUser;
  bool _isLoading = true;
  bool _isCreatingUser = false;
  String? _subscribedUid;
  StreamSubscription<User?>? _authSubscription;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;
  bool get hasUserProfile => _appUser != null;

  AuthRouteState get routeState {
    if (_isLoading || _isCreatingUser) return AuthRouteState.loading;
    if (_firebaseUser == null) return AuthRouteState.unauthenticated;
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

    if (user == null) {
      _appUser = null;
      _isLoading = false;
      _isCreatingUser = false;
      _subscribedUid = null;
      userStore.reset();
      petStore.clearData();
      notificationStore.clearData();
      notificationStore.reset();
      settingsStore.reset();
      notifyListeners();
      return;
    }

    _appUser = null;
    _isLoading = true;
    notifyListeners();

    var appUser = await userRepository.getUser(user.uid);

    if (appUser == null && !_isCreatingUser) {
      _isCreatingUser = true;
      notifyListeners();
      try {
        final displayName = user.displayName ?? '';
        final photoUrl = user.photoURL ??
            _uiAvatarsFallback(displayName, user.email ?? '');
        await userRepository.createUser(
          uid: user.uid,
          email: user.email ?? '',
          role: AppUserRole.owner,
          displayName: displayName,
          photoUrl: photoUrl,
        );
        // Re-fetch the newly created user doc.
        appUser = await userRepository.getUser(user.uid);
      } catch (_) {
        _isCreatingUser = false;
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    _appUser = appUser;
    _isCreatingUser = false;
    if (appUser != null) {
      userStore.seedFromAppUser(appUser);
      settingsStore.seedFromAppUser(appUser);
      if (_subscribedUid != appUser.uid) {
        _subscribedUid = appUser.uid;
        try {
          await petStore.fetchForUser(appUser.uid);
          await notificationStore.fetchForUser(appUser.uid);
        } catch (e) {
          debugPrint('[AuthProvider] Failed to fetch data: $e');
        }
      }
    } else {
      settingsStore.reset();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Generates a UI Avatars fallback URL from name or email.
  static String _uiAvatarsFallback(String name, String email) {
    final label = name.isNotEmpty ? name : email.split('@').first;
    final encoded = Uri.encodeComponent(label);
    return 'https://ui-avatars.com/api/?name=$encoded&background=6B4EFF&color=fff&size=128';
  }

  Future<void> refresh() async {
    await AuthService.reloadUser();
    _firebaseUser = AuthService.currentUser;
    if (_firebaseUser != null) {
      _appUser = await userRepository.getUser(_firebaseUser!.uid);
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
    super.dispose();
  }
}
