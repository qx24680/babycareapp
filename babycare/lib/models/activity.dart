import '../core/constants/activity_types.dart';

// --- Enums ---

// ActivityType is specific to the Model layer for now as it maps directly to DB operations
// The UI uses string constants from ActivityTypes class mostly.
enum ActivityType {
  sleep,
  breastfeeding,
  bottleFeeding,
  diaper,
  pumping,
  potty,
  food,
  bath,
  toothBrushing,
  crying,
  walkingOutside,
  nap,
  health,
  grooming,
  measurement,
  other; // Fallback

  String get dbValue {
    switch (this) {
      case ActivityType.bottleFeeding:
        return 'bottle_feeding';
      case ActivityType.toothBrushing:
        return 'tooth_brushing';
      case ActivityType.walkingOutside:
        return 'walking_outside';
      case ActivityType.measurement:
        return 'measurement';
      default:
        return name;
    }
  }

  static ActivityType fromDbValue(String value) => ActivityType.values
      .firstWhere((e) => e.dbValue == value, orElse: () => other);
}

// Other Enums (BreastSide, MilkType etc) are imported from core/constants/activity_types.dart

// --- Activity Model ---

class Activity {
  final int? id;
  final int babyId;
  final ActivityType type;

  // Timestamps (Milliseconds Since Epoch)
  final DateTime startTime;
  final DateTime? endTime;

  // Duration in minutes (calculated or explicit)
  final int? durationMinutes;

  // Generic amount (ml, oz, grams, etc.)
  final double? amount;
  final QuantityUnit? unit;

  // Specific Enums
  final BreastSide? side;
  final MilkType? milkType;
  final PumpSide? pumpSide;
  final PottyType? pottyType;

  // Flags
  final bool? isWet;
  final bool? isDry;
  final bool? hairWash;

  // Health specific
  final double? temperature; // Celsius
  final String? symptom;
  final int? severity; // 1-10
  final String? medication;
  final String? dosage;

  // Grooming specific
  final String? groomingType;

  // Other details
  final String? notes;

  Activity({
    this.id,
    required this.babyId,

    required this.type,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    this.amount,
    this.unit,
    this.side,
    this.milkType,
    this.pumpSide,
    this.pottyType,
    this.isWet,
    this.isDry,
    this.hairWash,
    this.temperature,
    this.symptom,
    this.severity,
    this.medication,
    this.dosage,
    this.groomingType,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baby_id': babyId,

      'type': type.dbValue,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'duration': durationMinutes,
      'amount': amount,
      'unit': unit?.value, // Using .value from imported Enum
      'side': side?.value,
      'milk_type': milkType?.value,
      'pump_side': pumpSide?.value,
      'potty_type': pottyType?.value,
      'is_wet': isWet == true ? 1 : 0,
      'is_dry': isDry == true ? 1 : 0,
      'hair_wash': hairWash == true ? 1 : 0,
      'temperature': temperature,
      'symptom': symptom,
      'severity': severity,
      'medication': medication,
      'dosage': dosage,
      'grooming_type': groomingType,
      'notes': notes,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as int?,
      babyId: map['baby_id'] as int,

      // Safe casting for ENUMs using fromString (legacy safe parser in activity_types.dart)
      type: ActivityType.fromDbValue(map['type'] as String),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: map['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int)
          : null,
      durationMinutes: map['duration'] as int?,
      amount: map['amount'] as double?,
      unit: map['unit'] != null
          ? QuantityUnit.fromString(map['unit'] as String)
          : null,
      side: map['side'] != null
          ? BreastSide.fromString(map['side'] as String)
          : null,
      milkType: map['milk_type'] != null
          ? MilkType.fromString(map['milk_type'] as String)
          : null,
      pumpSide: map['pump_side'] != null
          ? PumpSide.fromString(map['pump_side'] as String)
          : null,
      pottyType: map['potty_type'] != null
          ? PottyType.fromString(map['potty_type'] as String)
          : null,
      isWet: (map['is_wet'] as int?) == 1,
      isDry: (map['is_dry'] as int?) == 1,
      hairWash: (map['hair_wash'] as int?) == 1,
      temperature: map['temperature'] as double?,
      symptom: map['symptom'] as String?,
      severity: map['severity'] as int?,
      medication: map['medication'] as String?,
      dosage: map['dosage'] as String?,
      groomingType: map['grooming_type'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Activity copyWith({
    int? id,
    int? babyId,

    ActivityType? type,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    double? amount,
    QuantityUnit? unit,
    BreastSide? side,
    MilkType? milkType,
    PumpSide? pumpSide,
    PottyType? pottyType,
    bool? isWet,
    bool? isDry,
    bool? hairWash,
    double? temperature,
    String? symptom,
    int? severity,
    String? medication,
    String? dosage,
    String? groomingType,
    String? notes,
  }) {
    return Activity(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,

      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      side: side ?? this.side,
      milkType: milkType ?? this.milkType,
      pumpSide: pumpSide ?? this.pumpSide,
      pottyType: pottyType ?? this.pottyType,
      isWet: isWet ?? this.isWet,
      isDry: isDry ?? this.isDry,
      hairWash: hairWash ?? this.hairWash,
      temperature: temperature ?? this.temperature,
      symptom: symptom ?? this.symptom,
      severity: severity ?? this.severity,
      medication: medication ?? this.medication,
      dosage: dosage ?? this.dosage,
      groomingType: groomingType ?? this.groomingType,
      notes: notes ?? this.notes,
    );
  }
}
