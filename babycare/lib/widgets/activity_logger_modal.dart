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
    final activity = ActivityLog(
      babyId: widget.babyId,
      userId: widget.userId,
      activityType: activityType,
      startTime: startTime ?? DateTime.now(),
      endTime: endTime,
      details: jsonEncode(metadata),
    );

    await _repository.insertActivityLog(activity);
    
    if (!mounted) return;
    
    widget.onActivityLogged();
    Navigator.of(context).pop();
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
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: config.lightColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
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
