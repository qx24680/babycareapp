import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/activity.dart';
import '../services/activity_repository.dart';
import '../widgets/timeline_feed.dart';
import '../widgets/activity_selector.dart';
import '../widgets/date_timeline.dart';
import '../widgets/daily_summary.dart';

import '../widgets/forms/sleep_form.dart';
import '../widgets/forms/diaper_form.dart';
import '../widgets/forms/bottle_feeding_form.dart';
import '../widgets/forms/pumping_form.dart';
import '../widgets/forms/potty_form.dart';
import '../widgets/forms/food_form.dart';
import '../widgets/forms/bath_form.dart';
import '../widgets/forms/health_form.dart';
import '../widgets/forms/grooming_form.dart';
import '../widgets/forms/measurement_form.dart';
import '../widgets/forms/misc_forms.dart';

import '../services/measurement_repository.dart';
import '../models/measurement.dart';
import '../core/constants/activity_types.dart';
import 'breastfeeding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title, this.babyId, this.userId});

  final String title;
  final int? babyId;
  final int? userId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = ActivityRepository();
  List<Activity> _activities = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (widget.babyId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final dailyLogs = await _repository.getDailyLogs(
        widget.babyId!,
        _selectedDate,
      );

      // Sort by newest first
      dailyLogs.sort((a, b) => b.startTime.compareTo(a.startTime));

      if (mounted) {
        setState(() {
          _activities = dailyLogs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadActivities();
  }

  void _onActivitySelected(String type) {
    if (widget.babyId == null) return;

    if (type == ActivityTypes.breastfeeding) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => BreastfeedingScreen(
            onSubmit:
                ({
                  required String activityType,
                  required Map<String, dynamic> metadata,
                  DateTime? startTime,
                  DateTime? endTime,
                }) {
                  _logActivity(
                    activityType: activityType,
                    metadata: metadata,
                    startTime: startTime,
                    endTime: endTime,
                  );
                },
          ),
        ),
      );
      return;
    }

    _showActivityForm(type, null);
  }

  void _showActivityForm(String type, Activity? activity) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoPageScaffold(
        backgroundColor: AppColors.background,
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            activity == null
                ? 'Log ${ActivityConfig.get(type).label}'
                : 'Edit ${ActivityConfig.get(type).label}',
          ),
          backgroundColor: AppColors.background,
          border: null,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        child: SafeArea(child: _buildActivityForm(type, activity)),
      ),
    );
  }

  void _editActivity(Activity activity) {
    _showActivityForm(activity.type.dbValue, activity);
  }

  Future<void> _logActivity({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (widget.babyId == null) return;

    final timestamp = startTime ?? DateTime.now();

    // Special handling for Measurements (Separate Table)
    if (activityType == ActivityTypes.measurement) {
      await _saveMeasurement(metadata, timestamp);
    } else {
      // Standard Activity
      final activity = _createActivityFromData(
        activityType,
        metadata,
        timestamp,
        endTime,
      );

      if (activity != null) {
        if (metadata.containsKey('id') && metadata['id'] != null) {
          // Update existing
          await _repository.updateActivity(
            activity.copyWith(id: metadata['id']),
          );
        } else {
          // Create new
          await _repository.insertActivity(activity);
        }
      }
    }

    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    _loadActivities(); // Refresh list
  }

  // Wrapper to handle updates from forms
  // The forms call back with metadata. We need to pass the ID if we are editing.
  // The forms don't know about ID, but the HomeScreen knows if it passed an activity.
  // Wait, the forms call `onSubmit`. If I reuse `_logActivity`, I need to know the ID.
  // The closures below inside `_buildActivityForm` will capture the ID.

  Future<void> _deleteActivity(int id) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Activity?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _repository.deleteActivity(id);
              if (mounted) {
                Navigator.pop(context); // Close form
                _loadActivities();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMeasurement(
    Map<String, dynamic> metadata,
    DateTime time,
  ) async {
    final measurement = Measurement(
      babyId: widget.babyId!,
      time: time,
      weight: (metadata['weight'] as num?)?.toDouble(),
      weightUnit: metadata['weight_unit'],
      height: (metadata['height'] as num?)?.toDouble(),
      heightUnit: metadata['height_unit'],
      headCircumference: (metadata['head_circumference'] as num?)?.toDouble(),
      headCircumferenceUnit: metadata['head_circumference_unit'],
      notes: metadata['notes'],
    );
    await MeasurementRepository().addMeasurement(measurement);
  }

  Activity? _createActivityFromData(
    String activityType,
    Map<String, dynamic> metadata,
    DateTime startTime,
    DateTime? endTime,
  ) {
    ActivityType type = ActivityType.fromDbValue(activityType);

    BreastSide? side;
    MilkType? milkType;
    QuantityUnit? unit;
    double? amount;
    int? duration;
    bool? isWet;
    bool? isDry;
    bool? hairWash;
    PottyType? pottyType;
    PumpSide? pumpSide;

    // New fields
    double? temperature;
    String? symptom;
    int? severity;
    String? medication;
    String? dosage;
    String? groomingType;

    String? notes = metadata['notes'];

    if (metadata.containsKey('side')) {
      side = BreastSide.fromString(metadata['side']);
    }
    if (metadata.containsKey('duration_minutes')) {
      duration = metadata['duration_minutes'];
    }
    if (metadata.containsKey('amount')) {
      amount = (metadata['amount'] as num?)?.toDouble();
    }
    if (metadata.containsKey('unit')) {
      unit = QuantityUnit.fromString(metadata['unit']);
    }
    if (metadata.containsKey('milk_type')) {
      milkType = MilkType.fromString(metadata['milk_type']);
    }
    if (metadata.containsKey('pump_side')) {
      pumpSide = PumpSide.fromString(metadata['pump_side']);
    }
    if (metadata.containsKey('potty_type')) {
      pottyType = PottyType.fromString(metadata['potty_type']);
    }
    if (metadata.containsKey('hair_wash')) {
      hairWash = (metadata['hair_wash'] as int?) == 1;
    }
    if (metadata.containsKey('is_wet')) {
      isWet = (metadata['is_wet'] as int?) == 1;
    }
    if (metadata.containsKey('is_dry')) {
      isDry = (metadata['is_dry'] as int?) == 1;
    }

    // Map new fields
    if (metadata.containsKey('temperature_celsius')) {
      temperature = (metadata['temperature_celsius'] as num?)?.toDouble();
    }
    if (metadata.containsKey('symptom')) {
      symptom = metadata['symptom'];
    }
    if (metadata.containsKey('severity')) {
      severity = metadata['severity'];
    }
    if (metadata.containsKey('medication')) {
      medication = metadata['medication'];
    }
    if (metadata.containsKey('dosage')) {
      dosage = metadata['dosage'];
    }
    if (metadata.containsKey('grooming_type')) {
      groomingType = metadata['grooming_type'];
    }

    if (duration == null && endTime != null) {
      duration = endTime.difference(startTime).inMinutes;
    }

    return Activity(
      babyId: widget.babyId!,
      type: type,
      startTime: startTime,
      endTime: endTime,
      side: side,
      milkType: milkType,
      amount: amount,
      unit: unit,
      durationMinutes: duration,
      isWet: isWet,
      isDry: isDry,
      hairWash: hairWash,
      pottyType: pottyType,
      pumpSide: pumpSide,

      // Pass new fields
      temperature: temperature,
      symptom: symptom,
      severity: severity,
      medication: medication,
      dosage: dosage,
      groomingType: groomingType,

      notes: notes,
    );
  }

  Widget _buildActivityForm(String type, Activity? activity) {
    // Helper to capture update logic
    onSubmit({
      required String activityType,
      required Map<String, dynamic> metadata,
      DateTime? startTime,
      DateTime? endTime,
    }) {
      if (activity != null) {
        metadata['id'] = activity.id;
      }
      _logActivity(
        activityType: activityType,
        metadata: metadata,
        startTime: startTime,
        endTime: endTime,
      );
    }

    // Helper for delete
    final onDelete = activity != null
        ? () => _deleteActivity(activity.id!)
        : null;

    return switch (type) {
      ActivityTypes.sleep => SleepForm(
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.nap => SleepForm(
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.breastfeeding => const SizedBox(),
      ActivityTypes.bottleFeeding => BottleFeedingForm(
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.diaper => DiaperForm(
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.pumping => PumpingForm(
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.potty => PottyForm(
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.food => FoodForm(
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.bath => BathForm(
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.toothBrushing => GenericTimeForm(
        activityType: type,
        title: 'Toothbrushing',
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.crying => DurationForm(
        activityType: type,
        title: 'Crying',
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.walkingOutside => DurationForm(
        activityType: type,
        title: 'Walking',
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.health => HealthForm(
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.grooming => GroomingForm(
        onSubmit: onSubmit,
        initialActivity: activity,
        onDelete: onDelete,
      ),
      ActivityTypes.measurement => MeasurementForm(
        onSubmit: onSubmit,
        initialActivity:
            activity, // MeasurementForm might need this if we want to edit measurements
        onDelete: onDelete,
      ),
      _ => Center(child: Text('Form for $type coming soon')),
    };
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.title,
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle
              .copyWith(color: AppColors.text, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        border: Border(bottom: BorderSide(color: AppColors.divider)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: Navigate to profile/settings
          },
          child: const Icon(
            CupertinoIcons.person_circle,
            color: AppColors.primary,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 1. Date Timeline
            const SizedBox(height: AppSpacing.md),
            DateTimeline(
              selectedDate: _selectedDate,
              onDateSelected: _onDateSelected,
            ),

            // 2. Activity Selector
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Log',
                  style: AppTypography.h3.copyWith(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ActivitySelector(onActivitySelected: _onActivitySelected),

            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Divider(color: AppColors.divider, height: 1),
            ),

            // 3. Timeline Feed
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(
                        radius: 16,
                        color: AppColors.primary,
                      ),
                    )
                  : widget.babyId == null
                  ? _buildNoBabyState()
                  : Container(
                      color: AppColors.background,
                      child: TimelineFeed(
                        activities: _activities,
                        onRefresh: _loadActivities,
                        onActivityTap: _editActivity,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoBabyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.secondary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: AppShadows.md,
              ),
              child: const Icon(
                CupertinoIcons.person_2_fill,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Welcome to BabyCare!',
              style: AppTypography.h1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Create a baby profile to start tracking activities',
              style: AppTypography.body.copyWith(
                color: AppColors.text.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.md,
              ),
              child: CupertinoButton(
                onPressed: () {
                  // TODO: Navigate to create baby profile
                },
                child: const Text(
                  'Create Baby Profile',
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
