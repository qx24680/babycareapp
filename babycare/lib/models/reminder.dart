class Reminder {
  final int? id;
  final int babyId;
  final String activityType;
  final DateTime reminderTime;
  final String repeatRule; // none, daily, custom (simplified string for MVP)
  final bool isEnabled;

  Reminder({
    this.id,
    required this.babyId,
    required this.activityType,
    required this.reminderTime,
    this.repeatRule = 'none',
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baby_id': babyId,
      'activity_type': activityType,
      'reminder_time': reminderTime.toIso8601String(),
      'repeat_rule': repeatRule,
      'is_enabled': isEnabled ? 1 : 0, // SQLite boolean
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      babyId: map['baby_id'] as int,
      activityType: map['activity_type'] as String,
      reminderTime: DateTime.parse(map['reminder_time'] as String),
      repeatRule: map['repeat_rule'] as String,
      isEnabled: (map['is_enabled'] as int) == 1,
    );
  }
}
