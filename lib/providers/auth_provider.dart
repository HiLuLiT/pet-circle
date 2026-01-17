import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/services/auth_service.dart';
import 'package:pet_circle/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _init();
  }

  User? _firebaseUser;
  AppUser? _appUser;
  bool _isLoading = true;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUser?>? _userSubscription;

  // Getters
  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;
  bool get hasUserProfile => _appUser != null;

  void _init() {
    _authSubscription = AuthService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;

    // Cancel previous user subscription
    await _userSubscription?.cancel();
    _userSubscription = null;

    if (user == null) {
      _appUser = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Listen to user profile changes
    _userSubscription = UserService.streamUser(user.uid).listen((appUser) {
      _appUser = appUser;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Refresh user data
  Future<void> refresh() async {
    await AuthService.reloadUser();
    if (_firebaseUser != null) {
      _appUser = await UserService.getUser(_firebaseUser!.uid);
    }
    notifyListeners();
  }

  /// Sign out
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
