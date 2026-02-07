import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/activity_types.dart';
import '../../models/activity.dart';
import '../../core/theme/app_theme.dart';
import 'form_helpers.dart';

class MeasurementForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;

  const MeasurementForm({
    super.key,
    required this.onSubmit,
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<MeasurementForm> createState() => _MeasurementFormState();
}

class _MeasurementFormState extends State<MeasurementForm> {
  late DateTime _time;
  double? _weight;
  double? _height;
  double? _headCircumference;

  // Units (defaults)
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  String _headUnit = 'cm';

  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      _time = initial.startTime;
      // Activity model lacks specific measurement fields, rely on user to re-enter for now
      // or implement fuller sync later.
      // Units might not be in Activity model, default them or extract if available?
      // Assuming Activity model doesn't store units separately or they are normalized?
      // For now keep defaults or improve if Activity has them.
      _notesController = TextEditingController(text: initial.notes);
    } else {
      _time = DateTime.now();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    // Only submit if at least one measurement is provided
    if (_weight == null && _height == null && _headCircumference == null) {
      return;
    }

    final metadata = <String, dynamic>{
      if (_weight != null) 'weight': _weight,
      if (_weight != null) 'weight_unit': _weightUnit,
      if (_height != null) 'height': _height,
      if (_height != null) 'height_unit': _heightUnit,
      if (_headCircumference != null) 'head_circumference': _headCircumference,
      if (_headCircumference != null) 'head_circumference_unit': _headUnit,
    };

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: ActivityTypes.measurement,
      metadata: metadata,
      startTime: _time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormContainer(
      onSubmit: _submit,
      onDelete: widget.onDelete,
      submitLabel: widget.initialActivity != null
          ? 'Update Measurement'
          : 'Log Measurement',
      children: [
        // Time Section
        FormSection(
          title: 'Time',
          icon: CupertinoIcons.clock_fill,
          children: [
            TimePickerRow(
              label: 'Date & Time',
              time: _time,
              onChanged: (newTime) => setState(() => _time = newTime),
            ),
          ],
        ),

        // Measurements Section
        FormSection(
          title: 'Measurements',
          icon: Icons.straighten, // Material Icon for Ruler
          children: [
            _buildMeasurementRow(
              label: 'Weight',
              value: _weight,
              unit: _weightUnit,
              unitOptions: ['kg', 'lb'],
              onChanged: (val) => setState(() => _weight = val),
              onUnitChanged: (val) => setState(() => _weightUnit = val),
              icon: Icons.monitor_weight, // Material Icon
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1),
            ),
            _buildMeasurementRow(
              label: 'Height',
              value: _height,
              unit: _heightUnit,
              unitOptions: ['cm', 'in'],
              onChanged: (val) => setState(() => _height = val),
              onUnitChanged: (val) => setState(() => _heightUnit = val),
              icon: Icons.height, // Material Icon
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1),
            ),
            _buildMeasurementRow(
              label: 'Head Circ.',
              value: _headCircumference,
              unit: _headUnit,
              unitOptions: ['cm', 'in'],
              onChanged: (val) => setState(() => _headCircumference = val),
              onUnitChanged: (val) => setState(() => _headUnit = val),
              icon: Icons.face, // Material Icon
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

  Widget _buildMeasurementRow({
    required String label,
    required double? value,
    required String unit,
    required List<String> unitOptions,
    required ValueChanged<double> onChanged,
    required ValueChanged<String> onUnitChanged,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 3,
          child: StatefulNumberInput(
            label: label,
            value: value ?? 0,
            onChanged: onChanged,
            suffix: null, // We use external dropdown for unit
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: DropdownSelector<String>(
            label: '',
            value: unit,
            items: unitOptions,
            labelBuilder: (s) => s,
            onChanged: onUnitChanged,
          ),
        ),
      ],
    );
  }
}
