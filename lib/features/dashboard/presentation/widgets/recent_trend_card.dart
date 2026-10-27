import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/models/sleep_stats.dart';

/// 7-day mini duration chart showing recent sleep habit trends on the dashboard.
class RecentTrendCard extends StatelessWidget {
  final List<DailySleepSummary> dailySummaries;
  final int goalMinutes;
  final VoidCallback? onTap;

  const RecentTrendCard({
    super.key,
    required this.dailySummaries,
    required this.goalMinutes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine max scale (at least goal + 2h)
    int maxMinutes = (goalMinutes * 1.25).round();
    for (final d in dailySummaries) {
      if (d.durationMinutes > maxMinutes) {
        maxMinutes = d.durationMinutes;
      }
    }
    if (maxMinutes == 0) maxMinutes = 480;

    return SomnaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-Day Sleep Trend',
                style: AppTypography.titleMedium(isDark),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.positive,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Goal met',
                    style: AppTypography.labelSmall(isDark),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bar Chart Row
          SizedBox(
            height: 96,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dailySummaries.map((day) {
                final ratio =
                    (day.durationMinutes / maxMinutes).clamp(0.0, 1.0);
                final dayLabel =
                    DateTimeFormatter.formatDayOfWeek(day.date).substring(0, 1);
                final hasSleep = day.durationMinutes > 0;
                final metGoal = day.metGoal;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Value tooltip text when data is present
                    if (hasSleep)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${day.durationMinutes ~/ 60}h',
                          style: AppTypography.labelSmall(isDark).copyWith(
                            fontSize: 10,
                            color: metGoal
                                ? AppColors.positive
                                : AppColors.primaryLight,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 18),

                    // Vertical Bar
                    Container(
                      width: 24,
                      height: (ratio * 70).clamp(6.0, 70.0),
                      decoration: BoxDecoration(
                        gradient: hasSleep
                            ? LinearGradient(
                                colors: metGoal
                                    ? [
                                        AppColors.positive,
                                        AppColors.positiveDark
                                      ]
                                    : [
                                        AppColors.primary,
                                        AppColors.primaryDark
                                      ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : null,
                        color: hasSleep
                            ? null
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Day of week letter
                    Text(
                      dayLabel,
                      style: AppTypography.labelSmall(isDark).copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
