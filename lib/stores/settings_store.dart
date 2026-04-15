import 'package:flutter/foundation.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/user_settings.dart';
import 'package:pet_circle/repositories/user_repository.dart';
import 'package:pet_circle/stores/user_store.dart';

final settingsStore = SettingsStore();

/// Callback type for when the push notifications toggle changes.
typedef PushToggleCallback = Future<void> Function(bool enabled);

/// Callback type for when measurement reminder settings change.
typedef MeasurementReminderCallback = Future<void> Function({
  required List<int> days,
  required int hour,
  required int minute,
  required bool enabled,
});

class SettingsStore extends ChangeNotifier {
  /// Optional callback invoked when push notifications are toggled.
  /// Set by main.dart to wire FCM token + reminder lifecycle.
  PushToggleCallback? onPushToggleChanged;

  /// Optional callback invoked when measurement reminder settings change.
  /// Set by main.dart to reschedule local notifications.
  MeasurementReminderCallback? onMeasurementReminderChanged;

  int _elevatedThreshold = 30;
  int _criticalThreshold = 40;
  bool _pushNotifications = true;
  bool _emergencyAlerts = true;
  bool _visionRREnabled = false;
  bool _autoExport = false;
  bool _measurementRemindersEnabled = true;
  int _measurementReminderFrequency = 3;
  List<int> _measurementReminderDays = const [1, 3, 5];
  int _measurementReminderHour = 20;
  int _measurementReminderMinute = 0;
  int _medicationMorningHour = 9;
  int _medicationMorningMinute = 0;
  int _medicationEveningHour = 21;
  int _medicationEveningMinute = 0;

  int get elevatedThreshold => _elevatedThreshold;
  int get criticalThreshold => _criticalThreshold;
  bool get pushNotifications => _pushNotifications;
  bool get emergencyAlerts => _emergencyAlerts;
  bool get visionRREnabled => _visionRREnabled;
  bool get autoExport => _autoExport;
  bool get measurementRemindersEnabled => _measurementRemindersEnabled;
  int get measurementReminderFrequency => _measurementReminderFrequency;
  List<int> get measurementReminderDays =>
      List.unmodifiable(_measurementReminderDays);
  int get measurementReminderHour => _measurementReminderHour;
  int get measurementReminderMinute => _measurementReminderMinute;
  int get medicationMorningHour => _medicationMorningHour;
  int get medicationMorningMinute => _medicationMorningMinute;
  int get medicationEveningHour => _medicationEveningHour;
  int get medicationEveningMinute => _medicationEveningMinute;

  void reset() {
    _elevatedThreshold = 30;
    _criticalThreshold = 40;
    _pushNotifications = true;
    _emergencyAlerts = true;
    _visionRREnabled = false;
    _autoExport = false;
    _measurementRemindersEnabled = true;
    _measurementReminderFrequency = 3;
    _measurementReminderDays = const [1, 3, 5];
    _measurementReminderHour = 20;
    _measurementReminderMinute = 0;
    _medicationMorningHour = 9;
    _medicationMorningMinute = 0;
    _medicationEveningHour = 21;
    _medicationEveningMinute = 0;
    notifyListeners();
  }

  void seedFromAppUser(AppUser appUser) {
    final settings = appUser.settings;
    _elevatedThreshold = settings.elevatedThreshold;
    _criticalThreshold = settings.criticalThreshold;
    _pushNotifications = settings.pushNotifications;
    _emergencyAlerts = settings.emergencyAlerts;
    _visionRREnabled = settings.visionRREnabled;
    _autoExport = settings.autoExport;
    _measurementRemindersEnabled = settings.measurementRemindersEnabled;
    _measurementReminderFrequency = settings.measurementReminderFrequency;
    _measurementReminderDays = List.of(settings.measurementReminderDays);
    _measurementReminderHour = settings.measurementReminderHour;
    _measurementReminderMinute = settings.measurementReminderMinute;
    _medicationMorningHour = settings.medicationMorningHour;
    _medicationMorningMinute = settings.medicationMorningMinute;
    _medicationEveningHour = settings.medicationEveningHour;
    _medicationEveningMinute = settings.medicationEveningMinute;
    notifyListeners();
  }

  Future<void> updateThresholds({int? elevated, int? critical}) async {
    if (elevated != null) _elevatedThreshold = elevated;
    if (critical != null) _criticalThreshold = critical;
    notifyListeners();
    await _persist();
  }

  Future<void> setPushNotifications(bool value) async {
    _pushNotifications = value;
    notifyListeners();
    await _persist();
    await onPushToggleChanged?.call(value);
  }

