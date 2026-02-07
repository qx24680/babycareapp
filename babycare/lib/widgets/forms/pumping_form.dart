import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../models/activity.dart';
import '../../core/theme/app_theme.dart';
import 'form_helpers.dart';

class PumpingForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;

  const PumpingForm({
    super.key,
    required this.onSubmit,
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<PumpingForm> createState() => _PumpingFormState();
}

class _PumpingFormState extends State<PumpingForm> {
  late DateTime startTime;
  PumpSide side = PumpSide.both;
  double amount = 60;
  QuantityUnit unit = QuantityUnit.ml;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      startTime = initial.startTime;
      side = initial.pumpSide ?? PumpSide.both;
      amount = initial.amount ?? 60;
      unit = initial.unit ?? QuantityUnit.ml;
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
      'pump_side': side.value,
      'amount': amount,
      'unit': unit.value,
    };

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: ActivityTypes.pumping,
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
          ? 'Update Pumping Log'
          : 'Log Pumping',
      children: [
        // Time Section
        FormSection(
          title: 'Timing',
          icon: CupertinoIcons.clock_fill,
          children: [
            TimePickerRow(
              label: 'Start Time',
              time: startTime,
              onChanged: (newTime) => setState(() => startTime = newTime),
            ),
          ],
        ),

        // Details Section
        FormSection(
          title: 'Details',
          icon: CupertinoIcons.drop_fill,
          children: [
            CustomSegmentedControl<PumpSide>(
              label: 'Side',
              groupValue: side,
              children: const {
                PumpSide.left: 'Left',
                PumpSide.both: 'Both',
                PumpSide.right: 'Right',
              },
              onValueChanged: (val) =>
                  setState(() => side = val ?? PumpSide.both),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: StatefulNumberInput(
                    label: 'Amount (Total)',
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
