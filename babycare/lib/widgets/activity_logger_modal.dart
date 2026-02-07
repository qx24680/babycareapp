import 'package:flutter/cupertino.dart';
import '../core/constants/activity_types.dart';
import '../core/theme/app_theme.dart';
import '../models/activity.dart';
import '../services/activity_repository.dart';
import '../screens/breastfeeding_screen.dart';

import 'forms/sleep_form.dart';
import 'forms/diaper_form.dart';
import 'forms/bottle_feeding_form.dart';
import 'forms/pumping_form.dart';
import 'forms/potty_form.dart';
import 'forms/food_form.dart';
import 'forms/bath_form.dart';
import 'forms/misc_forms.dart';

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
  final _repository = ActivityRepository();

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

    final activity = _createActivityFromData(
      activityType,
      metadata,
      timestamp,
      endTime,
    );

    if (activity != null) {
      await _repository.insertActivity(activity);
    }

    if (!mounted) return;

    widget.onActivityLogged();
    Navigator.of(context).pop();
  }

  Activity? _createActivityFromData(
    String activityType,
    Map<String, dynamic> metadata,
    DateTime startTime,
    DateTime? endTime,
  ) {
    ActivityType type = ActivityType.fromDbValue(activityType);

    // Default values
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
    String? notes = metadata['notes'];

    // Map metadata for keys
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

    // Calculate duration for activities that pass start/end
    if (duration == null && endTime != null) {
      duration = endTime.difference(startTime).inMinutes;
    }

    return Activity(
      babyId: widget.babyId,
      // userId: widget.userId,
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
      notes: notes,
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
              ? ActivityConfig.get(selectedType!).label
              : 'New Entry',
          style: const TextStyle(color: CupertinoColors.white),
        ),
        leading: selectedType != null
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _goBack,
                child: const Icon(
                  CupertinoIcons.back,
                  color: CupertinoColors.white,
                ),
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: CupertinoColors.white,
                ),
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
    final gridTypes = [
      ActivityTypes.sleep,
      ActivityTypes.breastfeeding,
      ActivityTypes.bottleFeeding,
      ActivityTypes.diaper,
      ActivityTypes.nap,
      ActivityTypes.pumping,
      ActivityTypes.potty,
      ActivityTypes.food,
      ActivityTypes.bath,
      ActivityTypes.toothBrushing,
      ActivityTypes.crying,
      ActivityTypes.walkingOutside,
    ];

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose Activity', style: AppTypography.h2),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              children: gridTypes.map((type) {
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
      onTap: () {
        if (config.type == ActivityTypes.breastfeeding) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => BreastfeedingScreen(
                onSubmit:
                    ({
                      required String activityType,
                      required Map<String, dynamic> metadata,
                      DateTime? startTime,
                      DateTime? endTime,
                    }) async {
                      final timestamp = startTime ?? DateTime.now();
                      final activity = _createActivityFromData(
                        activityType,
                        metadata,
                        timestamp,
                        endTime,
                      );
                      if (activity != null) {
                        await _repository.insertActivity(activity);
                      }
                      widget.onActivityLogged();
                    },
              ),
            ),
          );
          return;
        }
        _selectActivityType(config.type);
      },
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
              child: Icon(config.icon, size: 32, color: config.color),
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
    return switch (type) {
      ActivityTypes.sleep => SleepForm(onSubmit: _logActivity),
      ActivityTypes.nap => SleepForm(onSubmit: _logActivity),
      ActivityTypes.breastfeeding => const SizedBox(),
      ActivityTypes.bottleFeeding => BottleFeedingForm(onSubmit: _logActivity),
      ActivityTypes.diaper => DiaperForm(onSubmit: _logActivity),
      ActivityTypes.pumping => PumpingForm(onSubmit: _logActivity),
      ActivityTypes.potty => PottyForm(onSubmit: _logActivity),
      ActivityTypes.food => FoodForm(onSubmit: _logActivity),
      ActivityTypes.bath => BathForm(onSubmit: _logActivity),
      ActivityTypes.toothBrushing => GenericTimeForm(
        activityType: type,
        title: 'Toothbrushing',
        onSubmit: _logActivity,
      ),
      ActivityTypes.crying => DurationForm(
        activityType: type,
        title: 'Crying',
        onSubmit: _logActivity,
      ),
      ActivityTypes.walkingOutside => DurationForm(
        activityType: type,
        title: 'Walking',
        onSubmit: _logActivity,
      ),
      _ => Center(child: Text('Form for $type coming soon')),
    };
  }
}
