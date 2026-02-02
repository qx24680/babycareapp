class BabyProfile {
  final int? id;
  final String name;
  final DateTime dob;
  final String feedingType; // breast, formula, mixed
  final double birthWeight;
  final double height;
  final String? gender;
  final String country;

  BabyProfile({
    this.id,
    required this.name,
    required this.dob,
    required this.feedingType,
    required this.birthWeight,
    required this.height,
    this.gender,
    required this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dob': dob.toIso8601String(),
      'feeding_type': feedingType,
      'birth_weight': birthWeight,
      'height': height,
      'gender': gender,
      'country': country,
    };
  }

  factory BabyProfile.fromMap(Map<String, dynamic> map) {
    return BabyProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      dob: DateTime.parse(map['dob'] as String),
      feedingType: map['feeding_type'] as String,
      birthWeight: (map['birth_weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      gender: map['gender'] as String?,
      country: map['country'] as String,
    );
  }
}
