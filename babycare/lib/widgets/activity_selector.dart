import 'package:flutter/cupertino.dart';
import '../core/constants/activity_types.dart';
import '../core/theme/app_theme.dart';

class ActivitySelector extends StatelessWidget {
  final Function(String) onActivitySelected;

  const ActivitySelector({super.key, required this.onActivitySelected});

  @override
  Widget build(BuildContext context) {
    // Defines the order of activities in the horizontal list
    final List<String> displayTypes = [
      ActivityTypes.sleep,
      ActivityTypes.breastfeeding,
      ActivityTypes.bottleFeeding,
      ActivityTypes.diaper,
      ActivityTypes.health, // Added
      ActivityTypes.measurement, // Added
      ActivityTypes.food,
      ActivityTypes.pumping,
      ActivityTypes.nap,
      ActivityTypes.potty,
      ActivityTypes.grooming, // Added (replaces bath)
      ActivityTypes.toothBrushing,
      ActivityTypes.crying,
      ActivityTypes.walkingOutside,
    ];

    return SizedBox(
      height: 100, // Fixed height for the selector strip
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: displayTypes.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.lg),
        itemBuilder: (context, index) {
          final type = displayTypes[index];
          final config = ActivityConfig.get(type);
          return _buildActivityItem(context, config);
        },
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityConfig config) {
    return GestureDetector(
      onTap: () => onActivitySelected(config.type),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60, // Slightly larger
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  config.lightColor,
                  config.color.withValues(alpha: 0.15),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: config.color.withValues(alpha: 0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: config.color.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(config.icon, color: config.color, size: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            config.label,
            style: AppTypography.caption.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
