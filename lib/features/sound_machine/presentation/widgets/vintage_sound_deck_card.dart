import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../domain/models/sound_track.dart';
import '../sound_machine_provider.dart';
import 'cassette_reel_painter.dart';

/// Vintage 1980s Cassette Sound Machine Deck for ambient sleep audio.
class VintageSoundDeckCard extends StatefulWidget {
  const VintageSoundDeckCard({super.key});

  @override
  State<VintageSoundDeckCard> createState() => _VintageSoundDeckCardState();
}

class _VintageSoundDeckCardState extends State<VintageSoundDeckCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _reelController;
  SoundMachineProvider? _internalProvider;

  @override
  void initState() {
    super.initState();
    _reelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
  }

  @override
  void dispose() {
    _reelController.dispose();
    _internalProvider?.dispose();
    super.dispose();
  }

  SoundMachineProvider _resolveProvider(BuildContext context) {
    try {
      final fromContext = Provider.of<SoundMachineProvider?>(context);
      if (fromContext != null) return fromContext;
    } catch (_) {}
    return _internalProvider ??= SoundMachineProvider();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sound = _resolveProvider(context);

    return ListenableBuilder(
      listenable: sound,
      builder: (context, _) {
        if (sound.isPlaying && !_reelController.isAnimating) {
          _reelController.repeat();
        } else if (!sound.isPlaying && _reelController.isAnimating) {
          _reelController.stop();
        }

        return SomnaCard(
          padding: const EdgeInsets.all(18),
          border: Border.all(
            color: sound.isPlaying
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1.2,
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Deck Header: System Name & Dolby NR-B Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: sound.isPlaying
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark
                              ? const Color(0xFF404040)
                              : const Color(0xFFCCCCCC)),
                      shape: BoxShape.circle,
                      boxShadow: sound.isPlaying
                          ? [
                              BoxShadow(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ANALOG SLEEP DECK • ST-84',
                    style: AppTypography.labelSmall(isDark).copyWith(
                      color: isDark
                          ? const Color(0xFFD4D4D4)
                          : const Color(0xFF262626),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF171717)
                      : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF262626)
                        : const Color(0xFFD4D4D4),
                  ),
                ),
                child: Text(
                  'DOLBY NR-B',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFA3A3A3)
                        : const Color(0xFF525252),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Space Mono',
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Inset Cassette Window with Rotating Dual Reels
          Container(
            height: 94,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF000000) : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDark ? const Color(0xFF262626) : const Color(0xFFCCCCCC),
                width: 1.2,
              ),
            ),
            child: Stack(
              children: [
                // Animated Reels Canvas
                AnimatedBuilder(
                  animation: _reelController,
                  builder: (context, _) {
                    return RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(double.infinity, 94),
                        painter: CassetteReelPainter(
                          angle: _reelController.value * 2 * math.pi,
                          isPlaying: sound.isPlaying,
                          isDark: isDark,
                        ),
                      ),
                    );
                  },
                ),

                // Mechanical Drum Tape Counter & Channel Label
                Positioned(
                  top: 8,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF333333)
                            : const Color(0xFF888888),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'TAPE ${sound.formattedTapeCounter}',
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Space Mono',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                // Status Chip (top right)
                Positioned(
                  top: 8,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: sound.isPlaying
                          ? (isDark
                              ? const Color(0xFF262626)
                              : const Color(0xFFE5E5E5))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: sound.isPlaying
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark
                                ? const Color(0xFF404040)
                                : const Color(0xFFCCCCCC)),
                      ),
                    ),
                    child: Text(
                      sound.isPlaying ? '▶ RUN' : '■ STOP',
                      style: TextStyle(
                        color: sound.isPlaying
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark
                                ? const Color(0xFFA3A3A3)
                                : const Color(0xFF737373)),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Space Mono',
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                // Active Track Title overlay at bottom of window
                Positioned(
                  bottom: 6,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sound.currentTrack.title,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFF1E293B),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Space Mono',
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        sound.currentTrack.frequencyLabel,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF78716C),
                          fontSize: 9,
                          fontFamily: 'Space Mono',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Stereo LED VU Meter
          _buildStereoVUMeter(isDark, sound.isPlaying),
          const SizedBox(height: 14),

          // 3. Channel Selector Push-Buttons
          Text(
            'SELECT CHANNEL',
            style: AppTypography.labelSmall(isDark).copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: SoundTrack.all.map((track) {
              final isSelected = track.id == sound.currentTrack.id;
              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  sound.playTrack(track);
                },
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? const Color(0xFF262626)
                            : const Color(0xFFE5E5E5))
                        : (isDark
                            ? const Color(0xFF141414)
                            : const Color(0xFFF7F7F7)),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isSelected
                          ? (isDark
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF000000))
                          : (isDark
                              ? const Color(0xFF262626)
                              : const Color(0xFFE5E5E5)),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (isDark
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFF000000))
                                  .withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        track.icon,
                        size: 13,
                        color: isSelected
                            ? (isDark
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF000000))
                            : (isDark
                                ? const Color(0xFF888888)
                                : const Color(0xFF666666)),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        track.title,
                        style: TextStyle(
                          color: isSelected
                              ? (isDark
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF000000))
                              : (isDark
                                  ? const Color(0xFFA3A3A3)
                                  : const Color(0xFF525252)),
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontFamily: 'Space Mono',
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // 4. Transport Controls & Volume Slider
          Row(
            children: [
              // Mechanical PLAY / PAUSE Button
              InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  sound.togglePlay();
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sound.isPlaying
                        ? (isDark
                            ? const Color(0xFF262626)
                            : const Color(0xFFE5E5E5))
                        : (isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF000000)),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF000000),
                      width: 1.4,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sound.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 16,
                        color: sound.isPlaying
                            ? (isDark
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF000000))
                            : (isDark ? Colors.black : Colors.white),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sound.isPlaying ? 'PAUSE' : 'PLAY',
                        style: TextStyle(
                          color: sound.isPlaying
                              ? (isDark
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF000000))
                              : (isDark ? Colors.black : Colors.white),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTypography.fontFamily,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Volume Slider with VU Scale
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'OUTPUT LEVEL',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFA3A3A3)
                                : const Color(0xFF525252),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTypography.fontFamily,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${(sound.volume * 100).toInt()}%',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF000000),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        activeTrackColor: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF000000),
                        inactiveTrackColor: isDark
                            ? const Color(0xFF262626)
                            : const Color(0xFFE5E5E5),
                        thumbColor: isDark
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF000000),
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: sound.volume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: sound.setVolume,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 5. Sleep Auto-Stop Timer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined,
                      size: 13,
                      color: isDark
                          ? const Color(0xFFA3A3A3)
                          : const Color(0xFF737373)),
                  const SizedBox(width: 4),
                  Text(
                    'SHUT-OFF TIMER:',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFA3A3A3)
                          : const Color(0xFF525252),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ],
              ),
              if (sound.sleepTimerMinutes != null)
                Text(
                  'FADE IN ${sound.formattedTimerRemaining}',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFD4D4D4)
                        : const Color(0xFF262626),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildTimerPill(
                label: 'OFF',
                isSelected: sound.sleepTimerMinutes == null,
                onTap: () => sound.setSleepTimer(null),
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildTimerPill(
                label: '15m',
                isSelected: sound.sleepTimerMinutes == 15,
                onTap: () => sound.setSleepTimer(15),
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildTimerPill(
                label: '30m',
                isSelected: sound.sleepTimerMinutes == 30,
                onTap: () => sound.setSleepTimer(30),
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildTimerPill(
                label: '45m',
                isSelected: sound.sleepTimerMinutes == 45,
                onTap: () => sound.setSleepTimer(45),
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildTimerPill(
                label: '60m',
                isSelected: sound.sleepTimerMinutes == 60,
                onTap: () => sound.setSleepTimer(60),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  },
);
  }

  Widget _buildTimerPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? const Color(0xFF262626)
                    : const Color(0xFFE5E5E5))
                : (isDark ? const Color(0xFF141414) : const Color(0xFFF7F7F7)),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: isSelected
                  ? (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000))
                  : (isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5)),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? (isDark
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF000000))
                  : (isDark
                      ? const Color(0xFFA3A3A3)
                      : const Color(0xFF525252)),
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontFamily: AppTypography.fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStereoVUMeter(bool isDark, bool isPlaying) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFCCCCCC),
        ),
      ),
      child: Row(
        children: [
          Text(
            'VU',
            style: TextStyle(
              color: isDark ? const Color(0xFFA3A3A3) : const Color(0xFF525252),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              fontFamily: 'Space Mono',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                _buildChannelMeter('L', isDark, isPlaying, 0.72),
                const SizedBox(height: 3),
                _buildChannelMeter('R', isDark, isPlaying, 0.65),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildChannelMeter(
      String ch, bool isDark, bool isPlaying, double bias) {
    final colors = isDark
        ? const [
            Color(0xFF555555),
            Color(0xFF666666),
            Color(0xFF777777),
            Color(0xFF888888),
            Color(0xFF999999),
            Color(0xFFAAAAAA),
            Color(0xFFCCCCCC),
            Color(0xFFDDDDDD),
            Color(0xFFEEEEEE),
            Color(0xFFFFFFFF),
          ]
        : const [
            Color(0xFFAAAAAA),
            Color(0xFF999999),
            Color(0xFF888888),
            Color(0xFF777777),
            Color(0xFF666666),
            Color(0xFF555555),
            Color(0xFF444444),
            Color(0xFF333333),
            Color(0xFF222222),
            Color(0xFF000000),
          ];

    return Row(
      children: [
        SizedBox(
          width: 10,
          child: Text(
            ch,
            style: TextStyle(
              color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              fontFamily: 'Space Mono',
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Row(
            children: List.generate(10, (idx) {
              final activeCount = isPlaying
                  ? ((bias * 8).round() + (idx % 2 == 0 ? 1 : 0)).clamp(0, 10)
                  : 0;
              final isLit = idx < activeCount;
              final segColor = colors[idx];
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isLit
                        ? segColor
                        : (isDark
                            ? segColor.withValues(alpha: 0.15)
                            : segColor.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: isLit
                        ? [
                            BoxShadow(
                              color: segColor.withValues(alpha: 0.5),
                              blurRadius: 3,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
