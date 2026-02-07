class BabyProfile {
  final int? id;
  final String name;
  final DateTime dob;
  final String? gender;

  BabyProfile({this.id, required this.name, required this.dob, this.gender});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dob': dob.toIso8601String(),
      'gender': gender,
    };
  }

  factory BabyProfile.fromMap(Map<String, dynamic> map) {
    return BabyProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      dob: DateTime.parse(map['dob'] as String),
      gender: map['gender'] as String?,
    );
  }
}
