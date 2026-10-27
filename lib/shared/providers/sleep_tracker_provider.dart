import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/utils/time_calculator.dart';
import '../models/sleep_insight.dart';
import '../models/sleep_session.dart';
import '../models/sleep_stats.dart';
import '../models/user_preferences.dart';
import '../repositories/sleep_repository.dart';
import '../services/analytics_service.dart';
import '../services/insight_engine.dart';

/// Central state provider for sleep tracking, session management,
/// and live analytics recalculation.
class SleepTrackerProvider with ChangeNotifier {
  final SleepRepository _sleepRepo;

  List<SleepSession> _sessions = [];
  SleepSession? _activeSession;
  Timer? _tickerTimer;
  Duration _elapsedDuration = Duration.zero;
  bool _isLoading = true;

  SleepStats _weeklyStats = SleepStats.empty();
  SleepStats _monthlyStats = SleepStats.empty();
  List<SleepInsight> _insights = [];

  SleepTrackerProvider({SleepRepository? sleepRepo})
      : _sleepRepo = sleepRepo ?? SqliteSleepRepository() {
    loadSessions();
  }

  List<SleepSession> get sessions => _sessions;
  List<SleepSession> get completedSessions =>
      _sessions.where((s) => s.endTimestamp != null).toList();
  SleepSession? get activeSession => _activeSession;
  bool get isTracking => _activeSession != null;
  Duration get elapsedDuration => _elapsedDuration;
  bool get isLoading => _isLoading;

  SleepStats get weeklyStats => _weeklyStats;
  SleepStats get monthlyStats => _monthlyStats;
  List<SleepInsight> get insights => _insights;

  /// The most recent completed sleep session, or null if none exist.
  SleepSession? get latestCompletedSession {
    final completed = completedSessions;
    if (completed.isEmpty) return null;
    return completed.first; // Already sorted descending by start time
  }

