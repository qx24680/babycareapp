import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../core/theme/app_theme.dart';

class DiaperForm extends StatefulWidget {
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  }) onSubmit;

  const DiaperForm({super.key, required this.onSubmit});

  @override
  State<DiaperForm> createState() => _DiaperFormState();
}

class _DiaperFormState extends State<DiaperForm> {
  String diaperType = DiaperTypes.pee;
  bool hasRash = false;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final metadata = {
      'type': diaperType,
      'has_rash': hasRash,
    };

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: ActivityTypes.diaper,
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
          const Text('Diaper Type', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          
          // Quick tap buttons
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
          const SizedBox(height: AppSpacing.xl),

          // Rash toggle
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.sm,
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: Color(0xFFFF6B6B),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Text('Diaper Rash Detected', style: AppTypography.body),
                ),
                CupertinoSwitch(
                  value: hasRash,
                  activeColor: const Color(0xFFFF6B6B),
                  onChanged: (value) => setState(() => hasRash = value),
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
            child: const Text('Log Diaper Change', style: TextStyle(color: AppColors.text)),
          ),
        ],
      ),
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
            Icon(icon, size: 32, color: AppColors.text),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
