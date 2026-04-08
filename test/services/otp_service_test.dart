import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/services/otp_service.dart';

void main() {
  group('OtpResult', () {
    test('constructs a successful result', () {
      const result = OtpResult(success: true);
      expect(result.success, isTrue);
      expect(result.error, isNull);
    });

    test('constructs a failure result with error message', () {
      const result = OtpResult(success: false, error: 'Invalid email');
      expect(result.success, isFalse);
      expect(result.error, 'Invalid email');
    });

    test('error defaults to null when not provided', () {
      const result = OtpResult(success: true);
      expect(result.error, isNull);
    });
  });

  group('OtpVerifyResult', () {
    test('constructs a successful result with token', () {
      const result = OtpVerifyResult(
        success: true,
        token: 'firebase-custom-token-123',
      );
      expect(result.success, isTrue);
      expect(result.token, 'firebase-custom-token-123');
      expect(result.error, isNull);
      expect(result.isNewUser, isFalse);
    });

    test('constructs a failure result with error', () {
      const result = OtpVerifyResult(
        success: false,
        error: 'Invalid OTP code',
      );
      expect(result.success, isFalse);
      expect(result.error, 'Invalid OTP code');
      expect(result.token, isNull);
    });

    test('isNewUser defaults to false', () {
      const result = OtpVerifyResult(success: true, token: 'abc');
      expect(result.isNewUser, isFalse);
    });

    test('isNewUser can be set to true', () {
      const result = OtpVerifyResult(
        success: true,
        token: 'abc',
        isNewUser: true,
      );
      expect(result.isNewUser, isTrue);
    });

    test('all fields are null-safe on failure', () {
      const result = OtpVerifyResult(success: false);
      expect(result.success, isFalse);
      expect(result.error, isNull);
      expect(result.token, isNull);
      expect(result.isNewUser, isFalse);
    });
  });
}