  /// Loads all sessions and recovers active tracking state if present.
  Future<void> loadSessions([UserPreferences? preferences]) async {
    _isLoading = true;
    notifyListeners();

    try {
      _sessions = await _sleepRepo.getAllSessions();
      _activeSession = await _sleepRepo.getActiveSession();

      if (_sessions.isEmpty) {
        final now = DateTime.now();
        final seedSessions = [
          SleepSession(
            id: 'seed_1',
            startTimestamp:
                DateTime(now.year, now.month, now.day - 1, 23, 15),
            endTimestamp: DateTime(now.year, now.month, now.day, 7, 10),
            qualityRating: 5,
            notes: 'Felt well-rested and energized',
            source: 'manual',
            createdAt: now,
            updatedAt: now,
          ),
          SleepSession(
            id: 'seed_2',
            startTimestamp:
                DateTime(now.year, now.month, now.day - 2, 23, 30),
            endTimestamp: DateTime(now.year, now.month, now.day - 1, 7, 5),
            qualityRating: 4,
            notes: 'Good deep sleep cycle',
            source: 'manual',
            createdAt: now,
            updatedAt: now,
          ),
          SleepSession(
            id: 'seed_3',
            startTimestamp:
                DateTime(now.year, now.month, now.day - 3, 23, 45),
            endTimestamp: DateTime(now.year, now.month, now.day - 2, 7, 20),
            qualityRating: 4,
            notes: 'Calm evening reading',
            source: 'manual',
            createdAt: now,
            updatedAt: now,
          ),
          SleepSession(
            id: 'seed_4',
            startTimestamp:
                DateTime(now.year, now.month, now.day - 4, 0, 10),
            endTimestamp: DateTime(now.year, now.month, now.day - 3, 7, 50),
            qualityRating: 4,
            notes: 'Restful sleep',
            source: 'manual',
            createdAt: now,
            updatedAt: now,
          ),
          SleepSession(
            id: 'seed_5',
            startTimestamp:
                DateTime(now.year, now.month, now.day - 5, 23, 20),
            endTimestamp: DateTime(now.year, now.month, now.day - 4, 6, 55),
            qualityRating: 3,
            notes: 'Slightly interrupted',
            source: 'manual',
            createdAt: now,
            updatedAt: now,
          ),
        ];
        for (final s in seedSessions) {
          await _sleepRepo.createSession(s);
        }
        _sessions = await _sleepRepo.getAllSessions();
      }

      if (_activeSession != null) {
        _startTicker();
      } else {
        _stopTicker();
      }

      _recalculateAnalytics(preferences ?? const UserPreferences());
    } catch (e) {
      debugPrint('Error loading sleep sessions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Starts the live sleep tracker. Persists the active session immediately.
  Future<void> startSleepTimer() async {
    if (_activeSession != null) return; // Prevent duplicate active sessions

    final now = DateTime.now();
    final newSession = SleepSession(
      id: 'session_${now.millisecondsSinceEpoch}',
      startTimestamp: now,
      endTimestamp: null,
      source: 'timer',
      createdAt: now,
      updatedAt: now,
    );

    await _sleepRepo.createSession(newSession);
    _activeSession = newSession;
    _sessions.insert(0, newSession);
    _startTicker();
    notifyListeners();
  }

  /// Cancels an in-progress sleep session without saving it.
  Future<void> cancelSleepTimer() async {
    if (_activeSession == null) return;

    final id = _activeSession!.id;
    _stopTicker();
    _activeSession = null;
    _sessions.removeWhere((s) => s.id == id);
    await _sleepRepo.deleteSession(id);
    notifyListeners();
  }

  /// Stops tracking, records wake-up timestamp, quality rating, and notes.
  Future<SleepSession?> stopSleepTimer({
    int? qualityRating,
    String? notes,
    UserPreferences? preferences,
  }) async {
    if (_activeSession == null) return null;

    final now = DateTime.now();
    final completedSession = _activeSession!.copyWith(
      endTimestamp: now,
      qualityRating: qualityRating,
      notes: notes,
      updatedAt: now,
    );

    _stopTicker();
    await _sleepRepo.updateSession(completedSession);
    _activeSession = null;

    // Refresh memory list
    final index = _sessions.indexWhere((s) => s.id == completedSession.id);
    if (index != -1) {
      _sessions[index] = completedSession;
    } else {
      _sessions.insert(0, completedSession);
    }

    _recalculateAnalytics(preferences ?? const UserPreferences());
    notifyListeners();
    return completedSession;
  }

  /// Records a manual sleep entry with validation and overlap check.
  Future<String?> addManualSession({
    required DateTime start,
    required DateTime end,
    int? qualityRating,
    String? notes,
    UserPreferences? preferences,
  }) async {
    final validationError = TimeCalculator.validateSessionTimes(start, end);
    if (validationError != null) return validationError;

    final overlaps = await _sleepRepo.hasOverlappingSession(start, end);
    if (overlaps) {
      return 'This entry overlaps with an existing recorded sleep session';
    }

    final now = DateTime.now();
    final newSession = SleepSession(
      id: 'manual_${now.millisecondsSinceEpoch}',
      startTimestamp: start,
      endTimestamp: end,
      qualityRating: qualityRating,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      source: 'manual',
      createdAt: now,
      updatedAt: now,
    );

    await _sleepRepo.createSession(newSession);
    _sessions.insert(0, newSession);
    _sessions.sort((a, b) => b.startTimestamp.compareTo(a.startTimestamp));

    _recalculateAnalytics(preferences ?? const UserPreferences());
    notifyListeners();
    return null; // Success
  }

  /// Updates an existing sleep session with validation.
  Future<String?> updateSession({
    required String id,
    required DateTime start,
    required DateTime end,
    int? qualityRating,
    String? notes,
    UserPreferences? preferences,
  }) async {
    final validationError = TimeCalculator.validateSessionTimes(start, end);
    if (validationError != null) return validationError;

    final overlaps =
        await _sleepRepo.hasOverlappingSession(start, end, excludeId: id);
    if (overlaps) {
      return 'Updated times overlap with another recorded session';
    }

    final existingIndex = _sessions.indexWhere((s) => s.id == id);
    if (existingIndex == -1) return 'Session not found';

    final updated = _sessions[existingIndex].copyWith(
      startTimestamp: start,
      endTimestamp: end,
      qualityRating: qualityRating,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      updatedAt: DateTime.now(),
      clearRating: qualityRating == null,
      clearNotes: notes == null || notes.trim().isEmpty,
    );

    await _sleepRepo.updateSession(updated);
    _sessions[existingIndex] = updated;
    _sessions.sort((a, b) => b.startTimestamp.compareTo(a.startTimestamp));

    _recalculateAnalytics(preferences ?? const UserPreferences());
    notifyListeners();
    return null; // Success
  }

  /// Deletes a recorded sleep session.
  Future<void> deleteSession(String id, [UserPreferences? preferences]) async {
    _sessions.removeWhere((s) => s.id == id);
    if (_activeSession?.id == id) {
      _stopTicker();
      _activeSession = null;
    }
    await _sleepRepo.deleteSession(id);
    _recalculateAnalytics(preferences ?? const UserPreferences());
    notifyListeners();
  }

  /// Clears all recorded sleep sessions.
  Future<void> clearAllSessions() async {
    _stopTicker();
    _activeSession = null;
    _sessions.clear();
    await _sleepRepo.clearAllSessions();
    _recalculateAnalytics(const UserPreferences());
    notifyListeners();
  }

  /// Recalculates stats when user preferences (like sleep goal) change.
  void refreshPreferences(UserPreferences preferences) {
    _recalculateAnalytics(preferences);
    notifyListeners();
  }

  void _recalculateAnalytics(UserPreferences preferences) {
    _weeklyStats = AnalyticsService.computeStats(
      sessions: _sessions,
      sleepGoalMinutes: preferences.sleepGoalMinutes,
      days: 7,
    );
    _monthlyStats = AnalyticsService.computeStats(
      sessions: _sessions,
      sleepGoalMinutes: preferences.sleepGoalMinutes,
      days: 30,
    );
    _insights = InsightEngine.generateInsights(
      sessions: _sessions,
      weeklyStats: _weeklyStats,
      preferences: preferences,
    );
  }

  void _startTicker() {
    _stopTicker();
    _updateElapsed();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
    });
  }

  void _updateElapsed() {
    if (_activeSession == null) return;
    _elapsedDuration =
        DateTime.now().difference(_activeSession!.startTimestamp);
    notifyListeners();
  }

  void _stopTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
    _elapsedDuration = Duration.zero;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
