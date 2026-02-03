import 'dart:convert';

class ActivityLog {
  final int? id;
  final int babyId;
  final int? userId; // Who logged this activity
  final String activityType;
  final DateTime startTime; // Used for singular events too
  final DateTime? endTime; // Optional for duration-based events
  final String? details; // JSON String

  ActivityLog({
    this.id,
    required this.babyId,
    this.userId,
    required this.activityType,
    required this.startTime,
    this.endTime,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baby_id': babyId,
      'user_id': userId,
      'activity_type': activityType,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'details': details, // Stored as TEXT (JSON)
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'] as int?,
      babyId: map['baby_id'] as int,
      userId: map['user_id'] as int?,
      activityType: map['activity_type'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'] as String)
          : null,
      details: map['details'] as String?,
    );
  }

  // Helper to parse details if needed, though raw string is primary for storage
  Map<String, dynamic>? get detailsMap {
    if (details == null) return null;
    try {
      return jsonDecode(details!) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
