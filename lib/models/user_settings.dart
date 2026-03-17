class UserSettings {
  const UserSettings({
    this.elevatedThreshold = 30,
    this.criticalThreshold = 40,
    this.pushNotifications = true,
    this.emergencyAlerts = true,
    this.visionRREnabled = false,
    this.autoExport = false,
  });

  final int elevatedThreshold;
  final int criticalThreshold;
  final bool pushNotifications;
  final bool emergencyAlerts;
  final bool visionRREnabled;
  final bool autoExport;

  factory UserSettings.fromMap(Map<String, dynamic> data) {
    return UserSettings(
      elevatedThreshold: data['elevatedThreshold'] ?? 30,
      criticalThreshold: data['criticalThreshold'] ?? 40,
      pushNotifications: data['pushNotifications'] ?? true,
      emergencyAlerts: data['emergencyAlerts'] ?? true,
      visionRREnabled: data['visionRREnabled'] ?? false,
      autoExport: data['autoExport'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elevatedThreshold': elevatedThreshold,
      'criticalThreshold': criticalThreshold,
      'pushNotifications': pushNotifications,
      'emergencyAlerts': emergencyAlerts,
      'visionRREnabled': visionRREnabled,
      'autoExport': autoExport,
    };
  }

  UserSettings copyWith({
    int? elevatedThreshold,
    int? criticalThreshold,
    bool? pushNotifications,
    bool? emergencyAlerts,
    bool? visionRREnabled,
    bool? autoExport,
  }) {
    return UserSettings(
      elevatedThreshold: elevatedThreshold ?? this.elevatedThreshold,
      criticalThreshold: criticalThreshold ?? this.criticalThreshold,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
      visionRREnabled: visionRREnabled ?? this.visionRREnabled,
      autoExport: autoExport ?? this.autoExport,
    );
  }
}
