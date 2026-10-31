import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/settings_provider.dart';

/// Wraps content in an authentic 1980s CRT monitor effect with horizontal raster scanlines,
/// curved tube corner vignette, and subtle phosphor bloom.
class CrtScanlineOverlay extends StatelessWidget {
  final Widget child;
  final bool? overrideEnabled;

  const CrtScanlineOverlay({
    super.key,
    required this.child,
    this.overrideEnabled,
  });

  @override
  Widget build(BuildContext context) {
    bool isEnabled = overrideEnabled ?? false;
    if (overrideEnabled == null) {
      try {
        final settings = Provider.of<SettingsProvider?>(context);
        if (settings != null) {
          isEnabled = settings.crtScanlinesEnabled;
        }
      } catch (_) {}
    }

    if (!isEnabled) {
      return child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CrtScanlinePainter(isDark: isDark),
            ),
          ),
        ),
      ],
    );
  }
}

class _CrtScanlinePainter extends CustomPainter {
  final bool isDark;

  const _CrtScanlinePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final linePaint = Paint()
      ..color = isDark ? const Color(0x28000000) : const Color(0x14000000)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 1. Repeating CRT Horizontal Raster Scanlines (every 3px)
    for (double y = 0; y < size.height; y += 3.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // 2. CRT Glass Tube Vignette (Darkened curved corners)
    final rect = Offset.zero & size;
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          Colors.transparent,
          isDark ? const Color(0x40000000) : const Color(0x22000000),
        ],
        stops: const [0.65, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, vignettePaint);

    // 3. Subtle Phosphor Bloom
    if (isDark) {
      final bloomPaint = Paint()
        ..color = const Color(0x05FFB020) // Very subtle warm amber phosphor glow
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, bloomPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CrtScanlinePainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
