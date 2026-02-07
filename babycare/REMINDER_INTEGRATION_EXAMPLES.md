# Reminder System Integration Examples

This file shows how to integrate the reminder system into your baby care app.
Copy the relevant parts to your actual implementation files.

**Note:** This is a reference file with code examples. Copy relevant sections to your implementation.

---

## 1. Update main.dart - Add Initialization

```dart

import 'package:flutter/material.dart';
import 'package:babycare/services/reminder_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize reminder system (IMPORTANT!)
  await ReminderManager().initialize();

  runApp(const MyApp());
}
```

## 2. Example: Reminder Settings Screen

```dart

import 'package:flutter/material.dart';
import 'package:babycare/services/reminder_manager.dart';
import 'package:babycare/models/reminder.dart';
import 'package:babycare/core/constants/activity_types.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final ReminderManager _reminderManager = ReminderManager();
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final reminders = await _reminderManager.getAllReminders();
    setState(() {
      _reminders = reminders;
      _isLoading = false;
    });
  }

  Future<void> _checkPermissions() async {
    final permissions = await _reminderManager.checkPermissions();

    if (!permissions.allGranted) {
      final requested = await _reminderManager.requestPermissions();

      if (!requested.allGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please enable notifications to use reminders: ${requested.missingPermissions.join(", ")}',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await _checkPermissions();
              // Navigate to create reminder screen
              // await Navigator.push(...);
              _loadReminders();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_off, size: 64),
                      const SizedBox(height: 16),
                      const Text('No reminders set'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await _checkPermissions();
                          // Navigate to create reminder screen
                        },
                        child: const Text('Create First Reminder'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    final config = ActivityConfig.get(reminder.activityType);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          config.icon,
                          color: config.color,
                        ),
                        title: Text(reminder.title ?? config.label),
                        subtitle: Text(_getReminderDescription(reminder)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (reminder.doNotDisturb)
                              const Icon(
                                Icons.notifications_off,
                                size: 20,
                              ),
                            const SizedBox(width: 8),
                            Switch(
                              value: reminder.isActive,
                              onChanged: (value) async {
                                await _reminderManager.toggleReminder(
                                  reminder.id!,
                                  value,
                                );
                                _loadReminders();
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigate to edit reminder screen
                        },
                        onLongPress: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Reminder'),
                              content: const Text(
                                'Are you sure you want to delete this reminder?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _reminderManager.deleteReminder(reminder.id!);
                            _loadReminders();
                          }
                        },
                      ),
                    );
                  },
                ),
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
        final days = reminder.weekdays
                ?.map((d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1])
                .join(', ') ??
            '';
        return 'Weekly on $days at $time';
      }
    }
  }
}
```

## 3. Example: Quick Action Buttons on Activity Screen

```dart

class ActivityQuickActions extends StatelessWidget {
  final String activityType;
  final int? babyId;

  const ActivityQuickActions({
    Key? key,
    required this.activityType,
    this.babyId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reminderManager = ReminderManager();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        switch (value) {
          case 'remind_3h':
            await reminderManager.createBasicReminder(
              activityType: activityType,
              intervalHours: 3,
              babyId: babyId,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder set for every 3 hours')),
              );
            }
            break;

          case 'remind_custom':
            // Navigate to custom reminder form
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'remind_3h',
          child: Row(
            children: [
              Icon(Icons.access_time),
              SizedBox(width: 8),
              Text('Remind every 3 hours'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'remind_custom',
          child: Row(
            children: [
              Icon(Icons.edit_calendar),
              SizedBox(width: 8),
              Text('Custom reminder'),
            ],
          ),
        ),
      ],
    );
  }
}
```

## 4. Example: Permission Check Widget (Show on first use)

```dart

class PermissionCheckWidget extends StatefulWidget {
  const PermissionCheckWidget({Key? key}) : super(key: key);

  @override
  State<PermissionCheckWidget> createState() => _PermissionCheckWidgetState();
}

class _PermissionCheckWidgetState extends State<PermissionCheckWidget> {
  final ReminderManager _reminderManager = ReminderManager();
  bool _checking = true;
  PermissionsStatus? _status;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _checking = true);
    final status = await _reminderManager.checkPermissions();
    setState(() {
      _status = status;
      _checking = false;
    });
  }

  Future<void> _requestPermissions() async {
    final status = await _reminderManager.requestPermissions();
    setState(() => _status = status);

    if (status.allGranted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_status?.allGranted == true) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text('All permissions granted!'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_active, size: 64),
          const SizedBox(height: 24),
          const Text(
            'Enable Reminders',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Get timely notifications for feeding, diaper changes, and other baby care activities.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_status != null && !_status!.allGranted)
            Column(
              children: [
                const Text(
                  'Required permissions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._status!.missingPermissions.map(
                  (permission) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Text(permission),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ElevatedButton(
            onPressed: _requestPermissions,
            child: const Text('Grant Permissions'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }
}
```

## 5. Example: Create Basic Reminder Dialog

```dart

Future<void> showCreateBasicReminderDialog(
  BuildContext context,
  String activityType,
) async {
  int intervalHours = 3;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Set ${ActivityConfig.get(activityType).label} Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Remind me every:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: intervalHours > 1
                      ? () => setState(() => intervalHours--)
                      : null,
                ),
                Text(
                  '$intervalHours hours',
                  style: const TextStyle(fontSize: 24),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: intervalHours < 12
                      ? () => setState(() => intervalHours++)
                      : null,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );

  if (result == true) {
    final reminderManager = ReminderManager();

    // Check permissions
    final permissions = await reminderManager.checkPermissions();
    if (!permissions.allGranted) {
      final requested = await reminderManager.requestPermissions();
      if (!requested.allGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission required for reminders'),
            ),
          );
        }
        return;
      }
    }

    // Create reminder
    await reminderManager.createBasicReminder(
      activityType: activityType,
      intervalHours: intervalHours,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder set for every $intervalHours hours'),
        ),
      );
    }
  }
}
```

## 6. Usage in Activity Logging Screen

```dart

class ActivityLogScreen extends StatelessWidget {
  final String activityType;

  const ActivityLogScreen({Key? key, required this.activityType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log ${ActivityConfig.get(activityType).label}'),
        actions: [
          // Add reminder button
          IconButton(
            icon: const Icon(Icons.alarm_add),
            onPressed: () => showCreateBasicReminderDialog(context, activityType),
            tooltip: 'Set Reminder',
          ),
        ],
      ),
      body: const Center(
        child: Text('Activity logging form here'),
      ),
    );
  }
}
```
