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

  group('UserSettings notification preferences', () {
    test('creates with default notification preferences', () {
      const settings = UserSettings();

      expect(settings.measurementRemindersEnabled, isTrue);
      expect(settings.measurementReminderFrequency, 3);
      expect(settings.measurementReminderDays, [1, 3, 5]);
      expect(settings.measurementReminderHour, 20);
      expect(settings.measurementReminderMinute, 0);
      expect(settings.medicationMorningHour, 9);
      expect(settings.medicationMorningMinute, 0);
      expect(settings.medicationEveningHour, 21);
      expect(settings.medicationEveningMinute, 0);
    });

    test('creates with custom notification preferences', () {
      const settings = UserSettings(
        measurementRemindersEnabled: false,
        measurementReminderFrequency: 7,
        measurementReminderDays: [1, 2, 3, 4, 5, 6, 7],
        measurementReminderHour: 8,
        measurementReminderMinute: 30,
        medicationMorningHour: 7,
        medicationMorningMinute: 15,
        medicationEveningHour: 19,
        medicationEveningMinute: 45,
      );

      expect(settings.measurementRemindersEnabled, isFalse);
      expect(settings.measurementReminderFrequency, 7);
      expect(settings.measurementReminderDays, [1, 2, 3, 4, 5, 6, 7]);
      expect(settings.measurementReminderHour, 8);
      expect(settings.measurementReminderMinute, 30);
      expect(settings.medicationMorningHour, 7);
      expect(settings.medicationMorningMinute, 15);
      expect(settings.medicationEveningHour, 19);
      expect(settings.medicationEveningMinute, 45);
    });

    test('fromMap reads notification preferences', () {
      final settings = UserSettings.fromMap({
        'measurementRemindersEnabled': false,
        'measurementReminderFrequency': 2,
        'measurementReminderDays': [1, 4],
        'measurementReminderHour': 18,
        'measurementReminderMinute': 15,
        'medicationMorningHour': 8,
        'medicationMorningMinute': 30,
        'medicationEveningHour': 20,
        'medicationEveningMinute': 0,
      });

      expect(settings.measurementRemindersEnabled, isFalse);
      expect(settings.measurementReminderFrequency, 2);
      expect(settings.measurementReminderDays, [1, 4]);
      expect(settings.measurementReminderHour, 18);
      expect(settings.measurementReminderMinute, 15);
      expect(settings.medicationMorningHour, 8);
      expect(settings.medicationMorningMinute, 30);
      expect(settings.medicationEveningHour, 20);
      expect(settings.medicationEveningMinute, 0);
    });

    test('fromMap uses defaults for missing notification preferences', () {
      final settings = UserSettings.fromMap({});

      expect(settings.measurementRemindersEnabled, isTrue);
      expect(settings.measurementReminderFrequency, 3);
      expect(settings.measurementReminderDays, [1, 3, 5]);
      expect(settings.measurementReminderHour, 20);
      expect(settings.measurementReminderMinute, 0);
      expect(settings.medicationMorningHour, 9);
      expect(settings.medicationMorningMinute, 0);
      expect(settings.medicationEveningHour, 21);
      expect(settings.medicationEveningMinute, 0);
    });

    test('toMap includes notification preferences', () {
      const settings = UserSettings(
        measurementRemindersEnabled: false,
        measurementReminderFrequency: 2,
        measurementReminderDays: [2, 5],
        measurementReminderHour: 19,
        measurementReminderMinute: 30,
      );
      final map = settings.toMap();

      expect(map['measurementRemindersEnabled'], isFalse);
      expect(map['measurementReminderFrequency'], 2);
      expect(map['measurementReminderDays'], [2, 5]);
      expect(map['measurementReminderHour'], 19);
      expect(map['measurementReminderMinute'], 30);
    });

    test('notification preferences roundtrip through toMap/fromMap', () {
      const original = UserSettings(
        measurementRemindersEnabled: false,
        measurementReminderFrequency: 7,
        measurementReminderDays: [1, 2, 3, 4, 5, 6, 7],
        measurementReminderHour: 6,
        measurementReminderMinute: 45,
        medicationMorningHour: 7,
        medicationMorningMinute: 0,
        medicationEveningHour: 22,
        medicationEveningMinute: 30,
      );

      final roundtripped = UserSettings.fromMap(original.toMap());

      expect(roundtripped.measurementRemindersEnabled,
          original.measurementRemindersEnabled);
      expect(roundtripped.measurementReminderFrequency,
          original.measurementReminderFrequency);
      expect(roundtripped.measurementReminderDays,
          original.measurementReminderDays);
      expect(roundtripped.measurementReminderHour,
          original.measurementReminderHour);
      expect(roundtripped.measurementReminderMinute,
          original.measurementReminderMinute);
      expect(roundtripped.medicationMorningHour,
          original.medicationMorningHour);
      expect(roundtripped.medicationMorningMinute,
          original.medicationMorningMinute);
      expect(roundtripped.medicationEveningHour,
          original.medicationEveningHour);
      expect(roundtripped.medicationEveningMinute,
          original.medicationEveningMinute);
    });

    test('copyWith updates notification preferences', () {
      const original = UserSettings();
      final updated = original.copyWith(
        measurementRemindersEnabled: false,
        measurementReminderFrequency: 2,
        measurementReminderDays: [2, 5],
        measurementReminderHour: 19,
        medicationMorningHour: 7,
        medicationEveningHour: 22,
      );

      expect(updated.measurementRemindersEnabled, isFalse);
      expect(updated.measurementReminderFrequency, 2);
      expect(updated.measurementReminderDays, [2, 5]);
      expect(updated.measurementReminderHour, 19);
      expect(updated.medicationMorningHour, 7);
      expect(updated.medicationEveningHour, 22);
      // Original unchanged
      expect(original.measurementRemindersEnabled, isTrue);
      expect(original.measurementReminderFrequency, 3);
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
