import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../../shared/providers/sleep_tracker_provider.dart';
import '../../domain/sleep_cycle_calculator.dart';

enum SleepCycleMode { sleepNow, wakeAt }

/// Retro cyberdeck hardware card calculating 90-minute ultradian sleep cycles.
class SleepCycleCard extends StatefulWidget {
  const SleepCycleCard({super.key});

  @override
  State<SleepCycleCard> createState() => _SleepCycleCardState();
}

class _SleepCycleCardState extends State<SleepCycleCard> {
  SleepCycleMode _mode = SleepCycleMode.sleepNow;
  TimeOfDay _targetWakeTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tracker = Provider.of<SleepTrackerProvider?>(context);
    final settings = Provider.of<SettingsProvider?>(context);

    final targets = _mode == SleepCycleMode.sleepNow
        ? SleepCycleCalculator.calculateWakeTimes(DateTime.now())
        : SleepCycleCalculator.calculateBedtimes(wakeTime: _targetWakeTime);

    return SomnaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Retro Tag & REM Sync Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.alarm_on_rounded,
                      size: 16,
                      color: isDark ? AppColors.primary : AppColors.primaryDark,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '90-MIN SLEEP CYCLES',
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
                  'REM SYNC • 1.5H',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFA3A3A3)
                        : const Color(0xFF525252),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Wake up between 90-min cycles to bypass sleep inertia & grogginess',
            style: AppTypography.bodySmall(isDark),
          ),
          const SizedBox(height: 14),

          // Mode Selector: Mechanical Buttons
          Row(
            children: [
              Expanded(
                child: _buildModeButton(
                  title: 'SLEEP NOW',
                  subtitle: 'Wake-up times',
                  icon: Icons.bedtime_rounded,
                  isSelected: _mode == SleepCycleMode.sleepNow,
                  isDark: isDark,
                  onTap: () =>
                      setState(() => _mode = SleepCycleMode.sleepNow),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModeButton(
                  title: 'WAKE AT...',
                  subtitle: 'Target bedtime',
                  icon: Icons.wb_sunny_rounded,
                  isSelected: _mode == SleepCycleMode.wakeAt,
                  isDark: isDark,
                  onTap: () =>
                      setState(() => _mode = SleepCycleMode.wakeAt),
                ),
              ),
            ],
          ),

          // If mode is "Wake At...", show clickable time selector
          if (_mode == SleepCycleMode.wakeAt) ...[
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _targetWakeTime,
                );
                if (picked != null) {
                  setState(() => _targetWakeTime = picked);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF404040)
                        : const Color(0xFFCCCCCC),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.primary
                              : AppColors.primaryDark,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TARGET WAKE-UP ALARM:',
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
                    Text(
                      _targetWakeTime.format(context),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.primary
                            : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Cycle Target Rows
          Column(
            children: targets.map((target) {
              return _buildTargetTile(target, isDark);
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Action Button depending on mode
          if (_mode == SleepCycleMode.sleepNow && tracker != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text(
                  'START SLEEP TRACKER NOW',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: tracker.isTracking
                    ? null
                    : () {
                        tracker.startSleepTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Sleep tracking initiated! Have a restful night.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
              ),
            ),
          ] else if (_mode == SleepCycleMode.wakeAt && settings != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  side: BorderSide(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.bookmark_added_rounded, size: 16),
                label: const Text(
                  'SET AS BEDTIME SCHEDULE',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () async {
                  // Find optimal target (5 cycles)
                  final optimal = targets.firstWhere((t) => t.isOptimal);
                  final bedtimeMinutes =
                      optimal.targetTime.hour * 60 + optimal.targetTime.minute;
                  final wakeMinutes =
                      _targetWakeTime.hour * 60 + _targetWakeTime.minute;
                  await settings.updateSchedule(
                    bedtimeMinutes: bedtimeMinutes,
                    wakeMinutes: wakeMinutes,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Target schedule updated: Bedtime ${optimal.formattedTime} for ${_targetWakeTime.format(context)} wake!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : (isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetTile(SleepCycleTarget target, bool isDark) {
    Color accentColor;
    if (target.isOptimal) {
      accentColor = isDark ? Colors.white : Colors.black;
    } else if (target.cycles == 6) {
      accentColor = const Color(0xFFA3A3A3);
    } else if (target.cycles == 4) {
      accentColor = const Color(0xFF737373);
    } else {
      accentColor = const Color(0xFF525252);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: target.isOptimal
            ? (isDark
                ? const Color(0xFF262626)
                : const Color(0xFFE5E5E5))
            : (isDark
                ? const Color(0xFF141414)
                : const Color(0xFFF7F7F7)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: target.isOptimal
              ? (isDark ? Colors.white : Colors.black)
              : (isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder),
          width: target.isOptimal ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time display
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                target.formattedTime,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          // Cycle and Optimal tag
          Row(
            children: [
              if (target.isOptimal) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF333333)
                        : const Color(0xFFD4D4D4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  child: Text(
                    'OPTIMAL',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '${target.cycles} CYCLES (${target.formattedDuration})',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

