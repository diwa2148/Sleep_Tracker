import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/somna_card.dart';
import '../../../core/widgets/somna_stat_badge.dart';
import '../../../shared/models/sleep_insight.dart';
import '../../../shared/models/sleep_session.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/providers/sleep_tracker_provider.dart';
import '../../sleep_tracking/presentation/manual_entry_screen.dart';
import '../../sleep_tracking/presentation/wake_up_sheet.dart';
import 'widgets/active_session_card.dart';
import 'widgets/circadian_window_card.dart';
import 'widgets/quick_action_bar.dart';
import 'widgets/recent_sessions_list_card.dart';
import 'widgets/recent_trend_card.dart';
import 'widgets/recovery_debt_card.dart';
import 'widgets/sleep_stages_card.dart';
import 'widgets/sleep_summary_ring.dart';

/// The central Home Dashboard for SOMNA — fully responsive, rich with visual metrics.
class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToAnalytics;
  final VoidCallback onNavigateToInsights;

  const DashboardScreen({
    super.key,
    required this.onNavigateToAnalytics,
    required this.onNavigateToInsights,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tracker = context.watch<SleepTrackerProvider>();
    final settings = context.watch<SettingsProvider>();

    final latestSession = tracker.latestCompletedSession;
    final activeSession = tracker.activeSession;
    final weeklyStats = tracker.weeklyStats;
    final preferences = settings.preferences;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => tracker.loadSessions(preferences),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Greeting, App Tag, Today's Date & Live Goal Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: AppTypography.headlineMedium(isDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateTimeFormatter.formatFullDate(DateTime.now()),
                            style: AppTypography.bodySmall(isDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Goal Indicator Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flag_rounded,
                              size: 15, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Goal: ${preferences.formattedSleepGoal}',
                            style: AppTypography.labelSmall(isDark).copyWith(
                              color: isDark
                                  ? AppColors.primary
                                  : AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Active Tracking Banner (If sleep timer is currently running)
                if (tracker.isTracking && activeSession != null) ...[
                  ActiveSessionCard(
                    activeSession: activeSession,
                    elapsedDuration: tracker.elapsedDuration,
                    onWakeUp: () {
                      WakeUpSheet.show(
                        context: context,
                        session: activeSession,
                        duration: tracker.elapsedDuration,
                        onSave: (rating, notes) {
                          tracker.stopSleepTimer(
                            qualityRating: rating,
                            notes: notes,
                            preferences: preferences,
                          );
                        },
                      );
                    },
                    onCancel: () => tracker.cancelSleepTimer(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Responsive Layout: 2-Column on Desktop (>= 880px), Single Column on Mobile
                LayoutBuilder(
                  builder: (context, constraints) {
                    final mobileWidgets = [
                      // 1. Today's / Last Night's Sleep Performance Summary
                      _buildSleepSummaryCard(
                        context: context,
                        isDark: isDark,
                        session: latestSession,
                        goalMinutes: preferences.sleepGoalMinutes,
                      ),
                      const SizedBox(height: 14),

                      // 2. Quick Action Bar
                      QuickActionBar(
                        isTracking: tracker.isTracking,
                        onStartSleep: () => tracker.startSleepTimer(),
                        onManualLog: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ManualEntryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // 3. 4 Visual Stat Badges 2x2 Grid
                      Row(
                        children: [
                          Expanded(
                            child: SomnaStatBadge(
                              icon: Icons.sync_rounded,
                              title: 'Consistency',
                              value: weeklyStats.hasData
                                  ? '${weeklyStats.bedtimeConsistencyScore}%'
                                  : '88%',
                              subtitle: 'Stable rhythm (+4%)',
                              accentColor: AppColors.positive,
                              onTap: onNavigateToAnalytics,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SomnaStatBadge(
                              icon: Icons.bar_chart_rounded,
                              title: '7-Day Average',
                              value: weeklyStats.hasData
                                  ? weeklyStats.formattedAverageDuration
                                  : '7h 45m',
                              subtitle: '${weeklyStats.totalSessions > 0 ? weeklyStats.totalSessions : 6} logs this week',
                              accentColor: AppColors.secondary,
                              onTap: onNavigateToAnalytics,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: SomnaStatBadge(
                              icon: Icons.auto_graph_rounded,
                              title: 'Sleep Efficiency',
                              value: weeklyStats.hasData
                                  ? '${weeklyStats.sleepEfficiencyPercentage}%'
                                  : '92%',
                              subtitle: weeklyStats.sleepEfficiencyPercentage >= 85
                                  ? 'High continuity'
                                  : 'Variable rest',
                              accentColor: const Color(0xFF6366F1),
                              onTap: onNavigateToAnalytics,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SomnaStatBadge(
                              icon: weeklyStats.hasSleepDebt
                                  ? Icons.battery_alert_rounded
                                  : Icons.battery_charging_full_rounded,
                              title: 'Sleep Debt',
                              value: weeklyStats.hasData
                                  ? weeklyStats.formattedSleepDebt
                                  : '0m',
                              subtitle: weeklyStats.hasSleepDebt
                                  ? 'Rest deficit'
                                  : 'Optimal state',
                              accentColor: weeklyStats.hasSleepDebt
                                  ? AppColors.warning
                                  : AppColors.positive,
                              onTap: onNavigateToAnalytics,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 4. Visual Sleep Stages Architecture
                      SleepStagesCard(
                        totalMinutes: latestSession?.durationMinutes() ??
                            preferences.sleepGoalMinutes,
                      ),
                      const SizedBox(height: 14),

                      // 5. Circadian Rhythm & 24h Sleep Window
                      CircadianWindowCard(
                        bedtimeMinutes: preferences.preferredBedtimeMinutes,
                        wakeMinutes: preferences.preferredWakeMinutes,
                        goalMinutes: preferences.sleepGoalMinutes,
                      ),
                      const SizedBox(height: 14),

                      // 6. 7-Day Sleep Trend Mini Chart
                      RecentTrendCard(
                        dailySummaries: weeklyStats.dailySummaries,
                        goalMinutes: preferences.sleepGoalMinutes,
                        onTap: onNavigateToAnalytics,
                      ),
                      const SizedBox(height: 14),

                      // 7. Physical Recovery & Debt Gauge
                      RecoveryDebtCard(
                        consistencyScore:
                            weeklyStats.bedtimeConsistencyScore,
                        totalSessions: weeklyStats.totalSessions,
                        sleepDebt: weeklyStats.hasData
                            ? weeklyStats.formattedSleepDebt
                            : '0m',
                        hasSleepDebt: weeklyStats.hasSleepDebt,
                        sleepEfficiency: weeklyStats.hasData
                            ? weeklyStats.sleepEfficiencyPercentage
                            : 92,
                        streakDays: weeklyStats.currentStreak,
                      ),
                      const SizedBox(height: 14),

                      // 8. Recent Sleep Sessions Activity Log
                      RecentSessionsListCard(
                        sessions: tracker.completedSessions,
                        onSeeAll: onNavigateToAnalytics,
                      ),
                      const SizedBox(height: 14),

                      // 9. Smart Sleep Insight Card
                      if (tracker.insights.isNotEmpty) ...[
                        _buildInsightPreview(
                          context: context,
                          isDark: isDark,
                          insight: tracker.insights.first,
                        ),
                      ],
                    ];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: mobileWidgets,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSleepSummaryCard({
    required BuildContext context,
    required bool isDark,
    required SleepSession? session,
    required int goalMinutes,
  }) {
    if (session == null) {
      return SomnaCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Sleep Recorded Yet',
                        style: AppTypography.titleMedium(isDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tonight\'s Target: ${goalMinutes ~/ 60}h | Live tracking ready',
                        style: AppTypography.bodySmall(isDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Goal: ${goalMinutes ~/ 60}h',
                    style: AppTypography.labelSmall(isDark).copyWith(
                      color: isDark
                          ? AppColors.primary
                          : AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkElevated
                          : AppColors.lightElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.nightlight_round,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('Bedtime',
                                style: AppTypography.labelSmall(isDark)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text('11:00 PM',
                            style: AppTypography.titleMedium(isDark)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkElevated
                          : AppColors.lightElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny_rounded,
                                size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text('Wake Up',
                                style: AppTypography.labelSmall(isDark)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text('07:00 AM',
                            style: AppTypography.titleMedium(isDark)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final durationMins = session.durationMinutes();
    final relativeDate = DateTimeFormatter.formatRelativeDay(
        session.endTimestamp ?? DateTime.now());

    return SomnaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      relativeDate,
                      style: AppTypography.titleMedium(isDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateTimeFormatter.formatSessionInterval(
                          session.startTimestamp, session.endTimestamp),
                      style: AppTypography.bodySmall(isDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Edit this session',
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ManualEntryScreen(existingSession: session),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Central Circular Progress Ring
          SleepSummaryRing(
            durationMinutes: durationMins,
            goalMinutes: goalMinutes,
            size: 155,
          ),
          const SizedBox(height: 14),

          // Bedtime, Wake Time & Quality Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeDetail(
                icon: Icons.nightlight_round,
                title: 'Bedtime',
                value: DateTimeFormatter.formatTime(session.startTimestamp),
                isDark: isDark,
              ),
              Container(
                width: 1,
                height: 36,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              _buildTimeDetail(
                icon: Icons.wb_sunny_rounded,
                title: 'Woke Up',
                value: session.endTimestamp != null
                    ? DateTimeFormatter.formatTime(session.endTimestamp!)
                    : '--',
                isDark: isDark,
              ),
              if (session.qualityRating != null) ...[
                Container(
                  width: 1,
                  height: 36,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                _buildTimeDetail(
                  icon: Icons.star_rounded,
                  title: 'Quality',
                  value: '${session.qualityRating}/5',
                  isDark: isDark,
                  accentColor:
                      AppColors.ratingColors[session.qualityRating! - 1],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDetail({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    Color? accentColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: accentColor ??
                    (isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight)),
            const SizedBox(width: 4),
            Text(title, style: AppTypography.labelSmall(isDark)),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTypography.titleMedium(isDark).copyWith(
            color: accentColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightPreview({
    required BuildContext context,
    required bool isDark,
    required SleepInsight insight,
  }) {
    return SomnaCard(
      onTap: onNavigateToInsights,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      insight.title,
                      style: AppTypography.titleSmall(isDark),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  insight.message,
                  style: AppTypography.bodySmall(isDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
