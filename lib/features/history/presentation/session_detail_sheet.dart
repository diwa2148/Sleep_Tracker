import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/somna_button.dart';
import '../../../core/widgets/somna_card.dart';
import '../../../core/widgets/star_rating_bar.dart';
import '../../../shared/models/sleep_session.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/providers/sleep_tracker_provider.dart';
import '../../sleep_tracking/presentation/manual_entry_screen.dart';

/// Modal bottom sheet presenting complete session details, notes, and actions.
class SessionDetailSheet extends StatelessWidget {
  final SleepSession session;

  const SessionDetailSheet({super.key, required this.session});

  static Future<void> show(BuildContext context, SleepSession session) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SessionDetailSheet(session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tracker = context.read<SleepTrackerProvider>();
    final settings = context.read<SettingsProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 20),

          // Title & Relative Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateTimeFormatter.formatFullDate(session.startTimestamp),
                      style: AppTypography.titleLarge(isDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recorded via ${session.source}',
                      style: AppTypography.bodySmall(isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  session.formattedDuration(),
                  style: AppTypography.labelLarge(isDark).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bedtime and Wake-up Times Card
          SomnaCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeColumn('BEDTIME', session.startTimestamp,
                    Icons.nightlight_round, isDark),
                Container(
                  width: 1,
                  height: 36,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                _buildTimeColumn(
                  'WAKE UP',
                  session.endTimestamp ?? DateTime.now(),
                  Icons.wb_sunny_rounded,
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quality Rating
          if (session.qualityRating != null) ...[
            SomnaCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sleep Quality',
                      style: AppTypography.titleSmall(isDark)),
                  StarRatingBar(
                    rating: session.qualityRating,
                    readOnly: true,
                    starSize: 22,
                    onRatingChanged: (_) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Notes
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            Text('NOTES & OBSERVATIONS',
                style: AppTypography.labelSmall(isDark)),
            const SizedBox(height: 6),
            SomnaCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                session.notes!,
                style: AppTypography.bodyMedium(isDark),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Action Buttons: Edit and Delete
          Row(
            children: [
              Expanded(
                child: SomnaButton(
                  text: 'Edit Session',
                  icon: Icons.edit_rounded,
                  type: SomnaButtonType.secondary,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ManualEntryScreen(existingSession: session),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SomnaButton(
                  text: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  type: SomnaButtonType.destructive,
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      context: context,
                      title: 'Delete Session?',
                      message:
                          'Are you sure you want to delete this recorded session? This action cannot be undone.',
                      confirmText: 'Delete',
                      isDestructive: true,
                    );
                    if (confirmed && context.mounted) {
                      await tracker.deleteSession(
                          session.id, settings.preferences);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(
      String label, DateTime dt, IconData icon, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.labelSmall(isDark)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          DateTimeFormatter.formatTime(dt),
          style: AppTypography.titleMedium(isDark),
        ),
      ],
    );
  }
}
