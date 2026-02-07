import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Colors; // Using Colors reference if needed, but AppColors is better
import '../core/theme/app_theme.dart';

import '../services/statistics_service.dart';
import '../models/activity.dart'; // For ActivityType enum
import '../widgets/stats/stats_charts.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Default to Sleep or first activity
  ActivityType _selectedType = ActivityType.sleep;
  // Default range: Last 7 Days
  DateTime _rangeEnd = DateTime.now();
  late DateTime _rangeStart;

  final StatisticsService _statsService = StatisticsService();

  @override
  void initState() {
    super.initState();
    // Start of 6 days ago (total 7 days including today)
    _rangeStart = _rangeEnd.subtract(const Duration(days: 6));
  }

  void _onActivitySelected(ActivityType type) {
    setState(() {
      _selectedType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Statistics',
          style: AppTypography.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.background.withValues(
          alpha: 0.9,
        ), // Transparent-ish
        border: Border(bottom: BorderSide(color: AppColors.divider)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Placeholder for date picker
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              'Last 7 Days',
              style: AppTypography.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),

            // --- Activity Selector ---
            SizedBox(
              height: 50,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                scrollDirection: Axis.horizontal,
                itemCount: ActivityType.values.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final type = ActivityType.values[index];
                  if (type == ActivityType.other)
                    return const SizedBox.shrink(); // Skip 'other'

                  final isSelected = _selectedType == type;

                  // Label Logic
                  String label = type.name.toUpperCase();
                  switch (type) {
                    case ActivityType.breastfeeding:
                      label = "Nursing";
                      break;
                    case ActivityType.bottleFeeding:
                      label = "Bottle";
                      break;
                    case ActivityType.walkingOutside:
                      label = "Walk";
                      break;
                    case ActivityType.toothBrushing:
                      label = "Brushing";
                      break;
                    default:
                      label =
                          type.name[0].toUpperCase() + type.name.substring(1);
                  }

                  return GestureDetector(
                    onTap: () => _onActivitySelected(type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                        boxShadow: isSelected ? AppShadows.sm : [],
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.text,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // --- Charts Area ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _buildContentForType(_selectedType),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentForType(ActivityType type) {
    // This will eventually return specific chart widgets based on type
    return StatsCharts(
      type: type,
      startDate: _rangeStart,
      endDate: _rangeEnd,
      service: _statsService,
    );
  }
}
