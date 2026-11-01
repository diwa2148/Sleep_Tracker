import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';

/// Circular progress ring visualizing sleep duration versus the user's sleep goal
/// with retro calibrated gauge tick marks, technical indicators, and digital readouts.
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
          // Background & Progress Arc Canvas with Hour Calibration Dots
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress,
              isDark: isDark,
              trackColor: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE2E8F0),
              progressColor: progress >= 1.0
                  ? AppColors.positive
                  : (isDark ? AppColors.primary : AppColors.primaryDark),
            ),
          ),

          // Central Metrics Display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateTimeFormatter.formatMinutes(durationMinutes),
                style: AppTypography.statNumber(isDark, fontSize: 30).copyWith(
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    progress >= 1.0
                        ? Icons.check_circle_rounded
                        : Icons.timelapse_rounded,
                    size: 13,
                    color: progress >= 1.0
                        ? AppColors.positive
                        : (isDark ? AppColors.primary : AppColors.primaryDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$percentage% of goal',
                    style: AppTypography.labelSmall(isDark).copyWith(
                      color: progress >= 1.0
                          ? AppColors.positive
                          : (isDark ? AppColors.primary : AppColors.primaryDark),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
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
    final strokeWidth = size.width * 0.08;
    final radius = (size.width - strokeWidth - 12) / 2;

    // 1. Draw 12 subtle modern hour dots around perimeter
    final dotRadius = size.width / 2 - 3.5;
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12.0) * 2 * math.pi - math.pi / 2;
      final isCardinal = i % 3 == 0;
      final dotPaint = Paint()
        ..color = isCardinal
            ? (isDark ? const Color(0xFF737373) : const Color(0xFFA3A3A3))
            : (isDark ? const Color(0xFF333333) : const Color(0xFFD4D4D4))
        ..style = PaintingStyle.fill;

      final dotCenter = Offset(
        center.dx + dotRadius * math.cos(angle),
        center.dy + dotRadius * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, isCardinal ? 2.0 : 1.2, dotPaint);
    }

    // 2. Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweepAngle = (progress * 2 * math.pi).clamp(0.0, 2 * math.pi);

    // 3. Ambient Glow behind progress arc
    final glowPaint = Paint()
      ..color = progressColor.withValues(alpha: isDark ? 0.2 : 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    // 4. Progress Paint with Modern Aurora & Starlight Sweep Shader
    final sweepColors = progress >= 1.0
        ? [
            const Color(0xFF38BDF8), // Celestial Cyan
            const Color(0xFF10B981), // Aurora Emerald
            const Color(0xFFFBBF24), // Starlight Gold
          ]
        : [
            const Color(0xFF6366F1), // Royal Indigo
            const Color(0xFF8B5CF6), // Electric Violet
            const Color(0xFF38BDF8), // Celestial Cyan
          ];

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        colors: sweepColors,
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

    // 5. Sparkling Starlight Bead at the Arc Endpoint
    final tipAngle = sweepAngle - math.pi / 2;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);

    final tipGlow = Paint()
      ..color = sweepColors.last.withValues(alpha: isDark ? 0.7 : 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(tipX, tipY), strokeWidth * 0.75, tipGlow);

    final tipCore = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(tipX, tipY), strokeWidth * 0.35, tipCore);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.isDark != isDark;
  }
}
