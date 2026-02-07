import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/onboarding_data.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/selection_card.dart';

/// Screen 1: Welcome - Validate, then personalize
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
      newTopics.add(topic);
    }
    onDataChanged(data.copyWith(selectedTopics: newTopics));
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = data.selectedTopics.length;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headline — clear value prop
          Center(
            child: Text(
              'Baby care, simplified.',
              style: AppTypography.h1.copyWith(
                height: 1.2,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Subtitle — what we're asking + why
          Center(
            child: Text(
              'Pick your focus areas — we\'ll personalize the rest.',
              style: AppTypography.body.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Selection count indicator

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

          // Reversibility reassurance — reduces commitment anxiety
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'You can always change these later.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // CTA — "See" implies receiving, not building
          OnboardingButton(
            label: 'Next',
            onPressed: selectedCount > 0 ? onNext : null,
          ),
        ],
      ),
    );
  }
}
