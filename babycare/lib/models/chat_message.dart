class ChatMessage {
  final int? id;
  final int sessionId;
  final bool isUser;
  final String? message;
  final DateTime timestamp;

  ChatMessage({
    this.id,
    required this.sessionId,
    required this.isUser,
    this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'is_user': isUser ? 1 : 0,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int,
      isUser: (map['is_user'] as int) == 1,
      message: map['message'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
