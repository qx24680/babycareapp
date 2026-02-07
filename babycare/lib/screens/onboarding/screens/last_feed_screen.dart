import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Colors, TextDecoration; // Use specific material imports
import '../../../../core/theme/app_theme.dart';
import '../../../../models/onboarding_data.dart';
import '../../../../models/activity.dart'; // New Activity Model
import '../../../../core/constants/activity_types.dart'; // for BreastSide
import '../widgets/onboarding_button.dart';
import 'package:intl/intl.dart';

class LastFeedScreen extends StatefulWidget {
  final OnboardingData data;
  final Function(OnboardingData) onDataChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LastFeedScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LastFeedScreen> createState() => _LastFeedScreenState();
}

class _LastFeedScreenState extends State<LastFeedScreen> {
  // Option selection
  bool? _knowsLastFeed; // null = nothing selected, true = Yes, false = Not sure
  bool _isFeedingNow = false;

  @override
  void initState() {
    super.initState();
    // Initialize based on existing data if present
    if (widget.data.lastFeedTime != null || widget.data.lastFeedType != null) {
      _knowsLastFeed = true;
      // Heuristic: if time is very close to now (e.g. within 1 min) and it was just set,
      // it might be "feeding now", but simplistic logic is fine.
    }
  }

  void _updateFeedType(ActivityType type) {
    widget.onDataChanged(widget.data.copyWith(lastFeedType: type));
  }

  void _updateTime(DateTime time) {
    widget.onDataChanged(widget.data.copyWith(lastFeedTime: time));
  }

