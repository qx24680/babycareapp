import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../core/theme/app_theme.dart';

class GroomingForm extends StatefulWidget {
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  }) onSubmit;

  const GroomingForm({super.key, required this.onSubmit});

  @override
  State<GroomingForm> createState() => _GroomingFormState();
}

class _GroomingFormState extends State<GroomingForm> {
  String groomingType = GroomingTypes.bath;
  DateTime selectedDateTime = DateTime.now();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final metadata = {
      'grooming_type': groomingType,
    };

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: ActivityTypes.grooming,
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
          const Text('Grooming Type', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          
          _buildGroomingButton(
            type: GroomingTypes.bath,
            icon: CupertinoIcons.drop_fill,
            label: 'Bath',
            description: 'Full body bath',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildGroomingButton(
            type: GroomingTypes.nails,
            icon: CupertinoIcons.scissors,
            label: 'Nail Trim',
            description: 'Trimmed nails',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildGroomingButton(
            type: GroomingTypes.hair,
            icon: CupertinoIcons.sparkles,
            label: 'Hair',
            description: 'Hair care',
          ),
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
            child: const Text('Log Grooming', style: TextStyle(color: AppColors.text)),
          ),
        ],
      ),
    );
  }

  Widget _buildGroomingButton({
    required String type,
    required IconData icon,
    required String label,
    required String description,
  }) {
    final isSelected = groomingType == type;
    return GestureDetector(
      onTap: () => setState(() => groomingType = type),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : CupertinoColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.text.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: isSelected ? AppShadows.md : AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.text.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: isSelected ? CupertinoColors.white : AppColors.text,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
