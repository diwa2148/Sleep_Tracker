import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_card.dart';

/// Card presenting the Bedtime Consistency Index (0-100%) and circadian stability rating.
class ConsistencyMeter extends StatelessWidget {
  final int consistencyScore; // 0 to 100
  final double variabilityMinutes;

  const ConsistencyMeter({
    super.key,
    required this.consistencyScore,
    required this.variabilityMinutes,
  });

  String get _ratingLabel {
    if (consistencyScore >= 80) return 'Highly Consistent';
    if (consistencyScore >= 60) return 'Moderate Consistency';
    if (consistencyScore > 0) return 'Variable Bedtimes';
    return 'Insufficient Data';
  }

  Color get _ratingColor {
    if (consistencyScore >= 80) return AppColors.positive;
    if (consistencyScore >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SomnaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bedtime Regularity',
                style: AppTypography.titleMedium(isDark),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _ratingColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _ratingLabel,
                  style: AppTypography.labelSmall(isDark).copyWith(
                    color: _ratingColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Score & Circular Indicator
          Row(
            children: [
              Text(
                '$consistencyScore%',
                style: AppTypography.statNumber(isDark, fontSize: 38).copyWith(
                  color: _ratingColor,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Circadian Stability',
                      style: AppTypography.titleSmall(isDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      variabilityMinutes > 0
                          ? 'Duration varied by ~${variabilityMinutes.round()}m between sessions'
                          : 'Consistent bedtimes help synchronize your internal sleep cycle',
                      style: AppTypography.bodySmall(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (consistencyScore / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor:
                  isDark ? AppColors.darkBorder : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(_ratingColor),
            ),
          ),
        ],
      ),
    );
  }
}
