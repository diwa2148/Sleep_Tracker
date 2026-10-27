import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/somna_button.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/models/sleep_session.dart';

/// Card displayed prominently on the dashboard when a live sleep session is being tracked.
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

    return SomnaCard(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF1E284A), const Color(0xFF12192F)]
            : [const Color(0xFFEDE9FE), const Color(0xFFF1F5F9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: AppColors.primary.withValues(alpha: 0.4),
        width: 1.5,
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          // Header with pulsating indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.positive,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.positive,
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SLEEP TRACKING ACTIVE',
                    style: AppTypography.labelSmall(isDark).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                tooltip: 'Cancel tracking',
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context: context,
                    title: 'Cancel Active Session?',
                    message:
                        'Are you sure you want to discard this sleep recording? Elapsed time will not be saved.',
                    confirmText: 'Discard',
                    isDestructive: true,
                  );
                  if (confirmed) onCancel();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Elapsed Duration
          Text(
            DateTimeFormatter.formatTimer(elapsedDuration),
            style: AppTypography.statNumber(isDark, fontSize: 44).copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Started at ${DateTimeFormatter.formatTime(activeSession.startTimestamp)}',
            style: AppTypography.bodySmall(isDark).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 22),

          // Primary Wake Up Action
          SomnaButton(
            text: 'Wake Up & Record',
            icon: Icons.wb_sunny_rounded,
            width: double.infinity,
            onPressed: onWakeUp,
          ),
        ],
      ),
    );
  }
}