  Future<void> togglePushNotifications() async {
    await setPushNotifications(!_pushNotifications);
  }

  Future<void> setEmergencyAlerts(bool value) async {
    _emergencyAlerts = value;
    notifyListeners();
    await _persist();
  }

  Future<void> toggleEmergencyAlerts() async {
    await setEmergencyAlerts(!_emergencyAlerts);
  }

  Future<void> setVisionRREnabled(bool value) async {
    _visionRREnabled = value;
    notifyListeners();
    await _persist();
  }

  Future<void> toggleVisionRR() async {
    await setVisionRREnabled(!_visionRREnabled);
  }

  Future<void> setAutoExport(bool value) async {
    _autoExport = value;
    notifyListeners();
    await _persist();
  }

  Future<void> toggleAutoExport() async {
    await setAutoExport(!_autoExport);
  }

  // ── Measurement reminder settings ─────────────────────────────────

  Future<void> setMeasurementRemindersEnabled(bool value) async {
    _measurementRemindersEnabled = value;
    notifyListeners();
    await _persist();
    await _notifyMeasurementReminderChange();
  }

  Future<void> toggleMeasurementReminders() async {
    await setMeasurementRemindersEnabled(!_measurementRemindersEnabled);
  }

  Future<void> setMeasurementReminderFrequency(int frequency) async {
    _measurementReminderFrequency = frequency;
    // Auto-assign days based on frequency.
    switch (frequency) {
      case 2:
        _measurementReminderDays = const [1, 4]; // Mon, Thu
        break;
      case 3:
        _measurementReminderDays = const [1, 3, 5]; // Mon, Wed, Fri
        break;
      case 7:
        _measurementReminderDays = const [1, 2, 3, 4, 5, 6, 7];
        break;
      default:
        _measurementReminderDays = const [1, 3, 5];
    }
    notifyListeners();
    await _persist();
    await _notifyMeasurementReminderChange();
  }

  Future<void> setMeasurementReminderDays(List<int> days) async {
    _measurementReminderDays = List.of(days);
    _measurementReminderFrequency = days.length;
    notifyListeners();
    await _persist();
    await _notifyMeasurementReminderChange();
  }

  Future<void> setMeasurementReminderTime(int hour, int minute) async {
    _measurementReminderHour = hour;
    _measurementReminderMinute = minute;
    notifyListeners();
    await _persist();
    await _notifyMeasurementReminderChange();
  }

  Future<void> _notifyMeasurementReminderChange() async {
    await onMeasurementReminderChanged?.call(
      days: _measurementReminderDays,
      hour: _measurementReminderHour,
      minute: _measurementReminderMinute,
      enabled: _measurementRemindersEnabled && _pushNotifications,
    );
  }

  // ── Medication reminder time settings ─────────────────────────────

  Future<void> setMedicationMorningTime(int hour, int minute) async {
    _medicationMorningHour = hour;
    _medicationMorningMinute = minute;
    notifyListeners();
    await _persist();
  }

  Future<void> setMedicationEveningTime(int hour, int minute) async {
    _medicationEveningHour = hour;
    _medicationEveningMinute = minute;
    notifyListeners();
    await _persist();
  }

  // ── Utilities ─────────────────────────────────────────────────────

  String classifyStatus(int bpm) {
    if (bpm >= _criticalThreshold) return 'Critical';
    if (bpm >= _elevatedThreshold) return 'Elevated';
    return 'Normal';
  }

  UserSettings _snapshot() {
    return UserSettings(
      elevatedThreshold: _elevatedThreshold,
      criticalThreshold: _criticalThreshold,
      pushNotifications: _pushNotifications,
      emergencyAlerts: _emergencyAlerts,
      visionRREnabled: _visionRREnabled,
      autoExport: _autoExport,
      measurementRemindersEnabled: _measurementRemindersEnabled,
      measurementReminderFrequency: _measurementReminderFrequency,
      measurementReminderDays: _measurementReminderDays,
      measurementReminderHour: _measurementReminderHour,
      measurementReminderMinute: _measurementReminderMinute,
      medicationMorningHour: _medicationMorningHour,
      medicationMorningMinute: _medicationMorningMinute,
      medicationEveningHour: _medicationEveningHour,
      medicationEveningMinute: _medicationEveningMinute,
    );
  }

  Future<void> _persist() async {
    if (!kEnableFirebase) return;
    final uid = userStore.currentUserUid;
    if (uid == null || uid.isEmpty) return;
    await userRepository.updateUser(uid, {
      'settings': _snapshot().toMap(),
    });
  }
}
