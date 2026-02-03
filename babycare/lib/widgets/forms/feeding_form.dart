import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../core/theme/app_theme.dart';

class FeedingForm extends StatefulWidget {
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  }) onSubmit;

  const FeedingForm({super.key, required this.onSubmit});

  @override
  State<FeedingForm> createState() => _FeedingFormState();
}

class _FeedingFormState extends State<FeedingForm> {
  String feedingType = FeedingTypes.breast;
  String side = 'left';
  int durationMinutes = 15;
  double amountMl = 120;
  String foodType = '';
  DateTime selectedDateTime = DateTime.now();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final metadata = <String, dynamic>{
      'feeding_type': feedingType,
    };

    if (feedingType == FeedingTypes.breast) {
      metadata['side'] = side;
      metadata['duration_minutes'] = durationMinutes;
    } else if (feedingType == FeedingTypes.bottle) {
      metadata['amount_ml'] = amountMl;
    } else if (feedingType == FeedingTypes.solid) {
      metadata['food_type'] = foodType;
    }

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: ActivityTypes.feeding,
      metadata: metadata,
      startTime: selectedDateTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Feeding Type Selector
          const Text('Feeding Type', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          CupertinoSegmentedControl<String>(
            padding: const EdgeInsets.all(4),
            children: const {
              FeedingTypes.breast: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('Breast'),
              ),
              FeedingTypes.bottle: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('Bottle'),
              ),
              FeedingTypes.solid: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('Solid'),
              ),
            },
            groupValue: feedingType,
            onValueChanged: (value) => setState(() => feedingType = value),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Conditional Fields based on type
          if (feedingType == FeedingTypes.breast) ...[
            _buildBreastFeedingFields(),
          ] else if (feedingType == FeedingTypes.bottle) ...[
            _buildBottleFeedingFields(),
          ] else if (feedingType == FeedingTypes.solid) ...[
            _buildSolidFeedingFields(),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Date & Time Picker
          const Text('Date & Time', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.sm,
            ),
            child: Column(
              children: [
                Text(
                  '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} ${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 150,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: selectedDateTime,
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (newDateTime) {
                      setState(() => selectedDateTime = newDateTime);
                    },
                  ),
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
            child: const Text('Log Feeding', style: TextStyle(color: AppColors.text)),
          ),
        ],
      ),
    );
  }

  Widget _buildBreastFeedingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Side', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        CupertinoSegmentedControl<String>(
          children: const {
            'left': Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text('Left'),
            ),
            'right': Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text('Right'),
            ),
            'both': Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text('Both'),
            ),
          },
          groupValue: side,
          onValueChanged: (value) => setState(() => side = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('Duration', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                '$durationMinutes minutes',
                style: AppTypography.h2.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (durationMinutes > 1) {
                  setState(() => durationMinutes -= 1);
                }
              },
              child: const Icon(CupertinoIcons.minus_circle_fill),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => setState(() => durationMinutes += 1),
              child: const Icon(CupertinoIcons.plus_circle_fill),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottleFeedingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Amount', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                '${amountMl.toInt()} ml',
                style: AppTypography.h2.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (amountMl > 10) {
                  setState(() => amountMl -= 10);
                }
              },
              child: const Icon(CupertinoIcons.minus_circle_fill),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => setState(() => amountMl += 10),
              child: const Icon(CupertinoIcons.plus_circle_fill),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSolidFeedingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Food Type', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        CupertinoTextField(
          placeholder: 'e.g., Rice cereal, Apple puree',
          padding: const EdgeInsets.all(AppSpacing.md),
          onChanged: (value) => foodType = value,
        ),
      ],
    );
  }
}
