import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Enums – stored as TEXT in SQLite via their `value` field.
// Each enum has a safe fromString helper with a sensible default.
// ---------------------------------------------------------------------------

/// Breast side for breastfeeding sessions.
enum BreastSide {
  left('left', 'Left'),
  right('right', 'Right');

  final String value;
  final String label;
  const BreastSide(this.value, this.label);

  static BreastSide fromString(String? value) {
    if (value == null) return BreastSide.left;
    return BreastSide.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BreastSide.left,
    );
  }
}

/// Milk type for bottle feeding.
enum MilkType {
  breastMilk('breast_milk', 'Breast Milk'),
  formula('formula', 'Formula'),
  tubeFeeding('tube_feeding', 'Tube Feeding'),
  cowMilk('cow_milk', 'Cow Milk'),
  goatMilk('goat_milk', 'Goat Milk'),
  soyMilk('soy_milk', 'Soy Milk'),
  other('other', 'Other');

  final String value;
  final String label;
  const MilkType(this.value, this.label);

  static MilkType fromString(String? value) {
    if (value == null) return MilkType.other;
    return MilkType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MilkType.other,
    );
  }
}

/// Pump side for pumping sessions.
enum PumpSide {
  left('left', 'Left'),
  right('right', 'Right'),
  both('both', 'Both');

  final String value;
  final String label;
  const PumpSide(this.value, this.label);

  static PumpSide fromString(String? value) {
    if (value == null) return PumpSide.both;
    return PumpSide.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PumpSide.both,
    );
  }
}

/// Potty event type.
enum PottyType {
  pee('pee', 'Pee'),
  poo('poo', 'Poo'),
  both('both', 'Both');

  final String value;
  final String label;
  const PottyType(this.value, this.label);

  static PottyType fromString(String? value) {
    if (value == null) return PottyType.pee;
    return PottyType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PottyType.pee,
    );
  }
}

/// Quantity / measurement unit for bottle feeding and food.
enum QuantityUnit {
  oz('oz', 'oz'),
  ml('ml', 'ml'),
  g('g', 'g'),
  flOz('fl_oz', 'fl oz'),
  drops('drops', 'drops'),
  pcs('pcs', 'pcs'),
  tsp('tsp', 'tsp'),
  tbsp('tbsp', 'tbsp');

  final String value;
  final String label;
  const QuantityUnit(this.value, this.label);

  static QuantityUnit fromString(String? value) {
    if (value == null) return QuantityUnit.ml;
    return QuantityUnit.values.firstWhere(
      (e) => e.value == value,
      orElse: () => QuantityUnit.ml,
    );
  }
}

// ---------------------------------------------------------------------------
// Activity type string constants.
// Legacy values are kept so existing form widgets continue to compile.
// ---------------------------------------------------------------------------

class ActivityTypes {
  // Legacy types (used by existing form widgets – do not remove)
  static const String feeding = 'feeding';
  static const String diaper = 'diaper';
  static const String sleep = 'sleep';
  static const String health = 'health';
  static const String grooming = 'grooming';
  static const String activity = 'activity';
  static const String milestone = 'milestone';
  static const String measurement = 'measurement';

  // New granular types
  static const String breastfeeding = 'breastfeeding';
  static const String bottleFeeding = 'bottle_feeding';
  static const String nap = 'nap';
  static const String pumping = 'pumping';
  static const String potty = 'potty';
  static const String food = 'food';
  static const String bath = 'bath';
  static const String toothBrushing = 'tooth_brushing';
  static const String crying = 'crying';
  static const String walkingOutside = 'walking_outside';

  /// Legacy list used by existing activity grid UI – unchanged.
  static const List<String> all = [
    feeding,
    diaper,
    sleep,
    health,
    grooming,
    activity,
    milestone,
    measurement,
  ];

  /// Complete list including new granular types.
  static const List<String> allTypes = [
    sleep,
    breastfeeding,
    bottleFeeding,
    diaper,
    nap,
    pumping,
    potty,
    food,
    bath,
    toothBrushing,
    crying,
    walkingOutside,
    // Legacy types retained for backward compatibility
    feeding,
    health,
    grooming,
    activity,
    milestone,
    measurement,
  ];
}

// ---------------------------------------------------------------------------
// Activity Configuration – maps type string → UI properties.
// ---------------------------------------------------------------------------

class ActivityConfig {
  final String type;
  final String label;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const ActivityConfig({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.lightColor,
  });

