import 'dart:math' as math;
import '../../shared/models/sleep_session.dart';

/// Accurate mathematical calculations for sleep durations,
/// circular time-of-day averaging around midnight, and session overlap detection.
class TimeCalculator {
  TimeCalculator._();

  static const int minutesInDay = 1440;

  /// Calculates duration between two timestamps in minutes.
  static int durationMinutes(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  /// Checks if two time intervals [startA, endA] and [startB, endB] overlap.
  ///
  /// Two intervals overlap if and only if:
  /// `startA < endB && endA > startB`
  static bool doSessionsOverlap(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) {
    return startA.isBefore(endB) && endA.isAfter(startB);
  }

  /// Checks if a proposed session overlaps with any session in [existingSessions].
  /// Optionally ignores a session matching [excludeId] (useful when editing).
  static bool hasOverlap(
    DateTime start,
    DateTime end,
    List<SleepSession> existingSessions, {
    String? excludeId,
  }) {
    for (final session in existingSessions) {
      if (excludeId != null && session.id == excludeId) continue;
      final sessionEnd = session.endTimestamp;
      if (sessionEnd == null) continue; // Active session handled separately
      if (doSessionsOverlap(start, end, session.startTimestamp, sessionEnd)) {
        return true;
      }
    }
    return false;
  }

  /// Calculates the circular mean of a list of minute-of-day values [0, 1440).
  ///
  /// This properly handles times clustering around midnight (e.g. 23:30 and 00:30)
  /// so they average to 00:00 (midnight) rather than 12:00 (noon).
  static int? circularMeanMinutes(List<int> minutesList) {
    if (minutesList.isEmpty) return null;

    double sumCos = 0.0;
    double sumSin = 0.0;

    for (final m in minutesList) {
      final normalized = m % minutesInDay;
      final theta = (normalized / minutesInDay) * 2.0 * math.pi;
      sumCos += math.cos(theta);
      sumSin += math.sin(theta);
    }

    final avgCos = sumCos / minutesList.length;
    final avgSin = sumSin / minutesList.length;

    double avgTheta = math.atan2(avgSin, avgCos);
    if (avgTheta < 0) {
      avgTheta += 2.0 * math.pi;
    }

    final avgMinute = ((avgTheta / (2.0 * math.pi)) * minutesInDay).round();
    return avgMinute % minutesInDay;
  }

  /// Calculates the circular mean bedtime for a list of completed sessions.
  static int? calculateAverageBedtime(List<SleepSession> sessions) {
    final bedtimes = sessions
        .where((s) => s.endTimestamp != null)
        .map((s) =>
            s.startTimestamp.toLocal().hour * 60 +
            s.startTimestamp.toLocal().minute)
        .toList();
    return circularMeanMinutes(bedtimes);
  }

  /// Calculates the circular mean wake-up time for a list of completed sessions.
  static int? calculateAverageWakeTime(List<SleepSession> sessions) {
    final wakeTimes = sessions
        .where((s) => s.endTimestamp != null)
        .map((s) =>
            s.endTimestamp!.toLocal().hour * 60 +
            s.endTimestamp!.toLocal().minute)
        .toList();
    return circularMeanMinutes(wakeTimes);
  }

  /// Calculates a bedtime consistency score (0 to 100).
  ///
  /// Based on the circular mean resultant vector length $R \in [0, 1]$:
  /// - $R = 1.0 \implies$ identical bedtimes every day (100% consistency)
  /// - Lower values indicate high variability in sleep schedules.
  static int calculateConsistencyScore(List<SleepSession> sessions) {
    final completed = sessions.where((s) => s.endTimestamp != null).toList();
    if (completed.length < 2) {
      return completed.isEmpty ? 0 : 100;
    }

    double sumCos = 0.0;
    double sumSin = 0.0;

    for (final s in completed) {
      final m = (s.startTimestamp.toLocal().hour * 60 +
              s.startTimestamp.toLocal().minute) %
          minutesInDay;
      final theta = (m / minutesInDay) * 2.0 * math.pi;
      sumCos += math.cos(theta);
      sumSin += math.sin(theta);
    }

    final meanCos = sumCos / completed.length;
    final meanSin = sumSin / completed.length;
    final r = math.sqrt(meanCos * meanCos + meanSin * meanSin);

    return (r * 100).clamp(0, 100).round();
  }

  /// Calculates the sample standard deviation of session durations in minutes.
  static double calculateDurationStandardDeviation(
      List<SleepSession> sessions) {
    final completed = sessions.where((s) => s.endTimestamp != null).toList();
    if (completed.length < 2) return 0.0;

    final durations =
        completed.map((s) => s.durationMinutes().toDouble()).toList();
    final mean = durations.reduce((a, b) => a + b) / durations.length;

    final sumSquaredDiffs =
        durations.map((d) => math.pow(d - mean, 2)).reduce((a, b) => a + b);

    return math.sqrt(sumSquaredDiffs / (durations.length - 1));
  }

  /// Validates a sleep session time range:
  /// - Start must be strictly before end.
  /// - Start cannot be in the future (relative to [now]).
  /// - End cannot be in the future (relative to [now]).
  /// - Duration cannot be zero or exceed 24 hours.
  static String? validateSessionTimes(DateTime start, DateTime end,
      [DateTime? now]) {
    final current = now ?? DateTime.now();

    if (!end.isAfter(start)) {
      return 'Wake-up time must be after bedtime';
    }

    if (start.isAfter(current)) {
      return 'Bedtime cannot be in the future';
    }

    if (end.isAfter(current.add(const Duration(minutes: 1)))) {
      return 'Wake-up time cannot be in the future';
    }

    final duration = end.difference(start);
    if (duration.inMinutes < 1) {
      return 'Sleep duration must be at least 1 minute';
    }

    if (duration.inHours > 24) {
      return 'Single session duration cannot exceed 24 hours';
    }

    return null;
  }
}
