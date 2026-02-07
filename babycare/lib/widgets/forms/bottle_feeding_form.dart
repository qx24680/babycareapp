import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../models/activity.dart';
import '../../core/theme/app_theme.dart';
import 'form_helpers.dart';

class BottleFeedingForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;

  const BottleFeedingForm({
    super.key,
    required this.onSubmit,
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<BottleFeedingForm> createState() => _BottleFeedingFormState();
}

class _BottleFeedingFormState extends State<BottleFeedingForm> {
  late DateTime startTime;
  double amount = 120;
  QuantityUnit unit = QuantityUnit.ml;
  MilkType milkType = MilkType.formula;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      startTime = initial.startTime;
      amount = initial.amount ?? 120;
      unit = initial.unit ?? QuantityUnit.ml;
      milkType = initial.milkType ?? MilkType.formula;
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
    final metadata = {
      'amount': amount,
      'unit': unit.value,
      'milk_type': milkType.value,
    };

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: ActivityTypes.bottleFeeding,
      metadata: metadata,
      startTime: startTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(
      onSubmit: _submit,
      onDelete: widget.onDelete,
      submitLabel: widget.initialActivity != null
          ? 'Update Feed'
          : 'Log Bottle Feed',
      children: [
        // Time Section
        FormSection(
          title: 'Timing',
          icon: CupertinoIcons.clock_fill,
          children: [
            TimePickerRow(
              label: 'Time',
              time: startTime,
              onChanged: (newTime) => setState(() => startTime = newTime),
            ),
          ],
        ),

        // Details Section
        FormSection(
          title: 'Feed Details',
          icon: CupertinoIcons.drop_fill,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: StatefulNumberInput(
                    label: 'Amount',
                    value: amount,
                    onChanged: (val) => setState(() => amount = val),
                    suffix: null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: DropdownSelector<QuantityUnit>(
                    label: '',
                    value: unit,
                    items: QuantityUnit.values,
                    labelBuilder: (e) => e.label,
                    onChanged: (val) => setState(() => unit = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownSelector<MilkType>(
              label: 'Milk Type',
              value: milkType,
              items: MilkType.values,
              labelBuilder: (e) => e.label,
              onChanged: (val) => setState(() => milkType = val),
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
}
