import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/onboarding_data.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/selection_card.dart';

/// Screen 7: Streak + Goals (keep it light)
class GoalsScreen extends StatelessWidget {
  final OnboardingData data;
  final Function(OnboardingData) onDataChanged;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const GoalsScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          OnboardingBackButton(onPressed: onBack),
          const SizedBox(height: AppSpacing.md),

          // Celebration illustration
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                const Text('🎉', style: TextStyle(fontSize: 50)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Title
          Center(
            child: Text(
              'You\'re almost ready!',
              style: AppTypography.h1,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              'Would you like to set a gentle goal to stay motivated?',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Goal options
          Expanded(
            child: ListView(
              children: [
                ...OnboardingGoal.values.map((goal) {
                  final isSelected = data.selectedGoal == goal;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SelectionCard(
                      emoji: goal.emoji,
                      title: goal.title,
                      subtitle: goal.description,
                      isSelected: isSelected,
                      onTap: () {
                        onDataChanged(data.copyWith(selectedGoal: goal));
                      },
                    ),
                  );
                }),

                const SizedBox(height: AppSpacing.md),

                // No goal option
                GestureDetector(
                  onTap: () {
                    // Clear goal selection by creating new data without goal
                    onDataChanged(OnboardingData(
                      selectedTopics: data.selectedTopics,
                      babyName: data.babyName,
                      dateOfBirth: data.dateOfBirth,
                      feedingType: data.feedingType,
                      country: data.country,
                      enabledTrackingButtons: data.enabledTrackingButtons,
                      reminderPreference: data.reminderPreference,
                      aiIntroCompleted: data.aiIntroCompleted,
                      firstAiQuestion: data.firstAiQuestion,
                      audioDetectionEnabled: data.audioDetectionEnabled,
                      lastFeedingSide: data.lastFeedingSide,
                      breastfeedTimerEnabled: data.breastfeedTimerEnabled,
                      pumpingEnabled: data.pumpingEnabled,
                      milkStashAmount: data.milkStashAmount,
                      selectedGoal: null,
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: data.selectedGoal == null
                          ? AppColors.text.withValues(alpha: 0.05)
                          : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: data.selectedGoal == null
                            ? AppColors.text.withValues(alpha: 0.2)
                            : AppColors.text.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.xmark_circle,
                          color: AppColors.text.withValues(alpha: 0.5),
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'No goal for now',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.text.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reassurance message
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Text('💚', style: TextStyle(fontSize: 18)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'No pressure—this is here to help, not judge. You\'re doing great!',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Complete button
          OnboardingButton(
            label: 'Get Started',
            onPressed: onComplete,
          ),
        ],
      ),
    );
  }
}
