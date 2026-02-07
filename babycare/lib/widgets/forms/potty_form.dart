import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../models/activity.dart';
// But better to be safe.
import 'form_helpers.dart';

class PottyForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;

  const PottyForm({
    super.key,
    required this.onSubmit,
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<PottyForm> createState() => _PottyFormState();
}

class _PottyFormState extends State<PottyForm> {
  late DateTime time;
  PottyType type = PottyType.pee;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      time = initial.startTime;
      type = initial.pottyType ?? PottyType.pee;
      _notesController = TextEditingController(text: initial.notes);
    } else {
      time = DateTime.now();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final metadata = {'potty_type': type.value};

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: ActivityTypes.potty,
      metadata: metadata,
      startTime: time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(
      onSubmit: _submit,
      onDelete: widget.onDelete,
      submitLabel: widget.initialActivity != null
          ? 'Update Potty Log'
          : 'Log Potty',
      children: [
        // Time Section
        FormSection(
          title: 'Timing',
          icon: CupertinoIcons.clock_fill,
          children: [
            TimePickerRow(
              label: 'Time',
              time: time,
              onChanged: (newTime) => setState(() => time = newTime),
            ),
          ],
        ),

        // Details Section
        FormSection(
          title: 'Type',
          icon: CupertinoIcons.sparkles,
          children: [
            CustomSegmentedControl<PottyType>(
              groupValue: type,
              children: const {
                PottyType.pee: 'Pee',
                PottyType.poo: 'Poo',
                PottyType.both: 'Both',
              },
              onValueChanged: (val) =>
                  setState(() => type = val ?? PottyType.pee),
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
