import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/models/sleep_session.dart';
import '../../../../shared/models/sleep_stats.dart';
import '../../../../shared/models/user_preferences.dart';
import '../../domain/sleep_receipt_generator.dart';

/// Modal bottom sheet presenting a nostalgic dot-matrix supermarket / thermal register sleep ticket.
class SleepReceiptSheet extends StatefulWidget {
  final List<SleepSession> sessions;
  final SleepStats stats;
  final UserPreferences preferences;

  const SleepReceiptSheet({
    super.key,
    required this.sessions,
    required this.stats,
    required this.preferences,
  });

  static Future<void> show({
    required BuildContext context,
    required List<SleepSession> sessions,
    required SleepStats stats,
    required UserPreferences preferences,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SleepReceiptSheet(
        sessions: sessions,
        stats: stats,
        preferences: preferences,
      ),
    );
  }

  @override
  State<SleepReceiptSheet> createState() => _SleepReceiptSheetState();
}

class _SleepReceiptSheetState extends State<SleepReceiptSheet>
    with SingleTickerProviderStateMixin {
  final GlobalKey _receiptBoundaryKey = GlobalKey();
  bool _isExporting = false;
  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _slideAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _exportAndShareReceipt(String textReceipt) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    HapticFeedback.mediumImpact();

    try {
      final boundary = _receiptBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        await Share.share(textReceipt, subject: 'SOMNA Sleep Receipt');
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        await Share.share(textReceipt, subject: 'SOMNA Sleep Receipt');
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final xFile = XFile.fromData(
        pngBytes,
        name: 'somna_sleep_receipt.png',
        mimeType: 'image/png',
      );

      await Share.shareXFiles(
        [xFile],
        text: 'My SOMNA Sleep Ticket 🖨️',
      );
    } catch (e) {
      debugPrint('Error sharing receipt image: $e');
      await Share.share(textReceipt, subject: 'SOMNA Sleep Receipt');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textReceipt = SleepReceiptGenerator.generateTextReceipt(
      sessions: widget.sessions,
      stats: widget.stats,
      preferences: widget.preferences,
    );
    final parts = textReceipt.split('====================================');
    final statsBody = parts.length > 2 ? parts[2].trim() : textReceipt.trim();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 18,
                    color: isDark ? AppColors.primary : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'THERMAL SLEEP TICKET',
                    style: AppTypography.titleSmall(isDark).copyWith(
                      fontFamily: AppTypography.fontFamily,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Receipt Dispenser Slot
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141414) : const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Animated Thermal Receipt Paper
          Expanded(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.15),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: RepaintBoundary(
                  key: _receiptBoundaryKey,
                  child: CustomPaint(
                    painter: _ReceiptPerforatedBorderPainter(),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF), // Crisp pure white paper
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        // Receipt Header
                        const Center(
                          child: Text(
                            '================================\n'
                            '    SOMNA SLEEP CLINIC & LAB    \n'
                            '  * * * 8-BIT BIO-STATION * * * \n'
                            '================================',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Space Mono',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF000000),
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Stats text
                        Text(
                          statsBody,
                          style: const TextStyle(
                            fontFamily: 'Space Mono',
                            fontSize: 10,
                            color: Color(0xFF000000),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Barcode Graphic
                        Center(
                          child: Column(
                            children: [
                              CustomPaint(
                                size: const Size(220, 36),
                                painter: _BarcodePainter(),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '* SOMNA-84-LAB *',
                                style: TextStyle(
                                  fontFamily: 'Space Mono',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF555555),
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

          // Actions: Share Slip Image + Copy ASCII Ticket
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isExporting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.black : Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.share_rounded, size: 16),
                  label: Text(
                    _isExporting
                        ? 'SAVING IMAGE...'
                        : 'SHARE / SAVE SLIP AS IMAGE',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                  onPressed: _isExporting
                      ? null
                      : () => _exportAndShareReceipt(textReceipt),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF404040)
                        : const Color(0xFFCCCCCC),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: Text(
                  'COPY',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: textReceipt));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dot-matrix receipt copied to clipboard!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}

/// Custom painter for jagged torn paper top and bottom edges.
class _ReceiptPerforatedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    const toothWidth = 8.0;
    const toothHeight = 5.0;

    // Top teeth
    final topPath = Path();
    topPath.moveTo(0, 0);
    for (double x = 0; x < size.width; x += toothWidth) {
      topPath.lineTo(x + (toothWidth / 2), -toothHeight);
      topPath.lineTo(x + toothWidth, 0);
    }
    topPath.close();
    canvas.drawPath(topPath, paint);

    // Bottom teeth
    final bottomPath = Path();
    bottomPath.moveTo(0, size.height);
    for (double x = 0; x < size.width; x += toothWidth) {
      bottomPath.lineTo(x + (toothWidth / 2), size.height + toothHeight);
      bottomPath.lineTo(x + toothWidth, size.height);
    }
    bottomPath.close();
    canvas.drawPath(bottomPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for retro 1D vertical barcode lines.
class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;

    final widths = [
      2, 1, 3, 1, 1, 4, 2, 1, 2, 3, 1, 1, 3, 2, 1, 4, 1, 2, 1, 3, 2, 1, 1, 4,
      2, 1, 3, 1, 2, 4, 1, 1, 3, 2, 1, 2, 4, 1, 3, 1, 2, 1, 4, 2, 1, 3
    ];

    double currentX = 10;
    for (int i = 0; i < widths.length; i++) {
      final w = widths[i].toDouble();
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(currentX, 0, w, size.height),
          paint,
        );
      }
      currentX += w + 2.0;
      if (currentX >= size.width - 10) break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
