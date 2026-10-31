import 'package:flutter/material.dart';
import '../../app/theme/app_typography.dart';

/// Wraps the application inside a high-fidelity Retro Handheld / Vintage Cyberdeck casing
/// with tactile hardware controls, vintage status indicators, and mechanical styling.
class AndroidEmulatorFrame extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;
  final VoidCallback? onHomePressed;
  final VoidCallback? onBackPressed;

  const AndroidEmulatorFrame({
    super.key,
    required this.child,
    this.navigatorKey,
    this.onHomePressed,
    this.onBackPressed,
  });

  @override
  State<AndroidEmulatorFrame> createState() => _AndroidEmulatorFrameState();
}

class _AndroidEmulatorFrameState extends State<AndroidEmulatorFrame> {
  bool _isRotated = false;

  String _formatTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // If already on a native mobile screen (e.g. physical phone, narrow window, or test runner)
    if (screenSize.width <= 600 || screenSize.height <= 650) {
      return widget.child;
    }

    final phoneHeight = _isRotated ? 412.0 : 860.0;
    final availableHeight = screenSize.height - 70;
    final targetHeight = phoneHeight.clamp(600.0, availableHeight);
    final targetWidth = _isRotated ? targetHeight * (820 / 412) : 412.0;

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure black studio workbench background
      body: SafeArea(
        child: Column(
          children: [
            // Retro Terminal Title Bar
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D0D0D),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF262626), width: 1.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.memory_rounded,
                          size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'SOMNA RETRO-TERMINAL • ST-84',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTypography.fontFamily,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262626),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFF404040)),
                        ),
                        child: const Text(
                          'CH-01 • HI-FI OS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTypography.fontFamily,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'SYS: ONLINE (60 FPS)',
                        style: TextStyle(
                          color: Color(0xFFA3A3A3),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTypography.fontFamily,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Central Retro Stage
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Handheld Chassis
                      _buildSmartphone(
                        width: targetWidth,
                        height: targetHeight,
                      ),
                      const SizedBox(width: 14),

                      // Side Mechanical Floating Toolbar
                      _buildSideToolbar(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartphone({required double width, required double height}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chassisBgColor =
        isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final statusContentColor =
        isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final gestureBarColor =
        isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF7F7F7), // Retro matte monochrome gunmetal
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFD4D4D4),
          width: 3.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner Screw Rivets
          Positioned(
            left: 10,
            top: 10,
            child: Text('✛',
                style: TextStyle(
                    color: isDark ? const Color(0xFF404040) : const Color(0xFFCCCCCC),
                    fontSize: 12,
                    fontWeight: FontWeight.w900)),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Text('✛',
                style: TextStyle(
                    color: isDark ? const Color(0xFF404040) : const Color(0xFFCCCCCC),
                    fontSize: 12,
                    fontWeight: FontWeight.w900)),
          ),
          Positioned(
            left: 10,
            bottom: 8,
            child: Text('✛',
                style: TextStyle(
                    color: isDark ? const Color(0xFF404040) : const Color(0xFFCCCCCC),
                    fontSize: 12,
                    fontWeight: FontWeight.w900)),
          ),
          Positioned(
            right: 10,
            bottom: 8,
            child: Text('✛',
                style: TextStyle(
                    color: isDark ? const Color(0xFF404040) : const Color(0xFFCCCCCC),
                    fontSize: 12,
                    fontWeight: FontWeight.w900)),
          ),

          // Outer Hardware Buttons on Right Side
          Positioned(
            right: -5,
            top: 140,
            child: Container(
              width: 5,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            right: -5,
            top: 200,
            child: Container(
              width: 5,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF404040) : const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            right: -5,
            top: 270,
            child: Container(
              width: 5,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF404040) : const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Inner Screen Bezel & Display
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 10.0), // Screen Bezel
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: chassisBgColor,
                  child: Stack(
                    children: [
                      // Application Content constrained to phone viewport
                      Positioned.fill(
                        top: 28, // Below Status Bar
                        bottom: 16, // Above Gesture Bar
                        child: ClipRect(
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              size: Size(width - 18, height - 64),
                              padding: EdgeInsets.zero,
                              viewInsets: EdgeInsets.zero,
                            ),
                            child: widget.child,
                          ),
                        ),
                      ),

                      // Retro Digital Status Bar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 28,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: chassisBgColor,
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? const Color(0xFF262626)
                                    : const Color(0xFFE5E5E5),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Digital Clock
                              Text(
                                _formatTime(),
                                style: TextStyle(
                                  color: statusContentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: AppTypography.fontFamily,
                                  letterSpacing: 0.5,
                                ),
                              ),

                              // Retro LED Center Status
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white : Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'REC',
                                    style: TextStyle(
                                      color: statusContentColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: AppTypography.fontFamily,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),

                              // System Icons (5G, Wi-Fi, Battery)
                              Row(
                                children: [
                                  Text(
                                    '[5G]',
                                    style: TextStyle(
                                      color: statusContentColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: AppTypography.fontFamily,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(Icons.wifi_rounded,
                                      size: 12, color: statusContentColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    '98%',
                                    style: TextStyle(
                                      color: statusContentColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: AppTypography.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Android Bottom Gesture Navigation Handle
                      Positioned(
                        bottom: 4,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: gestureBarColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideToolbar() {
    return Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF262626), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolButton(
            icon: Icons.power_settings_new_rounded,
            tooltip: 'Power Button',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Power Button toggled'),
                  duration: Duration(milliseconds: 900),
                ),
              );
            },
          ),
          _buildToolButton(
            icon: Icons.volume_up_rounded,
            tooltip: 'Volume Up',
            onTap: () {},
          ),
          _buildToolButton(
            icon: Icons.volume_down_rounded,
            tooltip: 'Volume Down',
            onTap: () {},
          ),
          const Divider(color: Color(0xFF262626), height: 12),
          _buildToolButton(
            icon: Icons.screen_rotation_rounded,
            tooltip: 'Rotate Device',
            onTap: () {
              setState(() => _isRotated = !_isRotated);
            },
          ),
          _buildToolButton(
            icon: Icons.camera_alt_outlined,
            tooltip: 'Take Screenshot',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Screenshot captured to gallery'),
                  duration: Duration(milliseconds: 900),
                ),
              );
            },
          ),
          const Divider(color: Color(0xFF262626), height: 12),
          // Android 3-Button Navigation
          _buildToolButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: () {
              if (widget.onBackPressed != null) {
                widget.onBackPressed!();
              } else if (widget.navigatorKey?.currentState != null) {
                widget.navigatorKey!.currentState!.maybePop();
              }
            },
          ),
          _buildToolButton(
            icon: Icons.circle_outlined,
            tooltip: 'Home',
            onTap: () {
              if (widget.onHomePressed != null) {
                widget.onHomePressed!();
              } else if (widget.navigatorKey?.currentState != null) {
                widget.navigatorKey!.currentState!
                    .popUntil((route) => route.isFirst);
              }
            },
          ),
          _buildToolButton(
            icon: Icons.crop_square_rounded,
            tooltip: 'Overview / Recents',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
