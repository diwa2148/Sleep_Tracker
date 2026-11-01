import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../sleep_cycle/domain/sleep_cycle_calculator.dart';
import '../alarm_provider.dart';
import '../../domain/models/alarm_tone.dart';

/// Retro synthesizer alarm panel with mechanical tone selector, volume, and live preview.
class RetroAlarmDeckCard extends StatelessWidget {
  const RetroAlarmDeckCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alarm = Provider.of<AlarmProvider?>(context);
    final settings = Provider.of<SettingsProvider?>(context);

    if (alarm == null) {
      return const SizedBox.shrink();
    }

    final bedtime = settings?.preferences.preferredBedtime ??
        const TimeOfDay(hour: 23, minute: 0);
    final wakeTime = settings?.preferences.preferredWakeTime ??
        const TimeOfDay(hour: 7, minute: 0);
    final smartWakeWindow = SleepCycleCalculator.calculateSmartWakeWindow(
      targetWakeTime: wakeTime,
      bedtime: bedtime,
      leewayMinutes: alarm.smartWakeLeeway,
    );

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
                Expanded(
                  child: Row(
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
                      Flexible(
                        child: Text(
                          '30S GENTLE RAMP',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
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

          // Cycle-Aware Smart Wake Window Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF141414)
                  : const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.alarm_on_rounded,
                            size: 15,
                            color: isDark
                                ? AppColors.primary
                                : AppColors.primaryDark,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'CYCLE SMART WAKE',
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall(isDark).copyWith(
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.primary
                                    : AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF262626)
                            : const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF404040)
                              : const Color(0xFFCCCCCC),
                        ),
                      ),
                      child: Text(
                        smartWakeWindow.statusSummary,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 3-Segment Leeway Selector: OFF, ±15 MIN, ±30 MIN
                Row(
                  children: [
                    Expanded(
                      child: _buildLeewayChip(
                        label: 'OFF',
                        minutes: 0,
                        currentMinutes: alarm.smartWakeLeeway,
                        alarm: alarm,
                        settings: settings,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildLeewayChip(
                        label: '±15 MIN',
                        minutes: 15,
                        currentMinutes: alarm.smartWakeLeeway,
                        alarm: alarm,
                        settings: settings,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildLeewayChip(
                        label: '±30 MIN',
                        minutes: 30,
                        currentMinutes: alarm.smartWakeLeeway,
                        alarm: alarm,
                        settings: settings,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Dual-marker Target Range & Harmonic sync note
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            smartWakeWindow.formattedRange,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          if (alarm.smartWakeLeeway > 0)
                            Text(
                              'CYCLE ${smartWakeWindow.targetCycles} END',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.primary
                                    : AppColors.primaryDark,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        smartWakeWindow.syncNote,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildLeewayChip({
    required String label,
    required int minutes,
    required int currentMinutes,
    required AlarmProvider alarm,
    required SettingsProvider? settings,
    required bool isDark,
  }) {
    final isSelected = currentMinutes == minutes;

    return InkWell(
      onTap: () {
        alarm.setSmartWakeLeeway(minutes);
        settings?.updateSmartWakeLeeway(minutes);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? const Color(0xFF383838) : const Color(0xFFCCCCCC)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }
}
