import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/activity.dart';
import '../../core/theme/app_theme.dart';

class LastActivityCard extends StatelessWidget {
  final String title;
  final Activity? activity;
  final IconData icon;
  final Color color;

  const LastActivityCard({
    super.key,
    required this.title,
    required this.activity,
    required this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (activity == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: BorderSide(color: AppColors.divider),
          right: BorderSide(color: AppColors.divider),
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                _getTimeAgo(activity!.startTime),
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMainDetail(activity!),
                      style: AppTypography.h3.copyWith(fontSize: 18),
                    ),
                    if (_getSubDetail(activity!).isNotEmpty)
                      Text(
                        _getSubDetail(activity!),
                        style: AppTypography.body.copyWith(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) {
      final m = diff.inMinutes % 60;
      return "${diff.inHours}h ${m}m ago";
    }
    if (diff.inDays == 1)
      return "Yesterday ${DateFormat('h:mm a').format(time)}";
    return DateFormat('MMM d, h:mm a').format(time);
  }

  String _getMainDetail(Activity act) {
    switch (act.type) {
      case ActivityType.breastfeeding:
        // "Left Side" or "Right Side"
        if (act.side != null) {
          // Capitalize first letter
          String side = act.side!.value;
          return "${side[0].toUpperCase()}${side.substring(1)} Side";
        }
        return "Nursing";

      case ActivityType.bottleFeeding:
        // "120 ml"
        return "${act.amount?.toStringAsFixed(0) ?? '--'} ${act.unit?.value ?? 'ml'}";

      case ActivityType.sleep:
        // If endTime is null -> "Sleeping..."
        if (act.endTime == null) return "Sleeping...";
        // If endTime exists -> "Slept 1h 20m"
        final duration = act.endTime!.difference(act.startTime);
        final h = duration.inHours;
        final m = duration.inMinutes % 60;
        if (h > 0) return "Slept ${h}h ${m}m";
        return "Slept ${m}m";

      case ActivityType.diaper:
        if (act.isWet == true && (act.notes?.contains('[Poop]') ?? false))
          return "Wet & Dirty";
        if (act.isWet == true) return "Wet Diaper";
        if (act.notes?.contains('[Poop]') ?? false) return "Dirty Diaper";
        return "Diaper Change";

      case ActivityType.pumping:
        return "${act.amount?.toStringAsFixed(0) ?? '--'} ${act.unit?.value ?? 'ml'}";

      case ActivityType.measurement:
        if (act.type == ActivityType.measurement) {
          // We might need to check which measurement is most relevant or non-null
          // But Activity model for measurement usually maps to specific 'ActivityType.measurement' generic?
          // Actually measurement is separate table but service maps it to Measurement object usually.
          // BUT logic here uses Activity object.
          // NOTE: getLastActivity in service returns Activity object from 'activity' table.
          // Measurements are in 'measurement' table usually?
          // Ah wait, `getGrowthStats` queries 'measurement' table.
          // `getLastActivity(ActivityType.measurement)` queries activity table.
          // If measurements are NOT in activity table, this won't work for Growth.
          // Let's assume Growth is handled differently or we won't show LastActivityCard for growth yet
          // unless we update service to query measurement table for Last Activity Card logic.
          // For now, let's stick to standard activities.
          return "Measurement";
        }
        return "Log";

      default:
        return act.type.name.toUpperCase();
    }
  }

  String _getSubDetail(Activity act) {
    switch (act.type) {
      case ActivityType.breastfeeding:
        // Duration: 15m
        final d =
            act.durationMinutes ??
            (act.endTime?.difference(act.startTime).inMinutes) ??
            0;
        return "$d min";

      case ActivityType.bottleFeeding:
        // Milk type?
        return act.milkType?.value ?? "Formula";

      case ActivityType.sleep:
        // Start time
        return "Started at ${DateFormat('h:mm a').format(act.startTime)}";

      case ActivityType.diaper:
        return "";

      case ActivityType.pumping:
        // Side
        if (act.pumpSide != null) {
          String side = act.pumpSide!.value;
          return "${side[0].toUpperCase()}${side.substring(1)} Side";
        }
        return "";

      default:
        return "";
    }
  }
}
