import '../models/baby_profile.dart';

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
}
