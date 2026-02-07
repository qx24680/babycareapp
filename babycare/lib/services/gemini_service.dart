import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;

  void initialize() {
    if (_model != null) return;

    try {
      final firebaseAI = FirebaseAI.vertexAI();
      _model = firebaseAI.generativeModel(
        model: 'gemini-2.5-flash-lite',
        generationConfig: GenerationConfig(
          maxOutputTokens: 2048,
          temperature: 0.7,
        ),
      );
    } catch (e) {
      debugPrint('[GeminiService] Initialization error: $e');
    }
  }

  Future<String> sendMessage(
    String message, {
    List<ChatMessage>? history,
  }) async {
    if (_model == null) initialize();

    try {
      final chatHistory =
          history?.map((msg) {
            final role = msg.isUser ? 'user' : 'model';
            return Content(role, [TextPart(msg.message ?? '')]);
          }).toList() ??
          [];

      // If history exists, use startChat, otherwise simple generation (though for chat, startChat is better)
      // Actually, for a stateless service request where we pass full history, we can just construct a chat.
      // However, startChat maintains local history state.
      // Since we persist detailed history in DB, we should probably reconstruct the chat history for context.

      final chat = _model!.startChat(history: chatHistory);
      final response = await chat.sendMessage(Content.text(message));

      return response.text ??
          'I generally understand, but I cannot answer that right now.';
    } catch (e) {
      debugPrint('[GeminiService] Error sending message: $e');
      return 'Sorry, I am having trouble connecting to the AI. Please try again later.';
    }
  }
}
