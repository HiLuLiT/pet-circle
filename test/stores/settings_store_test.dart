import 'package:flutter_test/flutter_test.dart';
import 'package:pet_circle/stores/settings_store.dart';

void main() {
  late SettingsStore store;

  setUp(() {
    store = SettingsStore();
  });

  group('SettingsStore defaults', () {
    test('default elevated threshold is 30', () {
      expect(store.elevatedThreshold, 30);
    });

    test('default critical threshold is 40', () {
      expect(store.criticalThreshold, 40);
    });

    test('default pushNotifications is true', () {
      expect(store.pushNotifications, isTrue);
    });

    test('default emergencyAlerts is true', () {
      expect(store.emergencyAlerts, isTrue);
    });

    test('default visionRREnabled is false', () {
      expect(store.visionRREnabled, isFalse);
    });

    test('default autoExport is false', () {
      expect(store.autoExport, isFalse);
    });
  });

  group('SettingsStore classifyStatus', () {
    test('returns Normal for bpm below elevated threshold', () {
      expect(store.classifyStatus(20), 'Normal');
      expect(store.classifyStatus(29), 'Normal');
    });

    test('returns Elevated for bpm at elevated threshold', () {
      expect(store.classifyStatus(30), 'Elevated');
    });

    test('returns Elevated for bpm between elevated and critical', () {
      expect(store.classifyStatus(35), 'Elevated');
      expect(store.classifyStatus(39), 'Elevated');
    });

    test('returns Critical for bpm at critical threshold', () {
      expect(store.classifyStatus(40), 'Critical');
    });

    test('returns Critical for bpm above critical threshold', () {
      expect(store.classifyStatus(50), 'Critical');
      expect(store.classifyStatus(100), 'Critical');
    });

    test('returns Normal for zero bpm', () {
      expect(store.classifyStatus(0), 'Normal');
    });
  });

  group('SettingsStore updateThresholds', () {
    test('updating elevated threshold works', () async {
      await store.updateThresholds(elevated: 25);
      expect(store.elevatedThreshold, 25);
    });

    test('updating critical threshold works', () async {
      await store.updateThresholds(critical: 45);
      expect(store.criticalThreshold, 45);
    });

    test('updating both thresholds works', () async {
      await store.updateThresholds(elevated: 20, critical: 35);
      expect(store.elevatedThreshold, 20);
      expect(store.criticalThreshold, 35);
    });

    test('classifyStatus reflects updated thresholds', () async {
      await store.updateThresholds(elevated: 20, critical: 35);

      expect(store.classifyStatus(15), 'Normal');
      expect(store.classifyStatus(20), 'Elevated');
      expect(store.classifyStatus(30), 'Elevated');
      expect(store.classifyStatus(35), 'Critical');
    });
  });

  group('SettingsStore toggles', () {
    test('setPushNotifications updates value', () async {
      await store.setPushNotifications(false);
      expect(store.pushNotifications, isFalse);

      await store.setPushNotifications(true);
      expect(store.pushNotifications, isTrue);
    });

    test('setEmergencyAlerts updates value', () async {
      await store.setEmergencyAlerts(false);
      expect(store.emergencyAlerts, isFalse);
    });

    test('setVisionRREnabled updates value', () async {
      await store.setVisionRREnabled(true);
      expect(store.visionRREnabled, isTrue);
    });

    test('setAutoExport updates value', () async {
      await store.setAutoExport(true);
      expect(store.autoExport, isTrue);
    });
  });

  group('SettingsStore reset', () {
    test('reset restores all defaults', () async {
      await store.updateThresholds(elevated: 10, critical: 20);
      await store.setPushNotifications(false);
      await store.setVisionRREnabled(true);

      store.reset();

      expect(store.elevatedThreshold, 30);
      expect(store.criticalThreshold, 40);
      expect(store.pushNotifications, isTrue);
      expect(store.visionRREnabled, isFalse);
    });
  });

  group('SettingsStore notifyListeners', () {
    test('notifyListeners called on updateThresholds', () async {
      int callCount = 0;
      store.addListener(() => callCount++);

      await store.updateThresholds(elevated: 25);
      expect(callCount, greaterThanOrEqualTo(1));
    });

    test('notifyListeners called on reset', () {
      int callCount = 0;
      store.addListener(() => callCount++);

      store.reset();
      expect(callCount, 1);
    });
  });
}