  void _selectTime() {
    // Round to nearest 5 minutes
    final now = DateTime.now();
    DateTime initialTime = widget.data.lastFeedTime ?? now;

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
                    'Time',
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
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: initialTime,
                maximumDate: now,
                minimumDate: now.subtract(const Duration(days: 2)),
                onDateTimeChanged: (date) {
                  _updateTime(date);
                  setState(() {
                    _isFeedingNow = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String label,
    required String prefix,
    required bool isSelected,
    required VoidCallback onTap,
    bool showCheckmark = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? AppColors.success
                : AppColors.text.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.success
                    : AppColors.text.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Text(
                prefix,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? CupertinoColors.white : AppColors.text,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (showCheckmark && isSelected)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.xs),
                child: Icon(
                  CupertinoIcons.checkmark_alt_circle_fill,
                  color: AppColors
                      .primary, // Using primary color for checkmark as per design
                  size: 24,
                ),
              ),
            if (isSelected && !showCheckmark)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.xs),
                child: Icon(
                  CupertinoIcons.checkmark_alt_circle_fill,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    final isNursing = widget.data.lastFeedType == ActivityType.breastfeeding;
    final isBottle = widget.data.lastFeedType == ActivityType.bottleFeeding;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                widget.onDataChanged(
                  widget.data.copyWith(
                    lastFeedType: ActivityType.breastfeeding,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isNursing ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.drop_fill,
                      size: 16,
                      color: isNursing
                          ? CupertinoColors.white
                          : AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Nursing',
                      style: AppTypography.body.copyWith(
                        color: isNursing
                            ? CupertinoColors.white
                            : AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                widget.onDataChanged(
                  widget.data.copyWith(
                    lastFeedType: ActivityType.bottleFeeding,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isBottle ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.pencil_outline,
                      size: 16,
                      color: isBottle
                          ? CupertinoColors.white
                          : AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Bottle',
                      style: AppTypography.body.copyWith(
                        color: isBottle
                            ? CupertinoColors.white
                            : AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default to nursing if not set but user selected "Yes" or "Feeding Now"
    // Actually better to force user to interact with toggle or set a default.
    // Let's set a default when they click Yes/Feeding Now if it's null.

    final bool showDetails = _knowsLastFeed == true || _isFeedingNow;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          OnboardingBackButton(onPressed: widget.onBack),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text(
            "Do you know the last time you fed your child?",
            style: AppTypography.h2,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "We'll help you keep track. You'll see how long it's been in time to get ready for their next feed.",
            style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
          ),
          const SizedBox(height: AppSpacing.xl),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Option A: Yes
                  _buildOptionCard(
                    label: 'Yes',
                    prefix: 'A',
                    isSelected: _knowsLastFeed == true && !_isFeedingNow,
                    showCheckmark: true,
                    onTap: () {
                      setState(() {
                        _knowsLastFeed = true;
                        _isFeedingNow = false;
                      });
                      // Set default time if null
                      if (widget.data.lastFeedTime == null) {
                        _updateTime(
                          DateTime.now().subtract(const Duration(hours: 2)),
                        );
                      }
                      // Set default type if null
                      if (widget.data.lastFeedType == null) {
                        _updateFeedType(ActivityType.breastfeeding);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Details Section (Visible only if Yes or Feeding Now is selected)
                  if (showDetails) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.text,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Column(
                        children: [
                          // Toggle Switch
                          _buildToggleSwitch(),
                          const SizedBox(height: AppSpacing.lg),

                          // Start Time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Start time",
                                style: AppTypography.body.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: _isFeedingNow
                                    ? null
                                    : _selectTime, // Disable if feeding now? Or allow edit?
                                child: Text(
                                  _isFeedingNow
                                      ? "Now"
                                      : DateFormat('h:mm a').format(
                                          widget.data.lastFeedTime ??
                                              DateTime.now(),
                                        ),
                                  style: AppTypography.body.copyWith(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Nursing: Side Selection
                          if (widget.data.lastFeedType ==
                              ActivityType.breastfeeding)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Last side: \n(Optional)",
                                  style: AppTypography.body.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131323),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: CupertinoColors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          widget.onDataChanged(
                                            widget.data.copyWith(
                                              lastFeedSide: BreastSide.left,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                            vertical: AppSpacing.sm,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                widget.data.lastFeedSide ==
                                                    BreastSide.left
                                                ? AppColors.primary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.sm,
                                            ),
                                          ),
                                          child: Text(
                                            "Left",
                                            style: AppTypography.body.copyWith(
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          widget.onDataChanged(
                                            widget.data.copyWith(
                                              lastFeedSide: BreastSide.right,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                            vertical: AppSpacing.sm,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                widget.data.lastFeedSide ==
                                                    BreastSide.right
                                                ? AppColors.primary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.sm,
                                            ),
                                          ),
                                          child: Text(
                                            "Right",
                                            style: AppTypography.body.copyWith(
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                          // Bottle: Type Selection
                          if (widget.data.lastFeedType ==
                              ActivityType.bottleFeeding)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Type:",
                                  style: AppTypography.body.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Simple toggle for now or show modal
                                    final current = widget.data.lastFeedContent;
                                    final next = current == 'Breastmilk'
                                        ? 'Formula'
                                        : 'Breastmilk';
                                    widget.onDataChanged(
                                      widget.data.copyWith(
                                        lastFeedContent: next,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    widget.data.lastFeedContent ?? "Formula",
                                    style: AppTypography.body.copyWith(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Option B: Feeding Now
                  _buildOptionCard(
                    label: "I'm feeding my child right now",
                    prefix: 'B',
                    isSelected: _isFeedingNow,
                    showCheckmark: true,
                    onTap: () {
                      setState(() {
                        _knowsLastFeed = true;
                        _isFeedingNow = true;
                      });
                      _updateTime(DateTime.now());
                      if (widget.data.lastFeedType == null) {
                        _updateFeedType(ActivityType.breastfeeding);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Option C: Not Sure
                  _buildOptionCard(
                    label: "I'm not sure",
                    prefix: 'C',
                    isSelected: _knowsLastFeed == false,
                    showCheckmark: false,
                    onTap: () {
                      setState(() {
                        _knowsLastFeed = false;
                        _isFeedingNow = false;
                      });
                      // Clear feed data (copyWith can't set nullable fields to null)
                      widget.onDataChanged(widget.data.clearFeedData());
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          OnboardingButton(
            label: 'Next',
            onPressed: _knowsLastFeed != null ? widget.onNext : null,
          ),
        ],
      ),
    );
  }
}
