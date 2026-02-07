import '../models/reminder.dart';
import 'notification_service.dart';
import 'permission_service.dart';
import 'reminder_scheduling_service.dart';
import 'reminder_repository.dart';

/// High-level manager for reminder functionality
/// This is the main entry point for reminder features
class ReminderManager {
  static final ReminderManager _instance = ReminderManager._internal();
  factory ReminderManager() => _instance;
  ReminderManager._internal();

  final NotificationService _notificationService = NotificationService();
  final PermissionService _permissionService = PermissionService();
  final ReminderSchedulingService _schedulingService = ReminderSchedulingService();
  final ReminderRepository _repository = ReminderRepository();

  bool _isInitialized = false;

  /// Initialize the reminder system
  /// Call this once during app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize notification service
      await _notificationService.initialize();

      // Reschedule all active reminders (important after app restart)
      await _schedulingService.rescheduleAllReminders();

      _isInitialized = true;
    } catch (e) {
      print('Error initializing ReminderManager: $e');
      rethrow;
    }
  }

  /// Check if reminder system is ready to use
  Future<bool> isReady() async {
    if (!_isInitialized) {
      await initialize();
    }

    final permissions = await _permissionService.checkReminderPermissions();
    return permissions.allGranted;
  }

  /// Request all necessary permissions
  Future<PermissionsStatus> requestPermissions() async {
    return await _permissionService.requestReminderPermissions();
  }

  /// Check current permission status
  Future<PermissionsStatus> checkPermissions() async {
    return await _permissionService.checkReminderPermissions();
  }

  /// Create and schedule a basic interval reminder
  /// Example: Every 3 hours reminder for feeding
  Future<int> createBasicReminder({
    required String activityType,
    required int intervalHours,
    bool doNotDisturb = false,
    String? groupId,
    String? title,
    String? message,
    int? babyId,
  }) async {
    final reminder = Reminder(
      activityType: activityType,
      mode: ReminderMode.basic,
      intervalHours: intervalHours,
      doNotDisturb: doNotDisturb,
      groupId: groupId,
      isActive: true,
      createdAt: DateTime.now(),
      title: title,
      message: message,
      babyId: babyId,
    );

    return await _schedulingService.createAndScheduleReminder(reminder);
  }

  /// Create and schedule an advanced one-time reminder
  /// Example: Reminder on specific date and time
  Future<int> createOneTimeReminder({
    required String activityType,
    required DateTime scheduledDate,
    required String scheduledTime, // HH:mm format
    bool doNotDisturb = false,
    String? groupId,
    String? title,
    String? message,
    int? babyId,
  }) async {
    final reminder = Reminder(
      activityType: activityType,
      mode: ReminderMode.advanced,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      repeatEnabled: false,
      doNotDisturb: doNotDisturb,
      groupId: groupId,
      isActive: true,
      createdAt: DateTime.now(),
      title: title,
      message: message,
      babyId: babyId,
    );

    return await _schedulingService.createAndScheduleReminder(reminder);
  }

  /// Create and schedule a daily repeating reminder
  /// Example: Every day at 9:00 AM
  Future<int> createDailyReminder({
    required String activityType,
    required String scheduledTime, // HH:mm format
    int? repeatEveryNDays, // null = every day, 2 = every 2 days, etc.
    bool doNotDisturb = false,
    String? groupId,
    String? title,
    String? message,
    int? babyId,
  }) async {
    final reminder = Reminder(
      activityType: activityType,
      mode: ReminderMode.advanced,
      scheduledDate: DateTime.now(), // Start from today
      scheduledTime: scheduledTime,
      repeatEnabled: true,
      repeatType: RepeatType.daily,
      repeatInterval: repeatEveryNDays ?? 1,
      doNotDisturb: doNotDisturb,
      groupId: groupId,
      isActive: true,
      createdAt: DateTime.now(),
      title: title,
      message: message,
      babyId: babyId,
    );

    return await _schedulingService.createAndScheduleReminder(reminder);
  }

  /// Create and schedule a weekly repeating reminder on specific days
  /// Example: Every Monday and Friday at 10:00 AM
  /// weekdays: 1=Monday, 2=Tuesday, ..., 7=Sunday
  Future<int> createWeeklyReminder({
    required String activityType,
    required String scheduledTime, // HH:mm format
    required List<int> weekdays, // [1,2,3,4,5,6,7]
    bool doNotDisturb = false,
    String? groupId,
    String? title,
    String? message,
    int? babyId,
  }) async {
    final reminder = Reminder(
      activityType: activityType,
      mode: ReminderMode.advanced,
      scheduledDate: DateTime.now(),
      scheduledTime: scheduledTime,
      repeatEnabled: true,
      repeatType: RepeatType.weekly,
      weekdays: weekdays,
      doNotDisturb: doNotDisturb,
      groupId: groupId,
      isActive: true,
      createdAt: DateTime.now(),
      title: title,
      message: message,
      babyId: babyId,
    );

    return await _schedulingService.createAndScheduleReminder(reminder);
  }

  /// Update an existing reminder
  Future<void> updateReminder(Reminder reminder) async {
    await _schedulingService.updateAndRescheduleReminder(
      reminder.copyWith(updatedAt: DateTime.now()),
    );
  }

  /// Delete a reminder
  Future<void> deleteReminder(int reminderId) async {
    await _schedulingService.deleteReminderAndCancel(reminderId);
  }

  /// Toggle reminder on/off
  Future<void> toggleReminder(int reminderId, bool isActive) async {
    await _schedulingService.toggleReminder(reminderId, isActive);
  }

  /// Toggle Do Not Disturb for a reminder
  Future<void> toggleDoNotDisturb(int reminderId, bool doNotDisturb) async {
    await _repository.toggleDoNotDisturb(reminderId, doNotDisturb);

    // Reschedule or cancel notifications based on new DND state
    final reminder = await _repository.getReminderById(reminderId);
    if (reminder != null) {
      if (doNotDisturb) {
        await _schedulingService.cancelReminder(reminderId);
      } else {
        await _schedulingService.scheduleReminder(reminder);
      }
    }
  }

  /// Get all reminders
  Future<List<Reminder>> getAllReminders({
    int? babyId,
    String? activityType,
    bool? isActive,
  }) async {
    return await _repository.fetchReminders(
      babyId: babyId,
      activityType: activityType,
      isActive: isActive,
    );
  }

  /// Get a specific reminder
  Future<Reminder?> getReminder(int reminderId) async {
    return await _repository.getReminderById(reminderId);
  }

  /// Get reminders by group
  Future<List<Reminder>> getRemindersByGroup(String groupId) async {
    return await _repository.getRemindersByGroup(groupId);
  }

  /// Get count of active reminders
  Future<int> getActiveReminderCount() async {
    return await _repository.countReminders(isActive: true);
  }

  /// Reschedule all reminders (useful after system boot or app update)
  Future<void> rescheduleAll() async {
    await _schedulingService.rescheduleAllReminders();
  }
}
