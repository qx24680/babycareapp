import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../core/constants/activity_types.dart';
import '../core/theme/app_theme.dart';
import '../models/activity_log.dart';

class TimelineFeed extends StatelessWidget {
  final List<ActivityLog> activities;
  final VoidCallback onRefresh;

  const TimelineFeed({
    super.key,
    required this.activities,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return _buildEmptyState();
    }

    // Group activities by date
    final groupedActivities = _groupByDate(activities);
    
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            onRefresh();
          },
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dateKey = groupedActivities.keys.elementAt(index);
                final dayActivities = groupedActivities[dateKey]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateHeader(dateKey),
                    const SizedBox(height: AppSpacing.md),
                    ...dayActivities.asMap().entries.map((entry) {
                      final isLast = entry.key == dayActivities.length - 1;
                      return _buildActivityCard(entry.value, isLast);
                    }),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                );
              },
              childCount: groupedActivities.length,
            ),
          ),
        ),
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
              CupertinoIcons.calendar,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'No activities yet',
            style: AppTypography.h2,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap the + button to log your first activity',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String dateKey) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        _formatDateHeader(dateKey),
        style: AppTypography.h3.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildActivityCard(ActivityLog activity, bool isLast) {
    final config = ActivityConfig.get(activity.activityType);
    final metadata = activity.detailsMap ?? {};
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: config.lightColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: config.color, width: 2),
                ),
                child: Icon(config.icon, color: config.color, size: 20),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        config.color.withValues(alpha: 0.3),
                        AppColors.text.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          
          // Activity card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.sm,
                border: Border(
                  left: BorderSide(color: config.color, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getActivityTitle(activity, metadata),
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(activity.startTime),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.text.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _getActivitySubtext(activity, metadata),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.7),
                    ),
                  ),
                  if (metadata.containsKey('notes')) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        metadata['notes'],
                        style: AppTypography.bodySmall.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<ActivityLog>> _groupByDate(List<ActivityLog> activities) {
    final Map<String, List<ActivityLog>> grouped = {};
    
    for (final activity in activities) {
      final dateKey = DateFormat('yyyy-MM-dd').format(activity.startTime);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(activity);
    }
    
    // Sort each day's activities by time (newest first)
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => b.startTime.compareTo(a.startTime));
    }
    
    return grouped;
  }

  String _formatDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (date.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  String _getActivityTitle(ActivityLog activity, Map<String, dynamic> metadata) {
    switch (activity.activityType) {
      case ActivityTypes.feeding:
        final feedingType = metadata['feeding_type'] ?? 'Feeding';
        return feedingType == FeedingTypes.breast
            ? 'Breastfeeding'
            : feedingType == FeedingTypes.bottle
                ? 'Bottle Feeding'
                : 'Solid Food';
      case ActivityTypes.diaper:
        return 'Diaper Change';
      case ActivityTypes.sleep:
        return metadata['is_nap'] == true ? 'Nap' : 'Night Sleep';
      case ActivityTypes.health:
        final healthType = metadata['health_type'];
        return healthType == HealthEventTypes.temperature
            ? 'Temperature Check'
            : healthType == HealthEventTypes.symptom
                ? 'Symptom'
                : healthType == HealthEventTypes.medication
                    ? 'Medication'
                    : 'Health Event';
      case ActivityTypes.grooming:
        final groomingType = metadata['grooming_type'];
        return groomingType == GroomingTypes.bath
            ? 'Bath Time'
            : groomingType == GroomingTypes.nails
                ? 'Nail Trim'
                : 'Hair Care';
      case ActivityTypes.activity:
        return metadata['activity_name'] ?? 'Activity';
      default:
        return ActivityConfig.get(activity.activityType).label;
    }
  }

  String _getActivitySubtext(ActivityLog activity, Map<String, dynamic> metadata) {
    switch (activity.activityType) {
      case ActivityTypes.feeding:
        final feedingType = metadata['feeding_type'];
        if (feedingType == FeedingTypes.breast) {
          final duration = metadata['duration_minutes'] ?? 0;
          final side = metadata['side'] ?? '';
          return '$side side • $duration min';
        } else if (feedingType == FeedingTypes.bottle) {
          final amount = metadata['amount_ml'] ?? 0;
          return '$amount ml';
        } else {
          return metadata['food_type'] ?? 'Solid food';
        }
      case ActivityTypes.diaper:
        final type = metadata['type'] ?? DiaperTypes.pee;
        final hasRash = metadata['has_rash'] == true;
        return hasRash ? '$type • Rash detected' : type;
      case ActivityTypes.sleep:
        final duration = metadata['duration_minutes'];
        final quality = metadata['quality'] ?? 'good';
        return duration != null ? '$duration min • $quality' : quality;
      case ActivityTypes.health:
        final healthType = metadata['health_type'];
        if (healthType == HealthEventTypes.temperature) {
          final temp = metadata['temperature_celsius'];
          return temp != null ? '$temp°C' : 'Temperature check';
        } else if (healthType == HealthEventTypes.symptom) {
          final symptom = metadata['symptom'];
          final severity = metadata['severity'];
          return '$symptom • Severity: $severity/10';
        } else if (healthType == HealthEventTypes.medication) {
          final medication = metadata['medication'];
          final dosage = metadata['dosage'];
          return '$medication • $dosage';
        }
        return 'Health event';
      case ActivityTypes.grooming:
        return _getActivityTitle(activity, metadata);
      case ActivityTypes.activity:
        final duration = metadata['duration_minutes'] ?? 0;
        return '$duration minutes';
      default:
        return '';
    }
  }
}
