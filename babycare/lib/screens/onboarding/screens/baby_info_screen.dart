import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/onboarding_data.dart';
import '../widgets/onboarding_button.dart';

/// Screen 2: Add Baby (Minimal) - Essential info only
class BabyInfoScreen extends StatefulWidget {
  final OnboardingData data;
  final Function(OnboardingData) onDataChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BabyInfoScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BabyInfoScreen> createState() => _BabyInfoScreenState();
}

class _BabyInfoScreenState extends State<BabyInfoScreen> {
  late TextEditingController _nameController;
  DateTime? _selectedDate;

  // Common countries with their units
  static const List<Map<String, String>> _countries = [
    {'code': 'US', 'name': 'United States', 'flag': '🇺🇸'},
    {'code': 'GB', 'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'code': 'CA', 'name': 'Canada', 'flag': '🇨🇦'},
    {'code': 'AU', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': 'IN', 'name': 'India', 'flag': '🇮🇳'},
    {'code': 'DE', 'name': 'Germany', 'flag': '🇩🇪'},
    {'code': 'FR', 'name': 'France', 'flag': '🇫🇷'},
    {'code': 'BR', 'name': 'Brazil', 'flag': '🇧🇷'},
    {'code': 'MX', 'name': 'Mexico', 'flag': '🇲🇽'},
    {'code': 'JP', 'name': 'Japan', 'flag': '🇯🇵'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.babyName);
    _selectedDate = widget.data.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateName(String name) {
    widget.onDataChanged(widget.data.copyWith(
      babyName: name.isEmpty ? 'Baby' : name,
    ));
  }

  void _selectDate() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.white,
        child: Column(
          children: [
            // Header with Done button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              color: AppColors.background,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Done'),
                    onPressed: () {
                      widget.onDataChanged(widget.data.copyWith(
                        dateOfBirth: _selectedDate ?? DateTime.now(),
                      ));
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            // Date picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate ?? DateTime.now(),
                maximumDate: DateTime.now(),
                minimumDate: DateTime.now().subtract(
                  const Duration(days: 365 * 3),
                ), // Up to 3 years ago
                onDateTimeChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCountry() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 350,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Country', style: AppTypography.h3),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.xmark_circle_fill),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Country list
            Expanded(
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  final isSelected = widget.data.country == country['code'];
                  return CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    onPressed: () {
                      widget.onDataChanged(widget.data.copyWith(
                        country: country['code'],
                      ));
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Text(
                          country['flag']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            country['name']!,
                            style: AppTypography.body.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.text,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            CupertinoIcons.checkmark,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCountryName(String code) {
    final country = _countries.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'name': code, 'flag': '🌍'},
    );
    return '${country['flag']} ${country['name']}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = widget.data.dateOfBirth != null &&
        widget.data.feedingType != null;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          OnboardingBackButton(onPressed: widget.onBack),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text("Let's meet your little one", style: AppTypography.h1),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Just the essentials for now—you can add more later',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Form fields
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baby name
                  Text(
                    'Baby\'s name',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CupertinoTextField(
                    controller: _nameController,
                    placeholder: 'Baby',
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.text.withValues(alpha: 0.1),
                      ),
                    ),
                    onChanged: _updateName,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Date of birth
                  Text(
                    'Date of birth',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: widget.data.dateOfBirth != null
                              ? AppColors.primary
                              : AppColors.text.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            color: AppColors.text.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            widget.data.dateOfBirth != null
                                ? _formatDate(widget.data.dateOfBirth!)
                                : 'Select date',
                            style: AppTypography.body.copyWith(
                              color: widget.data.dateOfBirth != null
                                  ? AppColors.text
                                  : AppColors.text.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Feeding type
                  Text(
                    'Feeding type',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: FeedingType.values.map((type) {
                      final isSelected = widget.data.feedingType == type;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: type != FeedingType.values.last
                                ? AppSpacing.sm
                                : 0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              widget.onDataChanged(widget.data.copyWith(
                                feedingType: type,
                              ));
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : CupertinoColors.white,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.text.withValues(alpha: 0.1),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    type.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    type.label,
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Country
                  Text(
                    'Country',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: _selectCountry,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.text.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getCountryName(widget.data.country),
                              style: AppTypography.body,
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_down,
                            color: AppColors.text.withValues(alpha: 0.5),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Continue button
          OnboardingButton(
            label: 'Continue',
            onPressed: canContinue ? widget.onNext : null,
          ),
        ],
      ),
    );
  }
}
