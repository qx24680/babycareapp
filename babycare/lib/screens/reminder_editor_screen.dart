import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay, Colors;
import '../core/constants/activity_types.dart';
import '../core/theme/app_theme.dart';
import '../models/reminder.dart';
import '../services/reminder_manager.dart';
import '../services/permission_service.dart';
import '../widgets/common/primary_button.dart';

class ReminderEditorScreen extends StatefulWidget {
  final int? babyId;
  final Reminder? reminder; // null for new reminder
  final String? preselectedActivityType;

  const ReminderEditorScreen({
    super.key,
    this.babyId,
    this.reminder,
    this.preselectedActivityType,
  });

  @override
  State<ReminderEditorScreen> createState() => _ReminderEditorScreenState();
}

class _ReminderEditorScreenState extends State<ReminderEditorScreen> {
  final ReminderManager _reminderManager = ReminderManager();
  final PermissionService _permissionService = PermissionService();

  // Form state
  ReminderMode _mode = ReminderMode.advanced;
  String? _activityType;
  int _intervalHours = 3;
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = TimeOfDay.now();
  bool _repeatEnabled = false;
  RepeatType _repeatType = RepeatType.daily;
  int _repeatInterval = 1;
  List<int> _selectedWeekdays = [];
  bool _doNotDisturb = false;
  String? _groupId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.reminder != null) {
      // Editing existing reminder
      final reminder = widget.reminder!;
      _mode = reminder.mode;
      _activityType = reminder.activityType;
      _intervalHours = reminder.intervalHours ?? 3;
      _scheduledDate = reminder.scheduledDate ?? DateTime.now();
      if (reminder.scheduledTime != null) {
        final parts = reminder.scheduledTime!.split(':');
        _scheduledTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      _repeatEnabled = reminder.repeatEnabled;
      _repeatType = reminder.repeatType ?? RepeatType.daily;
      _repeatInterval = reminder.repeatInterval ?? 1;
      _selectedWeekdays = reminder.weekdays ?? [];
      _doNotDisturb = reminder.doNotDisturb;
      _groupId = reminder.groupId;
    } else if (widget.preselectedActivityType != null) {
      // New reminder with preselected activity
      _activityType = widget.preselectedActivityType;
    } else {
      // Show activity selector
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showActivitySelector();
      });
    }
  }

  Future<void> _showActivitySelector() async {
    final selected = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => _ActivitySelectorSheet(),
    );

    if (selected != null) {
      setState(() => _activityType = selected);
    } else if (widget.reminder == null) {
      // User cancelled, go back
      if (mounted) Navigator.pop(context);
    }
  }

  bool _isFormValid() {
    if (_activityType == null) return false;

    if (_mode == ReminderMode.basic) {
      return _intervalHours >= 1;
    } else {
      // Advanced mode
      if (_repeatEnabled && _repeatType == RepeatType.weekly) {
        return _selectedWeekdays.isNotEmpty;
      }
      return true;
    }
  }

  Future<void> _saveReminder() async {
    if (!_isFormValid()) return;

    setState(() => _isSaving = true);

    try {
      // Check permissions
      final hasPermission = await _permissionService
          .hasNotificationPermission();
      if (!hasPermission && !_doNotDisturb) {
        final requested = await _permissionService
            .requestNotificationPermission();
        if (requested != PermissionResult.granted) {
          if (mounted) {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Permission Required'),
                content: const Text(
                  'Notification permission is required to receive reminders. You can still save the reminder with "Do Not Disturb" enabled.',
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          setState(() => _isSaving = false);
          return;
        }
      }

      final scheduledTimeStr =
          '${_scheduledTime.hour.toString().padLeft(2, '0')}:${_scheduledTime.minute.toString().padLeft(2, '0')}';

      if (widget.reminder != null) {
        // Update existing
        final updated = widget.reminder!.copyWith(
          activityType: _activityType,
          mode: _mode,
          intervalHours: _mode == ReminderMode.basic ? _intervalHours : null,
          scheduledDate: _mode == ReminderMode.advanced ? _scheduledDate : null,
          scheduledTime: _mode == ReminderMode.advanced
              ? scheduledTimeStr
              : null,
          repeatEnabled: _mode == ReminderMode.advanced
              ? _repeatEnabled
              : false,
          repeatType: _repeatEnabled ? _repeatType : null,
          repeatInterval: _repeatEnabled && _repeatType == RepeatType.daily
              ? _repeatInterval
              : null,
          weekdays: _repeatEnabled && _repeatType == RepeatType.weekly
              ? _selectedWeekdays
              : null,
          doNotDisturb: _doNotDisturb,
          groupId: _groupId,
          updatedAt: DateTime.now(),
        );
        await _reminderManager.updateReminder(updated);
      } else {
        // Create new
        if (_mode == ReminderMode.basic) {
          await _reminderManager.createBasicReminder(
            activityType: _activityType!,
            intervalHours: _intervalHours,
            doNotDisturb: _doNotDisturb,
            groupId: _groupId,
            babyId: widget.babyId,
          );
        } else if (_repeatEnabled) {
          if (_repeatType == RepeatType.weekly) {
            await _reminderManager.createWeeklyReminder(
              activityType: _activityType!,
              scheduledTime: scheduledTimeStr,
              weekdays: _selectedWeekdays,
              doNotDisturb: _doNotDisturb,
              groupId: _groupId,
              babyId: widget.babyId,
            );
          } else {
            await _reminderManager.createDailyReminder(
              activityType: _activityType!,
              scheduledTime: scheduledTimeStr,
              repeatEveryNDays: _repeatInterval > 1 ? _repeatInterval : null,
              doNotDisturb: _doNotDisturb,
              groupId: _groupId,
              babyId: widget.babyId,
            );
          }
        } else {
          await _reminderManager.createOneTimeReminder(
            activityType: _activityType!,
            scheduledDate: _scheduledDate,
            scheduledTime: scheduledTimeStr,
            doNotDisturb: _doNotDisturb,
            groupId: _groupId,
            babyId: widget.babyId,
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save reminder: $e'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteReminder() async {
    if (widget.reminder == null) return;

    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _reminderManager.deleteReminder(widget.reminder!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _activityType != null
        ? ActivityConfig.get(_activityType!)
        : null;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.reminder != null ? 'Edit Reminder' : 'New Reminder',
          style: AppTypography.h3,
        ),
        backgroundColor: AppColors.background,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        trailing: widget.reminder != null
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _deleteReminder,
                child: const Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.destructiveRed,
                ),
              )
            : null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                children: [
                  // Activity type header
                  if (config != null) _buildActivityHeader(config),

                  const SizedBox(height: AppSpacing.lg),

                  // Mode toggle
                  _buildModeToggle(),

                  const SizedBox(height: AppSpacing.lg),

                  // Mode-specific UI
                  if (_mode == ReminderMode.basic)
                    _buildBasicModeUI()
                  else
                    _buildAdvancedModeUI(),

                  const SizedBox(height: AppSpacing.lg),

                  // Do Not Disturb
                  _buildDoNotDisturbToggle(),

                  const SizedBox(height: 100), // Space for save button
                ],
              ),
            ),

            // Save button (fixed at bottom)
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityHeader(ActivityConfig config) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: config.lightColor,
              shape: BoxShape.circle,
              boxShadow: AppShadows.sm,
            ),
            child: Icon(config.icon, color: config.color, size: 40),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(config.label, style: AppTypography.h2),
          if (widget.reminder == null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showActivitySelector,
              child: Text(
                'Change Activity',
                style: AppTypography.buttonSecondary.copyWith(fontSize: 15),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoSlidingSegmentedControl<ReminderMode>(
          groupValue: _mode,
          backgroundColor: AppColors.surface,
          thumbColor: AppColors.primary,
          children: {
            ReminderMode.basic: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Interval',
                style: TextStyle(
                  color: _mode == ReminderMode.basic
                      ? Colors.white
                      : AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ReminderMode.advanced: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Scheduled',
                style: TextStyle(
                  color: _mode == ReminderMode.advanced
                      ? Colors.white
                      : AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          },
          onValueChanged: (value) {
            if (value != null) {
              setState(() => _mode = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBasicModeUI() {
    return CupertinoListSection.insetGrouped(
      header: Text('INTERVAL', style: AppTypography.caption),
      backgroundColor: Colors.transparent,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      children: [
        CupertinoListTile(
          title: const Text('Remind Every'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _intervalHours > 1
                    ? () => setState(() => _intervalHours--)
                    : null,
                child: Icon(
                  CupertinoIcons.minus_circle_fill,
                  color: _intervalHours > 1
                      ? AppColors.primary
                      : AppColors.textLight.withValues(alpha: 0.3),
                  size: 28,
                ),
              ),
              Container(
                width: 80,
                alignment: Alignment.center,
                child: Text(
                  '$_intervalHours ${_intervalHours == 1 ? 'hour' : 'hours'}',
                  style: AppTypography.h3,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _intervalHours < 24
                    ? () => setState(() => _intervalHours++)
                    : null,
                child: const Icon(
                  CupertinoIcons.plus_circle_fill,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedModeUI() {
    return Column(
      children: [
        CupertinoListSection.insetGrouped(
          header: Text('SCHEDULE', style: AppTypography.caption),
          backgroundColor: Colors.transparent,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.card,
          ),
          children: [
            CupertinoListTile(
              title: const Text('Date'),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showDatePicker(),
                child: Text(
                  '${_scheduledDate.month}/${_scheduledDate.day}/${_scheduledDate.year}',
                  style: AppTypography.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            CupertinoListTile(
              title: const Text('Time'),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showTimePicker(),
                child: Text(
                  _scheduledTime.format(context),
                  style: AppTypography.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Repeat toggle
        CupertinoListSection.insetGrouped(
          header: Text('REPEAT', style: AppTypography.caption),
          backgroundColor: Colors.transparent,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.card,
          ),
          children: [
            CupertinoListTile(
              title: const Text('Repeat'),
              trailing: CupertinoSwitch(
                value: _repeatEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: (value) => setState(() => _repeatEnabled = value),
              ),
            ),
          ],
        ),

        // Repeat options (when enabled)
        if (_repeatEnabled) ...[
          const SizedBox(height: AppSpacing.md),
          _buildRepeatOptions(),
        ],
      ],
    );
  }

  Widget _buildRepeatOptions() {
    return Column(
      children: [
        // Repeat type selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: CupertinoSlidingSegmentedControl<RepeatType>(
            groupValue: _repeatType,
            thumbColor: AppColors.primary,
            children: {
              RepeatType.daily: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Daily',
                  style: TextStyle(
                    color: _repeatType == RepeatType.daily
                        ? Colors.white
                        : AppColors.text,
                  ),
                ),
              ),
              RepeatType.weekly: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Weekly',
                  style: TextStyle(
                    color: _repeatType == RepeatType.weekly
                        ? Colors.white
                        : AppColors.text,
                  ),
                ),
              ),
            },
            onValueChanged: (value) {
              if (value != null) {
                setState(() => _repeatType = value);
              }
            },
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Daily interval or weekly weekdays
        if (_repeatType == RepeatType.daily)
          _buildDailyIntervalUI()
        else
          _buildWeekdaySelector(),
      ],
    );
  }

  Widget _buildDailyIntervalUI() {
    return CupertinoListSection.insetGrouped(
      backgroundColor: Colors.transparent,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      children: [
        CupertinoListTile(
          title: const Text('Repeat Every'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _repeatInterval > 1
                    ? () => setState(() => _repeatInterval--)
                    : null,
                child: Icon(
                  CupertinoIcons.minus_circle_fill,
                  color: _repeatInterval > 1
                      ? AppColors.primary
                      : AppColors.textLight.withValues(alpha: 0.3),
                  size: 28,
                ),
              ),
              Container(
                width: 70,
                alignment: Alignment.center,
                child: Text(
                  '$_repeatInterval ${_repeatInterval == 1 ? 'day' : 'days'}',
                  style: AppTypography.h3,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _repeatInterval < 30
                    ? () => setState(() => _repeatInterval++)
                    : null,
                child: const Icon(
                  CupertinoIcons.plus_circle_fill,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdaySelector() {
    const weekdays = [
      {'value': 1, 'label': 'Mon'},
      {'value': 2, 'label': 'Tue'},
      {'value': 3, 'label': 'Wed'},
      {'value': 4, 'label': 'Thu'},
      {'value': 5, 'label': 'Fri'},
      {'value': 6, 'label': 'Sat'},
      {'value': 7, 'label': 'Sun'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Days', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weekdays.map((day) {
                final value = day['value'] as int;
                final label = day['label'] as String;
                final isSelected = _selectedWeekdays.contains(value);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedWeekdays.remove(value);
                      } else {
                        _selectedWeekdays.add(value);
                      }
                      _selectedWeekdays.sort();
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? Colors.white : AppColors.text,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoNotDisturbToggle() {
    return CupertinoListSection.insetGrouped(
      header: Text('NOTIFICATIONS', style: AppTypography.caption),
      backgroundColor: Colors.transparent,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      children: [
        CupertinoListTile(
          title: const Text('Do Not Disturb'),
          subtitle: const Text('Save reminder but don\'t send notifications'),
          trailing: CupertinoSwitch(
            value: _doNotDisturb,
            activeColor: AppColors.primary,
            onChanged: (value) => setState(() => _doNotDisturb = value),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.lg,
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          label: widget.reminder != null ? 'Update Reminder' : 'Save Reminder',
          onPressed: _isFormValid() ? _saveReminder : null,
          isLoading: _isSaving,
          backgroundColor: _isFormValid()
              ? AppColors.primary
              : AppColors.textLight.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => _buildPickerContainer(
        CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: _scheduledDate,
          minimumDate: DateTime.now(),
          onDateTimeChanged: (date) {
            setState(() => _scheduledDate = date);
          },
        ),
      ),
    );
  }

  Future<void> _showTimePicker() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => _buildPickerContainer(
        CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: DateTime(
            2000,
            1,
            1,
            _scheduledTime.hour,
            _scheduledTime.minute,
          ),
          onDateTimeChanged: (time) {
            setState(() {
              _scheduledTime = TimeOfDay(hour: time.hour, minute: time.minute);
            });
          },
        ),
      ),
    );
  }

  Widget _buildPickerContainer(Widget picker) {
    return Container(
      height: 280,
      color: AppColors.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 44,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: picker),
        ],
      ),
    );
  }
}

// Activity Selector Bottom Sheet
class _ActivitySelectorSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activities = [
      ActivityTypes.breastfeeding,
      ActivityTypes.bottleFeeding,
      ActivityTypes.diaper,
      ActivityTypes.sleep,
      ActivityTypes.nap,
      ActivityTypes.food,
      ActivityTypes.bath,
      ActivityTypes.health,
      ActivityTypes.pumping,
      ActivityTypes.potty,
    ];

    return Container(
      height: 450,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Activity', style: AppTypography.h3),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // Activity grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activityType = activities[index];
                final config = ActivityConfig.get(activityType);

                return GestureDetector(
                  onTap: () => Navigator.pop(context, activityType),
                  child: Container(
                    decoration: BoxDecoration(
                      color: config.lightColor,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: config.color.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(config.icon, color: config.color, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          config.label,
                          style: AppTypography.caption.copyWith(
                            color: config.color,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
