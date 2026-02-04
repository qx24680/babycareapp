/// Model to store all onboarding selections and data
class OnboardingData {
  // Screen 1: Help Topics
  final Set<HelpTopic> selectedTopics;

  // Screen 2: Baby Info
  final String babyName;
  final DateTime? dateOfBirth;
  final FeedingType? feedingType;
  final String country;

  // Screen 3: Tracking Buttons
  final Set<TrackingButton> enabledTrackingButtons;

  // Screen 4: Reminders
  final ReminderPreference reminderPreference;

  // Screen 5: AI Assistant acknowledged
  final bool aiIntroCompleted;
  final String? firstAiQuestion;

  // Screen 6: Smart Features (Audio + Breastfeeding combined)
  final bool audioDetectionEnabled;
  final BreastfeedingSide? lastFeedingSide;
  final bool breastfeedTimerEnabled;
  final bool pumpingEnabled;
  final double? milkStashAmount;

  // Screen 7: Goals
  final OnboardingGoal? selectedGoal;

  const OnboardingData({
    this.selectedTopics = const {},
    this.babyName = 'Baby',
    this.dateOfBirth,
    this.feedingType,
    this.country = 'US',
    this.enabledTrackingButtons = const {},
    this.reminderPreference = ReminderPreference.smart,
    this.aiIntroCompleted = false,
    this.firstAiQuestion,
    this.audioDetectionEnabled = false,
    this.lastFeedingSide,
    this.breastfeedTimerEnabled = false,
    this.pumpingEnabled = false,
    this.milkStashAmount,
    this.selectedGoal,
  });

  OnboardingData copyWith({
    Set<HelpTopic>? selectedTopics,
    String? babyName,
    DateTime? dateOfBirth,
    FeedingType? feedingType,
    String? country,
    Set<TrackingButton>? enabledTrackingButtons,
    ReminderPreference? reminderPreference,
    bool? aiIntroCompleted,
    String? firstAiQuestion,
    bool? audioDetectionEnabled,
    BreastfeedingSide? lastFeedingSide,
    bool? breastfeedTimerEnabled,
    bool? pumpingEnabled,
    double? milkStashAmount,
    OnboardingGoal? selectedGoal,
  }) {
    return OnboardingData(
      selectedTopics: selectedTopics ?? this.selectedTopics,
      babyName: babyName ?? this.babyName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      feedingType: feedingType ?? this.feedingType,
      country: country ?? this.country,
      enabledTrackingButtons:
          enabledTrackingButtons ?? this.enabledTrackingButtons,
      reminderPreference: reminderPreference ?? this.reminderPreference,
      aiIntroCompleted: aiIntroCompleted ?? this.aiIntroCompleted,
      firstAiQuestion: firstAiQuestion ?? this.firstAiQuestion,
      audioDetectionEnabled:
          audioDetectionEnabled ?? this.audioDetectionEnabled,
      lastFeedingSide: lastFeedingSide ?? this.lastFeedingSide,
      breastfeedTimerEnabled:
          breastfeedTimerEnabled ?? this.breastfeedTimerEnabled,
      pumpingEnabled: pumpingEnabled ?? this.pumpingEnabled,
      milkStashAmount: milkStashAmount ?? this.milkStashAmount,
      selectedGoal: selectedGoal ?? this.selectedGoal,
    );
  }

  /// Check if essential data is complete for creating a baby profile
  bool get isEssentialDataComplete =>
      dateOfBirth != null && feedingType != null;

  /// Get age in days from DOB
  int? get ageInDays {
    if (dateOfBirth == null) return null;
    return DateTime.now().difference(dateOfBirth!).inDays;
  }

  /// Check if breastfeeding features should be shown
  bool get showBreastfeedingFeatures =>
      feedingType == FeedingType.breast || feedingType == FeedingType.mixed;
}

/// Topics user needs help with (Screen 1)
enum HelpTopic {
  sleep('💤', 'Sleep', 'Track sleep patterns & wake windows'),
  feeding('🍼', 'Feeding', 'Log feeds, bottles & nursing'),
  crying('😭', 'Crying / Soothing', 'Track fussy periods & what helps'),
  diapers('🚼', 'Diapers', 'Monitor diaper changes & patterns'),
  growth('📈', 'Growth', 'Track weight, height & milestones'),
  health('🩺', 'Health / Vaccines', 'Manage appointments & medications'),
  routines('🎯', 'Routines', 'Build healthy daily schedules');

  final String emoji;
  final String title;
  final String subtitle;
  const HelpTopic(this.emoji, this.title, this.subtitle);
}

/// Feeding type options (Screen 2)
enum FeedingType {
  breast('Breastfeeding', '🤱'),
  formula('Formula', '🍼'),
  mixed('Mixed', '🤱🍼');

  final String label;
  final String emoji;
  const FeedingType(this.label, this.emoji);
}

/// Tracking buttons for home screen (Screen 3)
enum TrackingButton {
  feed('Feed', '🍼', 'Log bottle or solid feeds'),
  breastfeed('Breastfeed', '🤱', 'Timer for nursing sessions'),
  sleep('Sleep', '💤', 'Track naps & nighttime'),
  diaper('Diaper', '🚼', 'Quick diaper logging'),
  pumping('Pumping', '🧴', 'Track pumping sessions'),
  mood('Mood', '😊', 'Track baby\'s mood & crying'),
  temperature('Temperature', '🌡️', 'Log temperature & medication'),
  growth('Growth', '📏', 'Record weight & height');

  final String label;
  final String emoji;
  final String description;
  const TrackingButton(this.label, this.emoji, this.description);
}

/// Reminder preferences (Screen 4)
enum ReminderPreference {
  smart('Smart reminders', 'Intelligent timing based on patterns'),
  manual('Manual only', 'You control all reminders'),
  none('No reminders', 'Disable all notifications');

  final String label;
  final String description;
  const ReminderPreference(this.label, this.description);
}

/// Last breastfeeding side (Screen 6)
enum BreastfeedingSide {
  left('Left'),
  right('Right'),
  notSure('Not sure');

  final String label;
  const BreastfeedingSide(this.label);
}

/// Onboarding goals (Screen 7)
enum OnboardingGoal {
  consistency('🔥', '3-day streak', 'Build a logging habit'),
  logging('📝', 'Log 2 things daily', 'Simple daily tracking'),
  memory('💭', '1 memory per day', 'Capture special moments');

  final String emoji;
  final String title;
  final String description;
  const OnboardingGoal(this.emoji, this.title, this.description);
}
