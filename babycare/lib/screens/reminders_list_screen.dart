import 'package:flutter/cupertino.dart';

import '../core/theme/app_theme.dart';
import '../core/constants/activity_types.dart';
import '../models/reminder.dart';
import '../services/reminder_manager.dart';
import '../services/permission_service.dart';
import '../widgets/common/primary_button.dart';
import 'reminder_editor_screen.dart';

class RemindersListScreen extends StatefulWidget {
  final int? babyId;

  const RemindersListScreen({super.key, this.babyId});

  @override
  State<RemindersListScreen> createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> {
  final ReminderManager _reminderManager = ReminderManager();
  final PermissionService _permissionService = PermissionService();

  List<Reminder> _reminders = [];
  bool _isLoading = true;
  bool _hasNotificationPermission = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _checkPermissions();
    await _loadReminders();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await _permissionService.hasNotificationPermission();
    if (mounted) {
      setState(() => _hasNotificationPermission = hasPermission);
    }
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);

    try {
      final reminders = await _reminderManager.getAllReminders(
        babyId: widget.babyId,
      );

      if (mounted) {
        setState(() {
          _reminders = reminders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleReminder(Reminder reminder) async {
    await _reminderManager.toggleReminder(reminder.id!, !reminder.isActive);
    _loadReminders();
  }

  void _navigateToEditor({Reminder? reminder}) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            ReminderEditorScreen(babyId: widget.babyId, reminder: reminder),
      ),
    );
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Reminders', style: AppTypography.h3),
        backgroundColor: AppColors.background,
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _navigateToEditor(),
          child: const Icon(CupertinoIcons.add, color: AppColors.primary),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Permission warning banner
            if (!_hasNotificationPermission) _buildPermissionBanner(),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _reminders.isEmpty
                  ? _buildEmptyState()
                  : _buildRemindersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionBanner() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: CupertinoColors.systemRed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: CupertinoColors.systemRed,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications Disabled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enable notifications to receive reminders',
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemRed.darkColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              await _permissionService.requestNotificationPermission();
              _checkPermissions();
            },
            child: const Text(
              'Enable',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.bell_slash,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text('No Reminders Yet', style: AppTypography.h2),
            const SizedBox(height: 12),
            Text(
              'Set reminders for feeding, diaper changes, and other baby care activities',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Add Reminder',
              icon: CupertinoIcons.add,
              onPressed: () => _navigateToEditor(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        final config = ActivityConfig.get(reminder.activityType);

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.card,
            ),
            child: CupertinoListTile(
              padding: const EdgeInsets.all(AppSpacing.md),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: config.lightColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(config.icon, color: config.color, size: 24),
              ),
              title: Text(
                reminder.title ?? config.label,
                style: AppTypography.h3.copyWith(fontSize: 17),
              ),
              subtitle: Text(
                _getReminderDescription(reminder),
                style: AppTypography.caption,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (reminder.doNotDisturb)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        CupertinoIcons.bell_slash_fill,
                        size: 18,
                        color: AppColors.textLight,
                      ),
                    ),
                  CupertinoSwitch(
                    value: reminder.isActive,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => _toggleReminder(reminder),
                  ),
                ],
              ),
              onTap: () => _navigateToEditor(reminder: reminder),
            ),
          ),
        );
      },
    );
  }

  String _getReminderDescription(Reminder reminder) {
    if (reminder.mode == ReminderMode.basic) {
      return 'Every ${reminder.intervalHours} hours';
    } else {
      final time = reminder.scheduledTime ?? '';
      if (!reminder.repeatEnabled) {
        return 'Once at $time';
      } else if (reminder.repeatType == RepeatType.daily) {
        if (reminder.repeatInterval != null && reminder.repeatInterval! > 1) {
          return 'Every ${reminder.repeatInterval} days at $time';
        }
        return 'Daily at $time';
      } else {
        final days =
            reminder.weekdays
                ?.map(
                  (d) =>
                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1],
                )
                .join(', ') ??
            '';
        return 'Weekly on $days at $time';
      }
    }
  }
}
