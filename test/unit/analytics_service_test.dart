import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/services/analytics_service.dart';

void main() {
  group('AnalyticsService Tests', () {
    final fixedNow = DateTime(2026, 10, 26, 12, 0);

    test('Returns empty stats with zero values for empty session list', () {
      final stats = AnalyticsService.computeStats(
        sessions: [],
        sleepGoalMinutes: 480,
        days: 7,
        endDate: fixedNow,
      );

      expect(stats.isEmpty, isTrue);
      expect(stats.totalSessions, 0);
      expect(stats.averageDurationMinutes, 0);
      expect(stats.averageBedtimeMinutes, isNull);
      expect(stats.averageWakeMinutes, isNull);
      expect(stats.goalCompletionPercentage, 0.0);
      expect(stats.dailySummaries.length, 7);
    });

    test('Computes 7-day average duration and goal completion percentage', () {
      final s1 = SleepSession(
        id: '1',
        startTimestamp: DateTime(2026, 10, 25, 23, 0),
        endTimestamp:
            DateTime(2026, 10, 26, 7, 0), // 8h = 480m (meets 480m goal)
        createdAt: fixedNow,
        updatedAt: fixedNow,
      );
      final s2 = SleepSession(
        id: '2',
        startTimestamp: DateTime(2026, 10, 24, 23, 0),
        endTimestamp: DateTime(2026, 10, 25, 6, 0), // 7h = 420m (misses goal)
        createdAt: fixedNow,
        updatedAt: fixedNow,
      );
      final s3 = SleepSession(
        id: '3',
        startTimestamp: DateTime(2026, 10, 23, 23, 0),
        endTimestamp: DateTime(2026, 10, 24, 8, 0), // 9h = 540m (meets goal)
        createdAt: fixedNow,
        updatedAt: fixedNow,
      );

      final stats = AnalyticsService.computeStats(
        sessions: [s1, s2, s3],
        sleepGoalMinutes: 480,
        days: 7,
        endDate: fixedNow,
      );

      expect(stats.totalSessions, 3);
      // Average: (480 + 420 + 540) / 3 = 480
      expect(stats.averageDurationMinutes, 480);
      // Met goal: 2 out of 3 = 66.66%
      expect(stats.goalCompletionPercentage, closeTo(66.66, 0.1));
      // Extremes
      expect(stats.shortestSession?.id, '2');
      expect(stats.longestSession?.id, '3');
    });

    test('Calculates duration difference against previous period', () {
      // Current week session: 8 hours
      final currentWeekSession = SleepSession(
        id: 'c1',
        startTimestamp: DateTime(2026, 10, 25, 23, 0),
        endTimestamp: DateTime(2026, 10, 26, 7, 0), // 480 mins
        createdAt: fixedNow,
        updatedAt: fixedNow,
      );
      // Previous week session: 7 hours (420 mins)
      final prevWeekSession = SleepSession(
        id: 'p1',
        startTimestamp: DateTime(2026, 10, 18, 23, 0),
        endTimestamp: DateTime(2026, 10, 19, 6, 0), // 420 mins
        createdAt: fixedNow,
        updatedAt: fixedNow,
      );

      final stats = AnalyticsService.computeStats(
        sessions: [currentWeekSession, prevWeekSession],
        sleepGoalMinutes: 480,
        days: 7,
        endDate: fixedNow,
      );

      expect(stats.averageDurationMinutes, 480);
      expect(stats.previousPeriodAverageDurationMinutes, 420);
      expect(stats.durationDifferenceMinutes, 60); // +60 mins increase
    });
  });
}
