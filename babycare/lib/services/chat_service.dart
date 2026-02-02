import 'dart:async';
import '../models/chat_message.dart';
import '../models/baby_profile.dart';
import '../services/chat_repository.dart';
import '../services/baby_repository.dart';
import '../services/gemini_service.dart';

class ChatService {
  final ChatRepository _chatRepo = ChatRepository();
  final BabyRepository _babyRepo = BabyRepository();
  final GeminiService _geminiService = GeminiService();

  // Replace with actual key from ENV or Config
  // For MVP demo, this should be passed in or secured
  final String _apiKey;

  ChatService(this._apiKey);

  Future<ChatMessage> sendMessage({
    required int babyId,
    required int conversationId,
    required String messageText,
  }) async {
    // 1. Fetch Profile for Context
    final profile = await _babyRepo.getBabyProfile(babyId);
    if (profile == null) throw Exception('Baby profile not found');

    // 2. Save User Message
    final userMsg = ChatMessage(
      conversationId: conversationId,
      senderRole: 'user',
      messageText: messageText,
      babyAgeDays: DateTime.now().difference(profile.dob).inDays,
      createdAt: DateTime.now(),
    );
    await _chatRepo.insertMessage(userMsg);

    // 3. Get Recent History (last 10 messages for context)
    // In a real app, you'd optimize this to not fetch everything
    final history = await _chatRepo.getMessages(conversationId);
    // Take last 10 excluding the one we just added?
    // Actually getMessages returns all.
    // Let's pass the latest history including the new user/AI turn.

    // 4. Call AI
    final aiResponseText = await _geminiService.generateResponse(
      apiKey: _apiKey,
      query: messageText,
      profile: profile,
      history: history
          .where((m) => m.messageText != messageText)
          .toList(), // Exclude current query from history to avoid double prompt
    );

    // 5. Save AI Response
    final aiMsg = ChatMessage(
      conversationId: conversationId,
      senderRole: 'assistant',
      messageText: aiResponseText,
      babyAgeDays: DateTime.now().difference(profile.dob).inDays,
      createdAt: DateTime.now(),
    );

    await _chatRepo.insertMessage(aiMsg);

    return aiMsg;
  }

  Future<List<ChatMessage>> loadMessages(int conversationId) {
    return _chatRepo.getMessages(conversationId);
  }
}
