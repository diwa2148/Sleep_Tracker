import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import 'crt_oscilloscope_painter.dart';

/// Interactive 4-7-8 wind-down breathing pacer visualized with a CRT oscilloscope beam.
class WindDownPacerSheet extends StatefulWidget {
  const WindDownPacerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const WindDownPacerSheet(),
    );
  }

  @override
  State<WindDownPacerSheet> createState() => _WindDownPacerSheetState();
}

class _WindDownPacerSheetState extends State<WindDownPacerSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _phaseTimer;

  bool _isRunning = false;
  bool _hapticsEnabled = true;
  int _currentCycle = 1;
  static const int _totalCycles = 4;

  String _currentPhase = 'INHALE'; // 'INHALE', 'HOLD', 'EXHALE'
  int _secondsLeftInPhase = 4;
  int _lastHapticSecond = -1;
  double _phaseProgress = 0.0;
  int _phaseElapsedMs = 0;

  static const int _inhaleMs = 4000;
  static const int _holdMs = 7000;
  static const int _exhaleMs = 8000;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  void _triggerPhaseHaptic(String phase) {
    if (!_hapticsEnabled) return;
    switch (phase) {
      case 'INHALE':
        HapticFeedback.mediumImpact();
        break;
      case 'HOLD':
        HapticFeedback.lightImpact();
        break;
      case 'EXHALE':
        HapticFeedback.heavyImpact();
        break;
    }
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _currentPhase = 'INHALE';
      _secondsLeftInPhase = 4;
      _lastHapticSecond = 4;
      _phaseElapsedMs = 0;
      _phaseProgress = 0.0;
    });
    _triggerPhaseHaptic('INHALE');

    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isRunning) return;

      setState(() {
        _phaseElapsedMs += 50;
        int totalPhaseMs;
        if (_currentPhase == 'INHALE') {
          totalPhaseMs = _inhaleMs;
          _secondsLeftInPhase = ((_inhaleMs - _phaseElapsedMs) / 1000).ceil();
        } else if (_currentPhase == 'HOLD') {
          totalPhaseMs = _holdMs;
          _secondsLeftInPhase = ((_holdMs - _phaseElapsedMs) / 1000).ceil();
        } else {
          totalPhaseMs = _exhaleMs;
          _secondsLeftInPhase = ((_exhaleMs - _phaseElapsedMs) / 1000).ceil();
        }

        if (_secondsLeftInPhase != _lastHapticSecond && _secondsLeftInPhase > 0) {
          _lastHapticSecond = _secondsLeftInPhase;
          if (_hapticsEnabled) {
            HapticFeedback.selectionClick();
          }
        }

        _phaseProgress = (_phaseElapsedMs / totalPhaseMs).clamp(0.0, 1.0);

        if (_phaseElapsedMs >= totalPhaseMs) {
          _advancePhase();
        }
      });
    });
  }

  void _advancePhase() {
    _phaseElapsedMs = 0;
    _phaseProgress = 0.0;

    if (_currentPhase == 'INHALE') {
      _currentPhase = 'HOLD';
      _secondsLeftInPhase = 7;
      _lastHapticSecond = 7;
    } else if (_currentPhase == 'HOLD') {
      _currentPhase = 'EXHALE';
      _secondsLeftInPhase = 8;
      _lastHapticSecond = 8;
    } else {
      // Completed one cycle
      if (_currentCycle >= _totalCycles) {
        _stop();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wind-down protocol complete. Have a restful sleep!'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      } else {
        _currentCycle++;
        _currentPhase = 'INHALE';
        _secondsLeftInPhase = 4;
        _lastHapticSecond = 4;
      }
    }
    _triggerPhaseHaptic(_currentPhase);
  }

  void _pause() {
    setState(() => _isRunning = false);
    _phaseTimer?.cancel();
  }

  void _stop() {
    setState(() {
      _isRunning = false;
      _currentCycle = 1;
      _currentPhase = 'INHALE';
      _secondsLeftInPhase = 4;
      _phaseProgress = 0.0;
      _phaseElapsedMs = 0;
    });
    _phaseTimer?.cancel();
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  String _getInstruction() {
    if (!_isRunning) return 'Tap START to begin the 4-7-8 relaxing breath cycle';
    switch (_currentPhase) {
      case 'INHALE':
        return 'Inhale smoothly through your nose...';
      case 'HOLD':
        return 'Hold your breath gently and stay relaxed...';
      case 'EXHALE':
        return 'Exhale completely with a slow, calming whoosh...';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
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
                    Icons.waves_rounded,
                    size: 18,
                    color: isDark ? AppColors.primary : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RELAXING BREATH PACER',
                    style: AppTypography.titleSmall(isDark).copyWith(
                      fontFamily: AppTypography.fontFamily,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.primary : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _hapticsEnabled
                          ? Icons.vibration_rounded
                          : Icons.mobile_off_rounded,
                      size: 18,
                      color: _hapticsEnabled
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? const Color(0xFF666666) : const Color(0xFF999999)),
                    ),
                    tooltip: _hapticsEnabled
                        ? 'Tactile haptics: ON (Eyes-closed breathing)'
                        : 'Tactile haptics: OFF',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _hapticsEnabled = !_hapticsEnabled;
                      });
                      if (_hapticsEnabled) {
                        HapticFeedback.mediumImpact();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1C1C1C)
                          : const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E2E2E)
                            : const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Text(
                      'CYCLE $_currentCycle/$_totalCycles • 4-7-8',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Oscilloscope Screen (Cathode ray tube chassis)
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF000000), // Ultra-deep pitch black
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF262626) : const Color(0xFF404040),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33FFFFFF),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(double.infinity, 160),
                        painter: CrtOscilloscopePainter(
                          animationValue: _animController.value,
                          phase: _currentPhase,
                          phaseProgress: _phaseProgress,
                          isDark: true,
                        ),
                      ),
                    );
                  },
                ),

                // Digital phase indicator
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xCC000000),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFFFFF)),
                    ),
                    child: Text(
                      '$_currentPhase: $_secondsLeftInPhase s',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFFFFF),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Frequency readout in corner
                Positioned(
                  bottom: 8,
                  right: 12,
                  child: Text(
                    _isRunning ? 'AUTONOMIC DOWN-REG • 0.05 Hz' : 'STANDBY',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF888888),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Guidance Prompt
          Text(
            _getInstruction(),
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(isDark).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Control Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning
                        ? (isDark ? const Color(0xFFD4D4D4) : const Color(0xFF404040))
                        : (isDark ? Colors.white : Colors.black),
                    foregroundColor: _isRunning
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? Colors.black : Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    _isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _isRunning ? 'PAUSE PACER' : 'START 4-7-8 PACER',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: () {
                    if (_isRunning) {
                      _pause();
                    } else {
                      _start();
                    }
                  },
                ),
              ),
              if (_isRunning || _currentCycle > 1) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _stop,
                  child: const Icon(Icons.refresh_rounded, size: 18),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

