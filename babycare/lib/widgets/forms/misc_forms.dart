import 'package:flutter/cupertino.dart';
import '../../models/activity.dart';
import 'form_helpers.dart';

// --- Simple Time Form (e.g. Toothbrushing) ---
// Note: HomeScreen primarily uses GenericTimeForm, but we keep this consistent.
class SimpleTimeForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;
  final String label;

  const SimpleTimeForm({
    super.key,
    required this.onSubmit,
    this.label = 'Log Activity',
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<SimpleTimeForm> createState() => _SimpleTimeFormState();
}

class _SimpleTimeFormState extends State<SimpleTimeForm> {
  late DateTime time;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      time = initial.startTime;
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
    final Map<String, dynamic> metadata = {};

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: widget.label,
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
          ? 'Update ${widget.label}'
          : widget.label,
      children: [
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
        FormSection(
          title: 'Notes',
          icon: CupertinoIcons.text_bubble_fill,
          children: [NotesInput(controller: _notesController)],
        ),
      ],
    );
  }
}

// Redefining SimpleTimeForm to accept activityType
class GenericTimeForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final String activityType;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;
  final String title;

  const GenericTimeForm({
    super.key,
    required this.activityType,
    required this.onSubmit,
    required this.title,
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<GenericTimeForm> createState() => _GenericTimeFormState();
}

class _GenericTimeFormState extends State<GenericTimeForm> {
  late DateTime time;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      time = initial.startTime;
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
    final Map<String, dynamic> metadata = {};
    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: widget.activityType,
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
          ? 'Update ${widget.title}'
          : 'Log ${widget.title}',
      children: [
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
        FormSection(
          title: 'Notes',
          icon: CupertinoIcons.text_bubble_fill,
          children: [NotesInput(controller: _notesController)],
        ),
      ],
    );
  }
}

// --- Duration Form (Crying, Walking) ---
class DurationForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final String activityType;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;
  final String title;

  const DurationForm({
    super.key,
    required this.activityType,
    required this.onSubmit,
    required this.title,
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<DurationForm> createState() => _DurationFormState();
}

class _DurationFormState extends State<DurationForm> {
  late DateTime startTime;
  int duration = 10;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      startTime = initial.startTime;
      duration = initial.durationMinutes ?? 10;
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
    final Map<String, dynamic> metadata = {'duration_minutes': duration};
    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: widget.activityType,
      metadata: metadata,
      startTime: startTime,
      endTime: startTime.add(Duration(minutes: duration)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(
      onSubmit: _submit,
      onDelete: widget.onDelete,
      submitLabel: widget.initialActivity != null
          ? 'Update ${widget.title}'
          : 'Log ${widget.title}',
      children: [
        FormSection(
          title: 'Timing',
          icon: CupertinoIcons.clock_fill,
          children: [
            TimePickerRow(
              label: 'Start Time',
              time: startTime,
              onChanged: (newTime) => setState(() => startTime = newTime),
            ),
            DurationPickerRow(
              label: 'Duration',
              durationMinutes: duration,
              onChanged: (val) => setState(() => duration = val),
            ),
          ],
        ),
        FormSection(
          title: 'Notes',
          icon: CupertinoIcons.text_bubble_fill,
          children: [NotesInput(controller: _notesController)],
        ),
      ],
    );
  }
}
