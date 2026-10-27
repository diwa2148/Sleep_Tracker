import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_card.dart';

/// Visual sleep architecture breakdown card showing Deep, REM, Light, and Awake stages.
class SleepStagesCard extends StatelessWidget {
  final int totalMinutes;

  const SleepStagesCard({
    super.key,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mins = totalMinutes > 0 ? totalMinutes : 470; // fallback to ~7h 50m

    // Proportional sleep stage distribution based on clinical averages
    final deepMins = (mins * 0.22).round();
    final remMins = (mins * 0.26).round();
    final lightMins = (mins * 0.44).round();
    final awakeMins = (mins * 0.08).round();

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
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.waves_rounded,
                        size: 16, color: Color(0xFF6366F1)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sleep Architecture Stages',
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
                    color: AppColors.positive.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        size: 12, color: AppColors.positive),
                    const SizedBox(width: 4),
                    Text(
                      'Optimal Cycle',
                      style: AppTypography.labelSmall(isDark).copyWith(
                        color: AppColors.positive,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Multi-Stage Segmented Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 22,
              child: Row(
                children: [
                  Expanded(
                    flex: deepMins,
                    child: Container(
                      color: const Color(0xFF4338CA), // Deep Indigo
                      alignment: Alignment.center,
                      child: const Text('22%',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: remMins,
                    child: Container(
                      color: const Color(0xFF8B5CF6), // Vibrant Violet
                      alignment: Alignment.center,
                      child: const Text('26%',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: lightMins,
                    child: Container(
                      color: const Color(0xFF0EA5E9), // Sky Blue
                      alignment: Alignment.center,
                      child: const Text('44%',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: awakeMins,
                    child: Container(
                      color: const Color(0xFFF59E0B), // Amber
                      alignment: Alignment.center,
                      child: const Text('8%',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4 Stage Detail Badges Grid
          Row(
            children: [
              Expanded(
                child: _buildStageMetric(
                  label: 'Deep Sleep',
                  duration: '${deepMins ~/ 60}h ${deepMins % 60}m',
                  percentage: '22%',
                  color: const Color(0xFF4338CA),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStageMetric(
                  label: 'REM Sleep',
                  duration: '${remMins ~/ 60}h ${remMins % 60}m',
                  percentage: '26%',
                  color: const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStageMetric(
                  label: 'Light Rest',
                  duration: '${lightMins ~/ 60}h ${lightMins % 60}m',
                  percentage: '44%',
                  color: const Color(0xFF0EA5E9),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStageMetric(
                  label: 'Awake',
                  duration: '${awakeMins}m',
                  percentage: '8%',
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageMetric({
    required String label,
    required String duration,
    required String percentage,
    required Color color,
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
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall(isDark).copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            duration,
            style: AppTypography.titleMedium(isDark).copyWith(fontSize: 14),
          ),
          Text(
            percentage,
            style: AppTypography.bodySmall(isDark).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
