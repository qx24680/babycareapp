class ChatConversation {
  final int? id;
  final int babyId;
  final DateTime createdAt;
  final bool archived;

  ChatConversation({
    this.id,
    required this.babyId,
    required this.createdAt,
    this.archived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baby_id': babyId,
      'created_at': createdAt.toIso8601String(),
      'archived': archived ? 1 : 0,
    };
  }

  factory ChatConversation.fromMap(Map<String, dynamic> map) {
    return ChatConversation(
      id: map['id'] as int?,
      babyId: map['baby_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      archived: (map['archived'] as int) == 1,
    );
  }
}
