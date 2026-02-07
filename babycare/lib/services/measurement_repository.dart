import '../models/measurement.dart';
import 'database_service.dart';

class MeasurementRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> addMeasurement(Measurement measurement) async {
    final db = await _dbService.database;
    return await db.insert('measurement', measurement.toMap());
  }

  Future<List<Measurement>> getMeasurements(int babyId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'measurement',
      where: 'baby_id = ?',
      whereArgs: [babyId],
      orderBy: 'time DESC',
    );
    return List.generate(maps.length, (i) => Measurement.fromMap(maps[i]));
  }

  Future<Measurement?> getLatestMeasurement(int babyId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'measurement',
      where: 'baby_id = ?',
      whereArgs: [babyId],
      orderBy: 'time DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Measurement.fromMap(maps.first);
    }
    return null;
  }

  Future<void> deleteMeasurement(int id) async {
    final db = await _dbService.database;
    await db.delete('measurement', where: 'id = ?', whereArgs: [id]);
  }
}
