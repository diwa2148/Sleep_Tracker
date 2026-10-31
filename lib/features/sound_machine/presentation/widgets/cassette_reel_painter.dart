import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter rendering dual spinning cassette tape spools with spokes and magnetic tape ribbon.
class CassetteReelPainter extends CustomPainter {
  final double angle;
  final bool isPlaying;
  final bool isDark;

  const CassetteReelPainter({
    required this.angle,
    required this.isPlaying,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final spoolRadius = height * 0.38;
    final leftCenter = Offset(width * 0.28, height * 0.5);
    final rightCenter = Offset(width * 0.72, height * 0.5);

    // 1. Magnetic Tape Pack (Monochrome dark graphite analog tape around reels)
    final tapePackPaint = Paint()
      ..color = isDark ? const Color(0xFF141414) : const Color(0xFF404040)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(leftCenter, spoolRadius * 1.15, tapePackPaint);
    canvas.drawCircle(rightCenter, spoolRadius * 0.95, tapePackPaint);

    // 2. Tape connecting ribbon between spools
    final tapeRibbonPaint = Paint()
      ..color = isDark ? const Color(0xFF262626) : const Color(0xFF2E2E2E)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final tapePath = Path()
      ..moveTo(leftCenter.dx, leftCenter.dy + spoolRadius * 1.15)
      ..lineTo(rightCenter.dx, rightCenter.dy + spoolRadius * 0.95);
    canvas.drawPath(tapePath, tapeRibbonPaint);

    // 3. Draw Left and Right Spools
    _drawSpool(canvas, leftCenter, spoolRadius, angle);
    _drawSpool(canvas, rightCenter, spoolRadius, angle);
  }

  void _drawSpool(Canvas canvas, Offset center, double radius, double currentAngle) {
    final outerRingPaint = Paint()
      ..color = isDark ? const Color(0xFFE0E0E0) : const Color(0xFFEEEEEE)
      ..style = PaintingStyle.fill;

    final innerHolePaint = Paint()
      ..color = isDark ? const Color(0xFF000000) : const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;

    final spokePaint = Paint()
      ..color = isDark ? const Color(0xFF555555) : const Color(0xFF777777)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final teethPaint = Paint()
      ..color = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000)
      ..style = PaintingStyle.fill;

    // Outer white/cream plastic spool ring
    canvas.drawCircle(center, radius, outerRingPaint);

    // Center spindle hole
    final spindleRadius = radius * 0.42;
    canvas.drawCircle(center, spindleRadius, innerHolePaint);

    // 6 Spool spokes & 3 drive teeth
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(currentAngle);

    for (int i = 0; i < 6; i++) {
      final spokeAngle = (i * math.pi) / 3;
      final x1 = math.cos(spokeAngle) * spindleRadius;
      final y1 = math.sin(spokeAngle) * spindleRadius;
      final x2 = math.cos(spokeAngle) * radius;
      final y2 = math.sin(spokeAngle) * radius;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), spokePaint);
    }

    // 3 Spindle drive teeth
    for (int i = 0; i < 3; i++) {
      final toothAngle = (i * 2 * math.pi) / 3;
      final toothPath = Path();
      final toothDistance = spindleRadius * 0.65;
      final tx = math.cos(toothAngle) * toothDistance;
      final ty = math.sin(toothAngle) * toothDistance;
      toothPath.addOval(Rect.fromCircle(center: Offset(tx, ty), radius: 2.2));
      canvas.drawPath(toothPath, teethPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CassetteReelPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.isDark != isDark;
  }
}

