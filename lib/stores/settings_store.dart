import 'package:flutter/foundation.dart';
import 'package:pet_circle/config/app_config.dart' show kEnableFirebase;
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/user_settings.dart';
import 'package:pet_circle/repositories/user_repository.dart';
import 'package:pet_circle/stores/user_store.dart';

final settingsStore = SettingsStore();

class SettingsStore extends ChangeNotifier {
  int _elevatedThreshold = 30;
  int _criticalThreshold = 40;
  bool _pushNotifications = true;
  bool _emergencyAlerts = true;
  bool _visionRREnabled = false;
  bool _autoExport = false;

  int get elevatedThreshold => _elevatedThreshold;
  int get criticalThreshold => _criticalThreshold;
  bool get pushNotifications => _pushNotifications;
  bool get emergencyAlerts => _emergencyAlerts;
  bool get visionRREnabled => _visionRREnabled;
  bool get autoExport => _autoExport;

  void reset() {
    _elevatedThreshold = 30;
    _criticalThreshold = 40;
    _pushNotifications = true;
    _emergencyAlerts = true;
    _visionRREnabled = false;
    _autoExport = false;
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
