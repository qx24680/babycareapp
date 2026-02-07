import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';

/// Progress indicator for onboarding flow
class OnboardingProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Function(int)? onStepTap;

  const OnboardingProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: GestureDetector(
            onTap: onStepTap != null && isCompleted
                ? () => onStepTap!(index)
                : null,
            child: Container(
              height: 4,
              margin: EdgeInsets.only(
                right: index < totalSteps - 1 ? AppSpacing.xs : 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.full),
                color: isCompleted || isCurrent
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
              child: isCurrent
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: constraints.maxWidth * 0.5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    )
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
