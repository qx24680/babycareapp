import '../models/chat_session.dart';
import '../models/chat_message.dart';
import 'database_service.dart';

class ChatRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> createSession(ChatSession session) async {
    final db = await _dbService.database;
    return await db.insert('chat_session', session.toMap());
  }

  Future<List<ChatSession>> getSessions() async {
    final db = await _dbService.database;
    final maps = await db.query('chat_session', orderBy: 'updated_at DESC');
    return List.generate(maps.length, (i) => ChatSession.fromMap(maps[i]));
  }

  Future<int> addMessage(ChatMessage message) async {
    final db = await _dbService.database;
    final id = await db.insert('chat_message', message.toMap());

    // Update session updated_at
    await db.update(
      'chat_session',
      {'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [message.sessionId],
    );

    return id;
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

  Future<void> deleteSession(int sessionId) async {
    final db = await _dbService.database;
    await db.delete('chat_session', where: 'id = ?', whereArgs: [sessionId]);
  }
}
