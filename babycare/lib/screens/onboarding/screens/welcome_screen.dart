import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/onboarding_data.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/selection_card.dart';

/// Screen 1: Welcome - "What do you need help with today?"
class WelcomeScreen extends StatelessWidget {
  final OnboardingData data;
  final Function(OnboardingData) onDataChanged;
  final VoidCallback onNext;

  const WelcomeScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onNext,
  });

  void _toggleTopic(HelpTopic topic) {
    final newTopics = Set<HelpTopic>.from(data.selectedTopics);
    if (newTopics.contains(topic)) {
      newTopics.remove(topic);
    } else {
      // Limit to 3 selections
      if (newTopics.length < 3) {
        newTopics.add(topic);
      }
    }
    onDataChanged(data.copyWith(selectedTopics: newTopics));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),

          // Welcome illustration/emoji
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👶', style: TextStyle(fontSize: 40)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Title
          Center(
            child: Text(
              'What do you need\nhelp with today?',
              style: AppTypography.h1,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Subtitle
          Center(
            child: Text(
              'Pick up to 3 topics to personalize your experience',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.text.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Selection count indicator
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '${data.selectedTopics.length} of 3 selected',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Topic cards
          Expanded(
            child: ListView.separated(
              itemCount: HelpTopic.values.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final topic = HelpTopic.values[index];
                return SelectionCard(
                  emoji: topic.emoji,
                  title: topic.title,
                  subtitle: topic.subtitle,
                  isSelected: data.selectedTopics.contains(topic),
                  onTap: () => _toggleTopic(topic),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Continue button
          OnboardingButton(
            label: 'Continue',
            onPressed: data.selectedTopics.isNotEmpty ? onNext : null,
          ),

          // Skip option
          Center(
            child: OnboardingTextButton(
              label: 'Skip for now',
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}
