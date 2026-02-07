# Baby Care App - Reminder System Documentation

## Overview

The reminder system provides comprehensive notification functionality for baby care activities with both Basic (interval-based) and Advanced (scheduled) reminder types.

## Features

- ✅ Activity-based reminders for all baby care activities
- ✅ Basic mode: Interval-based reminders (e.g., every 3 hours)
- ✅ Advanced mode: Scheduled reminders with date/time
- ✅ One-time and repeating reminders
- ✅ Daily and weekly repeat patterns
- ✅ Do Not Disturb toggle per reminder
- ✅ Group management for related reminders
- ✅ iOS and Android support
- ✅ Local database persistence
- ✅ Permission handling

## Architecture

### Models
- **[reminder.dart](babycare/lib/models/reminder.dart)**: Core reminder model with all configuration fields

### Services
- **[reminder_manager.dart](babycare/lib/services/reminder_manager.dart)**: High-level API (use this!)
- **[notification_service.dart](babycare/lib/services/notification_service.dart)**: Local notification handling
- **[reminder_scheduling_service.dart](babycare/lib/services/reminder_scheduling_service.dart)**: Scheduling logic
- **[reminder_repository.dart](babycare/lib/services/reminder_repository.dart)**: Database CRUD operations
- **[permission_service.dart](babycare/lib/services/permission_service.dart)**: Permission management

## Setup

### 1. Install Dependencies

```bash
flutter pub get
```

The following packages are already added:
- `flutter_local_notifications: ^18.0.1`
- `timezone: ^0.9.4`
- `flutter_timezone: ^3.0.1`
- `permission_handler: ^11.3.1`

### 2. Initialize in main.dart

Add initialization in your `main()` function:

```dart
import 'package:babycare/services/reminder_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize reminder system
  await ReminderManager().initialize();

  runApp(MyApp());
}
```

### 3. Platform-Specific Configuration

#### iOS
Already configured in [Info.plist](babycare/ios/Runner/Info.plist):
- Notification permissions
- Background modes

#### Android
Already configured in [AndroidManifest.xml](babycare/android/app/src/main/AndroidManifest.xml):
- Notification permissions
- Exact alarm permissions
- Boot receiver for rescheduling

## Usage Examples

### Basic Setup: Check and Request Permissions

```dart
import 'package:babycare/services/reminder_manager.dart';

final reminderManager = ReminderManager();

// Check if ready
final isReady = await reminderManager.isReady();

if (!isReady) {
  // Request permissions
  final permissions = await reminderManager.requestPermissions();

  if (!permissions.allGranted) {
    // Show dialog explaining why permissions are needed
    print('Missing permissions: ${permissions.missingPermissions}');
  }
}
```

### Example 1: Basic Interval Reminder

Every 3 hours feeding reminder:

```dart
await reminderManager.createBasicReminder(
  activityType: ActivityTypes.breastfeeding,
  intervalHours: 3,
  title: 'Feeding Time',
  message: 'Time to feed your baby',
  babyId: currentBabyId,
);
```

### Example 2: One-Time Reminder

Reminder for doctor appointment:

```dart
await reminderManager.createOneTimeReminder(
  activityType: ActivityTypes.health,
  scheduledDate: DateTime(2026, 2, 15),
  scheduledTime: '14:30', // 2:30 PM
  title: 'Doctor Appointment',
  message: 'Pediatrician checkup at 2:30 PM',
  babyId: currentBabyId,
);
```

### Example 3: Daily Reminder

Daily bath time at 7:00 PM:

```dart
await reminderManager.createDailyReminder(
  activityType: ActivityTypes.bath,
  scheduledTime: '19:00', // 7:00 PM
  title: 'Bath Time',
  message: 'Time for baby\'s bath',
  babyId: currentBabyId,
);
```

### Example 4: Every N Days Reminder

Medication every 2 days:

```dart
await reminderManager.createDailyReminder(
  activityType: ActivityTypes.health,
  scheduledTime: '08:00', // 8:00 AM
  repeatEveryNDays: 2,
  title: 'Medication',
  message: 'Time for baby\'s medication',
  babyId: currentBabyId,
);
```

### Example 5: Weekly Reminder on Specific Days

Reminder every Monday, Wednesday, and Friday:

