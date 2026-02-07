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
    final isEnabled = onPressed != null && !isLoading;

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: isPrimary && isEnabled
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isPrimary
              ? (isEnabled ? null : AppColors.primary.withValues(alpha: 0.35))
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
          boxShadow: isPrimary && isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
              : Text(
                  label,
                  style: isPrimary
                      ? AppTypography.button.copyWith(
                          color: isEnabled
                              ? AppColors.textOnPrimary
                              : AppColors.textOnPrimary.withValues(alpha: 0.6),
                        )
                      : AppTypography.buttonSecondary,
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
          color: color ?? AppColors.textLight,
          fontWeight: FontWeight.w500,
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
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Icon(
          CupertinoIcons.chevron_left,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }
}
