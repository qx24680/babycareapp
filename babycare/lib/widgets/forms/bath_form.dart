import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../models/activity.dart';
import 'form_helpers.dart';

class BathForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;

  const BathForm({
    super.key,
    required this.onSubmit,
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<BathForm> createState() => _BathFormState();
}

class _BathFormState extends State<BathForm> {
  late DateTime time;
  bool hairWash = false;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      time = initial.startTime;
      hairWash = initial.hairWash == true;
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
    final Map<String, dynamic> metadata = {'hair_wash': hairWash ? 1 : 0};

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: ActivityTypes.bath,
      metadata: metadata,
      startTime: time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(
      onSubmit: _submit,
      onDelete: widget.onDelete,
      submitLabel: widget.initialActivity != null ? 'Update Bath' : 'Log Bath',
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
          title: 'Details',
          icon: CupertinoIcons.sparkles,
          children: [
            ToggleButton(
              label: 'Hair Wash',
              value: hairWash,
              onChanged: (val) => setState(() => hairWash = val),
              icon: CupertinoIcons.drop_fill,
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
