import 'package:flutter/cupertino.dart';
import '../../core/constants/activity_types.dart';
import '../../core/theme/app_theme.dart';

class HealthForm extends StatefulWidget {
  final Function({
    required String activityType,
    required Map<String, dynamic> metadata,
    DateTime? startTime,
    DateTime? endTime,
  }) onSubmit;

  const HealthForm({super.key, required this.onSubmit});

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
  DateTime selectedDateTime = DateTime.now();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final metadata = <String, dynamic>{
      'health_type': healthType,
    };

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Health Event Type', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          CupertinoSegmentedControl<String>(
            padding: const EdgeInsets.all(4),
            children: const {
              HealthEventTypes.temperature: Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Text('Temp', style: TextStyle(fontSize: 12)),
              ),
              HealthEventTypes.symptom: Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Text('Symptom', style: TextStyle(fontSize: 12)),
              ),
              HealthEventTypes.medication: Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Text('Medication', style: TextStyle(fontSize: 12)),
              ),
            },
            groupValue: healthType,
            onValueChanged: (value) => setState(() => healthType = value),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Conditional fields
          if (healthType == HealthEventTypes.temperature) ...[
            _buildTemperatureFields(),
          ] else if (healthType == HealthEventTypes.symptom) ...[
            _buildSymptomFields(),
          ] else if (healthType == HealthEventTypes.medication) ...[
            _buildMedicationFields(),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Date & Time Picker
          const Text('Date & Time', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.sm,
            ),
            child: Column(
              children: [
                Text(
                  '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} ${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 150,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: selectedDateTime,
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (newDateTime) {
                      setState(() => selectedDateTime = newDateTime);
                    },
                  ),
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
            child: const Text('Log Health Event', style: TextStyle(color: AppColors.text)),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureFields() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          const Icon(CupertinoIcons.thermometer, size: 48, color: Color(0xFFE57373)),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${temperature.toStringAsFixed(1)}°C',
            style: AppTypography.h1.copyWith(color: Color(0xFFE57373)),
          ),
          const SizedBox(height: AppSpacing.md),
          CupertinoSlider(
            value: temperature,
            min: 35.0,
            max: 42.0,
            divisions: 70,
            onChanged: (value) => setState(() => temperature = value),
          ),
          Text(
            '${(temperature * 9 / 5 + 32).toStringAsFixed(1)}°F',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Symptom Description', style: AppTypography.body),
        const SizedBox(height: AppSpacing.sm),
        CupertinoTextField(
          placeholder: 'e.g., Cough, Fever, Rash',
          padding: const EdgeInsets.all(AppSpacing.md),
          onChanged: (value) => symptom = value,
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('Severity (1-10)', style: AppTypography.body),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            children: [
              Text(
                '$severity',
                style: AppTypography.h1.copyWith(
                  color: severity > 7
                      ? const Color(0xFFE57373)
                      : severity > 4
                          ? const Color(0xFFFFB74D)
                          : const Color(0xFF81C784),
                ),
              ),
              CupertinoSlider(
                value: severity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (value) => setState(() => severity = value.round()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Medication Name', style: AppTypography.body),
        const SizedBox(height: AppSpacing.sm),
        CupertinoTextField(
          placeholder: 'e.g., Paracetamol',
          padding: const EdgeInsets.all(AppSpacing.md),
          onChanged: (value) => medication = value,
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('Dosage', style: AppTypography.body),
        const SizedBox(height: AppSpacing.sm),
        CupertinoTextField(
          placeholder: 'e.g., 2.5 ml',
          padding: const EdgeInsets.all(AppSpacing.md),
          onChanged: (value) => dosage = value,
        ),
      ],
    );
  }
}
