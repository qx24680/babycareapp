import '../models/baby_profile.dart';
import '../models/guardian.dart';
import '../models/activity_log.dart';
import '../models/reminder.dart';
import '../models/daily_streak.dart';
import 'database_service.dart';

class BabyRepository {
  final DatabaseService _dbService = DatabaseService();

  // --- Baby Profile & Guardian ---

  Future<int> saveBabyProfile(BabyProfile profile) async {
    final db = await _dbService.database;
    if (profile.id != null) {
      return await db.update(
        'baby_profile',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [profile.id],
      );
    } else {
      return await db.insert('baby_profile', profile.toMap());
    }
  }

  Future<BabyProfile?> getBabyProfile(int id) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'baby_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return BabyProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> saveGuardian(Guardian guardian) async {
    final db = await _dbService.database;
    if (guardian.id != null) {
      return await db.update(
        'guardian',
        guardian.toMap(),
        where: 'id = ?',
        whereArgs: [guardian.id],
      );
    } else {
      return await db.insert('guardian', guardian.toMap());
    }
  }

  // --- Activity Logs ---

  Future<int> insertActivityLog(ActivityLog log) async {
    final db = await _dbService.database;
    final id = await db.insert('activity_log', log.toMap());

    // Update daily streak whenever a log is added
    await updateDailyStreak(log.babyId, log.startTime);

    return id;
  }

  Future<List<ActivityLog>> getDailyLogs(int babyId, DateTime date) async {
    final db = await _dbService.database;

    // Filter by start_time string matching YYYY-MM-DD
    // SQLite string comparison: start_time LIKE '2023-10-27%'
    String dateStr = date.toIso8601String().substring(0, 10);

    final maps = await db.query(
      'activity_log',
      where: 'baby_id = ? AND start_time LIKE ?',
      whereArgs: [babyId, '$dateStr%'],
      orderBy: 'start_time DESC',
    );

    return List.generate(maps.length, (i) {
      return ActivityLog.fromMap(maps[i]);
    });
  }

  // --- Reminders ---

  Future<int> createReminder(Reminder reminder) async {
    final db = await _dbService.database;
    return await db.insert('reminder', reminder.toMap());
  }

  Future<List<Reminder>> getUpcomingReminders(int babyId) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    // Simplified logic: get enabled reminders strictly in the future
    // Complex repeat logic would happen in business layer (UseCase), fetching all reminders
    final maps = await db.query(
      'reminder',
      where: 'baby_id = ? AND is_enabled = 1 AND reminder_time > ?',
      whereArgs: [babyId, now],
      orderBy: 'reminder_time ASC',
    );

    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  // --- Daily Streak ---

  Future<void> updateDailyStreak(int babyId, DateTime activityDate) async {
    final db = await _dbService.database;
    String dateStr = activityDate.toIso8601String().substring(0, 10);

    // Check if streak entry exists
    final List<Map<String, dynamic>> existing = await db.query(
      'daily_streak',
      where: 'baby_id = ? AND date = ?',
      whereArgs: [babyId, dateStr],
    );

    if (existing.isNotEmpty) {
      int currentCount = existing.first['log_count'] as int;
      await db.update(
        'daily_streak',
        {'log_count': currentCount + 1},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      await db.insert('daily_streak', {
        'baby_id': babyId,
        'date': dateStr,
        'log_count': 1,
      });
    }
  }

  Future<DailyStreak?> getStreakForDate(int babyId, DateTime date) async {
    final db = await _dbService.database;
    String dateStr = date.toIso8601String().substring(0, 10);

    final maps = await db.query(
      'daily_streak',
      where: 'baby_id = ? AND date = ?',
      whereArgs: [babyId, dateStr],
    );

    if (maps.isNotEmpty) {
      return DailyStreak.fromMap(maps.first);
    }
    return null;
  }
}
