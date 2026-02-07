import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Needed for Material and InkWell
import 'package:intl/intl.dart';
import '../core/constants/activity_types.dart';
import '../core/theme/app_theme.dart';
import '../models/activity.dart';

class TimelineFeed extends StatelessWidget {
  final List<Activity> activities;
  final VoidCallback onRefresh;
  final Function(Activity) onActivityTap;

  const TimelineFeed({
    super.key,
    required this.activities,
    required this.onRefresh,
    required this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            onRefresh();
          },
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final isLast = index == activities.length - 1;
              return _buildActivityCard(activities[index], isLast);
            }, childCount: activities.length),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Icon(
              CupertinoIcons.heart_circle_fill,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('No activities for this day', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Use the "Quick Log" above to add one',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Activity activity, bool isLast) {
    final config = ActivityConfig.get(activity.type.dbValue);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline visualization
          SizedBox(
            width: 24, // Narrower timeline
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 14), // Align with title
                  decoration: BoxDecoration(
                    color: config.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: CupertinoColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: config.color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.divider.withValues(alpha: 0.6),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Activity Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.text.withValues(alpha: 0.03),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Material(
                    // Material for ripple if clickable later
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onActivityTap(activity);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: config.lightColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    config.icon,
                                    size: 18,
                                    color: config.color,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),

                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _getActivityTitle(activity),
                                            style: AppTypography.body.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'h:mm a',
                                            ).format(activity.startTime),
                                            style: AppTypography.caption
                                                .copyWith(
                                                  color: AppColors.textLight,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      if (_getActivitySubtext(
                                        activity,
                                      ).isNotEmpty)
                                        Text(
                                          _getActivitySubtext(activity),
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.text
                                                    .withOpacity(0.8),
                                                height: 1.3,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (activity.notes != null &&
                                activity.notes!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 46,
                                ), // Align with text
                                child: Text(
                                  activity.notes!,
                                  style: AppTypography.caption.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityTitle(Activity activity) {
    switch (activity.type) {
      case ActivityType.breastfeeding:
        return 'Breastfeeding';
      case ActivityType.bottleFeeding:
        return 'Bottle Feeding';
      case ActivityType.food:
        return 'Food';
      case ActivityType.diaper:
        return 'Diaper Change';
      case ActivityType.sleep:
      case ActivityType.nap:
        return activity.type == ActivityType.nap ? 'Nap' : 'Sleep';
      case ActivityType.pumping:
        return 'Pumping';
      case ActivityType.potty:
        return 'Potty';
      case ActivityType.bath:
        return 'Bath';
      case ActivityType.toothBrushing:
        return 'Tooth Brushing';
      case ActivityType.crying:
        return 'Crying';
      case ActivityType.walkingOutside:
        return 'Walking';
      default:
        return ActivityConfig.get(activity.type.dbValue).label;
    }
  }

  String _getActivitySubtext(Activity activity) {
    switch (activity.type) {
      case ActivityType.breastfeeding:
        final duration = activity.durationMinutes ?? 0;
        final side = _capitalize(activity.side?.name ?? '');
        return '$side side • $duration min';

      case ActivityType.bottleFeeding:
        final amount = activity.amount ?? 0;
        final unit =
            activity.unit?.name ??
            'ml'; // unit usually short like 'ml' or 'oz', keep lowercase
        final milk = _capitalize(activity.milkType?.name ?? '');
        return '$amount $unit • $milk';

      case ActivityType.food:
        final amount = activity.amount ?? 0;
        final unit = activity.unit?.name ?? '';
        return '$amount $unit';

      case ActivityType.diaper:
        List<String> conditions = [];
        if (activity.isWet == true) conditions.add('Wet');
        if (activity.isDry == true) conditions.add('Dry');
        return conditions.join(' & ');

      case ActivityType.sleep:
      case ActivityType.nap:
        final duration = activity.durationMinutes;
        return duration != null ? '$duration min' : 'Sleeping';

      case ActivityType.pumping:
        final amount = activity.amount ?? 0;
        final unit = activity.unit?.name ?? 'ml';
        final side = _capitalize(activity.pumpSide?.name ?? '');
        return '$amount $unit • $side';

      case ActivityType.potty:
        return _capitalize(activity.pottyType?.name ?? 'Potty');

      case ActivityType.bath:
        return activity.hairWash == true ? 'Hair Wash' : 'Bath';

      case ActivityType.crying:
      case ActivityType.walkingOutside:
        final duration = activity.durationMinutes ?? 0;
        return '$duration min';

      default:
        return '';
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
