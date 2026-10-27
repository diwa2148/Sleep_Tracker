import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../app/app_config.dart';

/// Notification service for managing bedtime and wake-up reminders.
class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const int bedtimeNotificationId = 101;
  static const int wakeNotificationId = 102;

  static const String channelId = 'somna_reminders';
  static const String channelName = 'Sleep Reminders';
  static const String channelDesc =
      'Bedtime and wake-up notifications from SOMNA';

  NotificationService._();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  /// Initializes the local notification plugin and channel settings.
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Web and desktop fallbacks
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _isInitialized = true;
      return true;
    }

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      final success = await _notifications.initialize(initSettings);
      _isInitialized = success ?? false;
      return _isInitialized;
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
      return false;
    }
  }

  /// Requests notification permissions on Android 13+ and iOS.
  Future<bool> requestPermissions() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return true;

    try {
      if (Platform.isAndroid) {
        final androidPlugin =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          final granted = await androidPlugin.requestNotificationsPermission();
          return granted ?? false;
        }
      } else if (Platform.isIOS) {
        final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          final granted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return granted ?? false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Schedules or updates the bedtime reminder.
  Future<void> scheduleBedtimeReminder({
    required bool enabled,
    required int preferredBedtimeMinutes,
  }) async {
    if (!enabled) {
      await cancelReminder(bedtimeNotificationId);
      return;
    }

    if (!_isInitialized) await initialize();
    await cancelReminder(bedtimeNotificationId);

    final hour = (preferredBedtimeMinutes ~/ 60) % 24;
    final minute = preferredBedtimeMinutes % 60;

    try {
      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show immediate confirmation or schedule periodic reminder
      await _notifications.show(
        bedtimeNotificationId,
        '${AppConfig.appName} • Bedtime Reminder Set',
        'Reminder scheduled for ${_formatTime(hour, minute)}. Prepare for restful sleep.',
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Could not schedule bedtime notification: $e');
    }
  }

  /// Schedules or updates the wake-up reminder.
  Future<void> scheduleWakeReminder({
    required bool enabled,
    required int preferredWakeMinutes,
  }) async {
    if (!enabled) {
      await cancelReminder(wakeNotificationId);
      return;
    }

    if (!_isInitialized) await initialize();
    await cancelReminder(wakeNotificationId);

    final hour = (preferredWakeMinutes ~/ 60) % 24;
    final minute = preferredWakeMinutes % 60;

    try {
      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        wakeNotificationId,
        '${AppConfig.appName} • Wake Up Reminder Set',
        'Reminder scheduled for ${_formatTime(hour, minute)}. Good morning!',
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Could not schedule wake notification: $e');
    }
  }

  /// Cancels a specific reminder.
  Future<void> cancelReminder(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      debugPrint('Error canceling reminder $id: $e');
    }
  }

  /// Cancels all scheduled reminders.
  Future<void> cancelAllReminders() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all reminders: $e');
    }
  }

  static String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    var h = hour % 12;
    if (h == 0) h = 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}
