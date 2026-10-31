import '../../core/utils/time_calculator.dart';
import '../models/sleep_factor.dart';
import '../models/sleep_session.dart';
import '../models/sleep_stats.dart';

/// Analytics engine for computing sleep statistics, circular averages,
/// goal completion rates, and daily trend summaries.
class AnalyticsService {
  /// Computes stats for a rolling window of [days] days ending at [endDate].
  static SleepStats computeStats({
    required List<SleepSession> sessions,
    required int sleepGoalMinutes,
    int days = 7,
    DateTime? endDate,
  }) {
    final now = endDate ?? DateTime.now();
    final windowEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final windowStart = windowEnd.subtract(Duration(days: days - 1));
    final normalizedStart =
        DateTime(windowStart.year, windowStart.month, windowStart.day);

    // Filter completed sessions that fall within this window (based on end timestamp)
    final periodSessions = sessions.where((s) {
      if (s.endTimestamp == null) return false;
      final end = s.endTimestamp!.toLocal();
      return end
              .isAfter(normalizedStart.subtract(const Duration(seconds: 1))) &&
          end.isBefore(windowEnd.add(const Duration(seconds: 1)));
    }).toList();

    if (periodSessions.isEmpty) {
      return SleepStats(
        totalSessions: 0,
        averageDurationMinutes: 0,
        averageBedtimeMinutes: null,
        averageWakeMinutes: null,
        goalCompletionPercentage: 0.0,
        durationVariabilityMinutes: 0.0,
        bedtimeConsistencyScore: 0,
        dailySummaries: _generateDailySummaries(
          periodSessions,
          normalizedStart,
          days,
          sleepGoalMinutes,
        ),
      );
    }

    // 1. Durations
    final totalDuration = periodSessions.fold<int>(
      0,
      (sum, s) => sum + s.durationMinutes(),
    );
    final avgDuration = (totalDuration / periodSessions.length).round();

    // 2. Circular Averages
    final avgBedtime = TimeCalculator.calculateAverageBedtime(periodSessions);
    final avgWake = TimeCalculator.calculateAverageWakeTime(periodSessions);

    // 3. Goal Completion
    final metGoalCount = periodSessions
        .where((s) => s.durationMinutes() >= sleepGoalMinutes)
        .length;
    final goalPercentage = (metGoalCount / periodSessions.length) * 100.0;

    // 4. Variability & Consistency
    final variability =
        TimeCalculator.calculateDurationStandardDeviation(periodSessions);
    final consistency =
        TimeCalculator.calculateConsistencyScore(periodSessions);

    // 5. Extremes
    SleepSession? shortest;
    SleepSession? longest;
    for (final s in periodSessions) {
      if (shortest == null ||
          s.durationMinutes() < shortest.durationMinutes()) {
        shortest = s;
      }
      if (longest == null || s.durationMinutes() > longest.durationMinutes()) {
        longest = s;
      }
    }

    // 6. Sleep Debt & Efficiency
    final targetTotalMinutes = periodSessions.length * sleepGoalMinutes;
    final sleepDebt = targetTotalMinutes - totalDuration;

    // Efficiency: Quality score (if rated) combined with duration consistency
    final ratedSessions =
        periodSessions.where((s) => s.qualityRating != null).toList();
    double baseEfficiency = 88.0;
    if (ratedSessions.isNotEmpty) {
      final avgRating = ratedSessions.fold<int>(
              0, (sum, s) => sum + s.qualityRating!) /
          ratedSessions.length;
      // 1 star -> 64%, 2 -> 72%, 3 -> 80%, 4 -> 89%, 5 -> 96%
      baseEfficiency = 55.0 + (avgRating * 8.2);
    }
    // Continuity factor from variability
    final continuityBonus = (consistency * 0.05);
    final calculatedEfficiency =
        (baseEfficiency + continuityBonus).clamp(65.0, 98.0).round();

    // 7. Day-by-day mapping for charts & Streak calculation
    final dailySummaries = _generateDailySummaries(
      periodSessions,
      normalizedStart,
      days,
      sleepGoalMinutes,
    );

    int streak = 0;
    for (final summary in dailySummaries.reversed) {
      if (summary.durationMinutes == 0) continue; // skip unrecorded days
      if (summary.metGoal) {
        streak++;
      } else {
        break;
      }
    }

    // 8. Previous Period Comparison (e.g. Previous 7 days)
    final prevPeriodEnd = normalizedStart.subtract(const Duration(seconds: 1));
    final prevPeriodStart = prevPeriodEnd.subtract(Duration(days: days));
    final prevSessions = sessions.where((s) {
      if (s.endTimestamp == null) return false;
      final end = s.endTimestamp!.toLocal();
      return end.isAfter(prevPeriodStart) && end.isBefore(prevPeriodEnd);
    }).toList();

    int? prevAvgDuration;
    int? durationDiff;
    if (prevSessions.isNotEmpty) {
      final prevTotal =
          prevSessions.fold<int>(0, (sum, s) => sum + s.durationMinutes());
      prevAvgDuration = (prevTotal / prevSessions.length).round();
      durationDiff = avgDuration - prevAvgDuration;
    }

    return SleepStats(
      totalSessions: periodSessions.length,
      averageDurationMinutes: avgDuration,
      averageBedtimeMinutes: avgBedtime,
      averageWakeMinutes: avgWake,
      goalCompletionPercentage: goalPercentage,
      durationVariabilityMinutes: variability,
      bedtimeConsistencyScore: consistency,
      shortestSession: shortest,
      longestSession: longest,
      dailySummaries: dailySummaries,
      sleepDebtMinutes: sleepDebt,
      sleepEfficiencyPercentage: calculatedEfficiency,
      currentStreak: streak,
      previousPeriodAverageDurationMinutes: prevAvgDuration,
      durationDifferenceMinutes: durationDiff,
    );
  }

