import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../models/activity.dart';
import '../../core/theme/app_theme.dart';
import 'form_helpers.dart';

class GroomingForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;

  const GroomingForm({
    super.key,
    required this.onSubmit,
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<GroomingForm> createState() => _GroomingFormState();
}

class _GroomingFormState extends State<GroomingForm> {
  String groomingType = GroomingTypes.bath;
  late DateTime selectedDateTime;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      selectedDateTime = initial.startTime;
      groomingType = initial.groomingType ?? GroomingTypes.bath;
      _notesController = TextEditingController(text: initial.notes);
    } else {
      selectedDateTime = DateTime.now();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final metadata = {'grooming_type': groomingType};

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
    return FormContainer(
      onSubmit: _submit,
      onDelete: widget.onDelete,
      submitLabel: widget.initialActivity != null
          ? 'Update Grooming'
          : 'Log Grooming',
      children: [
        // Type Section
        FormSection(
          title: 'Grooming Type',
          icon: CupertinoIcons.sparkles,
          children: [
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
              icon: CupertinoIcons.star_fill,
              label: 'Hair',
              description: 'Hair care',
            ),
          ],
        ),

        // Time Section
        FormSection(
          title: 'Time',
          icon: CupertinoIcons.clock_fill,
          children: [
            TimePickerRow(
              label: 'Time',
              time: selectedDateTime,
              onChanged: (newTime) =>
                  setState(() => selectedDateTime = newTime),
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

  Widget _buildGroomingButton({
    required String type,
    required IconData icon,
    required String label,
    required String description,
  }) {
    final isSelected = groomingType == type;
    return GestureDetector(
      onTap: () => setState(() => groomingType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.sm : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.divider.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: isSelected ? CupertinoColors.white : AppColors.textLight,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.text : AppColors.text,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      color: isSelected
                          ? AppColors.text.withValues(alpha: 0.7)
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
