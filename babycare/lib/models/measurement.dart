class Measurement {
  final int? id;
  final int babyId;
  final DateTime time;
  final double? weight;
  final String? weightUnit;
  final double? height;
  final String? heightUnit;
  final double? headCircumference;
  final String? headCircumferenceUnit;
  final String? notes;

  Measurement({
    this.id,
    required this.babyId,
    required this.time,
    this.weight,
    this.weightUnit,
    this.height,
    this.heightUnit,
    this.headCircumference,
    this.headCircumferenceUnit,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baby_id': babyId,
      'time': time.millisecondsSinceEpoch,
      'weight': weight,
      'weight_unit': weightUnit,
      'height': height,
      'height_unit': heightUnit,
      'head_circumference': headCircumference,
      'head_circumference_unit': headCircumferenceUnit,
      'notes': notes,
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: map['id'] as int?,
      babyId: map['baby_id'] as int,
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int),
      weight: map['weight'] as double?,
      weightUnit: map['weight_unit'] as String?,
      height: map['height'] as double?,
      heightUnit: map['height_unit'] as String?,
      headCircumference: map['head_circumference'] as double?,
      headCircumferenceUnit: map['head_circumference_unit'] as String?,
      notes: map['notes'] as String?,
    );
  }
}
