import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  // PENDING AUTH STORAGE (SharedPreferences)
  // ─────────────────────────────────────────────────────────────────────────────

  static const _kPendingEmail = 'pending_auth_email';
  static const _kPendingName = 'pending_auth_name';
  static const _kPendingIsSignup = 'pending_auth_is_signup';

  /// Save pending auth data before sending the email link.
  static Future<void> savePendingAuth({
    required String email,
    String? name,
    required bool isSignup,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPendingEmail, email);
    if (name != null) {
      await prefs.setString(_kPendingName, name);
    } else {
      await prefs.remove(_kPendingName);
    }
    await prefs.setBool(_kPendingIsSignup, isSignup);
  }

  /// Retrieve pending auth data.
  static Future<({String? email, String? name, bool isSignup})> getPendingAuth() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      email: prefs.getString(_kPendingEmail),
      name: prefs.getString(_kPendingName),
      isSignup: prefs.getBool(_kPendingIsSignup) ?? false,
    );
  }

  /// Clear pending auth data after successful sign-in.
  static Future<void> clearPendingAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPendingEmail);
    await prefs.remove(_kPendingName);
    await prefs.remove(_kPendingIsSignup);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // EMAIL LINK AUTH
  // ─────────────────────────────────────────────────────────────────────────────

  /// The callback URL where Firebase redirects after the user clicks the
  /// email link. On web, this must match the origin the app is running on
  /// (localhost in dev, hosted domain in production). On native, the OS
  /// intercepts the link via App Links / Universal Links before it reaches
  /// the browser, so the production URL is always correct.
  static const _prodCallbackUrl = 'https://pet-circle-app.web.app/auth/callback';

  /// Build the callback URL, using the current origin on web so that
  /// development (localhost) and production (hosted) both work.
  static String _buildCallbackUrl() {
    if (kIsWeb) {
      final origin = Uri.base.origin; // e.g. http://localhost:12345
      return '$origin/auth/callback';
    }
    return _prodCallbackUrl;
  }

  /// Send a sign-in link to the given email address.
  static Future<AuthResult> sendSignInLink({required String email}) async {
    try {
      final actionCodeSettings = ActionCodeSettings(
        url: _buildCallbackUrl(),
        handleCodeInApp: true,
        iOSBundleId: 'com.example.petCircle',
        androidPackageName: 'com.example.pet_circle',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// Complete sign-in after the user clicks the email link.
  static Future<AuthResult> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      final credential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
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

  /// Check if a URL is a Firebase sign-in email link.
  static bool isSignInLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  /// Reload user to check email verification status
  static Future<void> reloadUser() async {
    await currentUser?.reload();
  }

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
      case 'expired-action-code':
        return 'This link has expired. Please request a new one.';
      case 'invalid-action-code':
        return 'This link is invalid or has already been used.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
