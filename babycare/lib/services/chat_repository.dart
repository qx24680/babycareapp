import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import 'database_service.dart';

class ChatRepository {
  final DatabaseService _dbService = DatabaseService();

  // --- Conversations ---

  Future<ChatConversation> createOrFetchConversation(int babyId) async {
    final db = await _dbService.database;

    // Check for active (non-archived) conversation first
    final List<Map<String, dynamic>> existing = await db.query(
      'chat_conversation',
      where: 'baby_id = ? AND archived = 0',
      whereArgs: [babyId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return ChatConversation.fromMap(existing.first);
    }

    // Create new if none exists
    final newConversation = ChatConversation(
      babyId: babyId,
      createdAt: DateTime.now(),
    );

    final id = await db.insert('chat_conversation', newConversation.toMap());

    // Return object with new ID
    return ChatConversation(
      id: id,
      babyId: babyId,
      createdAt: newConversation.createdAt,
    );
  }

  Future<void> archiveConversation(int conversationId) async {
    final db = await _dbService.database;
    await db.update(
      'chat_conversation',
      {'archived': 1},
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  // --- Messages ---

  Future<int> insertMessage(ChatMessage message) async {
    final db = await _dbService.database;
    return await db.insert('chat_message', message.toMap());
  }

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'chat_message',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC', // Oldest first for chat history
    );

    return List.generate(maps.length, (i) {
      return ChatMessage.fromMap(maps[i]);
    });
  }
}
