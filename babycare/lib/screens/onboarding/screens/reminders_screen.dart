import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/onboarding_data.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/selection_card.dart';

/// Screen 5: Set 1 helpful reminder (not 10)
class RemindersScreen extends StatelessWidget {
  final OnboardingData data;
  final Function(OnboardingData) onDataChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RemindersScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onNext,
    required this.onBack,
  });

  String _getSmartReminderExample() {
    final ageInDays = data.ageInDays ?? 0;

    if (ageInDays < 90) {
      // Newborn - frequent feeds
      return 'Feeding reminder in ~2-3 hours';
    } else if (ageInDays < 180) {
      // 3-6 months
      return 'Nap window reminder based on wake time';
    } else {
      // 6+ months
      return 'Meal & nap time suggestions';
    }
  }

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

          // Illustration
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔔', style: TextStyle(fontSize: 50)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Title
          Center(
            child: Text(
              'Stay on track with\ngentle reminders',
              style: AppTypography.h1,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              'We\'ll help you remember without overwhelming you',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Smart reminders example
          if (data.reminderPreference == ReminderPreference.smart)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Example for ${data.babyName}:',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.text.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          _getSmartReminderExample(),
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Reminder options
          Expanded(
            child: ListView(
              children: [
                RadioCard(
                  title: ReminderPreference.smart.label,
                  description: ReminderPreference.smart.description,
                  isSelected: data.reminderPreference == ReminderPreference.smart,
                  recommendedLabel: 'Recommended',
                  onTap: () {
                    onDataChanged(data.copyWith(
                      reminderPreference: ReminderPreference.smart,
                    ));
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                RadioCard(
                  title: ReminderPreference.manual.label,
                  description: ReminderPreference.manual.description,
                  isSelected: data.reminderPreference == ReminderPreference.manual,
                  onTap: () {
                    onDataChanged(data.copyWith(
                      reminderPreference: ReminderPreference.manual,
                    ));
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                RadioCard(
                  title: ReminderPreference.none.label,
                  description: ReminderPreference.none.description,
                  isSelected: data.reminderPreference == ReminderPreference.none,
                  onTap: () {
                    onDataChanged(data.copyWith(
                      reminderPreference: ReminderPreference.none,
                    ));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Privacy note
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.text.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.lock_shield,
                  color: AppColors.text.withValues(alpha: 0.4),
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'You can change notification settings anytime',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.text.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Continue button
          OnboardingButton(
            label: 'Continue',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
