class NotificationSettings {
  final int? id;
  final String activityType; // e.g., 'feeding_breast', or 'GLOBAL_QUIET_HOURS'
  final bool isEnabled;
  final String? quietHoursStart; // HH:mm format
  final String? quietHoursEnd; // HH:mm format

  NotificationSettings({
    this.id,
    required this.activityType,
    this.isEnabled = true,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity_type': activityType,
      'is_enabled': isEnabled ? 1 : 0,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      id: map['id'] as int?,
      activityType: map['activity_type'] as String,
      isEnabled: (map['is_enabled'] as int) == 1,
      quietHoursStart: map['quiet_hours_start'] as String?,
      quietHoursEnd: map['quiet_hours_end'] as String?,
    );
  }
}
