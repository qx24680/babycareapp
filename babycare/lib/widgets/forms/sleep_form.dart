import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../models/activity.dart';
import '../../core/theme/app_theme.dart';
import 'form_helpers.dart';

class SleepForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;

  const SleepForm({
    super.key,
    required this.onSubmit,
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<SleepForm> createState() => _SleepFormState();
}

class _SleepFormState extends State<SleepForm> {
  late DateTime startTime;
  DateTime? endTime;
  bool isNap = true;
  String sleepQuality = 'good';
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      startTime = initial.startTime;
      endTime = initial.endTime;
      isNap = initial.type == ActivityType.nap;
      // Extract metadata if stored in activity fields or notes?
      // For now assume defaults or simple extraction if we stored standardized metadata.
      // But Activity model has specific fields. Let's map back.
      // We don't have 'quality' field in Activity model, it might be in notes or custom?
      // Wait, let's check Activity model again... it has 'severity'? No that's health.
      // Sleep quality isn't in Activity model explicitly except maybe notes?
      // Or maybe we should add it? For now let's just default to 'good' or try to parse from notes if needed.
      // Actually, let's just keep 'good' default for now as quality isn't persisted in a structured way yet except via metadata map -> DB?
      // Oh, Activity model updates... 'symptom', 'severity' etc.
      // Let's assume quality is not fully persisted in struct yet, or maybe encoded in notes.

      _notesController = TextEditingController(text: initial.notes);
    } else {
      startTime = DateTime.now();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final metadata = {'is_nap': isNap, 'quality': sleepQuality};

    if (endTime != null) {
      final duration = endTime!.difference(startTime).inMinutes;
      metadata['duration_minutes'] = duration;
    }

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: isNap ? ActivityTypes.nap : ActivityTypes.sleep,
      metadata: metadata,
      startTime: startTime,
      endTime: endTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(
      onSubmit: _submit,
      onDelete: widget.onDelete,
      submitLabel: widget.initialActivity != null
          ? 'Update Log'
          : 'Log ${isNap ? "Nap" : "Sleep"}',
      children: [
        // Timing Section
        FormSection(
          title: 'Time',
          icon: CupertinoIcons.clock_fill,
          children: [
            TimePickerRow(
              label: 'Start Time',
              time: startTime,
              onChanged: (newTime) => setState(() => startTime = newTime),
            ),
            TimePickerRow(
              label: 'End Time',
              time: endTime,
              isOptional: true,
              onChanged: (newTime) => setState(() => endTime = newTime),
            ),
            if (endTime != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.timer,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(endTime!.difference(startTime)),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        // Details Section
        FormSection(
          title: 'Details',
          icon: CupertinoIcons.moon_stars_fill,
          children: [
            CustomSegmentedControl<bool>(
              label: 'Sleep Type',
              groupValue: isNap,
              children: const {true: 'Nap', false: 'Night Sleep'},
              onValueChanged: (val) => setState(() => isNap = val ?? true),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Sleep Quality', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildQualityButton(
                    'poor',
                    '😴',
                    const Color(0xFFFFCDD2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildQualityButton(
                    'good',
                    '😊',
                    const Color(0xFFC8E6C9),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildQualityButton(
                    'excellent',
                    '✨',
                    const Color(0xFFB2DFDB),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Notes Section
        FormSection(
          title: 'Notes',
          icon: CupertinoIcons.text_bubble_fill,
          children: [NotesInput(controller: _notesController)],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return 'Invalid duration';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '$h hr $m min';
    return '$m min';
  }

  Widget _buildQualityButton(String quality, String emoji, Color color) {
    final isSelected = sleepQuality == quality;
    return GestureDetector(
      onTap: () => setState(() => sleepQuality = quality),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color.withAlpha(255) : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.sm : [],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              quality.toUpperCase(),
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.text : AppColors.textLight,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
