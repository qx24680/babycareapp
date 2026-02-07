import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../models/activity.dart';
import '../../core/theme/app_theme.dart';
import 'form_helpers.dart';

class DiaperForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;

  const DiaperForm({
    super.key,
    required this.onSubmit,
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<DiaperForm> createState() => _DiaperFormState();
}

class _DiaperFormState extends State<DiaperForm> {
  String diaperType = DiaperTypes.pee;
  bool hasRash = false;
  late DateTime selectedDateTime;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      selectedDateTime = initial.startTime;
      _notesController = TextEditingController(text: initial.notes);

      // Attempt to reconstruct state
      // Note: Current DB schema effectively only stores isWet. Poop is not clearly stored.
      // We will assume if notes contains "Poop", it involves poop.
      final isWet = initial.isWet == true;
      final isPoop = initial.notes?.contains('[Poop]') ?? false;

      if (isWet && isPoop) {
        diaperType = DiaperTypes.both;
      } else if (isPoop) {
        diaperType = DiaperTypes.poop;
      } else {
        diaperType = DiaperTypes.pee; // Default/Fallback
      }

      // Rash mapping (if we use symptom or notes)
      hasRash = initial.notes?.contains('[Rash]') ?? false;
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
    final metadata = <String, dynamic>{
      'type': diaperType, // Kept for legacy/debug
      'has_rash': hasRash,
    };

    // Map to Activity fields
    if (diaperType == DiaperTypes.pee || diaperType == DiaperTypes.both) {
      metadata['is_wet'] = 1;
    }

    // Store Poop/Rash in notes since DB lacks fields
    final notesBuffer = StringBuffer();
    if (_notesController.text.isNotEmpty) {
      notesBuffer.write(_notesController.text);
    }

    if (diaperType == DiaperTypes.poop || diaperType == DiaperTypes.both) {
      if (notesBuffer.isNotEmpty) notesBuffer.write(' ');
      notesBuffer.write('[Poop]');
    }

    if (hasRash) {
      if (notesBuffer.isNotEmpty) notesBuffer.write(' ');
      notesBuffer.write('[Rash]');
    }

    if (notesBuffer.isNotEmpty) {
      metadata['notes'] = notesBuffer.toString();
    }

    widget.onSubmit(
      activityType: ActivityTypes.diaper,
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
          ? 'Update Diaper Log'
          : 'Log Diaper Change',
      children: [
        // Type Section
        FormSection(
          title: 'Diaper Type',
          icon: CupertinoIcons.sparkles,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDiaperButton(
                    type: DiaperTypes.pee,
                    icon: CupertinoIcons.drop_fill,
                    label: 'Pee',
                    color: const Color(0xFFFFF9C4),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildDiaperButton(
                    type: DiaperTypes.poop,
                    icon: CupertinoIcons.circle_fill,
                    label: 'Poop',
                    color: const Color(0xFFD7CCC8),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildDiaperButton(
                    type: DiaperTypes.both,
                    icon: CupertinoIcons.square_stack_fill,
                    label: 'Both',
                    color: const Color(0xFFFFE0B2),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Status Section with Rash Toggle
        FormSection(
          title: 'Status',
          icon: CupertinoIcons.exclamationmark_triangle_fill,
          children: [
            ToggleButton(
              label: 'Diaper Rash Detected',
              value: hasRash,
              onChanged: (val) => setState(() => hasRash = val),
              icon: CupertinoIcons.exclamationmark_circle_fill,
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

  Widget _buildDiaperButton({
    required String type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = diaperType == type;
    return GestureDetector(
      onTap: () => setState(() => diaperType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
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
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.text : AppColors.textLight,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.text : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
