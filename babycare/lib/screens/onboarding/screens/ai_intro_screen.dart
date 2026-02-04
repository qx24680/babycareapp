import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/onboarding_data.dart';
import '../widgets/onboarding_button.dart';

/// Screen 6: AI Assistant Intro + Smart Features (combined)
class AiIntroScreen extends StatefulWidget {
  final OnboardingData data;
  final Function(OnboardingData) onDataChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AiIntroScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<AiIntroScreen> createState() => _AiIntroScreenState();
}

class _AiIntroScreenState extends State<AiIntroScreen> {
  final List<String> _suggestionChips = [
    'Is this amount of sleep normal?',
    'Sample daily routine',
    'How to soothe baby at night?',
    'When to start solids?',
  ];

  String? _selectedQuestion;
  bool _showAudioSection = false;

  @override
  void initState() {
    super.initState();
    // Show audio section after AI intro is viewed
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showAudioSection = true;
        });
      }
    });
  }

  void _selectQuestion(String question) {
    setState(() {
      _selectedQuestion = question;
    });
    widget.onDataChanged(widget.data.copyWith(
      firstAiQuestion: question,
      aiIntroCompleted: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          OnboardingBackButton(onPressed: widget.onBack),
          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Assistant Section
                  _buildAiSection(),

                  const SizedBox(height: AppSpacing.xl),

                  // Smart Features Section (Audio Detection)
                  AnimatedOpacity(
                    opacity: _showAudioSection ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: _buildSmartFeaturesSection(),
                  ),

                  // Breastfeeding features (if applicable)
                  if (widget.data.showBreastfeedingFeatures) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildBreastfeedingSection(),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Continue button
          OnboardingButton(
            label: 'Continue',
            onPressed: widget.onNext,
          ),
        ],
      ),
    );
  }

  Widget _buildAiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Header
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meet your AI Assistant', style: AppTypography.h2),
                  Text(
                    'Personalized guidance for ${widget.data.babyName}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // AI Chat bubble
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi! I can answer questions based on ${widget.data.babyName}\'s age and your logs. I\'ll learn your patterns to give better suggestions.',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.md),
              // Disclaimer
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'I\'m not a medical professional—please seek urgent care if needed.',
                        style: AppTypography.caption.copyWith(
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

        // Suggestion chips
        Text(
          'Try asking:',
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _suggestionChips.map((chip) {
            final isSelected = _selectedQuestion == chip;
            return GestureDetector(
              onTap: () => _selectQuestion(chip),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                ),
                child: Text(
                  chip,
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? CupertinoColors.white : AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Selected question response preview
        if (_selectedQuestion != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Great question! I\'ll answer this when you start the app.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSmartFeaturesSection() {
    return Container(
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
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text('🎤', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-detect crying',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Log fussing & soothing sessions automatically',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.text.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: widget.data.audioDetectionEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: (value) {
                  widget.onDataChanged(widget.data.copyWith(
                    audioDetectionEnabled: value,
                  ));
                },
              ),
            ],
          ),

          if (widget.data.audioDetectionEnabled) ...[
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
                      'Audio is processed locally to detect events. You can disable anytime.',
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

  Widget _buildBreastfeedingSection() {
    return Container(
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
              const Text('🤱', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Breastfeeding Tools',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Last feeding side
          Text(
            'Which side did you last feed from?',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: BreastfeedingSide.values.map((side) {
              final isSelected = widget.data.lastFeedingSide == side;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: side != BreastfeedingSide.values.last
                        ? AppSpacing.sm
                        : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      widget.onDataChanged(widget.data.copyWith(
                        lastFeedingSide: side,
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.text.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          side.label,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Timer toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Breastfeed timer + pause for burping',
                    style: AppTypography.bodySmall,
                  ),
                  Text(
                    'Timer appears in notifications',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.text.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              CupertinoSwitch(
                value: widget.data.breastfeedTimerEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: (value) {
                  widget.onDataChanged(widget.data.copyWith(
                    breastfeedTimerEnabled: value,
                  ));
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Pumping toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Do you pump?', style: AppTypography.bodySmall),
              CupertinoSwitch(
                value: widget.data.pumpingEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: (value) {
                  widget.onDataChanged(widget.data.copyWith(
                    pumpingEnabled: value,
                  ));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
