import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../shared/models/sleep_stats.dart';

/// Full interactive duration bar chart for weekly and monthly analytics.
class DurationBarChart extends StatelessWidget {
  final List<DailySleepSummary> summaries;
  final int goalMinutes;
  final double height;

  const DurationBarChart({
    super.key,
    required this.summaries,
    required this.goalMinutes,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (summaries.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child:
              Text('No data to chart', style: AppTypography.bodyMedium(isDark)),
        ),
      );
    }

    int maxMinutes = (goalMinutes * 1.3).round();
    for (final s in summaries) {
      if (s.durationMinutes > maxMinutes) {
        maxMinutes = s.durationMinutes;
      }
    }
    if (maxMinutes == 0) maxMinutes = 480;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          // Chart Canvas & Goal Reference
          Expanded(
            child: Stack(
              children: [
                // Goal Reference Line
                Positioned(
                  top: (1.0 - (goalMinutes / maxMinutes).clamp(0.0, 1.0)) *
                      (height - 40),
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF262626)
                              : const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF404040)
                                : const Color(0xFFCCCCCC),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'Goal: ${goalMinutes ~/ 60}h',
                          style: AppTypography.labelSmall(isDark).copyWith(
                            fontSize: 10,
                            color: isDark
                                ? const Color(0xFFD4D4D4)
                                : const Color(0xFF262626),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF404040)
                              : const Color(0xFFCCCCCC),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bars
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: summaries.map((item) {
                      final ratio =
                          (item.durationMinutes / maxMinutes).clamp(0.0, 1.0);
                      final hasData = item.durationMinutes > 0;
                      final metGoal = item.metGoal;
                      final barHeight =
                          (ratio * (height - 60)).clamp(6.0, height - 60);

                      return Flexible(
                        child: Tooltip(
                          message:
                              '${DateTimeFormatter.formatShortDate(item.date)}: ${DateTimeFormatter.formatMinutes(item.durationMinutes)}',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: summaries.length > 14 ? 8 : 22,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      summaries.length > 14 ? 3 : 6),
                                  gradient: hasData
                                      ? LinearGradient(
                                          colors: metGoal
                                              ? (isDark
                                                  ? const [
                                                      Color(0xFFFFFFFF),
                                                      Color(0xFFD4D4D4)
                                                    ]
                                                  : const [
                                                      Color(0xFF000000),
                                                      Color(0xFF262626)
                                                    ])
                                              : (isDark
                                                  ? const [
                                                      Color(0xFF737373),
                                                      Color(0xFF404040)
                                                    ]
                                                  : const [
                                                      Color(0xFF888888),
                                                      Color(0xFFBDBDBD)
                                                    ]),
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        )
                                      : null,
                                  color: hasData
                                      ? null
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Date Labels Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: summaries.map((item) {
              final label = summaries.length <= 7
                  ? DateTimeFormatter.formatDayOfWeek(item.date).substring(0, 1)
                  : (item.date.day % 5 == 0 ? '${item.date.day}' : '');

              return Flexible(
                child: Center(
                  child: Text(
                    label,
                    style: AppTypography.labelSmall(isDark).copyWith(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
