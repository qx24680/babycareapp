import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/onboarding_data.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/selection_card.dart';

/// Screen 3: Quick Setup - Choose tracking buttons
class TrackingSetupScreen extends StatefulWidget {
  final OnboardingData data;
  final Function(OnboardingData) onDataChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const TrackingSetupScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<TrackingSetupScreen> createState() => _TrackingSetupScreenState();
}

class _TrackingSetupScreenState extends State<TrackingSetupScreen> {
  @override
  void initState() {
    super.initState();
    // Set smart defaults based on feeding type if not already set
    if (widget.data.enabledTrackingButtons.isEmpty) {
      _setSmartDefaults();
    }
  }

  void _setSmartDefaults() {
    final defaults = <TrackingButton>{
      TrackingButton.sleep,
      TrackingButton.diaper,
    };

    // Add feeding-specific defaults
    if (widget.data.feedingType == FeedingType.breast) {
      defaults.add(TrackingButton.breastfeed);
      defaults.add(TrackingButton.pumping);
    } else if (widget.data.feedingType == FeedingType.formula) {
      defaults.add(TrackingButton.feed);
    } else {
      // Mixed
      defaults.add(TrackingButton.breastfeed);
      defaults.add(TrackingButton.feed);
      defaults.add(TrackingButton.pumping);
    }

    // Add mood for newborns (< 3 months)
    final ageInDays = widget.data.ageInDays ?? 0;
    if (ageInDays < 90) {
      defaults.add(TrackingButton.mood);
    }

    widget.onDataChanged(widget.data.copyWith(
      enabledTrackingButtons: defaults,
    ));
  }

  void _toggleButton(TrackingButton button) {
    final newButtons = Set<TrackingButton>.from(
      widget.data.enabledTrackingButtons,
    );
    if (newButtons.contains(button)) {
      newButtons.remove(button);
    } else {
      newButtons.add(button);
    }
    widget.onDataChanged(widget.data.copyWith(
      enabledTrackingButtons: newButtons,
    ));
  }

  List<TrackingButton> _getRelevantButtons() {
    // Filter buttons based on feeding type
    final buttons = TrackingButton.values.toList();

    if (widget.data.feedingType == FeedingType.formula) {
      // Remove breastfeeding-specific buttons
      buttons.remove(TrackingButton.breastfeed);
      buttons.remove(TrackingButton.pumping);
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    final relevantButtons = _getRelevantButtons();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          OnboardingBackButton(onPressed: widget.onBack),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text('Quick Setup', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose your one-tap tracking buttons for the home screen',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Smart defaults badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.sparkles,
                  color: AppColors.secondary,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'We\'ve selected recommendations based on your setup',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.text.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Tracking button grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.3,
              ),
              itemCount: relevantButtons.length,
              itemBuilder: (context, index) {
                final button = relevantButtons[index];
                final isEnabled = widget.data.enabledTrackingButtons.contains(
                  button,
                );
                return ToggleCard(
                  emoji: button.emoji,
                  label: button.label,
                  description: button.description,
                  isEnabled: isEnabled,
                  onTap: () => _toggleButton(button),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Selected count
          Center(
            child: Text(
              '${widget.data.enabledTrackingButtons.length} buttons selected',
              style: AppTypography.caption.copyWith(
                color: AppColors.text.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Continue button
          OnboardingButton(
            label: 'Continue',
            onPressed: widget.data.enabledTrackingButtons.isNotEmpty
                ? widget.onNext
                : null,
          ),
        ],
      ),
    );
  }
}
