import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/reminder.dart';
import 'notification_service.dart';
import 'reminder_repository.dart';

/// Service for scheduling and managing reminder notifications
class ReminderSchedulingService {
  static final ReminderSchedulingService _instance =
      ReminderSchedulingService._internal();
  factory ReminderSchedulingService() => _instance;
  ReminderSchedulingService._internal();

  final NotificationService _notificationService = NotificationService();
  final ReminderRepository _reminderRepository = ReminderRepository();

  /// Schedule or reschedule a reminder
  Future<void> scheduleReminder(Reminder reminder) async {
    // Check if notifications are enabled
    final notificationsEnabled =
        await _notificationService.areNotificationsEnabled();

    // If Do Not Disturb is enabled or notifications are disabled, don't schedule
    if (reminder.doNotDisturb || !notificationsEnabled || !reminder.isActive) {
      return;
    }

    // Cancel any existing notifications for this reminder
    if (reminder.id != null) {
      await cancelReminder(reminder.id!);
    }

    // Get notification content
    final content = _notificationService.getNotificationContent(
      reminder.activityType,
      customTitle: reminder.title,
      customMessage: reminder.message,
    );

    final String title = content['title']!;
    final String body = content['body']!;
    final String payload = 'reminder_${reminder.id}_${reminder.activityType}';

    // Schedule based on mode
    if (reminder.mode == ReminderMode.basic) {
      await _scheduleBasicReminder(reminder, title, body, payload);
    } else {
      await _scheduleAdvancedReminder(reminder, title, body, payload);
    }
  }

  /// Schedule basic interval-based reminder
  Future<void> _scheduleBasicReminder(
    Reminder reminder,
    String title,
    String body,
    String payload,
  ) async {
    if (reminder.intervalHours == null) return;

    // Calculate next notification time
    final now = DateTime.now();
    final nextTime = now.add(Duration(hours: reminder.intervalHours!));

    // Generate unique notification ID based on reminder ID
    final int notificationId = _generateNotificationId(reminder.id!);

    // Schedule repeating notification at interval
    await _scheduleIntervalNotification(
      notificationId,
      title,
      body,
      nextTime,
      reminder.intervalHours!,
      payload,
    );
  }

  /// Schedule advanced date/time based reminder
  Future<void> _scheduleAdvancedReminder(
    Reminder reminder,
    String title,
    String body,
    String payload,
  ) async {
    if (reminder.scheduledDate == null || reminder.scheduledTime == null) {
      return;
    }

    // Parse time (HH:mm format)
    final timeParts = reminder.scheduledTime!.split(':');
    if (timeParts.length != 2) return;

    final int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);

