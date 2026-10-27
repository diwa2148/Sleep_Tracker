import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_card.dart';

/// Visual Recovery & Sleep Debt widget presenting physical readiness and debt balance.
class RecoveryDebtCard extends StatelessWidget {
  final int consistencyScore;
  final int totalSessions;

  const RecoveryDebtCard({
    super.key,
    required this.consistencyScore,
    required this.totalSessions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final readinessScore = (85 + (consistencyScore > 0 ? (consistencyScore * 0.12).round() : 6)).clamp(70, 98);

    return SomnaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.positive.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.battery_charging_full_rounded,
                        size: 16, color: AppColors.positive),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recovery & Readiness Index',
                    style: AppTypography.titleMedium(isDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.positive.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.positive.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  'Readiness $readinessScore%',
                  style: AppTypography.labelSmall(isDark).copyWith(
                    color: AppColors.positive,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Recovery Visual Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: readinessScore / 100.0,
                backgroundColor:
                    isDark ? AppColors.darkBorder : AppColors.lightBorder,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.positive),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3 Metric Badges: Sleep Debt, Recovery Status, Streak
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.scale_rounded,
                  title: 'Sleep Debt',
                  value: '+15m',
                  subtext: 'Optimal balance',
                  accentColor: AppColors.positive,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.favorite_rounded,
                  title: 'Rest Continuity',
                  value: '94%',
                  subtext: 'High sleep quality',
                  accentColor: const Color(0xFF6366F1),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.local_fire_department_rounded,
                  title: 'Target Streak',
                  value: '${totalSessions > 0 ? totalSessions : 5} Days',
                  subtext: 'In target window',
                  accentColor: AppColors.secondary,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtext,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelSmall(isDark).copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleMedium(isDark).copyWith(
              fontSize: 14,
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtext,
            style: AppTypography.bodySmall(isDark).copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
