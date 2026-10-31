import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/somna_button.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/models/sleep_session.dart';

/// Card displayed prominently on the dashboard when a live sleep session is being tracked.
/// Modernized with luminous ambient glow, rounded geometry, and sleek live status indicators.
class ActiveSessionCard extends StatelessWidget {
  final SleepSession activeSession;
  final Duration elapsedDuration;
  final VoidCallback onWakeUp;
  final VoidCallback onCancel;

  const ActiveSessionCard({
    super.key,
    required this.activeSession,
    required this.elapsedDuration,
    required this.onWakeUp,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark ? Colors.white : Colors.black;

    return SomnaCard(
      gradient: LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF1A1A1A),
                const Color(0xFF0F0F0F),
              ]
            : [
                const Color(0xFFF7F7F7),
                const Color(0xFFFFFFFF),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: isDark
            ? const Color(0xFF333333)
            : const Color(0xFFD4D4D4),
        width: 1.2,
      ),
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        children: [
          // Header with pulsating live recording pill & close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: dotColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'SLEEP TRACKING ACTIVE',
                      style: AppTypography.labelSmall(isDark).copyWith(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
                tooltip: 'Discard tracking',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context: context,
                    title: 'Cancel Sleep Tracking?',
                    message:
                        'This in-progress sleep session will not be saved. Are you sure you want to discard it?',
                    confirmText: 'Discard',
                    isDestructive: true,
                  );
                  if (confirmed) onCancel();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Digital Timer Readout Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF080808)
                  : const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF262626)
                    : const Color(0xFFE5E5E5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  DateTimeFormatter.formatTimer(elapsedDuration),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Started at ${DateTimeFormatter.formatTime(activeSession.startTimestamp.toLocal())}',
                      style: AppTypography.bodySmall(isDark).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Action Button
          SomnaButton(
            text: 'Wake Up & Record',
            icon: Icons.alarm_on_rounded,
            type: SomnaButtonType.primary,
            borderRadius: 14,
            height: 48,
            onPressed: onWakeUp,
          ),
        ],
      ),
    );
  }
}
