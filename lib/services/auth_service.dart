import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/services/user_service.dart';

class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final bool isNewUser;

  AuthResult({
    required this.success,
    this.error,
    this.user,
    this.isNewUser = false,
  });
}

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();

  /// Current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─────────────────────────────────────────────────────────────────────────────
  // GOOGLE SIGN IN
  // ─────────────────────────────────────────────────────────────────────────────

  /// Sign in with Google
  static Future<AuthResult> signInWithGoogle({AppUserRole? role}) async {
    try {
      UserCredential credential;

      if (kIsWeb) {
        // Web: Use popup
        final googleProvider = GoogleAuthProvider();
        credential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile: Use native Google Sign In
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return AuthResult(success: false, error: 'Sign in cancelled');
        }

        final googleAuth = await googleUser.authentication;
        final oauthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _auth.signInWithCredential(oauthCredential);
      }

      final user = credential.user;
      if (user == null) {
        return AuthResult(success: false, error: 'Failed to sign in');
      }

      // Check if user already exists in Firestore
      final existingUser = await UserService.getUser(user.uid);
      final isNewUser = existingUser == null;

      if (isNewUser && role != null) {
        // Create user document for new users
        await UserService.createUser(
          uid: user.uid,
          email: user.email ?? '',
          role: role,
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
      }

      return AuthResult(success: true, user: user, isNewUser: isNewUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // APPLE SIGN IN
  // ─────────────────────────────────────────────────────────────────────────────

  /// Check if Apple Sign In is available
  static Future<bool> isAppleSignInAvailable() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      return false;
    }
    return await SignInWithApple.isAvailable();
  }

  /// Sign in with Apple
  static Future<AuthResult> signInWithApple({AppUserRole? role}) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final credential = await _auth.signInWithCredential(oauthCredential);
      final user = credential.user;

      if (user == null) {
        return AuthResult(success: false, error: 'Failed to sign in');
      }

      // Check if user already exists in Firestore
      final existingUser = await UserService.getUser(user.uid);
      final isNewUser = existingUser == null;

      if (isNewUser && role != null) {
        // Apple may provide name only on first sign in
        final displayName = appleCredential.givenName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'.trim()
            : user.displayName;

        await UserService.createUser(
          uid: user.uid,
          email: user.email ?? appleCredential.email ?? '',
          role: role,
          displayName: displayName,
        );
      }

      return AuthResult(success: true, user: user, isNewUser: isNewUser);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return AuthResult(success: false, error: 'Sign in cancelled');
      }
      return AuthResult(success: false, error: e.message);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SIGN OUT
  // ─────────────────────────────────────────────────────────────────────────────

  /// Sign out from all providers
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Sign in with a Firebase Custom Auth Token (from OTP verification).
  static Future<AuthResult> signInWithCustomToken(String token) async {
    try {
      final credential = await _auth.signInWithCustomToken(token);
      final user = credential.user;
      if (user == null) {
        return AuthResult(success: false, error: 'Failed to sign in');
      }
      final existingUser = await UserService.getUser(user.uid);
      return AuthResult(
        success: true,
        user: user,
        isNewUser: existingUser == null,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────────

  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
