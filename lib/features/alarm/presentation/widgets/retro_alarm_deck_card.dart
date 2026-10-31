import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_card.dart';
import '../alarm_provider.dart';
import '../../domain/models/alarm_tone.dart';

/// Retro synthesizer alarm panel with mechanical tone selector, volume, and live preview.
class RetroAlarmDeckCard extends StatelessWidget {
  const RetroAlarmDeckCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alarm = Provider.of<AlarmProvider?>(context);

    if (alarm == null) {
      return const SizedBox.shrink();
    }

    return SomnaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.alarm_rounded,
                      size: 16,
                      color:
                          isDark ? AppColors.primary : AppColors.primaryDark,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'WAKE ALARM SYNTH',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLarge(isDark).copyWith(
                          color: isDark
                              ? AppColors.primary
                              : AppColors.primaryDark,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF262626)
                      : const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF404040)
                        : const Color(0xFFCCCCCC),
                  ),
                ),
                child: Text(
                  alarm.isPreviewing ? '● LIVE OUTPUT' : 'SYNTH • 8-BIT/FM',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: alarm.isPreviewing
                        ? (isDark ? Colors.white : Colors.black)
                        : (isDark
                            ? const Color(0xFFA3A3A3)
                            : const Color(0xFF525252)),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Procedural morning chime tones generated directly in browser',
            style: AppTypography.bodySmall(isDark),
          ),
          const SizedBox(height: 12),

          // Tone Selector 2x2 Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildToneTile(
                      alarm: alarm,
                      tone: AlarmTone.all[0],
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildToneTile(
                      alarm: alarm,
                      tone: AlarmTone.all[1],
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildToneTile(
                      alarm: alarm,
                      tone: AlarmTone.all[2],
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildToneTile(
                      alarm: alarm,
                      tone: AlarmTone.all[3],
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // VU / Waveform Indicator & Controls Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF141414)
                  : const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gentle ramp toggle
                Row(
                  children: [
                    Icon(
                      alarm.gentleRampEnabled
                          ? Icons.trending_up_rounded
                          : Icons.volume_up_rounded,
                      size: 16,
                      color:
                          isDark ? AppColors.primary : AppColors.primaryDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '30S GENTLE RAMP',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: alarm.gentleRampEnabled,
                  activeThumbColor: isDark ? Colors.white : Colors.black,
                  onChanged: (val) => alarm.setGentleRamp(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Big Mechanical Preview Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: alarm.isPreviewing
                    ? (isDark
                        ? const Color(0xFF404040)
                        : const Color(0xFFCCCCCC))
                    : (isDark ? Colors.white : Colors.black),
                foregroundColor: alarm.isPreviewing
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.black : Colors.white),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                alarm.isPreviewing
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded,
                size: 18,
                color: alarm.isPreviewing
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.black : Colors.white),
              ),
              label: Text(
                alarm.isPreviewing
                    ? 'STOP ALARM PREVIEW'
                    : 'TEST "${alarm.selectedTone.name.toUpperCase()}" TONE',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: alarm.isPreviewing
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.black : Colors.white),
                ),
              ),
              onPressed: () {
                alarm.togglePreview(alarm.selectedToneId);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToneTile({
    required AlarmProvider alarm,
    required AlarmTone tone,
    required bool isDark,
  }) {
    final isSelected = alarm.selectedToneId == tone.id;
    final isCurrentlyPlaying =
        alarm.isPreviewing && alarm.previewingToneId == tone.id;

    return InkWell(
      onTap: () => alarm.selectTone(tone.id),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? const Color(0xFF262626)
                  : const Color(0xFFE5E5E5))
              : (isDark
                  ? const Color(0xFF141414)
                  : const Color(0xFFF7F7F7)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentlyPlaying
                ? (isDark ? Colors.white : Colors.black)
                : isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected || isCurrentlyPlaying ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  tone.icon,
                  size: 16,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF262626)
                        : const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tone.badge,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tone.name,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
            Text(
              tone.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9.5,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
