import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/glitter_sparkle_overlay.dart';
import '../../../../core/widgets/somna_button.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/models/sleep_session.dart';

/// Card displayed prominently on the dashboard when a live sleep session is being tracked.
/// Modernized with celestial starlight glitter, glowing cosmic gradient, and pulsing aurora indicators.
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
    const dotColor = AppColors.positive;

    return SomnaCard(
      gradient: LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF1E1B4B), // Deep Cosmic Indigo
                const Color(0xFF0F172A), // Slate Obsidian
              ]
            : [
                const Color(0xFFEEF2FF),
                const Color(0xFFFFFFFF),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: isDark
            ? const Color(0xFF8B5CF6).withValues(alpha: 0.35)
            : const Color(0xFF6366F1).withValues(alpha: 0.3),
        width: 1.5,
      ),
      padding: EdgeInsets.zero,
      borderRadius: 22,
      child: Stack(
        children: [
          // Ambient Celestial Glitter Sparkles
          const Positioned.fill(
            child: GlitterSparkleOverlay(
              particleCount: 16,
              maxStarSize: 8.0,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header with pulsating live recording pill & close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: dotColor.withValues(alpha: isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: dotColor.withValues(alpha: 0.4),
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
                                  color: dotColor.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'SLEEP TRACKING ACTIVE',
                            style: AppTypography.labelSmall(isDark).copyWith(
                              color: isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF059669),
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

                // Digital Timer Readout Container with subtle inner glow
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF090D16).withValues(alpha: 0.75)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF8B5CF6).withValues(alpha: 0.25)
                          : const Color(0xFF6366F1).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateTimeFormatter.formatTimer(elapsedDuration),
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF0F172A),
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
                                ? AppColors.secondaryLight
                                : AppColors.secondaryDark,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Started at ${DateTimeFormatter.formatTime(activeSession.startTimestamp.toLocal())}',
                            style: AppTypography.bodySmall(isDark).copyWith(
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
                ),
                const SizedBox(height: 18),

                // Action Button with Modern Gradient Aura
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
          ),
        ],
      ),
    );
  }
}
