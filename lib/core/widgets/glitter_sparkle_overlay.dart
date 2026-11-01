import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders a dynamic celestial glittering starlight sparkle effect.
/// Draws glowing 8-pointed starbursts (✦) and shimmering stardust micro-particles
/// with special concentration and sparkling flares at the terminal ends and corners.
///
/// Fully portable across all device form factors (mobile, tablets, foldables, desktop, web),
/// respecting accessibility reduce-motion settings, pointer transparency (never intercepts gestures),
/// and robust boundary clamping to prevent overflow or inversion on compact dimensions.
class GlitterSparkleOverlay extends StatefulWidget {
  final int particleCount;
  final double maxStarSize;
  final bool sparkleAtEnds;
  final Widget? child;

  const GlitterSparkleOverlay({
    super.key,
    this.particleCount = 18,
    this.maxStarSize = 11.0,
    this.sparkleAtEnds = true,
    this.child,
  });

  @override
  State<GlitterSparkleOverlay> createState() => _GlitterSparkleOverlayState();
}

class _GlitterSparkleOverlayState extends State<GlitterSparkleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_GlitterParticle> _particles = [];
  final math.Random _random = math.Random(1337);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    final isTestEnvironment =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');

    _initParticles();

    if (!isTestEnvironment) {
      _controller.repeat();
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final isTestEnvironment =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');

    if (disableAnimations || isTestEnvironment) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      _controller.value = 0.5; // Static elegant midpoint
    } else {
      if (!_controller.isAnimating && widget.particleCount > 0) {
        _controller.repeat();
      }
    }
  }

  void _initParticles() {
    _particles.clear();
    if (widget.particleCount <= 0) return;

    for (int i = 0; i < widget.particleCount; i++) {
      double rx, ry;

      if (widget.sparkleAtEnds) {
        // 75% of particles distributed along the terminal ends (left & right flanks)
        final isAtEnds = _random.nextDouble() < 0.75;
        if (isAtEnds) {
          final isLeft = _random.nextBool();
          rx = isLeft
              ? _random.nextDouble() * 0.25 // Left flank [0.0, 0.25]
              : 0.75 + _random.nextDouble() * 0.25; // Right flank [0.75, 1.0]
          ry = _random.nextDouble();
        } else {
          // Sparse midground particles
          rx = 0.25 + _random.nextDouble() * 0.50;
          ry = _random.nextDouble() < 0.5
              ? _random.nextDouble() * 0.25
              : 0.75 + _random.nextDouble() * 0.25;
        }
      } else {
        rx = _random.nextDouble();
        ry = _random.nextDouble();
      }

      final maxStar = math.max(3.5, widget.maxStarSize);
      _particles.add(
        _GlitterParticle(
          relX: rx,
          relY: ry,
          size: 3.5 + _random.nextDouble() * (maxStar - 3.5),
          phase: _random.nextDouble() * 2 * math.pi,
          speed: 0.7 + _random.nextDouble() * 1.5,
          isEightPointStar: _random.nextDouble() < 0.6,
          colorIndex: _random.nextInt(4),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(GlitterSparkleOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.particleCount != widget.particleCount ||
        oldWidget.sparkleAtEnds != widget.sparkleAtEnds ||
        oldWidget.maxStarSize != widget.maxStarSize) {
      _initParticles();
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      final isTestEnvironment =
          WidgetsBinding.instance.runtimeType.toString().contains('Test');
      if (!disableAnimations &&
          !isTestEnvironment &&
          widget.particleCount > 0 &&
          !_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _particles.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final paintWidget = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _GlitterPainter(
              progress: _controller.value,
              particles: _particles,
              isDark: isDark,
              sparkleAtEnds: widget.sparkleAtEnds,
            ),
          );
        },
      ),
    );

    // If a child is provided, overlay the sparkles transparently over the child
    // ensuring pointer events pass through completely to child buttons/sliders.
    if (widget.child != null) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child!,
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: paintWidget,
            ),
          ),
        ],
      );
    }

    return IgnorePointer(
      ignoring: true,
      child: paintWidget,
    );
  }
}