```dart
await reminderManager.createWeeklyReminder(
  activityType: ActivityTypes.measurement,
  scheduledTime: '10:00', // 10:00 AM
  weekdays: [1, 3, 5], // Monday, Wednesday, Friday
  title: 'Weight Measurement',
  message: 'Time to measure baby\'s weight',
  babyId: currentBabyId,
);
```

### Managing Reminders

```dart
// Get all reminders
final allReminders = await reminderManager.getAllReminders();

// Get reminders for specific baby
final babyReminders = await reminderManager.getAllReminders(
  babyId: currentBabyId,
);

// Get reminders for specific activity
final feedingReminders = await reminderManager.getAllReminders(
  activityType: ActivityTypes.breastfeeding,
);

// Get only active reminders
final activeReminders = await reminderManager.getAllReminders(
  isActive: true,
);

// Toggle reminder on/off
await reminderManager.toggleReminder(reminderId, false); // Disable
await reminderManager.toggleReminder(reminderId, true);  // Enable

// Toggle Do Not Disturb
await reminderManager.toggleDoNotDisturb(reminderId, true);

// Update reminder
final reminder = await reminderManager.getReminder(reminderId);
if (reminder != null) {
  final updated = reminder.copyWith(
    scheduledTime: '15:00',
    title: 'Updated Title',
  );
  await reminderManager.updateReminder(updated);
}

// Delete reminder
await reminderManager.deleteReminder(reminderId);
```

### Group Management

Group related reminders together:

```dart
// Create reminders with same group ID
await reminderManager.createDailyReminder(
  activityType: ActivityTypes.breastfeeding,
  scheduledTime: '08:00',
  groupId: 'morning_routine',
);

await reminderManager.createDailyReminder(
  activityType: ActivityTypes.diaper,
  scheduledTime: '08:30',
  groupId: 'morning_routine',
);

// Fetch all reminders in a group
final groupReminders = await reminderManager.getRemindersByGroup('morning_routine');
```

## UI Integration

### Example: Reminder Form Widget

```dart
class ReminderFormWidget extends StatefulWidget {
  final String activityType;

  const ReminderFormWidget({required this.activityType});

  @override
  State<ReminderFormWidget> createState() => _ReminderFormWidgetState();
}

class _ReminderFormWidgetState extends State<ReminderFormWidget> {
  ReminderMode mode = ReminderMode.basic;
  int intervalHours = 3;
  TimeOfDay? selectedTime;
  bool repeatEnabled = false;
  List<int> selectedWeekdays = [];
  bool doNotDisturb = false;

  final reminderManager = ReminderManager();

  Future<void> _saveReminder() async {
    // Check permissions first
    final permissions = await reminderManager.checkPermissions();
    if (!permissions.allGranted) {
      final requested = await reminderManager.requestPermissions();
      if (!requested.allGranted) {
        // Show error
        return;
      }
    }

    // Create reminder based on mode
    if (mode == ReminderMode.basic) {
      await reminderManager.createBasicReminder(
        activityType: widget.activityType,
        intervalHours: intervalHours,
        doNotDisturb: doNotDisturb,
      );
    } else {
      // Advanced mode logic
      if (repeatEnabled && selectedWeekdays.isNotEmpty) {
        await reminderManager.createWeeklyReminder(
          activityType: widget.activityType,
          scheduledTime: '${selectedTime!.hour}:${selectedTime!.minute}',
          weekdays: selectedWeekdays,
          doNotDisturb: doNotDisturb,
        );
      } else if (repeatEnabled) {
        await reminderManager.createDailyReminder(
          activityType: widget.activityType,
          scheduledTime: '${selectedTime!.hour}:${selectedTime!.minute}',
          doNotDisturb: doNotDisturb,
        );
      } else {
        await reminderManager.createOneTimeReminder(
          activityType: widget.activityType,
          scheduledDate: DateTime.now(),
          scheduledTime: '${selectedTime!.hour}:${selectedTime!.minute}',
          doNotDisturb: doNotDisturb,
        );
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Build your form UI here
    return Scaffold(
      appBar: AppBar(title: Text('Create Reminder')),
      body: Column(
        children: [
          // Mode selector (Basic/Advanced)
          SegmentedButton(
            segments: [
              ButtonSegment(value: ReminderMode.basic, label: Text('Basic')),
              ButtonSegment(value: ReminderMode.advanced, label: Text('Advanced')),
            ],
            selected: {mode},
            onSelectionChanged: (Set<ReminderMode> selected) {
              setState(() => mode = selected.first);
            },
          ),

          // Show different controls based on mode
          if (mode == ReminderMode.basic) ...[
            // Interval selector
            Text('Every $_intervalHours hours'),
            Slider(
              value: intervalHours.toDouble(),
              min: 1,
              max: 12,
              divisions: 11,
              onChanged: (value) => setState(() => intervalHours = value.toInt()),
            ),
          ] else ...[
            // Time picker
            ListTile(
              title: Text('Time'),
              trailing: Text(selectedTime?.format(context) ?? 'Select'),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) setState(() => selectedTime = time);
              },
            ),

            // Repeat toggle
            SwitchListTile(
              title: Text('Repeat'),
              value: repeatEnabled,
              onChanged: (value) => setState(() => repeatEnabled = value),
            ),

            // Weekday selector (if repeat enabled)
            if (repeatEnabled) ...[
              // Add weekday chips here
            ],
          ],

          // Do Not Disturb toggle
          SwitchListTile(
            title: Text('Do Not Disturb'),
            value: doNotDisturb,
            onChanged: (value) => setState(() => doNotDisturb = value),
          ),

          // Save button
          ElevatedButton(
            onPressed: _saveReminder,
            child: Text('Save Reminder'),
          ),
        ],
      ),
    );
  }
}
```

