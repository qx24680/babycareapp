class DailyStreak {
  final int? id;
  final int babyId;
  final DateTime date; // Store as date only (00:00:00)
  final int logCount;

  DailyStreak({
    this.id,
    required this.babyId,
    required this.date,
    this.logCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baby_id': babyId,
      'date': date.toIso8601String().substring(0, 10), // Store YYYY-MM-DD
      'log_count': logCount,
    };
  }

  factory DailyStreak.fromMap(Map<String, dynamic> map) {
    return DailyStreak(
      id: map['id'] as int?,
      babyId: map['baby_id'] as int,
      date: DateTime.parse(map['date'] as String),
      logCount: map['log_count'] as int,
    );
  }
}
