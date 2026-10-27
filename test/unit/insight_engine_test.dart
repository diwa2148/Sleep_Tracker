import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/shared/models/sleep_insight.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/models/user_preferences.dart';
import 'package:sleep_tracker/shared/services/analytics_service.dart';
import 'package:sleep_tracker/shared/services/insight_engine.dart';

void main() {
  group('InsightEngine Deterministic Rule Tests', () {
    final fixedNow = DateTime(2026, 10, 26, 12, 0);
    const preferences = UserPreferences(sleepGoalMinutes: 480);

    test('Prompts initial log collection when completed sessions < 3', () {
      final sessions = [
        SleepSession(
          id: '1',
          startTimestamp: DateTime(2026, 10, 25, 23, 0),
          endTimestamp: DateTime(2026, 10, 26, 7, 0),
          createdAt: fixedNow,
          updatedAt: fixedNow,
        ),
      ];

      final stats = AnalyticsService.computeStats(
        sessions: sessions,
        sleepGoalMinutes: 480,
        endDate: fixedNow,
      );

      final insights = InsightEngine.generateInsights(
        sessions: sessions,
        weeklyStats: stats,
        preferences: preferences,
      );

      expect(insights.length, 1);
      expect(insights.first.id, 'initial_setup');
      expect(insights.first.type, InsightType.recommendation);
      expect(insights.first.message, contains('Record 2 more sleep sessions'));
    });

    test('Generates goal streak insight when meeting goal 5+ nights', () {
      final sessions = List.generate(5, (i) {
        final day = fixedNow.subtract(Duration(days: i + 1));
        return SleepSession(
          id: 'session_$i',
          startTimestamp: DateTime(day.year, day.month, day.day, 23, 0),
          endTimestamp:
              DateTime(day.year, day.month, day.day + 1, 7, 30), // 8h 30m >= 8h
          createdAt: fixedNow,
          updatedAt: fixedNow,
        );
      });

      final stats = AnalyticsService.computeStats(
        sessions: sessions,
        sleepGoalMinutes: 480,
        endDate: fixedNow,
      );

      final insights = InsightEngine.generateInsights(
        sessions: sessions,
        weeklyStats: stats,
        preferences: preferences,
      );

      final goalInsight = insights.firstWhere((i) => i.id == 'goal_streak');
      expect(goalInsight.type, InsightType.positive);
      expect(goalInsight.category, InsightCategory.duration);
      expect(goalInsight.calculationExplanation,
          contains('where recorded sleep duration >= 480'));
    });
  });
}
