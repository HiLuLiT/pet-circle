class UserSettings {
  const UserSettings({
    this.elevatedThreshold = 30,
    this.criticalThreshold = 40,
    this.pushNotifications = true,
    this.emergencyAlerts = true,
    this.visionRREnabled = false,
    this.autoExport = false,
    this.measurementRemindersEnabled = true,
    this.measurementReminderFrequency = 3,
    this.measurementReminderDays = const [1, 3, 5],
    this.measurementReminderHour = 20,
    this.measurementReminderMinute = 0,
    this.medicationMorningHour = 9,
    this.medicationMorningMinute = 0,
    this.medicationEveningHour = 21,
    this.medicationEveningMinute = 0,
  });

  final int elevatedThreshold;
  final int criticalThreshold;
  final bool pushNotifications;
  final bool emergencyAlerts;
  final bool visionRREnabled;
  final bool autoExport;

  /// Whether measurement reminders are enabled.
  final bool measurementRemindersEnabled;

  /// Target measurements per week (2, 3, or 7 for daily).
  final int measurementReminderFrequency;

  /// Days of week to remind (1=Mon..7=Sun).
  final List<int> measurementReminderDays;

  /// Hour (0–23) for measurement reminders.
  final int measurementReminderHour;

  /// Minute (0–59) for measurement reminders.
  final int measurementReminderMinute;

  /// Hour (0–23) for morning medication reminders.
  final int medicationMorningHour;

  /// Minute (0–59) for morning medication reminders.
  final int medicationMorningMinute;

  /// Hour (0–23) for evening medication reminders.
  final int medicationEveningHour;

  /// Minute (0–59) for evening medication reminders.
  final int medicationEveningMinute;

  factory UserSettings.fromMap(Map<String, dynamic> data) {
    return UserSettings(
      elevatedThreshold: data['elevatedThreshold'] ?? 30,
      criticalThreshold: data['criticalThreshold'] ?? 40,
      pushNotifications: data['pushNotifications'] ?? true,
      emergencyAlerts: data['emergencyAlerts'] ?? true,
      visionRREnabled: data['visionRREnabled'] ?? false,
      autoExport: data['autoExport'] ?? false,
      measurementRemindersEnabled:
          data['measurementRemindersEnabled'] ?? true,
      measurementReminderFrequency:
          data['measurementReminderFrequency'] ?? 3,
      measurementReminderDays:
          (data['measurementReminderDays'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toList() ??
              const [1, 3, 5],
      measurementReminderHour: data['measurementReminderHour'] ?? 20,
      measurementReminderMinute: data['measurementReminderMinute'] ?? 0,
      medicationMorningHour: data['medicationMorningHour'] ?? 9,
      medicationMorningMinute: data['medicationMorningMinute'] ?? 0,
      medicationEveningHour: data['medicationEveningHour'] ?? 21,
      medicationEveningMinute: data['medicationEveningMinute'] ?? 0,
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
      'measurementRemindersEnabled': measurementRemindersEnabled,
      'measurementReminderFrequency': measurementReminderFrequency,
      'measurementReminderDays': measurementReminderDays,
      'measurementReminderHour': measurementReminderHour,
      'measurementReminderMinute': measurementReminderMinute,
      'medicationMorningHour': medicationMorningHour,
      'medicationMorningMinute': medicationMorningMinute,
      'medicationEveningHour': medicationEveningHour,
      'medicationEveningMinute': medicationEveningMinute,
    };
  }

  UserSettings copyWith({
    int? elevatedThreshold,
    int? criticalThreshold,
    bool? pushNotifications,
    bool? emergencyAlerts,
    bool? visionRREnabled,
    bool? autoExport,
    bool? measurementRemindersEnabled,
    int? measurementReminderFrequency,
    List<int>? measurementReminderDays,
    int? measurementReminderHour,
    int? measurementReminderMinute,
    int? medicationMorningHour,
    int? medicationMorningMinute,
    int? medicationEveningHour,
    int? medicationEveningMinute,
  }) {
    return UserSettings(
      elevatedThreshold: elevatedThreshold ?? this.elevatedThreshold,
      criticalThreshold: criticalThreshold ?? this.criticalThreshold,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
      visionRREnabled: visionRREnabled ?? this.visionRREnabled,
      autoExport: autoExport ?? this.autoExport,
      measurementRemindersEnabled:
          measurementRemindersEnabled ?? this.measurementRemindersEnabled,
      measurementReminderFrequency:
          measurementReminderFrequency ?? this.measurementReminderFrequency,
      measurementReminderDays:
          measurementReminderDays ?? this.measurementReminderDays,
      measurementReminderHour:
          measurementReminderHour ?? this.measurementReminderHour,
      measurementReminderMinute:
          measurementReminderMinute ?? this.measurementReminderMinute,
      medicationMorningHour:
          medicationMorningHour ?? this.medicationMorningHour,
      medicationMorningMinute:
          medicationMorningMinute ?? this.medicationMorningMinute,
      medicationEveningHour:
          medicationEveningHour ?? this.medicationEveningHour,
      medicationEveningMinute:
          medicationEveningMinute ?? this.medicationEveningMinute,
    );
  }
}
