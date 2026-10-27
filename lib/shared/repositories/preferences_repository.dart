import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/app_config.dart';
import '../models/user_preferences.dart';

/// Repository for loading and persisting [UserPreferences] in SharedPreferences.
class PreferencesRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Loads current user preferences from storage.
  Future<UserPreferences> loadPreferences() async {
    final prefs = await _instance;

    final goal = prefs.getInt(AppConfig.keySleepGoal) ??
        AppConfig.defaultSleepGoalMinutes;
    final bedtime =
        prefs.getInt(AppConfig.keyBedtime) ?? AppConfig.defaultBedtimeMinutes;
    final wake =
        prefs.getInt(AppConfig.keyWakeTime) ?? AppConfig.defaultWakeMinutes;
    final bedtimeReminder =
        prefs.getBool(AppConfig.keyBedtimeReminder) ?? false;
    final wakeReminder = prefs.getBool(AppConfig.keyWakeReminder) ?? false;
    final themeStr = prefs.getString(AppConfig.keyThemeMode) ?? 'light';
    final onboarding = prefs.getBool(AppConfig.keyOnboardingCompleted) ?? true;
    final haptics = prefs.getBool(AppConfig.keyHapticsEnabled) ?? true;

    ThemeMode mode = ThemeMode.light;
    if (themeStr == 'dark') mode = ThemeMode.dark;
    if (themeStr == 'system') mode = ThemeMode.system;

    return UserPreferences(
      sleepGoalMinutes: goal,
      preferredBedtimeMinutes: bedtime,
      preferredWakeMinutes: wake,
      bedtimeReminderEnabled: bedtimeReminder,
      wakeReminderEnabled: wakeReminder,
      themeMode: mode,
      onboardingCompleted: onboarding,
      hapticsEnabled: haptics,
    );
  }

  /// Saves updated preferences to storage.
  Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = await _instance;

    await prefs.setInt(AppConfig.keySleepGoal, preferences.sleepGoalMinutes);
    await prefs.setInt(
        AppConfig.keyBedtime, preferences.preferredBedtimeMinutes);
    await prefs.setInt(AppConfig.keyWakeTime, preferences.preferredWakeMinutes);
    await prefs.setBool(
        AppConfig.keyBedtimeReminder, preferences.bedtimeReminderEnabled);
    await prefs.setBool(
        AppConfig.keyWakeReminder, preferences.wakeReminderEnabled);
    await prefs.setString(AppConfig.keyThemeMode, preferences.themeMode.name);
    await prefs.setBool(
        AppConfig.keyOnboardingCompleted, preferences.onboardingCompleted);
    await prefs.setBool(
        AppConfig.keyHapticsEnabled, preferences.hapticsEnabled);
  }

  /// Sets onboarding completed flag.
  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await _instance;
    await prefs.setBool(AppConfig.keyOnboardingCompleted, completed);
  }

  /// Clears all preferences back to factory defaults.
  Future<void> resetAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