  /// Builds a continuous list of [days] days starting from [startDate].
  /// Aggregates sessions ending on each calendar day.
  static List<DailySleepSummary> _generateDailySummaries(
    List<SleepSession> sessions,
    DateTime startDate,
    int days,
    int goalMinutes,
  ) {
    final summaries = <DailySleepSummary>[];

    for (int i = 0; i < days; i++) {
      final day = DateTime(startDate.year, startDate.month, startDate.day + i);
      final nextDay = day.add(const Duration(days: 1));

      // Sessions that concluded on this day
      final daySessions = sessions.where((s) {
        if (s.endTimestamp == null) return false;
        final end = s.endTimestamp!.toLocal();
        return (end.isAfter(day) || end.isAtSameMomentAs(day)) &&
            end.isBefore(nextDay);
      }).toList();

      final totalDayDuration = daySessions.fold<int>(
        0,
        (sum, s) => sum + s.durationMinutes(),
      );

      int? avgRating;
      final rated = daySessions.where((s) => s.qualityRating != null).toList();
      if (rated.isNotEmpty) {
        final totalRating =
            rated.fold<int>(0, (sum, s) => sum + s.qualityRating!);
        avgRating = (totalRating / rated.length).round();
      }

      summaries.add(DailySleepSummary(
        date: day,
        durationMinutes: totalDayDuration,
        qualityRating: avgRating,
        metGoal: totalDayDuration >= goalMinutes,
      ));
    }

    return summaries;
  }

  /// Computes statistical habit correlations for lifestyle factors (caffeine, workout, reading, etc.).
  static List<FactorCorrelation> computeFactorCorrelations(
      List<SleepSession> sessions) {
    final completed = sessions.where((s) => s.endTimestamp != null).toList();
    if (completed.length < 2) return const [];

    final correlations = <FactorCorrelation>[];

    for (final factor in SleepFactor.all) {
      final withFactor = completed.where((s) {
        if (s.notes == null) return false;
        final lower = s.notes!.toLowerCase();
        return s.notes!.contains(factor.label) ||
            lower.contains(factor.name.toLowerCase());
      }).toList();

      if (withFactor.isEmpty) continue;

      final withoutFactor = completed.where((s) {
        if (s.notes == null) return true;
        final lower = s.notes!.toLowerCase();
        return !s.notes!.contains(factor.label) &&
            !lower.contains(factor.name.toLowerCase());
      }).toList();

      final totalWith = withFactor.fold<int>(
        0,
        (sum, s) => sum + s.durationMinutes(),
      );
      final avgWith = (totalWith / withFactor.length).round();

      final totalWithout = withoutFactor.isEmpty
          ? completed.fold<int>(0, (sum, s) => sum + s.durationMinutes())
          : withoutFactor.fold<int>(0, (sum, s) => sum + s.durationMinutes());
      final countWithout =
          withoutFactor.isEmpty ? completed.length : withoutFactor.length;
      final avgWithout = (totalWithout / countWithout).round();

      // Quality ratings
      final ratedWith =
          withFactor.where((s) => s.qualityRating != null).toList();
      final avgQualityWith = ratedWith.isEmpty
          ? 0.0
          : ratedWith.fold<int>(0, (sum, s) => sum + s.qualityRating!) /
              ratedWith.length;

      final ratedWithout =
          withoutFactor.where((s) => s.qualityRating != null).toList();
      final avgQualityWithout = ratedWithout.isEmpty
          ? avgQualityWith
          : ratedWithout.fold<int>(0, (sum, s) => sum + s.qualityRating!) /
              ratedWithout.length;

      correlations.add(FactorCorrelation(
        factor: factor,
        occurrences: withFactor.length,
        avgDurationMinutesWith: avgWith,
        avgDurationMinutesWithout: avgWithout,
        avgQualityWith: avgQualityWith,
        avgQualityWithout: avgQualityWithout,
      ));
    }

    correlations.sort((a, b) {
      final occComp = b.occurrences.compareTo(a.occurrences);
      if (occComp != 0) return occComp;
      return b.durationDiffMinutes.abs().compareTo(a.durationDiffMinutes.abs());
    });

    return correlations;
  }
}
