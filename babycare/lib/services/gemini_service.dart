import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/baby_profile.dart';
import '../models/chat_message.dart';

class GeminiService {
  Future<String> generateResponse({
    required String apiKey,
    required String query,
    required BabyProfile profile,
    List<ChatMessage> history = const [],
  }) async {
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

    // Calculate generic age string
    final ageDuration = DateTime.now().difference(profile.dob);
    final ageDays = ageDuration.inDays;
    final ageStr = ageDays < 30 ? '$ageDays days' : '${ageDays ~/ 30} months';

    // Construct Context System Prompt
    final systemPrompt =
        '''
You are a supportive, knowledgeable, and empathetic pediatric assistant for a parent.
Your name is BabyCare AI.
    
CONTEXT:
- Baby Name: ${profile.name}
- Age: $ageStr ($ageDays days old)
- Gender: ${profile.gender ?? 'Unknown'}
- Weight: ${profile.birthWeight} kg (at birth)
- Height: ${profile.height} cm (at birth)
- Feeding: ${profile.feedingType}
- Country: ${profile.country}

Tone: Warm, encouraging, concise, and evidence-based. 
Safety: If the issue sounds like a medical emergency (high fever, difficulty breathing, etc.), ALWAYS advise seeing a doctor immediately.

Answer the user's question based on this context.
    ''';

    // Build Chat History
    final chatHistory = history.map((msg) {
      if (msg.senderRole == 'user') {
        return Content.text(msg.messageText);
      } else {
        return Content.model([TextPart(msg.messageText)]);
      }
    }).toList();

    // Add current query
    chatHistory.add(Content.text(query));

    // Full Prompt (System + History)
    // Note: 'gemini-pro' doesn't support 'system' role strictly in all versions yet,
    // so we prepend system instructions to the first message or send as context.
    // Efficient approach: Send system prompt + user query if no history, or prepend context.

    // Simple prompting for MVP:
    // "Context: ... \n History: ... \n Query: ..."

    // Better: Start chat
    // For single-turn or simple multi-turn using invoke() with full context in prompt is often robust for MVP.

    final prompt = [
      Content.text(systemPrompt),
      ...history.map(
        (msg) => msg.senderRole == 'user'
            ? Content.text('User: ${msg.messageText}')
            : Content.model([TextPart('Assistant: ${msg.messageText}')]),
      ),
      Content.text('User: $query\nAssistant:'),
    ];

    try {
      final response = await model.generateContent(prompt);
      return response.text ?? "I'm sorry, I couldn't generate a response.";
    } catch (e) {
      // In production, handle quota limits, network errors, etc.
      return "I'm having trouble connecting right now. Please try again later. ($e)";
    }
  }
}
