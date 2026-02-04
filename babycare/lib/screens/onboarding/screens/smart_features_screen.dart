import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/onboarding_data.dart';
import '../widgets/onboarding_button.dart';

/// Screen 8 (Post-onboarding): Smart Features - Audio Detection + Breastfeeding
/// This is now combined into AiIntroScreen but kept as standalone for optional use
class SmartFeaturesScreen extends StatelessWidget {
  final OnboardingData data;
  final Function(OnboardingData) onDataChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SmartFeaturesScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onNext,
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

          // Title
          Text('Smart Features', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Optional features to make tracking easier',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Audio Detection Card
                  _FeatureCard(
                    emoji: '🎤',
                    title: 'Auto-detect crying',
                    description: 'Automatically log fussing & soothing sessions',
                    isEnabled: data.audioDetectionEnabled,
                    onToggle: (value) {
                      onDataChanged(data.copyWith(
                        audioDetectionEnabled: value,
                      ));
                    },
                    privacyNote: 'Audio is processed locally. Disable anytime.',
                  ),

                  // Breastfeeding features (if applicable)
                  if (data.showBreastfeedingFeatures) ...[
                    const SizedBox(height: AppSpacing.md),
                    _FeatureCard(
                      emoji: '⏱️',
                      title: 'Breastfeed timer',
                      description: 'Timer with pause for burping + notification',
                      isEnabled: data.breastfeedTimerEnabled,
                      onToggle: (value) {
                        onDataChanged(data.copyWith(
                          breastfeedTimerEnabled: value,
                        ));
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FeatureCard(
                      emoji: '🧴',
                      title: 'Milk stash tracking',
                      description: 'Track pumped milk & freezer inventory',
                      isEnabled: data.pumpingEnabled,
                      onToggle: (value) {
                        onDataChanged(data.copyWith(
                          pumpingEnabled: value,
                        ));
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Continue button
          OnboardingButton(
            label: 'Continue',
            onPressed: onNext,
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

/// Feature toggle card widget
class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final bool isEnabled;
  final Function(bool) onToggle;
  final String? privacyNote;

  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.onToggle,
    this.privacyNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.text.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: isEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: onToggle,
              ),
            ],
          ),
          if (privacyNote != null && isEnabled) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.lock_shield,
                    color: AppColors.text.withValues(alpha: 0.4),
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      privacyNote!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