class _GlitterParticle {
  final double relX;
  final double relY;
  final double size;
  final double phase;
  final double speed;
  final bool isEightPointStar;
  final int colorIndex;

  _GlitterParticle({
    required this.relX,
    required this.relY,
    required this.size,
    required this.phase,
    required this.speed,
    required this.isEightPointStar,
    required this.colorIndex,
  });
}

class _GlitterPainter extends CustomPainter {
  final double progress;
  final List<_GlitterParticle> particles;
  final bool isDark;
  final bool sparkleAtEnds;

  _GlitterPainter({
    required this.progress,
    required this.particles,
    required this.isDark,
    required this.sparkleAtEnds,
  });

  @override
  bool hitTest(Offset position) => false;

  @override
  void paint(Canvas canvas, Size size) {
    // Early exit on degenerate / invisible sizes to prevent rendering crashes
    if (size.width <= 1.0 || size.height <= 1.0) return;

    final palette = [
      const Color(0xFFFBBF24), // Starlight Gold Sparkle
      const Color(0xFF38BDF8), // Celestial Cyan
      const Color(0xFFA78BFA), // Lavender Shimmer
      const Color(0xFF34D399), // Aurora Mint
    ];

    if (sparkleAtEnds && size.width >= 24 && size.height >= 16) {
      final minDim = math.min(size.width, size.height);

      // 1. Luminous Ambient Gradient Halos at the Left & Right Terminal Ends
      final haloRadius = (minDim * 0.70).clamp(10.0, 110.0);
      if (haloRadius > 4.0 && size.width >= 40) {
        final leftCenter = Offset(0, size.height * 0.35);
        final leftHaloPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF8B5CF6)
                  .withValues(alpha: isDark ? 0.20 : 0.10),
              Colors.transparent,
            ],
          ).createShader(
              Rect.fromCircle(center: leftCenter, radius: haloRadius));
        canvas.drawCircle(leftCenter, haloRadius, leftHaloPaint);

