import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../core/theme/app_theme.dart';

class SleepForm extends StatefulWidget {
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  }) onSubmit;

  const SleepForm({super.key, required this.onSubmit});

  @override
  State<SleepForm> createState() => _SleepFormState();
}

class _SleepFormState extends State<SleepForm> {
  DateTime startTime = DateTime.now();
  DateTime? endTime;
  bool isNap = true;
  String sleepQuality = 'good';
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final metadata = {
      'is_nap': isNap,
      'quality': sleepQuality,
    };

    if (endTime != null) {
      final duration = endTime!.difference(startTime).inMinutes;
      metadata['duration_minutes'] = duration;
    }

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: ActivityTypes.sleep,
      metadata: metadata,
      startTime: startTime,
      endTime: endTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sleep Type
          const Text('Sleep Type', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          CupertinoSegmentedControl<bool>(
            children: const {
              true: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text('Nap'),
              ),
              false: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text('Night Sleep'),
              ),
            },
            groupValue: isNap,
            onValueChanged: (value) => setState(() => isNap = value),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Start Time
          _buildTimePicker(
            label: 'Start Time',
            time: startTime,
            onChanged: (newTime) => setState(() => startTime = newTime),
          ),
          const SizedBox(height: AppSpacing.md),

          // End Time (Optional)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('End Time (Optional)', style: AppTypography.body),
                    ),
                    CupertinoSwitch(
                      value: endTime != null,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          endTime = value ? DateTime.now() : null;
                        });
                      },
                    ),
                  ],
                ),
                if (endTime != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 100,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: endTime,
                      onDateTimeChanged: (newTime) {
                        setState(() => endTime = newTime);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sleep Quality
          const Text('Sleep Quality', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildQualityButton('poor', '😴', const Color(0xFFFFCDD2)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildQualityButton('good', '😊', const Color(0xFFC8E6C9)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildQualityButton('excellent', '😴✨', const Color(0xFFB2DFDB)),
              ),
            ],
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
            child: const Text('Log Sleep', style: TextStyle(color: AppColors.text)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required DateTime time,
    required ValueChanged<DateTime> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.body),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 100,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: time,
              onDateTimeChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityButton(String quality, String emoji, Color color) {
    final isSelected = sleepQuality == quality;
    return GestureDetector(
      onTap: () => setState(() => sleepQuality = quality),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? color : CupertinoColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color : AppColors.text.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: isSelected ? AppShadows.md : AppShadows.sm,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              quality.toUpperCase(),
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
