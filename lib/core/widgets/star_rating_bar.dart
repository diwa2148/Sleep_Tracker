import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Interactive 5-star rating selector for subjective sleep quality.
class StarRatingBar extends StatelessWidget {
  final int? rating; // 1 to 5, or null
  final ValueChanged<int?> onRatingChanged;
  final bool readOnly;
  final double starSize;

  const StarRatingBar({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.readOnly = false,
    this.starSize = 36,
  });

  static const List<String> _ratingLabels = [
    'Poor',
    'Fair',
    'Good',
    'Great',
    'Excellent',
  ];

  static const List<Color> _ratingColors = [
    AppColors.rating1,
    AppColors.rating2,
    AppColors.rating3,
    AppColors.rating4,
    AppColors.rating5,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentRating = rating ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isFilled = starIndex <= currentRating;
            final starColor = isFilled
                ? _ratingColors[currentRating - 1]
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: InkWell(
                onTap: readOnly
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        // Toggle if tapped again
                        if (rating == starIndex) {
                          onRatingChanged(null);
                        } else {
                          onRatingChanged(starIndex);
                        }
                      },
                borderRadius: BorderRadius.circular(starSize / 2),
                child: AnimatedScale(
                  scale: isFilled ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: starSize,
                    color: starColor,
                  ),
                ),
              ),
            );
          }),
        ),
        if (currentRating > 0 && !readOnly) ...[
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _ratingLabels[currentRating - 1],
              key: ValueKey<int>(currentRating),
              style: AppTypography.labelLarge(isDark).copyWith(
                color: _ratingColors[currentRating - 1],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
