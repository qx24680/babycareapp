import 'package:sqflite/sqflite.dart';
import '../models/reminder.dart';
import 'database_service.dart';

/// Repository for managing reminders in local database
class ReminderRepository {
  final DatabaseService _dbService = DatabaseService();

  /// Creates a new reminder
  Future<int> createReminder(Reminder reminder) async {
    final db = await _dbService.database;
    return await db.insert(
      'reminder',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing reminder
  Future<int> updateReminder(Reminder reminder) async {
    final db = await _dbService.database;
    return await db.update(
      'reminder',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  /// Deletes a reminder by ID
  Future<int> deleteReminder(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'reminder',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Fetches all reminders
  Future<List<Reminder>> fetchReminders({
    int? babyId,
    String? activityType,
    bool? isActive,
  }) async {
    final db = await _dbService.database;

    // Build dynamic where clause
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (babyId != null) {
      whereClauses.add('baby_id = ?');
      whereArgs.add(babyId);
    }

    if (activityType != null) {
      whereClauses.add('activity_type = ?');
      whereArgs.add(activityType);
    }

    if (isActive != null) {
      whereClauses.add('is_active = ?');
      whereArgs.add(isActive ? 1 : 0);
    }

    final String? whereClause =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'reminder',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  /// Fetches a single reminder by ID
  Future<Reminder?> getReminderById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminder',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Reminder.fromMap(maps.first);
  }

  /// Toggles reminder active state
  Future<int> toggleReminderState(int id, bool isActive) async {
    final db = await _dbService.database;
    return await db.update(
      'reminder',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggles Do Not Disturb state for a reminder
  Future<int> toggleDoNotDisturb(int id, bool doNotDisturb) async {
    final db = await _dbService.database;
    return await db.update(
      'reminder',
      {
        'do_not_disturb': doNotDisturb ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Fetches all active reminders (for scheduling purposes)
  Future<List<Reminder>> getActiveReminders() async {
    return fetchReminders(isActive: true);
  }

  /// Fetches reminders by group ID
  Future<List<Reminder>> getRemindersByGroup(String groupId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminder',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  /// Deletes all reminders for a specific baby (cascade handled by FK)
  Future<int> deleteRemindersByBaby(int babyId) async {
    final db = await _dbService.database;
    return await db.delete(
      'reminder',
      where: 'baby_id = ?',
      whereArgs: [babyId],
    );
  }

  /// Counts total reminders
  Future<int> countReminders({bool? isActive}) async {
    final db = await _dbService.database;

    final String? where = isActive != null ? 'is_active = ?' : null;
    final List<dynamic>? whereArgs = isActive != null ? [isActive ? 1 : 0] : null;

    final result = await db.query(
      'reminder',
      columns: ['COUNT(*) as count'],
      where: where,
      whereArgs: whereArgs,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