## Database Schema

The reminder table is automatically created with these fields:

```sql
CREATE TABLE reminder (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  activity_type TEXT NOT NULL,
  mode TEXT NOT NULL,
  interval_hours INTEGER,
  scheduled_date INTEGER,
  scheduled_time TEXT,
  repeat_enabled INTEGER DEFAULT 0,
  repeat_type TEXT,
  repeat_interval INTEGER,
  weekdays TEXT,
  do_not_disturb INTEGER DEFAULT 0,
  group_id TEXT,
  is_active INTEGER DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER,
  title TEXT,
  message TEXT,
  baby_id INTEGER,
  FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
)
```

## Troubleshooting

### Notifications not appearing

1. Check permissions:
```dart
final permissions = await reminderManager.checkPermissions();
print(permissions.allGranted); // Should be true
```

2. Verify reminder is active and not in DND mode
3. Check system notification settings
4. For iOS: Check Focus mode settings
5. For Android 12+: Ensure exact alarm permission is granted

### Reminders not persisting after app restart

The system automatically reschedules all reminders on app startup. Ensure `ReminderManager().initialize()` is called in `main()`.

### Time zone issues

The system uses device local time zone. If you need UTC or specific time zones, modify [notification_service.dart:14](babycare/lib/services/notification_service.dart#L14).

## Advanced Customization

### Custom Notification Sounds

Modify [notification_service.dart:84](babycare/lib/services/notification_service.dart#L84) to add custom sounds:

```dart
AndroidNotificationDetails(
  'baby_care_reminders',
  'Baby Care Reminders',
  sound: RawResourceAndroidNotificationSound('custom_sound'),
  // ...
)
```

### Notification Actions

Add action buttons to notifications by modifying the notification details in [notification_service.dart](babycare/lib/services/notification_service.dart).

## Best Practices

1. **Always check permissions** before creating reminders
2. **Initialize once** in main.dart
3. **Use groupId** to organize related reminders
4. **Provide custom titles/messages** for better UX
5. **Link to babyId** for multi-baby support
6. **Handle DND properly** - save reminder but suppress notifications
7. **Reschedule after updates** - system handles this automatically

## Testing

```dart
// Test basic reminder
final id = await reminderManager.createBasicReminder(
  activityType: ActivityTypes.diaper,
  intervalHours: 2,
);

// Verify it was created
final reminder = await reminderManager.getReminder(id);
assert(reminder != null);
assert(reminder!.intervalHours == 2);

// Verify it's scheduled (check pending notifications)
final notificationService = NotificationService();
final pending = await notificationService.getPendingNotifications();
print('Pending notifications: ${pending.length}');
```

## Support

For issues or questions:
- Check this guide first
- Review the service implementations
- Ensure all dependencies are installed
- Verify platform configurations are correct
