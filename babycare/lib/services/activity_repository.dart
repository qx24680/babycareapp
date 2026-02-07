import 'package:sqflite/sqflite.dart';
import '../models/activity.dart';
import 'daily_streak_repository.dart';
import 'database_service.dart';

class ActivityRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> insertActivity(Activity activity) async {
    final db = await _dbService.database;
    final id = await db.insert(
      'activity',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update daily streak whenever a log is added
    // We can iterate on this later to decouple, but for now calling the repo directly is fine.
    // However, to avoid circular dependencies if DailyStreakRepo uses ActivityRepo (it doesn't),
    // we should be careful. Here it is safe.
    // Ideally we should inject this dependency, but for now strict instantiation
    await DailyStreakRepository().updateDailyStreak(
      activity.babyId,
      activity.startTime,
    );

    return id;
  }

  // Future-proof alias for insertActivity to match generic content
  Future<int> createActivity(Activity activity) => insertActivity(activity);

  Future<List<Activity>> getDailyLogs(int babyId, DateTime date) async {
    final db = await _dbService.database;

    // Filter by start_time (INTEGER milliseconds)
    // We need start of day and end of day in millis
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).millisecondsSinceEpoch;
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
      999,
    ).millisecondsSinceEpoch;

    final maps = await db.query(
      'activity',
      where: 'baby_id = ? AND start_time >= ? AND start_time <= ?',
      whereArgs: [babyId, startOfDay, endOfDay],
      orderBy: 'start_time DESC',
    );

    return List.generate(maps.length, (i) {
      return Activity.fromMap(maps[i]);
    });
  }

  Future<Activity?> getLastActivity(int babyId, List<String>? types) async {
    final db = await _dbService.database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (types != null && types.isNotEmpty) {
      final placeholders = List.filled(types.length, '?').join(', ');
      whereClause = 'baby_id = ? AND type IN ($placeholders)';
      whereArgs = [babyId, ...types];
    } else {
      whereClause = 'baby_id = ?';
      whereArgs = [babyId];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'activity',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'start_time DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Activity.fromMap(maps.first);
  }

  Future<List<Activity>> getActivitiesForBaby(
    int babyId, {
    List<String>? types,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _dbService.database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (types != null && types.isNotEmpty) {
      final placeholders = List.filled(types.length, '?').join(', ');
      whereClause = 'baby_id = ? AND type IN ($placeholders)';
      whereArgs = [babyId, ...types];
    } else {
      whereClause = 'baby_id = ?';
      whereArgs = [babyId];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'activity',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'start_time DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return Activity.fromMap(maps[i]);
    });
  }

  Future<void> deleteActivity(int id) async {
    final db = await _dbService.database;
    await db.delete('activity', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await _dbService.database;
    return await db.update(
      'activity',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }
}
