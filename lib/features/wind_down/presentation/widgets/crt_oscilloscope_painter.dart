import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders a vintage Tektronix-style cathode ray oscilloscope vector beam
/// that dynamically modulates based on the 4-7-8 breathing phase.
class CrtOscilloscopePainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0 continuously
  final String phase; // 'INHALE', 'HOLD', 'EXHALE'
  final double phaseProgress; // 0.0 to 1.0 within the phase
  final bool isDark;

  const CrtOscilloscopePainter({
    required this.animationValue,
    required this.phase,
    required this.phaseProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final centerY = size.height / 2;

    // 1. Draw Oscilloscope Reticle Grid
    final gridPaint = Paint()
      ..color = isDark ? const Color(0x22FFFFFF) : const Color(0x22000000)
      ..strokeWidth = 1.0;

    const divisions = 8;
    final dx = size.width / divisions;
    for (int i = 1; i < divisions; i++) {
      canvas.drawLine(Offset(dx * i, 0), Offset(dx * i, size.height), gridPaint);
    }
    const yDivisions = 6;
    final dy = size.height / yDivisions;
    for (int i = 1; i < yDivisions; i++) {
      canvas.drawLine(Offset(0, dy * i), Offset(size.width, dy * i), gridPaint);
    }

    // 2. Compute dynamic waveform parameters based on breathing phase
    double amplitude;
    double frequency;

    if (phase == 'INHALE') {
      // Expands from 8px to 45px amplitude
      amplitude = 8.0 + (phaseProgress * 38.0);
      frequency = 2.0 + (phaseProgress * 1.5);
    } else if (phase == 'HOLD') {
      // Steady harmonic oscillation with gentle breathing pulse
      final pulse = math.sin(animationValue * math.pi * 4) * 3.0;
      amplitude = 46.0 + pulse;
      frequency = 3.5;
    } else {
      // EXHALE: Gently contracts from 45px down to 6px
      amplitude = 46.0 * (1.0 - phaseProgress) + 6.0;
      frequency = 3.5 - (phaseProgress * 1.8);
    }

    // 3. Draw Vector Beam with Phosphor Bloom (Pure Monochromatic White Beam)
    final path = Path();
    for (double x = 0; x <= size.width; x += 2.0) {
      final normalizedX = x / size.width;
      // Damped window at boundaries
      final window = math.sin(normalizedX * math.pi);
      final y = centerY +
          math.sin((normalizedX * frequency * 2 * math.pi) +
                  (animationValue * 2 * math.pi)) *
              amplitude *
              window;

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Bloom layer (thick, low opacity)
    final bloomPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, bloomPaint);

    // Medium glow layer
    final glowPaint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, glowPaint);

    // Intense phosphor core
    final corePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, corePaint);
  }

  @override
  bool shouldRepaint(covariant CrtOscilloscopePainter oldDelegate) => true;
}

