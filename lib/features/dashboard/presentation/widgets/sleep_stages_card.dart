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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF262626)
                            : const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.waves_rounded,
                        size: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sleep Stages',
                        style: AppTypography.titleMedium(isDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 12,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Optimal Cycle',
                      style: AppTypography.labelSmall(isDark).copyWith(
                        color: isDark ? Colors.white : Colors.black,
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
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  Expanded(
                    flex: deepMins,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '22%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: remMins,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '26%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: lightMins,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '44%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: awakeMins,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE11D48), Color(0xFFFB7185)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '8%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4 Stage Detail Badges Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final deepBadge = _buildStageMetric(
                label: 'Deep Sleep',
                duration: '${deepMins ~/ 60}h ${deepMins % 60}m',
                percentage: '22%',
                color: AppColors.deepSleep,
                isDark: isDark,
              );
              final remBadge = _buildStageMetric(
                label: 'REM Sleep',
                duration: '${remMins ~/ 60}h ${remMins % 60}m',
                percentage: '26%',
                color: AppColors.remSleep,
                isDark: isDark,
              );
              final lightBadge = _buildStageMetric(
                label: 'Light Rest',
                duration: '${lightMins ~/ 60}h ${lightMins % 60}m',
                percentage: '44%',
                color: AppColors.lightSleep,
                isDark: isDark,
              );
              final awakeBadge = _buildStageMetric(
                label: 'Awake',
                duration: '${awakeMins}m',
                percentage: '8%',
                color: AppColors.awake,
                isDark: isDark,
              );

              if (constraints.maxWidth < 440) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: deepBadge),
                        const SizedBox(width: 8),
                        Expanded(child: remBadge),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: lightBadge),
                        const SizedBox(width: 8),
                        Expanded(child: awakeBadge),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: deepBadge),
                  const SizedBox(width: 8),
                  Expanded(child: remBadge),
                  const SizedBox(width: 8),
                  Expanded(child: lightBadge),
                  const SizedBox(width: 8),
                  Expanded(child: awakeBadge),
                ],
              );
            },
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              duration,
              style: AppTypography.titleMedium(isDark).copyWith(fontSize: 14),
            ),
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
