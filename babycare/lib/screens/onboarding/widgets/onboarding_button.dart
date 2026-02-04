import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';

/// Primary action button for onboarding
class OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;

  const OnboardingButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isPrimary
              ? (onPressed != null
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.5))
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppColors.text.withValues(alpha: 0.2),
                  width: 1.5,
                ),
          boxShadow: isPrimary && onPressed != null ? AppShadows.sm : null,
        ),
        child: Center(
          child: isLoading
              ? const CupertinoActivityIndicator()
              : Text(
                  label,
                  style: AppTypography.button.copyWith(
                    color: isPrimary ? AppColors.text : AppColors.text,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Secondary text button
class OnboardingTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const OnboardingTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: color ?? AppColors.text.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

/// Back button for navigation
class OnboardingBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.text.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(
          CupertinoIcons.chevron_left,
          color: AppColors.text,
          size: 20,
        ),
      ),
    );
  }
}
