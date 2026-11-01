import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/models/sleep_factor.dart';
import '../../../../shared/models/sleep_session.dart';
import '../../../../shared/services/analytics_service.dart';

/// Retro technical panel displaying behavioral correlations between lifestyle factors
/// (caffeine, workout, late screen, reading) and sleep duration/quality.
class HabitImpactCard extends StatelessWidget {
  final List<SleepSession> sessions;

  const HabitImpactCard({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final correlations = AnalyticsService.computeFactorCorrelations(sessions);

    return SomnaCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 4,
      border: Border.all(
        color: isDark ? const Color(0xFF2B3346) : const Color(0xFFD5CCBF),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: System Tag & Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.bubble_chart_rounded,
                      size: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'HABIT & FACTOR IMPACT MATRIX',
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSmall(isDark).copyWith(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF262626)
                      : const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF404040)
                        : const Color(0xFFCCCCCC),
                  ),
                ),
                child: Text(
                  '${correlations.length} TRACKED',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFA3A3A3)
                        : const Color(0xFF525252),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.fontFamily,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Behavioral correlation with sleep duration & quality',
            style: AppTypography.bodySmall(isDark),
          ),
          const SizedBox(height: 14),

          // Content
          if (correlations.isEmpty)
            _buildEmptyState(isDark)
          else
            ...correlations.map((corr) => _buildCorrelationTile(corr, isDark)),
        ],
      ),
    );
  }

  Widget _buildCorrelationTile(FactorCorrelation corr, bool isDark) {
    final hasDurationDelta = corr.durationDiffMinutes != 0;
    final isDurationPositive = corr.durationDiffMinutes > 0;
    final durationColor = hasDurationDelta
        ? (isDurationPositive
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? const Color(0xFFA3A3A3) : const Color(0xFF525252)))
        : (isDark ? const Color(0xFF888888) : const Color(0xFF666666));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Factor Label & Occurrences
              Row(
                children: [
                  Text(
                    corr.factor.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamily,
                      color: isDark
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF262626)
                          : const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${corr.occurrences}x',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              // Duration Impact Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF262626)
                      : const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF404040)
                        : const Color(0xFFCCCCCC),
                    width: 1,
                  ),
                ),
                child: Text(
                  corr.formattedDurationDiff,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.fontFamily,
                    color: durationColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avg with: ${corr.avgDurationMinutesWith ~/ 60}h ${corr.avgDurationMinutesWith % 60}m  (vs ${corr.avgDurationMinutesWithout ~/ 60}h ${corr.avgDurationMinutesWithout % 60}m base)',
                style: TextStyle(
                  fontSize: 10.5,
                  fontFamily: AppTypography.fontFamily,
                  color: isDark
                      ? const Color(0xFF8B949E)
                      : const Color(0xFF6B7280),
                ),
              ),
              if (corr.avgQualityWith > 0)
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${corr.avgQualityWith.toStringAsFixed(1)} ★',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTypography.fontFamily,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                'No Factor Correlations Yet',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTypography.fontFamily,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tag sessions when waking up or logging past sleep to unlock deep correlation insights between habits and sleep quality.',
            style: AppTypography.bodySmall(isDark),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: SleepFactor.all.take(5).map((f) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  f.label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTypography.fontFamily,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
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

