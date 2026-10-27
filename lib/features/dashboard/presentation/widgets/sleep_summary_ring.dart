import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';

/// Circular progress ring visualizing sleep duration versus the user's sleep goal.
class SleepSummaryRing extends StatelessWidget {
  final int durationMinutes;
  final int goalMinutes;
  final double size;

  const SleepSummaryRing({
    super.key,
    required this.durationMinutes,
    required this.goalMinutes,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = goalMinutes > 0
        ? (durationMinutes / goalMinutes).clamp(0.0, 1.25)
        : 0.0;
    final percentage = (progress * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background & Progress Arc Canvas
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress,
              isDark: isDark,
              trackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              progressColor:
                  progress >= 1.0 ? AppColors.positive : AppColors.primary,
            ),
          ),

          // Central Metrics Display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateTimeFormatter.formatMinutes(durationMinutes),
                style: AppTypography.statNumber(isDark, fontSize: 32),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    progress >= 1.0
                        ? Icons.check_circle_rounded
                        : Icons.track_changes_rounded,
                    size: 14,
                    color: progress >= 1.0
                        ? AppColors.positive
                        : AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$percentage% of goal',
                    style: AppTypography.labelMedium(isDark).copyWith(
                      color: progress >= 1.0
                          ? AppColors.positive
                          : AppColors.secondary,
                      fontWeight: FontWeight.w600,
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
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.isDark,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.085;
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Progress Paint with Gradient
    final sweepAngle = (progress * 2 * math.pi).clamp(0.0, 2 * math.pi);
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        colors: [
          progressColor.withValues(alpha: 0.7),
          progressColor,
        ],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at 12 o'clock
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
