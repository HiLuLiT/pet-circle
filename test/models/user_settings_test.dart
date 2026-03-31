import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/models/user_settings.dart';

void main() {
  group('UserSettings construction', () {
    test('creates with default values', () {
      const settings = UserSettings();

      expect(settings.elevatedThreshold, 30);
      expect(settings.criticalThreshold, 40);
      expect(settings.pushNotifications, isTrue);
      expect(settings.emergencyAlerts, isTrue);
      expect(settings.visionRREnabled, isFalse);
      expect(settings.autoExport, isFalse);
    });

    test('creates with custom values', () {
      const settings = UserSettings(
        elevatedThreshold: 25,
        criticalThreshold: 35,
        pushNotifications: false,
        emergencyAlerts: false,
        visionRREnabled: true,
        autoExport: true,
      );

      expect(settings.elevatedThreshold, 25);
      expect(settings.criticalThreshold, 35);
      expect(settings.pushNotifications, isFalse);
      expect(settings.emergencyAlerts, isFalse);
      expect(settings.visionRREnabled, isTrue);
      expect(settings.autoExport, isTrue);
    });
  });

  group('UserSettings copyWith', () {
    test('copyWith creates a new instance', () {
      const original = UserSettings();
      final copy = original.copyWith(elevatedThreshold: 20);

      expect(identical(original, copy), isFalse);
      expect(copy.elevatedThreshold, 20);
      expect(original.elevatedThreshold, 30);
    });

    test('copyWith preserves all fields when no args given', () {
      const original = UserSettings(
        elevatedThreshold: 25,
        criticalThreshold: 35,
        pushNotifications: false,
        emergencyAlerts: false,
        visionRREnabled: true,
        autoExport: true,
      );

      final copy = original.copyWith();

      expect(copy.elevatedThreshold, original.elevatedThreshold);
      expect(copy.criticalThreshold, original.criticalThreshold);
      expect(copy.pushNotifications, original.pushNotifications);
      expect(copy.emergencyAlerts, original.emergencyAlerts);
      expect(copy.visionRREnabled, original.visionRREnabled);
      expect(copy.autoExport, original.autoExport);
    });

    test('original is unchanged after copyWith', () {
      const original = UserSettings();

      original.copyWith(
        elevatedThreshold: 10,
        criticalThreshold: 50,
        pushNotifications: false,
        autoExport: true,
      );

      expect(original.elevatedThreshold, 30);
      expect(original.criticalThreshold, 40);
      expect(original.pushNotifications, isTrue);
      expect(original.autoExport, isFalse);
    });

    test('copyWith can update each field independently', () {
      const original = UserSettings();

      expect(
        original.copyWith(elevatedThreshold: 15).elevatedThreshold,
        15,
      );
      expect(
        original.copyWith(criticalThreshold: 50).criticalThreshold,
        50,
      );
      expect(
        original.copyWith(pushNotifications: false).pushNotifications,
        isFalse,
      );
      expect(
        original.copyWith(emergencyAlerts: false).emergencyAlerts,
        isFalse,
      );
      expect(
        original.copyWith(visionRREnabled: true).visionRREnabled,
        isTrue,
      );
      expect(
        original.copyWith(autoExport: true).autoExport,
        isTrue,
      );
    });
  });

  group('UserSettings fromMap', () {
    test('fromMap creates with all fields', () {
      final settings = UserSettings.fromMap({
        'elevatedThreshold': 20,
        'criticalThreshold': 45,
        'pushNotifications': false,
        'emergencyAlerts': false,
        'visionRREnabled': true,
        'autoExport': true,
      });

      expect(settings.elevatedThreshold, 20);
      expect(settings.criticalThreshold, 45);
      expect(settings.pushNotifications, isFalse);
      expect(settings.emergencyAlerts, isFalse);
      expect(settings.visionRREnabled, isTrue);
      expect(settings.autoExport, isTrue);
    });

    test('fromMap uses defaults for missing fields', () {
      final settings = UserSettings.fromMap({});

      expect(settings.elevatedThreshold, 30);
      expect(settings.criticalThreshold, 40);
      expect(settings.pushNotifications, isTrue);
      expect(settings.emergencyAlerts, isTrue);
      expect(settings.visionRREnabled, isFalse);
      expect(settings.autoExport, isFalse);
    });

    test('fromMap uses defaults for null values', () {
      final settings = UserSettings.fromMap({
        'elevatedThreshold': null,
        'criticalThreshold': null,
        'pushNotifications': null,
        'emergencyAlerts': null,
        'visionRREnabled': null,
        'autoExport': null,
      });

      expect(settings.elevatedThreshold, 30);
      expect(settings.criticalThreshold, 40);
      expect(settings.pushNotifications, isTrue);
      expect(settings.emergencyAlerts, isTrue);
      expect(settings.visionRREnabled, isFalse);
      expect(settings.autoExport, isFalse);
    });
  });

  group('UserSettings toMap', () {
    test('toMap includes all fields', () {
      const settings = UserSettings(
        elevatedThreshold: 25,
        criticalThreshold: 35,
        pushNotifications: false,
        emergencyAlerts: true,
        visionRREnabled: true,
        autoExport: false,
      );

      final map = settings.toMap();

      expect(map['elevatedThreshold'], 25);
      expect(map['criticalThreshold'], 35);
      expect(map['pushNotifications'], isFalse);
      expect(map['emergencyAlerts'], isTrue);
      expect(map['visionRREnabled'], isTrue);
      expect(map['autoExport'], isFalse);
    });

    test('toMap roundtrips with fromMap', () {
      const original = UserSettings(
        elevatedThreshold: 22,
        criticalThreshold: 38,
        pushNotifications: false,
        emergencyAlerts: false,
        visionRREnabled: true,
        autoExport: true,
      );

      final roundtripped = UserSettings.fromMap(original.toMap());

      expect(roundtripped.elevatedThreshold, original.elevatedThreshold);
      expect(roundtripped.criticalThreshold, original.criticalThreshold);
      expect(roundtripped.pushNotifications, original.pushNotifications);
      expect(roundtripped.emergencyAlerts, original.emergencyAlerts);
      expect(roundtripped.visionRREnabled, original.visionRREnabled);
      expect(roundtripped.autoExport, original.autoExport);
    });
  });

  group('UserSettings edge cases', () {
    test('threshold can be zero', () {
      const settings = UserSettings(
        elevatedThreshold: 0,
        criticalThreshold: 0,
      );

      expect(settings.elevatedThreshold, 0);
      expect(settings.criticalThreshold, 0);
    });

    test('threshold can be very large', () {
      const settings = UserSettings(
        elevatedThreshold: 999,
        criticalThreshold: 9999,
      );

      expect(settings.elevatedThreshold, 999);
      expect(settings.criticalThreshold, 9999);
    });
  });
}
