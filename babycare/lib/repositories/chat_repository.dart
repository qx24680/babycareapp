import '../services/database_service.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> createSession(String title) async {
    final db = await _dbService.database;
    final now = DateTime.now();
    return await db.insert('chat_session', {
      'title': title,
      'created_at': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
    });
  }

  Future<List<ChatSession>> getSessions() async {
    final db = await _dbService.database;
    final maps = await db.query('chat_session', orderBy: 'updated_at DESC');
    return List.generate(maps.length, (i) => ChatSession.fromMap(maps[i]));
  }

  Future<void> updateSessionTitle(int sessionId, String title) async {
    final db = await _dbService.database;
    await db.update(
      'chat_session',
      {'title': title, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> deleteSession(int sessionId) async {
    final db = await _dbService.database;
    await db.delete('chat_session', where: 'id = ?', whereArgs: [sessionId]);
  }

  Future<void> saveMessage(int sessionId, String message, bool isUser) async {
    final db = await _dbService.database;
    final now = DateTime.now();

    // Save message
    await db.insert('chat_message', {
      'session_id': sessionId,
      'is_user': isUser ? 1 : 0,
      'message': message,
      'timestamp': now.millisecondsSinceEpoch,
    });

    // Update session timestamp
    await db.update(
      'chat_session',
      {'updated_at': now.millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<List<ChatMessage>> getMessages(int sessionId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'chat_message',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => ChatMessage.fromMap(maps[i]));
  }
}
