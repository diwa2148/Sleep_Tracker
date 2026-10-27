import 'package:flutter/material.dart';
import '../../core/utils/date_time_formatter.dart';
import '../models/sleep_insight.dart';
import '../models/sleep_session.dart';
import '../models/sleep_stats.dart';
import '../models/user_preferences.dart';

/// Deterministic, explainable insight engine for SOMNA.
/// Formulates transparent wellness observations grounded strictly in recorded data.
class InsightEngine {
  /// Generates a list of deterministic insights based on recorded data.
  static List<SleepInsight> generateInsights({
    required List<SleepSession> sessions,
    required SleepStats weeklyStats,
    required UserPreferences preferences,
  }) {
    final completed = sessions.where((s) => s.endTimestamp != null).toList();
    final insights = <SleepInsight>[];

    // Case 1: Empty or minimal data (< 3 completed sessions)
    if (completed.length < 3) {
      final remaining = 3 - completed.length;
      insights.add(SleepInsight(
        id: 'initial_setup',
        title: 'Unlock Deep Sleep Trends',
        message: completed.isEmpty
            ? 'Start logging your sleep sessions to discover your personal sleep patterns and consistency.'
            : 'Record $remaining more sleep ${remaining == 1 ? 'session' : 'sessions'} to unlock your 7-day trend analysis.',
        type: InsightType.recommendation,
        category: InsightCategory.schedule,
        calculationExplanation:
            'Requires at least 3 completed sleep sessions to calculate valid weekly averages and consistency trends.',
        icon: Icons.auto_awesome_rounded,
      ));
      return insights;
    }

    // Case 2: Goal Completion Insight
    final metCount = weeklyStats.dailySummaries.where((d) => d.metGoal).length;
    final totalDaysRecorded =
        weeklyStats.dailySummaries.where((d) => d.durationMinutes > 0).length;

    if (totalDaysRecorded > 0) {
      if (metCount >= 5) {
        insights.add(SleepInsight(
          id: 'goal_streak',
          title: 'Strong Goal Consistency',
          message:
              'You met your ${preferences.formattedSleepGoal} sleep goal on $metCount of the last 7 nights.',
          type: InsightType.positive,
          category: InsightCategory.duration,
          calculationExplanation:
              'Calculated from days in the past 7 days where recorded sleep duration >= ${preferences.sleepGoalMinutes} minutes ($metCount/$totalDaysRecorded recorded nights).',
          icon: Icons.emoji_events_rounded,
        ));
      } else if (metCount == 0 && totalDaysRecorded >= 3) {
        insights.add(SleepInsight(
          id: 'goal_deficit',
          title: 'Sleep Below Selected Goal',
          message:
              'Your average recorded sleep this week was ${weeklyStats.formattedAverageDuration}, which is below your target of ${preferences.formattedSleepGoal}.',
          type: InsightType.warning,
          category: InsightCategory.duration,
          calculationExplanation:
              'Weekly average duration (${weeklyStats.formattedAverageDuration}) compared with user configured goal (${preferences.formattedSleepGoal}).',
          icon: Icons.bedtime_outlined,
        ));
      }
    }

    // Case 3: Bedtime Consistency Insight
    if (weeklyStats.bedtimeConsistencyScore >= 80) {
      insights.add(SleepInsight(
        id: 'high_consistency',
        title: 'Stable Bedtime Routine',
        message:
            'Your bedtime consistency score is ${weeklyStats.bedtimeConsistencyScore}%, showing a very steady circadian rhythm.',
        type: InsightType.positive,
        category: InsightCategory.consistency,
        calculationExplanation:
            'Derived from the circular standard deviation of bedtimes around midnight over the last 7 recorded sessions (consistency score: ${weeklyStats.bedtimeConsistencyScore}%).',
        icon: Icons.schedule_rounded,
      ));
    } else if (weeklyStats.bedtimeConsistencyScore < 60 &&
        totalDaysRecorded >= 3) {
      insights.add(SleepInsight(
        id: 'low_consistency',
        title: 'Bedtime Fluctuations',
        message:
            'Your bedtimes varied considerably this week. Consistent sleep and wake times support higher restorative rest.',
        type: InsightType.warning,
        category: InsightCategory.consistency,
        calculationExplanation:
            'Bedtime consistency score fell below 60% (${weeklyStats.bedtimeConsistencyScore}%) due to dispersed bedtime timestamps across days.',
        icon: Icons.sync_problem_rounded,
      ));
    }

    // Case 4: Week-over-Week Duration Change
    if (weeklyStats.durationDifferenceMinutes != null) {
      final diff = weeklyStats.durationDifferenceMinutes!;
      if (diff.abs() >= 20) {
        final isIncrease = diff > 0;
        final formattedDiff = DateTimeFormatter.formatMinutes(diff.abs());
        insights.add(SleepInsight(
          id: 'wow_duration',
          title: isIncrease
              ? 'Sleep Duration Increased'
              : 'Sleep Duration Decreased',
          message:
              'You averaged $formattedDiff ${isIncrease ? 'more' : 'less'} sleep per night compared to the previous 7-day period.',
          type: isIncrease ? InsightType.positive : InsightType.neutral,
          category: InsightCategory.duration,
          calculationExplanation:
              'Current 7-day average (${weeklyStats.averageDurationMinutes}m) minus previous 7-day average (${weeklyStats.previousPeriodAverageDurationMinutes}m) = ${diff > 0 ? '+' : ''}${diff}m.',
          icon: isIncrease
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
        ));
      }
    }

    // Case 5: Subjective Rating Correlation
    final ratedSessions =
        completed.where((s) => s.qualityRating != null).toList();
    if (ratedSessions.length >= 4) {
      final highRated =
          ratedSessions.where((s) => s.qualityRating! >= 4).toList();
      if (highRated.isNotEmpty) {
        final avgHighDuration =
            highRated.fold<int>(0, (sum, s) => sum + s.durationMinutes()) ~/
                highRated.length;
        insights.add(SleepInsight(
          id: 'quality_duration_correlation',
          title: 'Quality & Duration Harmony',
          message:
              'Nights where you rated your sleep 4 or 5 stars averaged ${DateTimeFormatter.formatMinutes(avgHighDuration)} of rest.',
          type: InsightType.positive,
          category: InsightCategory.quality,
          calculationExplanation:
              'Average duration computed exclusively from sessions where subjective rating was 4 or 5 stars (${highRated.length} sessions analyzed).',
          icon: Icons.star_rounded,
        ));
      }
    }

    return insights;
  }
}
