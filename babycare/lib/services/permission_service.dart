import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

/// Service for managing app permissions
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Request notification permission
  Future<PermissionResult> requestNotificationPermission() async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      return PermissionResult.granted;
    } else if (status.isDenied) {
      return PermissionResult.denied;
    } else if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.restricted;
    }
  }

  /// Check if exact alarm permission is granted (Android 12+)
  Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    // For Android 12+ (API 31+), we need exact alarm permission
    if (await _isAndroid12OrHigher()) {
      final status = await Permission.scheduleExactAlarm.status;
      return status.isGranted;
    }

    return true;
  }

  /// Request exact alarm permission (Android 12+)
  Future<PermissionResult> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return PermissionResult.granted;

    if (await _isAndroid12OrHigher()) {
      final status = await Permission.scheduleExactAlarm.request();

      if (status.isGranted) {
        return PermissionResult.granted;
      } else if (status.isDenied) {
        return PermissionResult.denied;
      } else if (status.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied;
      } else {
        return PermissionResult.restricted;
      }
    }

    return PermissionResult.granted;
  }

  /// Check all required permissions for reminders
  Future<PermissionsStatus> checkReminderPermissions() async {
    final notificationGranted = await hasNotificationPermission();
    final exactAlarmGranted = await hasExactAlarmPermission();

    return PermissionsStatus(
      notificationPermission: notificationGranted,
      exactAlarmPermission: exactAlarmGranted,
    );
  }

  /// Request all required permissions for reminders
  Future<PermissionsStatus> requestReminderPermissions() async {
    final notificationResult = await requestNotificationPermission();
    final exactAlarmResult = await requestExactAlarmPermission();

    return PermissionsStatus(
      notificationPermission: notificationResult == PermissionResult.granted,
      exactAlarmPermission: exactAlarmResult == PermissionResult.granted,
    );
  }

  /// Open app settings if permissions are permanently denied
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Check if device is running Android 12 or higher
  Future<bool> _isAndroid12OrHigher() async {
    if (!Platform.isAndroid) return false;

    // This is a simplified check. In production, you might want to use
    // device_info_plus package to get actual SDK version
    return true; // Assume Android 12+ for safety
  }
}

/// Result of a permission request
enum PermissionResult {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

/// Status of all required permissions
class PermissionsStatus {
  final bool notificationPermission;
  final bool exactAlarmPermission;

  PermissionsStatus({
    required this.notificationPermission,
    required this.exactAlarmPermission,
  });

  /// Check if all required permissions are granted
  bool get allGranted => notificationPermission && exactAlarmPermission;

  /// Get list of missing permissions
  List<String> get missingPermissions {
    List<String> missing = [];
    if (!notificationPermission) missing.add('Notifications');
    if (!exactAlarmPermission) missing.add('Exact Alarms');
    return missing;
  }
}
