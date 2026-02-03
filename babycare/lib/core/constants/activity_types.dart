import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

/// Activity Type Constants for Baby Care
class ActivityTypes {
  static const String feeding = 'feeding';
  static const String diaper = 'diaper';
  static const String sleep = 'sleep';
  static const String health = 'health';
  static const String grooming = 'grooming';
  static const String activity = 'activity';
  static const String milestone = 'milestone';
  static const String measurement = 'measurement';

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
}

/// Activity Configuration with UI properties
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
    ActivityTypes.feeding: ActivityConfig(
      type: ActivityTypes.feeding,
      label: 'Feeding',
      icon: CupertinoIcons.square_favorites_alt_fill,
      color: Color(0xFF4CAF50), // Green
      lightColor: Color(0xFFE8F5E9),
    ),
    ActivityTypes.diaper: ActivityConfig(
      type: ActivityTypes.diaper,
      label: 'Diaper',
      icon: CupertinoIcons.drop_fill,
      color: Color(0xFF8D6E63), // Brown
      lightColor: Color(0xFFEFEBE9),
    ),
    ActivityTypes.sleep: ActivityConfig(
      type: ActivityTypes.sleep,
      label: 'Sleep',
      icon: CupertinoIcons.moon_fill,
      color: Color(0xFF5C6BC0), // Indigo
      lightColor: Color(0xFFE8EAF6),
    ),
    ActivityTypes.health: ActivityConfig(
      type: ActivityTypes.health,
      label: 'Health',
      icon: CupertinoIcons.heart_fill,
      color: Color(0xFFE91E63), // Pink
      lightColor: Color(0xFFFCE4EC),
    ),
    ActivityTypes.grooming: ActivityConfig(
      type: ActivityTypes.grooming,
      label: 'Grooming',
      icon: CupertinoIcons.sparkles,
      color: Color(0xFF00BCD4), // Cyan
      lightColor: Color(0xFFE0F7FA),
    ),
    ActivityTypes.activity: ActivityConfig(
      type: ActivityTypes.activity,
      label: 'Activity',
      icon: CupertinoIcons.play_fill,
      color: Color(0xFFFF9800), // Orange
      lightColor: Color(0xFFFFF3E0),
    ),
    ActivityTypes.milestone: ActivityConfig(
      type: ActivityTypes.milestone,
      label: 'Milestone',
      icon: CupertinoIcons.star_fill,
      color: Color(0xFFFFD700), // Gold
      lightColor: Color(0xFFFFFDE7),
    ),
    ActivityTypes.measurement: ActivityConfig(
      type: ActivityTypes.measurement,
      label: 'Measurement',
      icon: CupertinoIcons.chart_bar_fill,
      color: Color(0xFF9C27B0), // Purple
      lightColor: Color(0xFFF3E5F5),
    ),
  };

  static ActivityConfig get(String type) {
    return configs[type] ??
        const ActivityConfig(
          type: 'unknown',
          label: 'Unknown',
          icon: CupertinoIcons.question_circle_fill,
          color: AppColors.text,
          lightColor: Color(0xFFF5F5F5),
        );
  }
}

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
