/// Global configuration for SOMNA — Smart Sleep Tracker.
class AppConfig {
  AppConfig._();

  static const String appName = 'SOMNA';
  static const String appTagline = 'Smart Sleep Tracker';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Default sleep goal: 8 hours (480 minutes)
  static const int defaultSleepGoalMinutes = 480;
  static const int minSleepGoalMinutes = 240; // 4 hours
  static const int maxSleepGoalMinutes = 720; // 12 hours

  // Default bedtime: 23:00 (11:00 PM) = 1380 minutes from midnight
  static const int defaultBedtimeMinutes = 1380;

  // Default wake time: 07:00 (7:00 AM) = 420 minutes from midnight
  static const int defaultWakeMinutes = 420;

  // Database
  static const String databaseName = 'somna_sleep_tracker.db';
  static const int databaseVersion = 1;

  // Storage Keys
  static const String keySleepGoal = 'somna_sleep_goal_minutes';
  static const String keyBedtime = 'somna_preferred_bedtime';
  static const String keyWakeTime = 'somna_preferred_wake_time';
  static const String keyBedtimeReminder = 'somna_bedtime_reminder_enabled';
  static const String keyWakeReminder = 'somna_wake_reminder_enabled';
  static const String keyThemeMode = 'somna_theme_mode';
  static const String keyOnboardingCompleted = 'somna_onboarding_completed';
  static const String keyHapticsEnabled = 'somna_haptics_enabled';
}