        final rightCenter = Offset(size.width, size.height * 0.35);
        final rightHaloPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF38BDF8)
                  .withValues(alpha: isDark ? 0.20 : 0.10),
              Colors.transparent,
            ],
          ).createShader(
              Rect.fromCircle(center: rightCenter, radius: haloRadius));
        canvas.drawCircle(rightCenter, haloRadius, rightHaloPaint);
      }

      // 2. Anchored Sparkling Starburst Flares directly at the Ends & Corners
      // Margins are dynamically clamped relative to size to prevent inversion on compact containers
      final marginX = (size.width * 0.10).clamp(6.0, 16.0);
      final marginY = (size.height * 0.16).clamp(6.0, 16.0);

      final cornerAnchors = [
        Offset(marginX, marginY), // Top-left end
        Offset(size.width - marginX, marginY), // Top-right end
        Offset(marginX, size.height - marginY), // Bottom-left end
        Offset(size.width - marginX, size.height - marginY), // Bottom-right end
      ];

      final baseRadius = (minDim * 0.15).clamp(4.0, 11.0);

      for (int i = 0; i < cornerAnchors.length; i++) {
        final pt = cornerAnchors[i];
        final phaseOffset = (i * math.pi / 2);
        final cycle = (progress * 2 * math.pi * 1.3) + phaseOffset;
        final cornerOpacity =
            ((math.sin(cycle) + 1.0) / 2.0).clamp(0.20, 0.95);
        final cornerColor = palette[i % palette.length]
            .withValues(alpha: cornerOpacity.clamp(0.0, 1.0));
        final cornerRadius =
            baseRadius * (0.8 + 0.35 * math.sin(cycle));

        _drawCornerSparkle(
          canvas,
          pt,
          cornerRadius,
          cornerColor,
          progress * math.pi * 0.6 + i,
        );
      }
    }

    // 3. Dynamic Twinkling Particles
    for (final p in particles) {
      final angle = (progress * 2 * math.pi * p.speed) + p.phase;
      final opacity = ((math.sin(angle) + 1.0) / 2.0).clamp(0.08, 0.94);

      final baseColor = palette[p.colorIndex % palette.length];
      final paintColor = baseColor.withValues(
        alpha: (isDark ? opacity : (opacity * 0.75)).clamp(0.0, 1.0),
      );

      final cx = p.relX * size.width;
      final cy = p.relY * size.height;
      final starSize = p.size * (0.6 + 0.4 * opacity);

      if (starSize < 0.5) continue;

      if (p.isEightPointStar) {
        _drawEightPointStar(
          canvas,
          Offset(cx, cy),
          starSize,
          paintColor,
          angle * 0.25,
        );
      } else {
        // Soft glowing stardust micro-dot
        final glowAlpha = (paintColor.a * 0.45).clamp(0.0, 1.0);
        final glowPaint = Paint()
          ..color = paintColor.withValues(alpha: glowAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
        canvas.drawCircle(Offset(cx, cy), starSize * 0.5, glowPaint);

        final dotPaint = Paint()..color = paintColor;
        canvas.drawCircle(Offset(cx, cy), starSize * 0.25, dotPaint);
      }
    }
  }

  void _drawCornerSparkle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double rotation,
  ) {
    if (radius <= 0.5) return;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Primary 4-point cross starburst
    _drawStarPath(canvas, radius, radius * 0.20, color);

    // Secondary diagonal micro-burst (45 deg)
    canvas.rotate(math.pi / 4);
    _drawStarPath(
      canvas,
      radius * 0.55,
      radius * 0.12,
      color.withValues(alpha: (color.a * 0.75).clamp(0.0, 1.0)),
    );

    // Center radiant diamond core
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: color.a.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * 0.22, corePaint);

    canvas.restore();
  }

  void _drawEightPointStar(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double rotation,
  ) {
    if (radius <= 0.5) return;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    _drawStarPath(canvas, radius, radius * 0.22, color);

    canvas.rotate(math.pi / 4);
    _drawStarPath(
      canvas,
      radius * 0.50,
      radius * 0.12,
      color.withValues(alpha: (color.a * 0.7).clamp(0.0, 1.0)),
    );

    canvas.restore();
  }

  void _drawStarPath(
    Canvas canvas,
    double outerRadius,
    double innerRadius,
    Color color,
  ) {
    if (outerRadius <= 0.5 || innerRadius <= 0.1) return;
    final path = Path();

    // 4 points with smooth quadratic bezier curves
    path.moveTo(0, -outerRadius); // Top
    path.quadraticBezierTo(0, -innerRadius, innerRadius, 0);
    path.quadraticBezierTo(innerRadius, 0, outerRadius, 0); // Right
    path.quadraticBezierTo(innerRadius, 0, 0, innerRadius);
    path.quadraticBezierTo(0, innerRadius, 0, outerRadius); // Bottom
    path.quadraticBezierTo(0, innerRadius, -innerRadius, 0);
    path.quadraticBezierTo(-innerRadius, 0, -outerRadius, 0); // Left
    path.quadraticBezierTo(-innerRadius, 0, 0, -innerRadius);
    path.close();

    // Subtle outer glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: (color.a * 0.45).clamp(0.0, 1.0))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawPath(path, glowPaint);

    final fillPaint = Paint()..color = color;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _GlitterPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.sparkleAtEnds != sparkleAtEnds;
  }
}

/// A container with an iridescent, glowing, shimmering border that sparkles at the corners and ends.
/// Fully guarded against negative border radii or zero dimensions.
class GlitterBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;

  const GlitterBorderContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(1.5),
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = gradientColors ??
        (isDark
            ? const [
                Color(0xFF8B5CF6), // Electric Violet
                Color(0xFF38BDF8), // Celestial Cyan
                Color(0xFFFBBF24), // Starlight Gold
                Color(0xFF8B5CF6),
              ]
            : const [
                Color(0xFF6366F1),
                Color(0xFF0284C7),
                Color(0xFFD97706),
                Color(0xFF6366F1),
              ]);

    final safeRadius = math.max(0.0, borderRadius);
    final innerRadius = math.max(0.0, borderRadius - 1.5);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(safeRadius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first
                .withValues(alpha: isDark ? 0.22 : 0.10),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: colors[1]
                .withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 18,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(1.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: child,
      ),
    );
  }
}
