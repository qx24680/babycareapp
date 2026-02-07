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

  static const List<Map<String, String>> _countries = [
    // North America
    {'code': 'US', 'name': 'United States', 'flag': '🇺🇸'},
    {'code': 'CA', 'name': 'Canada', 'flag': '🇨🇦'},
    {'code': 'MX', 'name': 'Mexico', 'flag': '🇲🇽'},
    // Europe
    {'code': 'GB', 'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'code': 'DE', 'name': 'Germany', 'flag': '🇩🇪'},
    {'code': 'FR', 'name': 'France', 'flag': '🇫🇷'},
    {'code': 'ES', 'name': 'Spain', 'flag': '🇪🇸'},
    {'code': 'IT', 'name': 'Italy', 'flag': '🇮🇹'},
    {'code': 'NL', 'name': 'Netherlands', 'flag': '🇳🇱'},
    {'code': 'PT', 'name': 'Portugal', 'flag': '🇵🇹'},
    {'code': 'SE', 'name': 'Sweden', 'flag': '🇸🇪'},
    {'code': 'NO', 'name': 'Norway', 'flag': '🇳🇴'},
    {'code': 'DK', 'name': 'Denmark', 'flag': '🇩🇰'},
    {'code': 'FI', 'name': 'Finland', 'flag': '🇫🇮'},
    {'code': 'CH', 'name': 'Switzerland', 'flag': '🇨🇭'},
    {'code': 'AT', 'name': 'Austria', 'flag': '🇦🇹'},
    {'code': 'BE', 'name': 'Belgium', 'flag': '🇧🇪'},
    {'code': 'IE', 'name': 'Ireland', 'flag': '🇮🇪'},
    {'code': 'PL', 'name': 'Poland', 'flag': '🇵🇱'},
    {'code': 'RO', 'name': 'Romania', 'flag': '🇷🇴'},
    {'code': 'GR', 'name': 'Greece', 'flag': '🇬🇷'},
    {'code': 'CZ', 'name': 'Czech Republic', 'flag': '🇨🇿'},
    {'code': 'HU', 'name': 'Hungary', 'flag': '🇭🇺'},
    // Asia
    {'code': 'IN', 'name': 'India', 'flag': '🇮🇳'},
    {'code': 'JP', 'name': 'Japan', 'flag': '🇯🇵'},
    {'code': 'CN', 'name': 'China', 'flag': '🇨🇳'},
    {'code': 'KR', 'name': 'South Korea', 'flag': '🇰🇷'},
    {'code': 'SG', 'name': 'Singapore', 'flag': '🇸🇬'},
    {'code': 'MY', 'name': 'Malaysia', 'flag': '🇲🇾'},
    {'code': 'ID', 'name': 'Indonesia', 'flag': '🇮🇩'},
    {'code': 'PH', 'name': 'Philippines', 'flag': '🇵🇭'},
    {'code': 'TH', 'name': 'Thailand', 'flag': '🇹🇭'},
    {'code': 'VN', 'name': 'Vietnam', 'flag': '🇻🇳'},
    {'code': 'PK', 'name': 'Pakistan', 'flag': '🇵🇰'},
    {'code': 'BD', 'name': 'Bangladesh', 'flag': '🇧🇩'},
    {'code': 'AE', 'name': 'United Arab Emirates', 'flag': '🇦🇪'},
    {'code': 'SA', 'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'code': 'IL', 'name': 'Israel', 'flag': '🇮🇱'},
    {'code': 'TR', 'name': 'Turkey', 'flag': '🇹🇷'},
    // South America
    {'code': 'BR', 'name': 'Brazil', 'flag': '🇧🇷'},
    {'code': 'AR', 'name': 'Argentina', 'flag': '🇦🇷'},
    {'code': 'CO', 'name': 'Colombia', 'flag': '🇨🇴'},
    {'code': 'CL', 'name': 'Chile', 'flag': '🇨🇱'},
    {'code': 'PE', 'name': 'Peru', 'flag': '🇵🇪'},
    // Africa
    {'code': 'ZA', 'name': 'South Africa', 'flag': '🇿🇦'},
    {'code': 'NG', 'name': 'Nigeria', 'flag': '🇳🇬'},
    {'code': 'KE', 'name': 'Kenya', 'flag': '🇰🇪'},
    {'code': 'EG', 'name': 'Egypt', 'flag': '🇪🇬'},
    // Oceania
    {'code': 'AU', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': 'NZ', 'name': 'New Zealand', 'flag': '🇳🇿'},
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
    widget.onDataChanged(
      widget.data.copyWith(babyName: name.isEmpty ? 'Baby' : name),
    );
  }

  void _selectDate() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 320,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Cancel',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Date of Birth',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Done',
                      style: AppTypography.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      widget.onDataChanged(
                        widget.data.copyWith(
                          dateOfBirth: _selectedDate ?? DateTime.now(),
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate ?? DateTime.now(),
                maximumDate: DateTime.now(),
                minimumDate: DateTime.now().subtract(
                  const Duration(days: 365 * 3),
                ),
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
    String searchQuery = '';
    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filtered = searchQuery.isEmpty
              ? _countries
              : _countries
                    .where(
                      (c) => c['name']!.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Select Country', style: AppTypography.h3),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              CupertinoIcons.xmark_circle_fill,
                              color: AppColors.textLight,
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Search field
                      CupertinoTextField(
                        placeholder: 'Search countries...',
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Icon(
                            CupertinoIcons.search,
                            color: AppColors.textLight,
                            size: 18,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: AppColors.text.withValues(alpha: 0.1),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Country list
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Text(
                              'No countries found',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Container(
                              height: 0.5,
                              color: AppColors.text.withValues(alpha: 0.06),
                            ),
                          ),
                          itemBuilder: (context, index) {
                            final country = filtered[index];
                            final isSelected =
                                widget.data.country == country['code'];
                            return CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 12,
                              ),
                              onPressed: () {
                                widget.onDataChanged(
                                  widget.data.copyWith(
                                    country: country['code'],
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      country['name']!,
                                      style: AppTypography.body.copyWith(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.text,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.checkmark,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getCountryName(String code) {
    final country = _countries.firstWhere(
      (c) => c['code'] == code,
      orElse: () => <String, String>{'name': code, 'flag': '🌍'},
    );
    return '${country['flag']} ${country['name']}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.text.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildFieldContainer({
    required Widget child,
    bool isHighlighted = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isHighlighted
                ? AppColors.primary
                : AppColors.text.withValues(alpha: 0.08),
          ),
          boxShadow: AppShadows.sm,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = widget.data.dateOfBirth != null;

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
            'Just the essentials for now — you can add more later',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Form fields
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baby name
                  _buildFieldLabel("Baby's name"),
                  CupertinoTextField(
                    controller: _nameController,
                    placeholder: 'Baby',
                    placeholderStyle: AppTypography.body.copyWith(
                      color: AppColors.textLight.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.text.withValues(alpha: 0.08),
                      ),
                      boxShadow: AppShadows.sm,
                    ),
                    style: AppTypography.body,
                    onChanged: _updateName,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Date of birth
                  _buildFieldLabel('Date of birth'),
                  _buildFieldContainer(
                    isHighlighted: widget.data.dateOfBirth != null,
                    onTap: _selectDate,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: widget.data.dateOfBirth != null
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.text.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CupertinoIcons.calendar,
                            color: widget.data.dateOfBirth != null
                                ? AppColors.primary
                                : AppColors.textLight,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            widget.data.dateOfBirth != null
                                ? _formatDate(widget.data.dateOfBirth!)
                                : 'Select date',
                            style: AppTypography.body.copyWith(
                              color: widget.data.dateOfBirth != null
                                  ? AppColors.text
                                  : AppColors.textLight,
                            ),
                          ),
                        ),
                        Icon(
                          CupertinoIcons.chevron_right,
                          color: AppColors.text.withValues(alpha: 0.3),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Feeding type
                  // //  _buildFieldLabel('Feeding type'),
                  // Row(
                  //   children: FeedingType.values.map((type) {
                  //     final isSelected = widget.data.feedingType == type;
                  //     return Expanded(
                  //       child: Padding(
                  //         padding: EdgeInsets.only(
                  //           right: type != FeedingType.values.last
                  //               ? AppSpacing.sm
                  //               : 0,
                  //         ),
                  //         child: GestureDetector(
                  //           onTap: () {
                  //             widget.onDataChanged(
                  //               widget.data.copyWith(feedingType: type),
                  //             );
                  //           },
                  //           child: AnimatedContainer(
                  //             duration: const Duration(milliseconds: 200),
                  //             padding: const EdgeInsets.symmetric(
                  //               vertical: AppSpacing.md,
                  //               horizontal: AppSpacing.xs,
                  //             ),
                  //             decoration: BoxDecoration(
                  //               color: isSelected
                  //                   ? AppColors.primary.withValues(alpha: 0.1)
                  //                   : CupertinoColors.white,
                  //               borderRadius: BorderRadius.circular(
                  //                 AppRadius.md,
                  //               ),
                  //               border: Border.all(
                  //                 color: isSelected
                  //                     ? AppColors.primary
                  //                     : AppColors.text.withValues(alpha: 0.08),
                  //                 width: isSelected ? 2 : 1,
                  //               ),
                  //               boxShadow: isSelected ? null : AppShadows.sm,
                  //             ),
                  //             child: Column(
                  //               children: [
                  //                 Text(
                  //                   type.emoji,
                  //                   style: const TextStyle(fontSize: 28),
                  //                 ),
                  //                 const SizedBox(height: AppSpacing.xs),
                  //                 Text(
                  //                   type.label,
                  //                   style: AppTypography.caption.copyWith(
                  //                     fontWeight: isSelected
                  //                         ? FontWeight.w600
                  //                         : FontWeight.normal,
                  //                     color: isSelected
                  //                         ? AppColors.primary
                  //                         : AppColors.textLight,
                  //                   ),
                  //                   textAlign: TextAlign.center,
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   }).toList(),
                  // ),
                  const SizedBox(height: AppSpacing.lg),

                  // Country
                  //  _buildFieldLabel('Country'),
                  // _buildFieldContainer(
                  //   onTap: _selectCountry,
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: Text(
                  //           _getCountryName(widget.data.country),
                  //           style: AppTypography.body,
                  //         ),
                  //       ),
                  //       Icon(
                  //         CupertinoIcons.chevron_down,
                  //         color: AppColors.text.withValues(alpha: 0.3),
                  //         size: 16,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: AppSpacing.md),
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
