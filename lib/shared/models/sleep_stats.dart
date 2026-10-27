import 'sleep_session.dart';

/// Single day summary for chart visualizations.
class DailySleepSummary {
  final DateTime date; // Normalized to start of day
  final int durationMinutes;
  final int? qualityRating;
  final bool metGoal;

  const DailySleepSummary({
    required this.date,
    required this.durationMinutes,
    this.qualityRating,
    this.metGoal = false,
  });

  double get durationHours => durationMinutes / 60.0;
}

/// Comprehensive analytics summary for a time window (e.g. week, month).
class SleepStats {
  final int totalSessions;
  final int averageDurationMinutes;
  final int? averageBedtimeMinutes; // Circular average (minutes from midnight)
  final int? averageWakeMinutes; // Circular average (minutes from midnight)
  final double goalCompletionPercentage; // 0.0 to 100.0
  final double durationVariabilityMinutes; // Std deviation of duration
  final int bedtimeConsistencyScore; // 0 to 100 consistency index
  final SleepSession? shortestSession;
  final SleepSession? longestSession;
  final List<DailySleepSummary> dailySummaries;

  // Comparison metrics against previous period (optional)
  final int? previousPeriodAverageDurationMinutes;
  final int? durationDifferenceMinutes; // positive = increased sleep

  const SleepStats({
    required this.totalSessions,
    required this.averageDurationMinutes,
    this.averageBedtimeMinutes,
    this.averageWakeMinutes,
    required this.goalCompletionPercentage,
    required this.durationVariabilityMinutes,
    required this.bedtimeConsistencyScore,
    this.shortestSession,
    this.longestSession,
    this.dailySummaries = const [],
    this.previousPeriodAverageDurationMinutes,
    this.durationDifferenceMinutes,
  });

  /// Factory for empty dataset when user has no recorded sessions.
  factory SleepStats.empty() {
    return const SleepStats(
      totalSessions: 0,
      averageDurationMinutes: 0,
      averageBedtimeMinutes: null,
      averageWakeMinutes: null,
      goalCompletionPercentage: 0.0,
      durationVariabilityMinutes: 0.0,
      bedtimeConsistencyScore: 0,
      shortestSession: null,
      longestSession: null,
      dailySummaries: [],
    );
  }

  bool get isEmpty => totalSessions == 0;
  bool get hasData => totalSessions > 0;

  /// Formatted average duration, e.g. "7h 45m" or "--".
  String get formattedAverageDuration {
    if (isEmpty) return '--';
    final h = averageDurationMinutes ~/ 60;
    final m = averageDurationMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  /// Formatted average bedtime (circular time), e.g. "11:15 PM" or "--".
  String get formattedAverageBedtime {
    if (averageBedtimeMinutes == null) return '--';
    return _formatMinutesOfDay(averageBedtimeMinutes!);
  }

  /// Formatted average wake time (circular time), e.g. "07:20 AM" or "--".
  String get formattedAverageWakeTime {
    if (averageWakeMinutes == null) return '--';
    return _formatMinutesOfDay(averageWakeMinutes!);
  }

  static String _formatMinutesOfDay(int minutes) {
    int h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    final mStr = m.toString().padLeft(2, '0');
    return '$h:$mStr $period';
  }
}
