class Guardian {
  final int? id;
  final String name;
  final String role; // mother, father, caregiver
  final int babyId; // Foreign key to BabyProfile

  Guardian({
    this.id,
    required this.name,
    required this.role,
    required this.babyId,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'role': role, 'baby_id': babyId};
  }

  factory Guardian.fromMap(Map<String, dynamic> map) {
    return Guardian(
      id: map['id'] as int?,
      name: map['name'] as String,
      role: map['role'] as String,
      babyId: map['baby_id'] as int,
    );
  }
}
