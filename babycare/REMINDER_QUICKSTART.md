# ⚡ Reminder System - 5 Minute Quick Start

## Step 1: Install Dependencies (30 seconds)

```bash
cd babycare
flutter pub get
```

## Step 2: Initialize in main.dart (1 minute)

Open [lib/main.dart](lib/main.dart) and add:

```dart
import 'package:babycare/services/reminder_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add this line ⬇️
  await ReminderManager().initialize();

  runApp(MyApp());
}
```

## Step 3: Create Your First Reminder (3 minutes)

Add this anywhere in your app (e.g., in a button's `onPressed`):

```dart
import 'package:babycare/services/reminder_manager.dart';
import 'package:babycare/core/constants/activity_types.dart';

// Create a feeding reminder every 3 hours
Future<void> createFeedingReminder() async {
  final manager = ReminderManager();

  // Check and request permissions
  final permissions = await manager.checkPermissions();
  if (!permissions.allGranted) {
    await manager.requestPermissions();
  }

  // Create reminder
  await manager.createBasicReminder(
    activityType: ActivityTypes.breastfeeding,
    intervalHours: 3,
    title: 'Feeding Time',
    message: 'Time to feed your baby',
  );

  print('Reminder created!');
}
```

## Step 4: Run and Test

```bash
flutter run
```

1. Tap the button that calls `createFeedingReminder()`
2. Grant notification permissions when prompted
3. Wait for notification (or change `intervalHours: 1` for faster testing)

## Done! 🎉

Your reminder system is working. Now explore:

- **[REMINDER_SYSTEM_GUIDE.md](REMINDER_SYSTEM_GUIDE.md)** - Full documentation
- **[REMINDER_INTEGRATION_EXAMPLES.md](REMINDER_INTEGRATION_EXAMPLES.md)** - UI examples
- **[REMINDER_IMPLEMENTATION_SUMMARY.md](REMINDER_IMPLEMENTATION_SUMMARY.md)** - What was built

## Common Reminder Types

### Every 3 Hours (Feeding)
```dart
await manager.createBasicReminder(
  activityType: ActivityTypes.breastfeeding,
  intervalHours: 3,
);
```

### Daily at 8:00 AM (Bath)
```dart
await manager.createDailyReminder(
  activityType: ActivityTypes.bath,
  scheduledTime: '08:00',
);
```

### Weekly on Mon/Wed/Fri (Doctor)
```dart
await manager.createWeeklyReminder(
  activityType: ActivityTypes.health,
  scheduledTime: '10:00',
  weekdays: [1, 3, 5], // Mon, Wed, Fri
);
```

### One-Time (Appointment)
```dart
await manager.createOneTimeReminder(
  activityType: ActivityTypes.health,
  scheduledDate: DateTime(2026, 2, 15),
  scheduledTime: '14:30',
);
```

## View All Reminders

```dart
final reminders = await manager.getAllReminders();
for (var reminder in reminders) {
  print('${reminder.activityType}: ${reminder.isActive}');
}
```

## Toggle Reminder

```dart
await manager.toggleReminder(reminderId, false); // Disable
await manager.toggleReminder(reminderId, true);  // Enable
```

## Delete Reminder

```dart
await manager.deleteReminder(reminderId);
```

---

**That's it!** You're now ready to build your reminder UI. Check the full documentation for advanced features like groups, Do Not Disturb, and more.
