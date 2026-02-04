import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/onboarding_data.dart';
import '../widgets/onboarding_button.dart';

/// Screen 4: Today's Plan - Immediate payoff with age-based insights
class TodayPlanScreen extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const TodayPlanScreen({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  String _getAgeLabel() {
    final days = data.ageInDays ?? 0;
    if (days < 7) return 'Newborn';
    if (days < 30) return '${(days / 7).floor()} weeks old';
    if (days < 365) return '${(days / 30).floor()} months old';
    return '${(days / 365).floor()} year(s) old';
  }

  Map<String, String> _getAgeBasedInsights() {
    final days = data.ageInDays ?? 0;

    if (days < 30) {
      // Newborn (0-4 weeks)
      return {
        'Wake Window': '45-60 min',
        'Typical Feeds': '8-12 per day',
        'Sleep': '14-17 hours total',
        'Diapers': '8-12 wet/day',
      };
    } else if (days < 90) {
      // 1-3 months
      return {
        'Wake Window': '1-1.5 hours',
        'Typical Feeds': '7-9 per day',
        'Sleep': '14-16 hours total',
        'Diapers': '6-8 wet/day',
      };
    } else if (days < 180) {
      // 3-6 months
      return {
        'Wake Window': '1.5-2.5 hours',
        'Typical Feeds': '5-7 per day',
        'Sleep': '12-15 hours total',
        'Diapers': '5-7 wet/day',
      };
    } else if (days < 365) {
      // 6-12 months
      return {
        'Wake Window': '2-3.5 hours',
        'Typical Feeds': '4-6 per day',
        'Sleep': '12-14 hours total',
        'Solids': 'Starting or established',
      };
    } else {
      // 1+ years
      return {
        'Wake Window': '3-5 hours',
        'Meals': '3 meals + snacks',
        'Sleep': '11-14 hours total',
        'Naps': '1-2 per day',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final insights = _getAgeBasedInsights();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          OnboardingBackButton(onPressed: onBack),
          const SizedBox(height: AppSpacing.md),

          // Title with baby name
          Text(
            "Here's ${data.babyName}'s\nplan for today",
            style: AppTypography.h1,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Age badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              _getAgeLabel(),
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Insights cards
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Age-based insights card
                  _InsightCard(
                    title: 'What to expect today',
                    icon: CupertinoIcons.lightbulb,
                    iconColor: AppColors.accent,
                    child: Column(
                      children: insights.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.text.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                entry.value,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Timeline placeholder
                  _InsightCard(
                    title: 'Your day',
                    icon: CupertinoIcons.time,
                    iconColor: AppColors.secondary,
                    child: Column(
                      children: [
                        // Timeline placeholder items
                        _TimelinePlaceholder(
                          time: 'Morning',
                          activity: 'First feed & diaper',
                          emoji: '🌅',
                        ),
                        _TimelinePlaceholder(
                          time: 'Throughout',
                          activity: 'Feeds, naps & play',
                          emoji: '☀️',
                        ),
                        _TimelinePlaceholder(
                          time: 'Evening',
                          activity: 'Bedtime routine',
                          emoji: '🌙',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.arrow_right_circle_fill,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Your timeline will fill up as you log',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.text.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Sample day preview
                  _InsightCard(
                    title: 'Sample logged day',
                    icon: CupertinoIcons.doc_text,
                    iconColor: AppColors.primary,
                    child: _SampleDayPreview(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Continue button
          OnboardingButton(
            label: 'Looks great!',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

/// Card widget for insights
class _InsightCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _InsightCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.h3.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

/// Timeline placeholder item
class _TimelinePlaceholder extends StatelessWidget {
  final String time;
  final String activity;
  final String emoji;

  const _TimelinePlaceholder({
    required this.time,
    required this.activity,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: AppTypography.caption.copyWith(
                  color: AppColors.text.withValues(alpha: 0.5),
                ),
              ),
              Text(activity, style: AppTypography.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sample day preview widget
class _SampleDayPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sampleEvents = [
      {'time': '6:30 AM', 'event': 'Feed', 'emoji': '🍼', 'detail': '120ml'},
      {'time': '7:15 AM', 'event': 'Diaper', 'emoji': '🚼', 'detail': 'Wet'},
      {'time': '8:00 AM', 'event': 'Sleep', 'emoji': '💤', 'detail': '1h 30m'},
      {'time': '9:30 AM', 'event': 'Feed', 'emoji': '🍼', 'detail': '100ml'},
    ];

    return Column(
      children: sampleEvents.map((event) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  event['time']!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.text.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Text(event['emoji']!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(event['event']!, style: AppTypography.bodySmall)),
              Text(
                event['detail']!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
