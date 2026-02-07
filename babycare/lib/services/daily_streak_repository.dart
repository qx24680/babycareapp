import '../models/daily_streak.dart';
import 'database_service.dart';

class DailyStreakRepository {
  final DatabaseService _dbService = DatabaseService();

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
      DailyStreak currentStreak = DailyStreak.fromMap(existing.first);
      await db.update(
        'daily_streak',
        currentStreak.copyWith(logCount: currentStreak.logCount + 1).toMap(),
        where: 'id = ?',
        whereArgs: [currentStreak.id],
      );
    } else {
      await db.insert(
        'daily_streak',
        DailyStreak(babyId: babyId, date: activityDate, logCount: 1).toMap(),
      );
    }
  }

  Future<int> getStreakForDate(int babyId, DateTime date) async {
    final db = await _dbService.database;
    String dateStr = date.toIso8601String().substring(0, 10);

    final List<Map<String, dynamic>> maps = await db.query(
      'daily_streak',
      where: 'baby_id = ? AND date = ?',
      whereArgs: [babyId, dateStr],
    );

    if (maps.isNotEmpty) {
      return DailyStreak.fromMap(maps.first).logCount;
    }
    return 0;
  }
}
