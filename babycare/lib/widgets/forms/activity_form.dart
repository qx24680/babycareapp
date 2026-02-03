import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../core/theme/app_theme.dart';

class ActivityForm extends StatefulWidget {
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  }) onSubmit;

  const ActivityForm({super.key, required this.onSubmit});

  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  String activityName = '';
  int durationMinutes = 30;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final metadata = {
      'activity_name': activityName,
      'duration_minutes': durationMinutes,
    };

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: ActivityTypes.activity,
      metadata: metadata,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Activity Name', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          CupertinoTextField(
            placeholder: 'e.g., Tummy time, Play time',
            padding: const EdgeInsets.all(AppSpacing.md),
            onChanged: (value) => activityName = value,
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text('Duration', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$durationMinutes min',
                    style: AppTypography.h2.copyWith(color: AppColors.primary),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (durationMinutes > 5) {
                      setState(() => durationMinutes -= 5);
                    }
                  },
                  child: const Icon(CupertinoIcons.minus_circle_fill),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => durationMinutes += 5),
                  child: const Icon(CupertinoIcons.plus_circle_fill),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Notes
          const Text('Notes (Optional)', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          CupertinoTextField(
            controller: _notesController,
            placeholder: 'Add any notes...',
            maxLines: 3,
            padding: const EdgeInsets.all(AppSpacing.md),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Submit Button
          CupertinoButton(
            color: AppColors.primary,
            onPressed: _submit,
            child: const Text('Log Activity', style: TextStyle(color: AppColors.text)),
          ),
        ],
      ),
    );
  }
}
