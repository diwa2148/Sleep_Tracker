import 'package:flutter/material.dart';
import '../../app/app_config.dart';

/// User settings and sleep preferences for SOMNA.
class UserPreferences {
  final int sleepGoalMinutes;
  final int
      preferredBedtimeMinutes; // Minutes from midnight (e.g. 1380 = 23:00)
  final int preferredWakeMinutes; // Minutes from midnight (e.g. 420 = 07:00)
  final bool bedtimeReminderEnabled;
  final bool wakeReminderEnabled;
  final ThemeMode themeMode;
  final bool onboardingCompleted;
  final bool hapticsEnabled;
  final bool crtScanlinesEnabled;
  final bool oledModeEnabled;
  final int smartWakeLeewayMinutes;
  final String chronotype;

  const UserPreferences({
    this.sleepGoalMinutes = AppConfig.defaultSleepGoalMinutes,
    this.preferredBedtimeMinutes = AppConfig.defaultBedtimeMinutes,
    this.preferredWakeMinutes = AppConfig.defaultWakeMinutes,
    this.bedtimeReminderEnabled = false,
    this.wakeReminderEnabled = false,
    this.themeMode = ThemeMode.light,
    this.onboardingCompleted = true,
    this.hapticsEnabled = true,
    this.crtScanlinesEnabled = false,
    this.oledModeEnabled = false,
    this.smartWakeLeewayMinutes = 15,
    this.chronotype = 'bear',
  });

  /// Formatted sleep goal, e.g. "8h 00m" or "7h 30m".
  String get formattedSleepGoal {
    final h = sleepGoalMinutes ~/ 60;
    final m = sleepGoalMinutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// TimeOfDay representation for preferred bedtime.
  TimeOfDay get preferredBedtime {
    final h = preferredBedtimeMinutes ~/ 60;
    final m = preferredBedtimeMinutes % 60;
    return TimeOfDay(hour: h % 24, minute: m);
  }

  /// TimeOfDay representation for preferred wake time.
  TimeOfDay get preferredWakeTime {
    final h = preferredWakeMinutes ~/ 60;
    final m = preferredWakeMinutes % 60;
    return TimeOfDay(hour: h % 24, minute: m);
  }

  /// Calculates target schedule duration in minutes.
  int get targetScheduleDurationMinutes {
    int duration = preferredWakeMinutes - preferredBedtimeMinutes;
    if (duration < 0) {
      duration += 1440; // Crossed midnight
    }
    return duration;
  }

  UserPreferences copyWith({
    int? sleepGoalMinutes,
    int? preferredBedtimeMinutes,
    int? preferredWakeMinutes,
    bool? bedtimeReminderEnabled,
    bool? wakeReminderEnabled,
    ThemeMode? themeMode,
    bool? onboardingCompleted,
    bool? hapticsEnabled,
    bool? crtScanlinesEnabled,
    bool? oledModeEnabled,
    int? smartWakeLeewayMinutes,
    String? chronotype,
  }) {
    return UserPreferences(
      sleepGoalMinutes: sleepGoalMinutes ?? this.sleepGoalMinutes,
      preferredBedtimeMinutes:
          preferredBedtimeMinutes ?? this.preferredBedtimeMinutes,
      preferredWakeMinutes: preferredWakeMinutes ?? this.preferredWakeMinutes,
      bedtimeReminderEnabled:
          bedtimeReminderEnabled ?? this.bedtimeReminderEnabled,
      wakeReminderEnabled: wakeReminderEnabled ?? this.wakeReminderEnabled,
      themeMode: themeMode ?? this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      crtScanlinesEnabled: crtScanlinesEnabled ?? this.crtScanlinesEnabled,
      oledModeEnabled: oledModeEnabled ?? this.oledModeEnabled,
      smartWakeLeewayMinutes:
          smartWakeLeewayMinutes ?? this.smartWakeLeewayMinutes,
      chronotype: chronotype ?? this.chronotype,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sleepGoalMinutes': sleepGoalMinutes,
      'preferredBedtimeMinutes': preferredBedtimeMinutes,
      'preferredWakeMinutes': preferredWakeMinutes,
      'bedtimeReminderEnabled': bedtimeReminderEnabled,
      'wakeReminderEnabled': wakeReminderEnabled,
      'themeMode': themeMode.name,
      'onboardingCompleted': onboardingCompleted,
      'hapticsEnabled': hapticsEnabled,
      'crtScanlinesEnabled': crtScanlinesEnabled,
      'oledModeEnabled': oledModeEnabled,
      'smartWakeLeewayMinutes': smartWakeLeewayMinutes,
      'chronotype': chronotype,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    // User explicitly requested light theme. Default to light even if dark was cached.
    ThemeMode mode = ThemeMode.light;
    if (json['themeMode'] == 'dark') {
      mode = ThemeMode.light;
    } else if (json['themeMode'] == 'system') {
      mode = ThemeMode.light;
    }

    return UserPreferences(
      sleepGoalMinutes: (json['sleepGoalMinutes'] as int?) ??
          AppConfig.defaultSleepGoalMinutes,
      preferredBedtimeMinutes: (json['preferredBedtimeMinutes'] as int?) ??
          AppConfig.defaultBedtimeMinutes,
      preferredWakeMinutes: (json['preferredWakeMinutes'] as int?) ??
          AppConfig.defaultWakeMinutes,
      bedtimeReminderEnabled:
          (json['bedtimeReminderEnabled'] as bool?) ?? false,
      wakeReminderEnabled: (json['wakeReminderEnabled'] as bool?) ?? false,
      themeMode: mode,
      onboardingCompleted: (json['onboardingCompleted'] as bool?) ?? true,
      hapticsEnabled: (json['hapticsEnabled'] as bool?) ?? true,
      crtScanlinesEnabled: (json['crtScanlinesEnabled'] as bool?) ?? false,
      oledModeEnabled: (json['oledModeEnabled'] as bool?) ?? false,
      smartWakeLeewayMinutes:
          (json['smartWakeLeewayMinutes'] as int?) ?? 15,
      chronotype: (json['chronotype'] as String?) ?? 'bear',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          runtimeType == other.runtimeType &&
          sleepGoalMinutes == other.sleepGoalMinutes &&
          preferredBedtimeMinutes == other.preferredBedtimeMinutes &&
          preferredWakeMinutes == other.preferredWakeMinutes &&
          bedtimeReminderEnabled == other.bedtimeReminderEnabled &&
          wakeReminderEnabled == other.wakeReminderEnabled &&
          themeMode == other.themeMode &&
          onboardingCompleted == other.onboardingCompleted &&
          hapticsEnabled == other.hapticsEnabled &&
          crtScanlinesEnabled == other.crtScanlinesEnabled &&
          smartWakeLeewayMinutes == other.smartWakeLeewayMinutes &&
          chronotype == other.chronotype;

  @override
  int get hashCode =>
      sleepGoalMinutes.hashCode ^
      preferredBedtimeMinutes.hashCode ^
      preferredWakeMinutes.hashCode ^
      bedtimeReminderEnabled.hashCode ^
      wakeReminderEnabled.hashCode ^
      themeMode.hashCode ^
      onboardingCompleted.hashCode ^
      hapticsEnabled.hashCode ^
      crtScanlinesEnabled.hashCode ^
      smartWakeLeewayMinutes.hashCode ^
      chronotype.hashCode;
}
