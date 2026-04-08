import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/utils/platform_utils.dart';

void main() {
  group('PlatformCapabilities', () {
    // Flutter unit tests run on the host machine (Linux/macOS/Windows), not on
    // a mobile simulator, so we verify the properties are consistent with each
    // other and with the known test environment rather than hardcoding expected
    // values that would differ per CI runner.

    group('isWeb', () {
      test('returns a bool', () {
        expect(PlatformCapabilities.isWeb, isA<bool>());
      });

      test('matches kIsWeb from foundation', () {
        expect(PlatformCapabilities.isWeb, equals(kIsWeb));
      });
    });

    group('isMobile', () {
      test('returns a bool', () {
        expect(PlatformCapabilities.isMobile, isA<bool>());
      });

      test('is false when isWeb is true (mutually exclusive)', () {
        // On web, isMobile must be false because !kIsWeb guards it.
        if (PlatformCapabilities.isWeb) {
          expect(PlatformCapabilities.isMobile, isFalse);
        }
      });

      test('is only true on iOS or Android (not desktop or web)', () {
        if (PlatformCapabilities.isMobile) {
          // If mobile, neither web nor desktop should be true.
          expect(PlatformCapabilities.isWeb, isFalse);
          expect(PlatformCapabilities.isDesktop, isFalse);
        }
      });
    });

    group('isDesktop', () {
      test('returns a bool', () {
        expect(PlatformCapabilities.isDesktop, isA<bool>());
      });

      test('is false when isWeb is true', () {
        if (PlatformCapabilities.isWeb) {
          expect(PlatformCapabilities.isDesktop, isFalse);
        }
      });

      test('is not simultaneously true as isMobile', () {
        // A device cannot be both desktop and mobile.
        expect(
          PlatformCapabilities.isDesktop && PlatformCapabilities.isMobile,
          isFalse,
        );
      });
    });

    group('supportsFileShare', () {
      test('returns a bool', () {
        expect(PlatformCapabilities.supportsFileShare, isA<bool>());
      });

      test('is false on web', () {
        if (PlatformCapabilities.isWeb) {
          expect(PlatformCapabilities.supportsFileShare, isFalse);
        }
      });

      test('is true on native platforms (non-web)', () {
        if (!PlatformCapabilities.isWeb) {
          expect(PlatformCapabilities.supportsFileShare, isTrue);
        }
      });
    });

    group('supportsNotifications', () {
      test('returns a bool', () {
        expect(PlatformCapabilities.supportsNotifications, isA<bool>());
      });

      test('is false on web', () {
        if (PlatformCapabilities.isWeb) {
          expect(PlatformCapabilities.supportsNotifications, isFalse);
        }
      });

      test('is false on desktop (Linux/Windows)', () {
        // Notifications are only supported on iOS, Android, macOS.
        // On Linux/Windows desktop, supportsNotifications is false.
        if (!PlatformCapabilities.isWeb &&
            (defaultTargetPlatform == TargetPlatform.linux ||
                defaultTargetPlatform == TargetPlatform.windows)) {
          expect(PlatformCapabilities.supportsNotifications, isFalse);
        }
      });
    });

    group('supportsAppleSignIn', () {
      test('returns a bool', () {
        expect(PlatformCapabilities.supportsAppleSignIn, isA<bool>());
      });

      test('is false on web', () {
        if (PlatformCapabilities.isWeb) {
          expect(PlatformCapabilities.supportsAppleSignIn, isFalse);
        }
      });

      test('is false on Android', () {
        if (!PlatformCapabilities.isWeb &&
            defaultTargetPlatform == TargetPlatform.android) {
          expect(PlatformCapabilities.supportsAppleSignIn, isFalse);
        }
      });

      test('is false on Linux or Windows', () {
        if (!PlatformCapabilities.isWeb &&
            (defaultTargetPlatform == TargetPlatform.linux ||
                defaultTargetPlatform == TargetPlatform.windows)) {
          expect(PlatformCapabilities.supportsAppleSignIn, isFalse);
        }
      });
    });

    group('logical consistency', () {
      test('at most one of isWeb/isMobile/isDesktop is true', () {
        final flags = [
          PlatformCapabilities.isWeb,
          PlatformCapabilities.isMobile,
          PlatformCapabilities.isDesktop,
        ];
        final trueCount = flags.where((f) => f).length;
        // They should never overlap — at most one can be true.
        expect(trueCount, lessThanOrEqualTo(1));
      });

      test('supportsFileShare implies not web', () {
        if (PlatformCapabilities.supportsFileShare) {
          expect(PlatformCapabilities.isWeb, isFalse);
        }
      });

      test('supportsAppleSignIn implies not web and not mobile-Android', () {
        if (PlatformCapabilities.supportsAppleSignIn) {
          expect(PlatformCapabilities.isWeb, isFalse);
          // Android does not support Apple Sign-In.
          expect(defaultTargetPlatform == TargetPlatform.android, isFalse);
        }
      });
    });
  });
}
