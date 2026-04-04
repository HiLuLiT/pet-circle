import 'package:cloud_functions/cloud_functions.dart';

class OtpResult {
  final bool success;
  final String? error;

  const OtpResult({required this.success, this.error});
}

class OtpVerifyResult {
  final bool success;
  final String? error;
  final String? token;
  final bool isNewUser;

  const OtpVerifyResult({
    required this.success,
    this.error,
    this.token,
    this.isNewUser = false,
  });
}

class OtpService {
  static final _functions = FirebaseFunctions.instance;

  /// Send a 6-digit OTP code to the given email.
  static Future<OtpResult> sendOtp({
    required String email,
    String? name,
    bool isSignup = false,
  }) async {
    try {
      await _functions.httpsCallable('sendOTP').call<Map<String, dynamic>>({
        'email': email.toLowerCase().trim(),
        'name': name,
        'isSignup': isSignup,
      });
      return const OtpResult(success: true);
    } on FirebaseFunctionsException catch (e) {
      return OtpResult(success: false, error: e.message ?? e.code);
    } catch (e) {
      return OtpResult(success: false, error: e.toString());
    }
  }

  /// Verify the OTP code and get a Firebase Custom Auth Token.
  static Future<OtpVerifyResult> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('verifyOTP')
          .call<Map<String, dynamic>>({
        'email': email.toLowerCase().trim(),
        'code': code,
      });

      final data = result.data;
      return OtpVerifyResult(
        success: data['success'] as bool,
        token: data['token'] as String?,
        isNewUser: data['isNewUser'] as bool? ?? false,
      );
    } on FirebaseFunctionsException catch (e) {
      return OtpVerifyResult(success: false, error: e.message ?? e.code);
    } catch (e) {
      return OtpVerifyResult(success: false, error: e.toString());
    }
  }
}
