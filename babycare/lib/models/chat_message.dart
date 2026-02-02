class ChatMessage {
  final int? id;
  final int conversationId;
  final String senderRole; // 'user' or 'assistant'
  final int? guardianId; // Nullable, only for senderRole == 'user'
  final String messageText;
  final String? topic; // sleep, feeding, etc.
  final int? babyAgeDays; // Context: age of baby when message sent
  final DateTime createdAt;

  ChatMessage({
    this.id,
    required this.conversationId,
    required this.senderRole,
    this.guardianId,
    required this.messageText,
    this.topic,
    this.babyAgeDays,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_role': senderRole,
      'guardian_id': guardianId,
      'message_text': messageText,
      'topic': topic,
      'baby_age_days': babyAgeDays,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int?,
      conversationId: map['conversation_id'] as int,
      senderRole: map['sender_role'] as String,
      guardianId: map['guardian_id'] as int?,
      messageText: map['message_text'] as String,
      topic: map['topic'] as String?,
      babyAgeDays: map['baby_age_days'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
