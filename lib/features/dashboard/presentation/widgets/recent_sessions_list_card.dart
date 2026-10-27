import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/models/sleep_session.dart';

/// Visual card showing recent logged sleep sessions with duration chips and star ratings.
class RecentSessionsListCard extends StatelessWidget {
  final List<SleepSession> sessions;
  final VoidCallback onSeeAll;

  const RecentSessionsListCard({
    super.key,
    required this.sessions,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displaySessions = sessions.take(4).toList();

    return SomnaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.history_toggle_off_rounded,
                          size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recent Sessions',
                        style: AppTypography.titleMedium(isDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onSeeAll,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'View History',
                        style: AppTypography.labelSmall(isDark).copyWith(
                          color: isDark
                              ? AppColors.primary
                              : AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded,
                          size: 14,
                          color: isDark
                              ? AppColors.primary
                              : AppColors.primaryDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (displaySessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No sessions recorded yet',
                  style: AppTypography.bodySmall(isDark),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displaySessions.length,
              separatorBuilder: (_, __) => Divider(
                height: 12,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              itemBuilder: (context, i) {
                final s = displaySessions[i];
                final durationStr =
                    DateTimeFormatter.formatMinutes(s.durationMinutes());
                final intervalStr = DateTimeFormatter.formatSessionInterval(
                    s.startTimestamp, s.endTimestamp);
                final relativeDate = DateTimeFormatter.formatRelativeDay(
                    s.endTimestamp ?? s.startTimestamp);
                final rating = s.qualityRating ?? 4;

                return Row(
                  children: [
                    // Date indicator box
                    Container(
                      width: 44,
                      padding: const EdgeInsets.symmetric(vertical: 4),
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
                        children: [
                          Text(
                            DateTimeFormatter.formatDayOfWeek(
                                    s.startTimestamp)
                                .substring(0, 3)
                                .toUpperCase(),
                            style: AppTypography.labelSmall(isDark).copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.primary
                                  : AppColors.primaryDark,
                            ),
                          ),
                          Text(
                            '${s.startTimestamp.day}',
                            style: AppTypography.titleMedium(isDark).copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Interval & Relative Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(relativeDate,
                              style: AppTypography.titleMedium(isDark)
                                  .copyWith(fontSize: 13)),
                          const SizedBox(height: 1),
                          Text(intervalStr,
                              style: AppTypography.bodySmall(isDark)
                                  .copyWith(fontSize: 11)),
                        ],
                      ),
                    ),

                    // Duration Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        durationStr,
                        style: AppTypography.labelSmall(isDark).copyWith(
                          color: isDark
                              ? AppColors.primary
                              : AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Star Rating
                    Row(
                      children: List.generate(
                        5,
                        (starIdx) => Icon(
                          starIdx < rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 13,
                          color: starIdx < rating
                              ? const Color(0xFFF59E0B)
                              : (isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
