import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../models/activity.dart';
import '../../core/theme/app_theme.dart';
import 'form_helpers.dart';

class HealthForm extends StatefulWidget {
  final Activity? initialActivity;
  final VoidCallback? onDelete;
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  })
  onSubmit;

  const HealthForm({
    super.key,
    required this.onSubmit,
    this.initialActivity,
    this.onDelete,
  });

  @override
  State<HealthForm> createState() => _HealthFormState();
}

class _HealthFormState extends State<HealthForm> {
  String healthType = HealthEventTypes.temperature;
  double temperature = 37.0;
  String symptom = '';
  int severity = 5;
  String medication = '';
  String dosage = '';
  late DateTime selectedDateTime;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialActivity;
    if (initial != null) {
      selectedDateTime = initial.startTime;
      _notesController = TextEditingController(text: initial.notes);

      // Infer health type from existing fields since Model doesn't store type explicitly
      if (initial.temperature != null) {
        healthType = HealthEventTypes.temperature;
      } else if (initial.symptom != null) {
        healthType = HealthEventTypes.symptom;
      } else if (initial.medication != null) {
        healthType = HealthEventTypes.medication;
      } else {
        healthType = HealthEventTypes.temperature;
      }

      temperature = initial.temperature ?? 37.0;
      symptom = initial.symptom ?? '';
      severity = initial.severity ?? 5;
      medication = initial.medication ?? '';
      dosage = initial.dosage ?? '';
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
    final metadata = <String, dynamic>{'health_type': healthType};

    if (healthType == HealthEventTypes.temperature) {
      metadata['temperature_celsius'] = temperature;
    } else if (healthType == HealthEventTypes.symptom) {
      metadata['symptom'] = symptom;
      metadata['severity'] = severity;
    } else if (healthType == HealthEventTypes.medication) {
      metadata['medication'] = medication;
      metadata['dosage'] = dosage;
    }

    if (_notesController.text.isNotEmpty) {
      metadata['notes'] = _notesController.text;
    }

    widget.onSubmit(
      activityType: ActivityTypes.health,
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
          ? 'Update Health Event'
          : 'Log Health Event',
      children: [
        // Type Section
        FormSection(
          title: 'Event Type',
          icon: CupertinoIcons.heart_fill,
          children: [
            CustomSegmentedControl<String>(
              groupValue: healthType,
              children: const {
                HealthEventTypes.temperature: 'Temperature',
                HealthEventTypes.symptom: 'Symptom',
                HealthEventTypes.medication: 'Medication',
              },
              onValueChanged: (val) => setState(() => healthType = val!),
            ),
          ],
        ),

        // Conditional Details Section
        if (healthType == HealthEventTypes.temperature)
          FormSection(
            title: 'Reading',
            icon: CupertinoIcons.thermometer,
            children: [_buildTemperatureSlider()],
          )
        else if (healthType == HealthEventTypes.symptom)
          FormSection(
            title: 'Symptom Details',
            icon: CupertinoIcons.bandage_fill,
            children: [
              _buildTextInput(
                label: 'Description',
                placeholder: 'e.g., Cough, Fever',
                onChanged: (val) => symptom = val,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSeveritySlider(),
            ],
          )
        else if (healthType == HealthEventTypes.medication)
          FormSection(
            title: 'Medication Details',
            icon: CupertinoIcons.capsule_fill,
            children: [
              _buildTextInput(
                label: 'Name',
                placeholder: 'e.g., Paracetamol',
                onChanged: (val) => medication = val,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextInput(
                label: 'Dosage',
                placeholder: 'e.g., 2.5 ml',
                onChanged: (val) => dosage = val,
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

  Widget _buildTemperatureSlider() {
    return Column(
      children: [
        Text(
          '${temperature.toStringAsFixed(1)}°C',
          style: AppTypography.h1.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.sm),
        CupertinoSlider(
          value: temperature,
          min: 35.0,
          max: 42.0,
          divisions: 70,
          onChanged: (value) => setState(() => temperature = value),
        ),
        Text(
          '${(temperature * 9 / 5 + 32).toStringAsFixed(1)}°F',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildSeveritySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Severity', style: AppTypography.caption),
            Text(
              '$severity/10',
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.bold,
                color: _getSeverityColor(severity),
              ),
            ),
          ],
        ),
        CupertinoSlider(
          value: severity.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: _getSeverityColor(severity),
          onChanged: (value) => setState(() => severity = value.round()),
        ),
      ],
    );
  }

  Color _getSeverityColor(int s) {
    if (s <= 3) return AppColors.success;
    if (s <= 7) return AppColors.accent;
    return AppColors.error;
  }

  Widget _buildTextInput({
    required String label,
    required String placeholder,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.xs),
        CupertinoTextField(
          placeholder: placeholder,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.divider),
          ),
          style: AppTypography.body,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
