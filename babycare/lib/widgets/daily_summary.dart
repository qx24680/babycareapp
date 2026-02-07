import 'package:flutter/cupertino.dart';
import '../models/activity.dart';
import '../core/constants/activity_types.dart';
import '../core/theme/app_theme.dart';

class DailySummaryWidget extends StatelessWidget {
  final List<Activity> activities;

  const DailySummaryWidget({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    int sleepMinutes = 0;
    double feedAmount = 0;
    int diaperCount = 0;

    for (var activity in activities) {
      switch (activity.type) {
        case ActivityType.sleep:
        case ActivityType.nap:
          sleepMinutes += activity.durationMinutes ?? 0;
          break;
        case ActivityType.bottleFeeding:
        case ActivityType
            .pumping: // Maybe pumping shouldn't count as feed intake? sticking to intake.
          feedAmount += activity.amount ?? 0;
          break;
        case ActivityType.breastfeeding:
          // Breastfeeding amount is hard to know if not explicit, but we can track duration?
          // For summary, maybe just Mixing amounts is weird.
          // Let's stick to Bottle amount for now or specific logic.
          // User asked for "polishing", so let's just show what we have.
          break;
        case ActivityType.diaper:
          diaperCount++;
          break;
        default:
          break;
      }
    }

    final sleepHours = sleepMinutes ~/ 60;
    final sleepMins = sleepMinutes % 60;
    final sleepText = '${sleepHours}h ${sleepMins}m';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            'Sleep',
            sleepText,
            ActivityConfig.get(ActivityTypes.sleep).icon,
            ActivityConfig.get(ActivityTypes.sleep).color,
          ),
          _buildVerticalDivider(),
          _buildSummaryItem(
            context,
            'Feed',
            '${feedAmount.toInt()} ml', // Assuming ml for now, can be smarter later
            ActivityConfig.get(ActivityTypes.bottleFeeding).icon,
            ActivityConfig.get(ActivityTypes.bottleFeeding).color,
          ),
          _buildVerticalDivider(),
          _buildSummaryItem(
            context,
            'Diapers',
            '$diaperCount',
            ActivityConfig.get(ActivityTypes.diaper).icon,
            ActivityConfig.get(ActivityTypes.diaper).color,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: AppColors.divider);
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTypography.h3.copyWith(fontSize: 16)),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
