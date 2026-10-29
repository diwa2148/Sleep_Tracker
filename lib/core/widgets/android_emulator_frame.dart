import 'package:flutter/material.dart';

/// Wraps the application inside a high-fidelity Android Emulator frame
/// with modern Android Studio controls, status bar, and gesture navigation.
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

    // If already on a native mobile screen (e.g. physical Android phone, narrow window, or test runner)
    if (screenSize.width <= 600 || screenSize.height <= 650) {
      return widget.child;
    }

    final phoneHeight = _isRotated ? 412.0 : 860.0;
    final availableHeight = screenSize.height - 70;
    final targetHeight = phoneHeight.clamp(600.0, availableHeight);
    final targetWidth = _isRotated ? targetHeight * (820 / 412) : 412.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Studio dark workbench background
      body: SafeArea(
        child: Column(
          children: [
            // Emulator Header Title Bar (like Android Studio Device Manager)
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF30363D), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone_android_rounded,
                          size: 18, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 8),
                      const Text(
                        'Android Emulator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF238636).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF238636)),
                        ),
                        child: const Text(
                          'Pixel 8 Pro • API 34',
                          style: TextStyle(
                            color: Color(0xFF3FB950),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
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
                          color: Color(0xFF3FB950),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'ONLINE (ARM64)',
                        style: TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Central Emulator Stage
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Phone Chassis
                      _buildSmartphone(
                        width: targetWidth,
                        height: targetHeight,
                      ),
                      const SizedBox(width: 14),

                      // Android Studio Side Floating Toolbar
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
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final statusContentColor =
        isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final gestureBarColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1E242B), // Matte Titanium edge
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: const Color(0xFF38424D), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Outer Hardware Buttons on Right Side (Power & Volume)
          Positioned(
            right: -5,
            top: 140,
            child: Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4A5568),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            right: -5,
            top: 200,
            child: Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4A5568),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            right: -5,
            top: 270,
            child: Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF4A5568),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Inner Screen Bezel & Display
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(7.0), // Screen Bezel
              child: ClipRRect(
                borderRadius: BorderRadius.circular(42),
                child: Container(
                  color: chassisBgColor,
                  child: Stack(
                    children: [
                      // Application Content constrained to phone viewport
                      Positioned.fill(
                        top: 28, // Below Status Bar
                        bottom: 18, // Above Gesture Bar
                        child: ClipRect(
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              size: Size(width - 14, height - 60),
                              padding: EdgeInsets.zero,
                              viewInsets: EdgeInsets.zero,
                            ),
                            child: widget.child,
                          ),
                        ),
                      ),

                      // Modern Android Status Bar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 28,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          color: chassisBgColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Digital Clock
                              Text(
                                _formatTime(),
                                style: TextStyle(
                                  color: statusContentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),

                              // Camera Punch-Hole
                              Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1E293B),
                                    width: 1,
                                  ),
                                ),
                              ),

                              // System Icons (5G, Wi-Fi, Battery)
                              Row(
                                children: [
                                  Icon(Icons.signal_cellular_4_bar_rounded,
                                      size: 13, color: statusContentColor),
                                  const SizedBox(width: 4),
                                  Icon(Icons.wifi_rounded,
                                      size: 13, color: statusContentColor),
                                  const SizedBox(width: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '98%',
                                        style: TextStyle(
                                          color: statusContentColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(Icons.battery_full_rounded,
                                          size: 14, color: statusContentColor),
                                    ],
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
                            width: 110,
                            height: 4,
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
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, 4),
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
                  content: Text('Android Power Button pressed'),
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
          const Divider(color: Color(0xFF30363D), height: 12),
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
          const Divider(color: Color(0xFF30363D), height: 12),
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
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Icon(icon, size: 18, color: const Color(0xFFC9D1D9)),
          ),
        ),
      ),
    );
  }
}
