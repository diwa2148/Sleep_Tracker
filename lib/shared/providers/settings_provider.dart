import 'package:flutter/material.dart';
import '../models/user_preferences.dart';
import '../repositories/preferences_repository.dart';
import '../services/notification_service.dart';

/// Provider for user preferences, theme mode, and schedule reminders.
class SettingsProvider with ChangeNotifier {
  final PreferencesRepository _prefsRepo;
  final NotificationService _notificationService;

  UserPreferences _preferences = const UserPreferences();
  bool _isLoading = true;

  SettingsProvider({
    PreferencesRepository? prefsRepo,
    NotificationService? notificationService,
  })  : _prefsRepo = prefsRepo ?? PreferencesRepository(),
        _notificationService =
            notificationService ?? NotificationService.instance {
    _loadSettings();
  }

  UserPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _preferences.themeMode;
  bool get onboardingCompleted => _preferences.onboardingCompleted;
  bool get crtScanlinesEnabled => _preferences.crtScanlinesEnabled;
  bool get oledModeEnabled => _preferences.oledModeEnabled;

  /// Updates CRT scanlines overlay toggle.
  Future<void> updateCrtScanlines(bool enabled) async {
    _preferences = _preferences.copyWith(crtScanlinesEnabled: enabled);
    notifyListeners();
    await _prefsRepo.savePreferences(_preferences);
  }

  /// Updates OLED True-Black Mode toggle.
  Future<void> updateOledMode(bool enabled) async {
    _preferences = _preferences.copyWith(oledModeEnabled: enabled);
    notifyListeners();
    await _prefsRepo.savePreferences(_preferences);
  }

  /// Updates Smart Wake leeway window (0 for OFF, 15m, or 30m).
  Future<void> updateSmartWakeLeeway(int minutes) async {
    _preferences = _preferences.copyWith(smartWakeLeewayMinutes: minutes);
    notifyListeners();
    await _prefsRepo.savePreferences(_preferences);
  }

  /// Updates circadian chronotype archetype ('lion', 'bear', 'wolf', 'dolphin').
  Future<void> updateChronotype(String chronotype) async {
    _preferences = _preferences.copyWith(chronotype: chronotype);
    notifyListeners();
    await _prefsRepo.savePreferences(_preferences);
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _preferences = await _prefsRepo.loadPreferences();
    } catch (e) {
      debugPrint('Failed to load preferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the sleep goal in minutes.
  Future<void> updateSleepGoal(int minutes) async {
    _preferences = _preferences.copyWith(sleepGoalMinutes: minutes);
    notifyListeners();
    await _prefsRepo.savePreferences(_preferences);
  }

  /// Updates preferred bedtime and wake time.
  Future<void> updateSchedule({
    required int bedtimeMinutes,
    required int wakeMinutes,
  }) async {
    _preferences = _preferences.copyWith(
      preferredBedtimeMinutes: bedtimeMinutes,
      preferredWakeMinutes: wakeMinutes,
    );
    notifyListeners();
    await _prefsRepo.savePreferences(_preferences);

    // Reschedule reminders if active
    if (_preferences.bedtimeReminderEnabled) {
      await _notificationService.scheduleBedtimeReminder(
        enabled: true,
        preferredBedtimeMinutes: bedtimeMinutes,
      );
    }
    if (_preferences.wakeReminderEnabled) {
      await _notificationService.scheduleWakeReminder(
        enabled: true,
        preferredWakeMinutes: wakeMinutes,
      );
    }
  }

  /// Toggles bedtime reminder.
  Future<bool> setBedtimeReminder(bool enabled) async {
    if (enabled) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) return false;
    }

    _preferences = _preferences.copyWith(bedtimeReminderEnabled: enabled);
    notifyListeners();
    await _prefsRepo.savePreferences(_preferences);

    await _notificationService.scheduleBedtimeReminder(
      enabled: enabled,
      preferredBedtimeMinutes: _preferences.preferredBedtimeMinutes,
    );
    return true;
  }

  /// Toggles wake-up reminder.
  Future<bool> setWakeReminder(bool enabled) async {
    if (enabled) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) return false;
    }

    _preferences = _preferences.copyWith(wakeReminderEnabled: enabled);
    notifyListeners();
    await _prefsRepo.savePreferences(_preferences);

    await _notificationService.scheduleWakeReminder(
      enabled: enabled,
      preferredWakeMinutes: _preferences.preferredWakeMinutes,
    );
    return true;
  }

  /// Updates app theme mode (System, Dark, Light).
  Future<void> setThemeMode(ThemeMode mode) async {
    _preferences = _preferences.copyWith(themeMode: mode);
    notifyListeners();
    await _prefsRepo.savePreferences(_preferences);
  }

  /// Toggles haptic feedback preference.
  Future<void> setHapticsEnabled(bool enabled) async {
    _preferences = _preferences.copyWith(hapticsEnabled: enabled);
    notifyListeners();
    await _prefsRepo.savePreferences(_preferences);
  }

  /// Marks onboarding as completed.
  Future<void> completeOnboarding({
    int? sleepGoalMinutes,
    int? bedtimeMinutes,
    int? wakeMinutes,
    bool? enableBedtimeReminder,
  }) async {
    _preferences = _preferences.copyWith(
      onboardingCompleted: true,
      sleepGoalMinutes: sleepGoalMinutes ?? _preferences.sleepGoalMinutes,
      preferredBedtimeMinutes:
          bedtimeMinutes ?? _preferences.preferredBedtimeMinutes,
      preferredWakeMinutes: wakeMinutes ?? _preferences.preferredWakeMinutes,
      bedtimeReminderEnabled:
          enableBedtimeReminder ?? _preferences.bedtimeReminderEnabled,
    );
    notifyListeners();
    await _prefsRepo.savePreferences(_preferences);

    if (enableBedtimeReminder == true) {
      await _notificationService.scheduleBedtimeReminder(
        enabled: true,
        preferredBedtimeMinutes: _preferences.preferredBedtimeMinutes,
      );
    }
  }

  /// Resets all preferences and cancels reminders.
  Future<void> resetAll() async {
    await _notificationService.cancelAllReminders();
    await _prefsRepo.resetAll();
    _preferences = const UserPreferences();
    notifyListeners();
  }
}
