import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/services/otp_service.dart';

void main() {
  group('OtpResult', () {
    test('success result has no error', () {
      final result = OtpResult(success: true);
      expect(result.success, isTrue);
      expect(result.error, isNull);
    });

    test('failure result has error message', () {
      final result = OtpResult(success: false, error: 'Invalid code');
      expect(result.success, isFalse);
      expect(result.error, equals('Invalid code'));
    });
  });

  group('OtpVerifyResult', () {
    test('success result has token', () {
      final result = OtpVerifyResult(
        success: true,
        token: 'custom-token-123',
        isNewUser: false,
      );
      expect(result.success, isTrue);
      expect(result.token, equals('custom-token-123'));
      expect(result.isNewUser, isFalse);
    });

    test('new user result', () {
      final result = OtpVerifyResult(
        success: true,
        token: 'token',
        isNewUser: true,
      );
      expect(result.isNewUser, isTrue);
    });
  });
}