    if (reminder.repeatEnabled) {
      await _scheduleRepeatingAdvancedReminder(
        reminder,
        hour,
        minute,
        title,
        body,
        payload,
      );
    } else {
      // One-time notification
      final scheduledDateTime = DateTime(
        reminder.scheduledDate!.year,
        reminder.scheduledDate!.month,
        reminder.scheduledDate!.day,
        hour,
        minute,
      );

      // Only schedule if in the future
      if (scheduledDateTime.isAfter(DateTime.now())) {
        final int notificationId = _generateNotificationId(reminder.id!);
        await _notificationService.scheduleNotification(
          id: notificationId,
          title: title,
          body: body,
          scheduledTime: scheduledDateTime,
          payload: payload,
        );
      }
    }
  }

  /// Schedule repeating advanced reminder
  Future<void> _scheduleRepeatingAdvancedReminder(
    Reminder reminder,
    int hour,
    int minute,
    String title,
    String body,
    String payload,
  ) async {
    if (reminder.repeatType == RepeatType.daily) {
      await _scheduleDailyReminder(
        reminder,
        hour,
        minute,
        title,
        body,
        payload,
      );
    } else if (reminder.repeatType == RepeatType.weekly) {
      await _scheduleWeeklyReminder(
        reminder,
        hour,
        minute,
        title,
        body,
        payload,
      );
    }
  }

  /// Schedule daily repeating reminder
  Future<void> _scheduleDailyReminder(
    Reminder reminder,
    int hour,
    int minute,
    String title,
    String body,
    String payload,
  ) async {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Handle repeatInterval (every N days)
    if (reminder.repeatInterval != null && reminder.repeatInterval! > 1) {
      // For custom intervals, schedule multiple single notifications
      // Note: flutter_local_notifications doesn't support custom day intervals natively
      // So we schedule next occurrence only
      final int notificationId = _generateNotificationId(reminder.id!);
      await _notificationService.scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        payload: payload,
      );
    } else {
      // Daily repeat
      final int notificationId = _generateNotificationId(reminder.id!);
      await _notificationService.scheduleRepeatingNotification(
        id: notificationId,
        title: title,
        body: body,
        firstScheduledTime: scheduledTime,
        repeatInterval: RepeatInterval.daily,
        payload: payload,
      );
    }
  }

  /// Schedule weekly repeating reminder on specific weekdays
  Future<void> _scheduleWeeklyReminder(
    Reminder reminder,
    int hour,
    int minute,
    String title,
    String body,
    String payload,
  ) async {
    if (reminder.weekdays == null || reminder.weekdays!.isEmpty) return;

    // Schedule notification for each selected weekday
    for (int i = 0; i < reminder.weekdays!.length; i++) {
      final int targetWeekday = reminder.weekdays![i];

      // Calculate next occurrence of this weekday
      DateTime scheduledTime = _getNextWeekday(targetWeekday, hour, minute);

      // Generate unique notification ID for each weekday
      final int notificationId =
          _generateNotificationId(reminder.id! * 10 + i);

      await _notificationService.scheduleRepeatingNotification(
        id: notificationId,
        title: title,
        body: body,
        firstScheduledTime: scheduledTime,
        repeatInterval: RepeatInterval.weekly,
        payload: payload,
      );
    }
  }

  /// Schedule interval-based notification (for basic mode)
  Future<void> _scheduleIntervalNotification(
    int notificationId,
    String title,
    String body,
    DateTime firstScheduledTime,
    int intervalHours,
    String payload,
  ) async {
    // Note: flutter_local_notifications doesn't support custom hour intervals
    // We schedule the next occurrence and will need to reschedule after each notification
    await _notificationService.scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledTime: firstScheduledTime,
      payload: payload,
    );
  }

  /// Cancel all notifications for a reminder
  Future<void> cancelReminder(int reminderId) async {
    // Cancel base notification
    final int baseNotificationId = _generateNotificationId(reminderId);
    await _notificationService.cancelNotification(baseNotificationId);

    // Cancel up to 10 potential weekday notifications
    for (int i = 0; i < 10; i++) {
      final int notificationId = _generateNotificationId(reminderId * 10 + i);
      await _notificationService.cancelNotification(notificationId);
    }
  }

  /// Reschedule all active reminders (useful after app restart)
  Future<void> rescheduleAllReminders() async {
    final reminders = await _reminderRepository.getActiveReminders();
    for (final reminder in reminders) {
      await scheduleReminder(reminder);
    }
  }

  /// Calculate next occurrence of a specific weekday
  DateTime _getNextWeekday(int targetWeekday, int hour, int minute) {
    final now = DateTime.now();
    int daysToAdd = targetWeekday - now.weekday;

    // If target weekday is today but time has passed, add 7 days
    if (daysToAdd == 0) {
      final todayScheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (todayScheduledTime.isBefore(now)) {
        daysToAdd = 7;
      }
    }

    // If target weekday is in the past this week, add 7 days
    if (daysToAdd < 0) {
      daysToAdd += 7;
    }

    return DateTime(
      now.year,
      now.month,
      now.day + daysToAdd,
      hour,
      minute,
    );
  }

  /// Generate consistent notification ID from reminder ID
  int _generateNotificationId(int reminderId) {
    // Use reminder ID directly, ensuring it's within valid range
    // SQLite IDs are positive integers
    return reminderId;
  }

  /// Save and schedule a new reminder
  Future<int> createAndScheduleReminder(Reminder reminder) async {
    final int id = await _reminderRepository.createReminder(reminder);
    final Reminder? savedReminder = await _reminderRepository.getReminderById(id);

    if (savedReminder != null) {
      await scheduleReminder(savedReminder);
    }

    return id;
  }

  /// Update and reschedule a reminder
  Future<void> updateAndRescheduleReminder(Reminder reminder) async {
    await _reminderRepository.updateReminder(reminder);
    await scheduleReminder(reminder);
  }

  /// Delete reminder and cancel its notifications
  Future<void> deleteReminderAndCancel(int reminderId) async {
    await cancelReminder(reminderId);
    await _reminderRepository.deleteReminder(reminderId);
  }

  /// Toggle reminder on/off
  Future<void> toggleReminder(int reminderId, bool isActive) async {
    await _reminderRepository.toggleReminderState(reminderId, isActive);

    if (isActive) {
      final reminder = await _reminderRepository.getReminderById(reminderId);
      if (reminder != null) {
        await scheduleReminder(reminder);
      }
    } else {
      await cancelReminder(reminderId);
    }
  }
}
