import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../core/constants/activity_types.dart';
import '../core/theme/app_theme.dart';
import '../models/activity_log.dart';
import '../services/baby_repository.dart';
import 'forms/feeding_form.dart';
import 'forms/diaper_form.dart';
import 'forms/sleep_form.dart';
import 'forms/health_form.dart';
import 'forms/grooming_form.dart';
import 'forms/activity_form.dart';

class ActivityLoggerModal extends StatefulWidget {
  final int babyId;
  final int? userId;
  final VoidCallback onActivityLogged;

  const ActivityLoggerModal({
    super.key,
    required this.babyId,
    this.userId,
    required this.onActivityLogged,
  });

  @override
  State<ActivityLoggerModal> createState() => _ActivityLoggerModalState();
}

class _ActivityLoggerModalState extends State<ActivityLoggerModal> {
  String? selectedType;
  final _repository = BabyRepository();

  void _selectActivityType(String type) {
    setState(() => selectedType = type);
  }

  void _goBack() {
    setState(() => selectedType = null);
  }

  Future<void> _logActivity({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final timestamp = startTime ?? DateTime.now();
    
    // Check for conflicting activities
    if (await _hasConflictingActivity(activityType, timestamp)) {
      if (!mounted) return;
      _showConflictDialog();
      return;
    }

    final activity = ActivityLog(
      babyId: widget.babyId,
      userId: widget.userId,
      activityType: activityType,
      startTime: timestamp,
      endTime: endTime,
      details: jsonEncode(metadata),
    );

    await _repository.insertActivityLog(activity);
    
    if (!mounted) return;
    
    widget.onActivityLogged();
    Navigator.of(context).pop();
  }

  Future<bool> _hasConflictingActivity(String activityType, DateTime timestamp) async {
    try {
      final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
      final existingLogs = await _repository.getDailyLogs(widget.babyId, date);
      
      // Define conflicting activity pairs
      final conflicts = <String, List<String>>{
        ActivityTypes.feeding: [ActivityTypes.sleep],
        ActivityTypes.sleep: [ActivityTypes.feeding, ActivityTypes.activity],
        ActivityTypes.activity: [ActivityTypes.sleep],
      };

      final conflictingTypes = conflicts[activityType] ?? [];
      
      // Check if there's an activity at the exact same minute that conflicts
      return existingLogs.any((log) {
        if (!conflictingTypes.contains(log.activityType)) return false;
        
        // Check if timestamps are within the same minute
        final logMinute = DateTime(
          log.startTime.year,
          log.startTime.month,
          log.startTime.day,
          log.startTime.hour,
          log.startTime.minute,
        );
        final newMinute = DateTime(
          timestamp.year,
          timestamp.month,
          timestamp.day,
          timestamp.hour,
          timestamp.minute,
        );
        
        return logMinute == newMinute;
      });
    } catch (e) {
      return false;
    }
  }

  void _showConflictDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Conflicting Activity'),
        content: const Text(
          'An activity that cannot occur at the same time is already logged for this minute. '
          'Please choose a different time or edit the existing activity.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.primary,
        middle: Text(
          selectedType != null 
              ? 'Log ${ActivityConfig.get(selectedType!).label}'
              : 'Quick Log Activity',
        ),
        leading: selectedType != null
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _goBack,
                child: const Icon(CupertinoIcons.back),
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Icon(CupertinoIcons.xmark),
              ),
      ),
      child: SafeArea(
        child: selectedType == null
            ? _buildActivityGrid()
            : _buildActivityForm(selectedType!),
      ),
    );
  }

  Widget _buildActivityGrid() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What would you like to log?',
            style: AppTypography.h2,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              children: ActivityTypes.all.map((type) {
                final config = ActivityConfig.get(type);
                return _buildActivityCard(config);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityConfig config) {
    return GestureDetector(
      onTap: () => _selectActivityType(config.type),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CupertinoColors.white,
              config.lightColor.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.card,
          border: Border.all(
            color: config.color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    config.lightColor,
                    config.color.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: config.color.withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                config.icon,
                size: 32,
                color: config.color,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              config.label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityForm(String type) {
    switch (type) {
      case ActivityTypes.feeding:
        return FeedingForm(onSubmit: _logActivity);
      case ActivityTypes.diaper:
        return DiaperForm(onSubmit: _logActivity);
      case ActivityTypes.sleep:
        return SleepForm(onSubmit: _logActivity);
      case ActivityTypes.health:
        return HealthForm(onSubmit: _logActivity);
      case ActivityTypes.grooming:
        return GroomingForm(onSubmit: _logActivity);
      case ActivityTypes.activity:
        return ActivityForm(onSubmit: _logActivity);
      default:
        return Center(
          child: Text('Form for $type coming soon'),
        );
    }
  }
}