  static const Map<String, ActivityConfig> configs = {
    // ---- Legacy types ----
    ActivityTypes.feeding: ActivityConfig(
      type: ActivityTypes.feeding,
      label: 'Feeding',
      icon: FontAwesomeIcons.bottleWater,
      color: Color(0xFF4CAF50),
      lightColor: Color(0xFFE8F5E9),
    ),
    ActivityTypes.diaper: ActivityConfig(
      type: ActivityTypes.diaper,
      label: 'Diaper',
      icon: FontAwesomeIcons.layerGroup, // Or FontAwesomeIcons.baby
      color: Color(0xFF8D6E63),
      lightColor: Color(0xFFEFEBE9),
    ),
    ActivityTypes.sleep: ActivityConfig(
      type: ActivityTypes.sleep,
      label: 'Sleep',
      icon: FontAwesomeIcons.bed,
      color: Color(0xFF5C6BC0),
      lightColor: Color(0xFFE8EAF6),
    ),
    ActivityTypes.health: ActivityConfig(
      type: ActivityTypes.health,
      label: 'Health',
      icon: FontAwesomeIcons.heartPulse,
      color: Color(0xFFE91E63),
      lightColor: Color(0xFFFCE4EC),
    ),
    ActivityTypes.grooming: ActivityConfig(
      type: ActivityTypes.grooming,
      label: 'Grooming',
      icon: FontAwesomeIcons.wind, // Hair/Wind? Or userTie?
      color: Color(0xFF00BCD4),
      lightColor: Color(0xFFE0F7FA),
    ),
    ActivityTypes.activity: ActivityConfig(
      type: ActivityTypes.activity,
      label: 'Activity',
      icon: FontAwesomeIcons.shapes,
      color: Color(0xFFFF9800),
      lightColor: Color(0xFFFFF3E0),
    ),
    ActivityTypes.milestone: ActivityConfig(
      type: ActivityTypes.milestone,
      label: 'Milestone',
      icon: FontAwesomeIcons.medal,
      color: Color(0xFFFFD700),
      lightColor: Color(0xFFFFFDE7),
    ),
    ActivityTypes.measurement: ActivityConfig(
      type: ActivityTypes.measurement,
      label: 'Measurement',
      icon: FontAwesomeIcons.ruler,
      color: Color(0xFF9C27B0),
      lightColor: Color(0xFFF3E5F5),
    ),

    // ---- New granular types ----
    ActivityTypes.breastfeeding: ActivityConfig(
      type: ActivityTypes.breastfeeding,
      label: 'Breastfeeding',
      icon: FontAwesomeIcons.personBreastfeeding,
      color: Color(0xFFF06292), // Pinkish for breastfeeding
      lightColor: Color(0xFFFCE4EC),
    ),
    ActivityTypes.bottleFeeding: ActivityConfig(
      type: ActivityTypes.bottleFeeding,
      label: 'Bottle',
      icon: FontAwesomeIcons.bottleWater,
      color: Color(0xFF42A5F5),
      lightColor: Color(0xFFE3F2FD),
    ),
    ActivityTypes.nap: ActivityConfig(
      type: ActivityTypes.nap,
      label: 'Nap',
      icon: FontAwesomeIcons.moon,
      color: Color(0xFF7986CB),
      lightColor: Color(0xFFE8EAF6),
    ),
    ActivityTypes.pumping: ActivityConfig(
      type: ActivityTypes.pumping,
      label: 'Breast Pump',
      icon: FontAwesomeIcons.infinity,
      color: Color(0xFFAB47BC),
      lightColor: Color(0xFFF3E5F5),
    ),
    ActivityTypes.potty: ActivityConfig(
      type: ActivityTypes.potty,
      label: 'Potty',
      icon: FontAwesomeIcons.toilet,
      color: Color(0xFF8D6E63),
      lightColor: Color(0xFFEFEBE9),
    ),
    ActivityTypes.food: ActivityConfig(
      type: ActivityTypes.food,
      label: 'Food',
      icon: FontAwesomeIcons.bowlFood,
      color: Color(0xFFFF7043),
      lightColor: Color(0xFFFBE9E7),
    ),
    ActivityTypes.bath: ActivityConfig(
      type: ActivityTypes.bath,
      label: 'Bath',
      icon: FontAwesomeIcons.bath,
      color: Color(0xFF26C6DA),
      lightColor: Color(0xFFE0F7FA),
    ),
    ActivityTypes.toothBrushing: ActivityConfig(
      type: ActivityTypes.toothBrushing,
      label: 'Tooth Brushing',
      icon: FontAwesomeIcons.tooth,
      color: Color(0xFF26A69A),
      lightColor: Color(0xFFE0F2F1),
    ),
    ActivityTypes.crying: ActivityConfig(
      type: ActivityTypes.crying,
      label: 'Crying',
      icon: FontAwesomeIcons.faceSadTear,
      color: Color(0xFFEF5350),
      lightColor: Color(0xFFFFEBEE),
    ),
    ActivityTypes.walkingOutside: ActivityConfig(
      type: ActivityTypes.walkingOutside,
      label: 'Walking',
      icon: FontAwesomeIcons.personWalking,
      color: Color(0xFF66BB6A),
      lightColor: Color(0xFFE8F5E9),
    ),
  };

  static ActivityConfig get(String type) {
    return configs[type] ??
        const ActivityConfig(
          type: 'unknown',
          label: 'Unknown',
          icon: FontAwesomeIcons.question,
          color: AppColors.text,
          lightColor: Color(0xFFF5F5F5),
        );
  }
}

// ---------------------------------------------------------------------------
// Legacy sub-type classes – kept for existing form widgets.
// ---------------------------------------------------------------------------

/// Diaper Type Constants
class DiaperTypes {
  static const String pee = 'pee';
  static const String poop = 'poop';
  static const String both = 'both';
}

/// Feeding Type Constants
class FeedingTypes {
  static const String breast = 'breast';
  static const String bottle = 'bottle';
  static const String solid = 'solid';
}

/// Health Event Types
class HealthEventTypes {
  static const String temperature = 'temperature';
  static const String symptom = 'symptom';
  static const String medication = 'medication';
  static const String vaccination = 'vaccination';
  static const String doctorVisit = 'doctor_visit';
}

/// Grooming Types
class GroomingTypes {
  static const String bath = 'bath';
  static const String nails = 'nails';
  static const String hair = 'hair';
}
