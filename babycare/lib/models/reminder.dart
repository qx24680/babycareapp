// Enums for reminder configuration

enum ReminderMode {
  basic,
  advanced;

  String get dbValue => name;

  static ReminderMode fromString(String? value) {
    if (value == null) return ReminderMode.basic;
    return ReminderMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReminderMode.basic,
    );
  }
}

enum RepeatType {
  daily,
  weekly;

  String get dbValue => name;

  static RepeatType fromString(String? value) {
    if (value == null) return RepeatType.daily;
    return RepeatType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RepeatType.daily,
    );
  }
}

/// Reminder Model for scheduling activity-based notifications
class Reminder {
  final int? id;
  final String activityType; // Maps to ActivityTypes constants
  final ReminderMode mode; // basic or advanced

  // Basic mode fields
  final int? intervalHours; // For interval-based reminders

  // Advanced mode fields
  final DateTime? scheduledDate; // Scheduled date (null for basic mode)
  final String? scheduledTime; // HH:mm format

  // Repeat configuration
  final bool repeatEnabled;
  final RepeatType? repeatType; // daily or weekly
  final int? repeatInterval; // Every N days (when repeatType is daily)
  final List<int>? weekdays; // 1=Monday, 7=Sunday (when repeatType is weekly)

  // Control flags
  final bool doNotDisturb; // Suppress notifications when true
  final String? groupId; // For grouping related reminders
  final bool isActive; // Whether reminder is enabled

  final DateTime createdAt;
  final DateTime? updatedAt;

  // Optional fields
  final String? title; // Custom reminder title
  final String? message; // Custom reminder message
  final int? babyId; // Link to specific baby profile

  Reminder({
    this.id,
    required this.activityType,
    required this.mode,
    this.intervalHours,
    this.scheduledDate,
    this.scheduledTime,
    this.repeatEnabled = false,
    this.repeatType,
    this.repeatInterval,
    this.weekdays,
    this.doNotDisturb = false,
    this.groupId,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.title,
    this.message,
    this.babyId,
  }) : assert(
          mode == ReminderMode.basic
              ? intervalHours != null
              : scheduledDate != null && scheduledTime != null,
          'Basic mode requires intervalHours, Advanced mode requires scheduledDate and scheduledTime',
        );

  /// Converts Reminder to SQLite-compatible Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity_type': activityType,
      'mode': mode.dbValue,
      'interval_hours': intervalHours,
      'scheduled_date': scheduledDate?.millisecondsSinceEpoch,
      'scheduled_time': scheduledTime,
      'repeat_enabled': repeatEnabled ? 1 : 0,
      'repeat_type': repeatType?.dbValue,
      'repeat_interval': repeatInterval,
      'weekdays': weekdays?.join(','), // Store as comma-separated string
      'do_not_disturb': doNotDisturb ? 1 : 0,
      'group_id': groupId,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'title': title,
      'message': message,
      'baby_id': babyId,
    };
  }

  /// Creates Reminder from SQLite Map
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      activityType: map['activity_type'] as String,
      mode: ReminderMode.fromString(map['mode'] as String?),
      intervalHours: map['interval_hours'] as int?,
      scheduledDate: map['scheduled_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['scheduled_date'] as int)
          : null,
      scheduledTime: map['scheduled_time'] as String?,
      repeatEnabled: (map['repeat_enabled'] as int?) == 1,
      repeatType: map['repeat_type'] != null
          ? RepeatType.fromString(map['repeat_type'] as String)
          : null,
      repeatInterval: map['repeat_interval'] as int?,
      weekdays: map['weekdays'] != null
          ? (map['weekdays'] as String)
              .split(',')
              .map((e) => int.parse(e))
              .toList()
          : null,
      doNotDisturb: (map['do_not_disturb'] as int?) == 1,
      groupId: map['group_id'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
      title: map['title'] as String?,
      message: map['message'] as String?,
      babyId: map['baby_id'] as int?,
    );
  }

  /// Creates a copy with updated fields
  Reminder copyWith({
    int? id,
    String? activityType,
    ReminderMode? mode,
    int? intervalHours,
    DateTime? scheduledDate,
    String? scheduledTime,
    bool? repeatEnabled,
    RepeatType? repeatType,
    int? repeatInterval,
    List<int>? weekdays,
    bool? doNotDisturb,
    String? groupId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? message,
    int? babyId,
  }) {
    return Reminder(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      mode: mode ?? this.mode,
      intervalHours: intervalHours ?? this.intervalHours,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      repeatEnabled: repeatEnabled ?? this.repeatEnabled,
      repeatType: repeatType ?? this.repeatType,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      weekdays: weekdays ?? this.weekdays,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      groupId: groupId ?? this.groupId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      message: message ?? this.message,
      babyId: babyId ?? this.babyId,
    );
  }
}
