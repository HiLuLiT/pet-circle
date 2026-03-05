import 'package:flutter/foundation.dart';

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

  void updateThresholds({int? elevated, int? critical}) {
    if (elevated != null) _elevatedThreshold = elevated;
    if (critical != null) _criticalThreshold = critical;
    notifyListeners();
  }

  void togglePushNotifications() {
    _pushNotifications = !_pushNotifications;
    notifyListeners();
  }

  void toggleEmergencyAlerts() {
    _emergencyAlerts = !_emergencyAlerts;
    notifyListeners();
  }

  void toggleVisionRR() {
    _visionRREnabled = !_visionRREnabled;
    notifyListeners();
  }

  void toggleAutoExport() {
    _autoExport = !_autoExport;
    notifyListeners();
  }

  String classifyStatus(int bpm) {
    if (bpm >= _criticalThreshold) return 'Critical';
    if (bpm >= _elevatedThreshold) return 'Elevated';
    return 'Normal';
  }
}
