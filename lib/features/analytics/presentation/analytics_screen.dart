import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/somna_card.dart';
import '../../../core/widgets/somna_stat_badge.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/providers/sleep_tracker_provider.dart';
import 'widgets/consistency_meter.dart';
import 'widgets/duration_bar_chart.dart';

/// The Sleep Analytics screen providing in-depth sleep metrics,
/// circular average calculations, goal completion percentages, and duration trends.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedTabIndex = 0; // 0 = 7 Days, 1 = 30 Days

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tracker = context.watch<SleepTrackerProvider>();
    final settings = context.watch<SettingsProvider>();

    final isWeekly = _selectedTabIndex == 0;
    final stats = isWeekly ? tracker.weeklyStats : tracker.monthlyStats;
    final preferences = settings.preferences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Analytics'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Tab Selector
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkElevated : AppColors.lightElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSegmentButton('Last 7 Days', 0, isDark),
                    ),
                    Expanded(
                      child: _buildSegmentButton('Last 30 Days', 1, isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (stats.isEmpty)
                _buildEmptyAnalytics(isDark)
              else ...[
                // Main Duration Chart Card
                SomnaCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isWeekly
                                    ? '7-Day Sleep Duration'
                                    : '30-Day Sleep Duration',
                                style: AppTypography.titleMedium(isDark),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Average: ${stats.formattedAverageDuration}',
                                style: AppTypography.bodySmall(isDark).copyWith(
                                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (stats.durationDifferenceMinutes != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (stats.durationDifferenceMinutes! >= 0
                                        ? AppColors.positive
                                        : AppColors.warning)
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    stats.durationDifferenceMinutes! >= 0
                                        ? Icons.arrow_upward_rounded
                                        : Icons.arrow_downward_rounded,
                                    size: 12,
                                    color: stats.durationDifferenceMinutes! >= 0
                                        ? AppColors.positive
                                        : AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${DateTimeFormatter.formatMinutes(stats.durationDifferenceMinutes!.abs())} vs prev',
                                    style: AppTypography.labelSmall(isDark)
                                        .copyWith(
                                      color:
                                          stats.durationDifferenceMinutes! >= 0
                                              ? AppColors.positive
                                              : AppColors.warning,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DurationBarChart(
                        summaries: stats.dailySummaries,
                        goalMinutes: preferences.sleepGoalMinutes,
                        height: 150,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Circular Average Bedtime & Wake-up Time
                Row(
                  children: [
                    Expanded(
                      child: SomnaStatBadge(
                        icon: Icons.nightlight_round,
                        title: 'Avg Bedtime',
                        value: stats.formattedAverageBedtime,
                        subtitle: 'Circular avg around midnight',
                        accentColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SomnaStatBadge(
                        icon: Icons.wb_sunny_rounded,
                        title: 'Avg Wake Up',
                        value: stats.formattedAverageWakeTime,
                        subtitle:
                            'Target: ${preferences.preferredWakeTime.format(context)}',
                        accentColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Goal Completion & Duration Variability
                Row(
                  children: [
                    Expanded(
                      child: SomnaStatBadge(
                        icon: Icons.flag_rounded,
                        title: 'Goal Hit Rate',
                        value: '${stats.goalCompletionPercentage.round()}%',
                        subtitle:
                            '${stats.dailySummaries.where((d) => d.metGoal).length} of ${stats.totalSessions} sessions',
                        accentColor: AppColors.positive,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SomnaStatBadge(
                        icon: Icons.tune_rounded,
                        title: 'Variability',
                        value: '±${stats.durationVariabilityMinutes.round()}m',
                        subtitle: 'Duration deviation',
                        accentColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Consistency Meter
                ConsistencyMeter(
                  consistencyScore: stats.bedtimeConsistencyScore,
                  variabilityMinutes: stats.durationVariabilityMinutes,
                ),
                const SizedBox(height: 12),

                // Shortest & Longest Sessions
                if (stats.shortestSession != null &&
                    stats.longestSession != null) ...[
                  SomnaCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recorded Extremes',
                            style: AppTypography.titleMedium(isDark)),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildExtremeRow(
                              'Shortest Sleep',
                              stats.shortestSession!.formattedDuration(),
                              DateTimeFormatter.formatShortDate(
                                  stats.shortestSession!.startTimestamp),
                              Icons.arrow_downward_rounded,
                              AppColors.warning,
                              isDark,
                            ),
                            Container(
                              width: 1,
                              height: 38,
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                            _buildExtremeRow(
                              'Longest Sleep',
                              stats.longestSession!.formattedDuration(),
                              DateTimeFormatter.formatShortDate(
                                  stats.longestSession!.startTimestamp),
                              Icons.arrow_upward_rounded,
                              AppColors.positive,
                              isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Scientific Disclaimer
                Center(
                  child: Text(
                    'Calculations are based on self-reported start and stop times.\nDoes not diagnose medical conditions.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall(isDark).copyWith(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton(String label, int index, bool isDark) {
    final isSelected = _selectedTabIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium(isDark).copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight)
                : (isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight),
          ),
        ),
      ),
    );
  }

  Widget _buildExtremeRow(
    String label,
    String duration,
    String date,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.labelSmall(isDark)),
          ],
        ),
        const SizedBox(height: 4),
        Text(duration, style: AppTypography.titleMedium(isDark)),
        Text(date, style: AppTypography.bodySmall(isDark)),
      ],
    );
  }

  Widget _buildEmptyAnalytics(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insights_rounded,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'No Sleep Sessions In This Period',
              style: AppTypography.titleLarge(isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Log your sleep sessions to generate detailed duration charts, circular consistency averages, and goal trends.',
              style: AppTypography.bodyMedium(isDark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
