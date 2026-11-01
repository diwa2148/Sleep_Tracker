import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/somna_button.dart';
import '../../../core/widgets/somna_card.dart';
import '../../../shared/models/sleep_session.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/providers/sleep_tracker_provider.dart';
import '../../sleep_tracking/presentation/manual_entry_screen.dart';
import '../../receipt/presentation/widgets/sleep_receipt_sheet.dart';
import 'session_detail_sheet.dart';

enum HistoryFilter { all, thisWeek, lastWeek, thisMonth }

/// The Sleep History screen presenting a chronological log of all sleep sessions,
/// filtering by timeframe, and providing full edit/delete workflows.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryFilter _currentFilter = HistoryFilter.all;

  List<SleepSession> _filterSessions(List<SleepSession> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_currentFilter) {
      case HistoryFilter.all:
        return sessions;
      case HistoryFilter.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return sessions
            .where((s) => s.startTimestamp.isAfter(startOfWeek))
            .toList();
      case HistoryFilter.lastWeek:
        final startOfThisWeek =
            today.subtract(Duration(days: today.weekday - 1));
        final startOfLastWeek =
            startOfThisWeek.subtract(const Duration(days: 7));
        return sessions.where((s) {
          return s.startTimestamp.isAfter(startOfLastWeek) &&
              s.startTimestamp.isBefore(startOfThisWeek);
        }).toList();
      case HistoryFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return sessions
            .where((s) => s.startTimestamp.isAfter(startOfMonth))
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tracker = context.watch<SleepTrackerProvider>();
    final settings = context.watch<SettingsProvider>();

    final allCompleted = tracker.completedSessions;
    final filteredSessions = _filterSessions(allCompleted);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Log sleep session',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManualEntryScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('All Time', HistoryFilter.all, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('This Week', HistoryFilter.thisWeek, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Last Week', HistoryFilter.lastWeek, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                      'This Month', HistoryFilter.thisMonth, isDark),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Dot-matrix receipt print banner
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Material(
                    color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        SleepReceiptSheet.show(
                          context: context,
                          sessions: allCompleted,
                          stats: tracker.weeklyStats,
                          preferences: settings.preferences,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.receipt_long_rounded,
                                      size: 18,
                                      color: isDark
                                          ? AppColors.primary
                                          : AppColors.primaryDark),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'DOT-MATRIX SLEEP TICKET',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.print_rounded,
                                      size: 11,
                                      color: isDark ? Colors.white : Colors.black),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PRINT',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : Colors.black,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Sessions List or Empty State
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: filteredSessions.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          itemCount: filteredSessions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final session = filteredSessions[index];
                            return _buildSessionCard(
                              context: context,
                              session: session,
                              isDark: isDark,
                              onTap: () =>
                                  SessionDetailSheet.show(context, session),
                              onDelete: () async {
                                final confirmed = await ConfirmDialog.show(
                                  context: context,
                                  title: 'Delete Session?',
                                  message:
                                      'Are you sure you want to permanently delete this sleep session?',
                                  confirmText: 'Delete',
                                  isDestructive: true,
                                );
                                if (confirmed && context.mounted) {
                                  await tracker.deleteSession(
                                      session.id, settings.preferences);
                                }
                              },
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, HistoryFilter filter, bool isDark) {
    final isSelected = _currentFilter == filter;

    return InkWell(
      onTap: () => setState(() => _currentFilter = filter),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary : AppColors.primaryDark)
              : (isDark ? AppColors.darkElevated : AppColors.lightElevated),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.primary : AppColors.primaryDark)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium(isDark).copyWith(
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard({
    required BuildContext context,
    required SleepSession session,
    required bool isDark,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final relativeDate = DateTimeFormatter.formatRelativeDay(
        session.endTimestamp ?? DateTime.now());
    final interval = DateTimeFormatter.formatSessionInterval(
        session.startTimestamp, session.endTimestamp);

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await ConfirmDialog.show(
          context: context,
          title: 'Delete Session?',
          message: 'Are you sure you want to delete this recorded session?',
          confirmText: 'Delete',
          isDestructive: true,
        );
        return confirmed;
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      child: SomnaCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date & Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    relativeDate,
                    style: AppTypography.titleMedium(isDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    session.formattedDuration(),
                    style: AppTypography.labelLarge(isDark).copyWith(
                      color: isDark ? AppColors.primary : AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Time Interval & Overnight Badge
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 14,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight),
                const SizedBox(width: 6),
                Text(
                  interval,
                  style: AppTypography.bodySmall(isDark),
                ),
                if (session.isOvernight) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF262626)
                          : const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Overnight',
                      style: AppTypography.labelSmall(isDark).copyWith(
                        fontSize: 10,
                        color: isDark
                            ? const Color(0xFFD4D4D4)
                            : const Color(0xFF262626),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Quality Rating & Notes preview
            if (session.qualityRating != null ||
                (session.notes != null && session.notes!.isNotEmpty)) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (session.qualityRating != null) ...[
                    Row(
                      children: List.generate(5, (index) {
                        final filled = index < session.qualityRating!;
                        return Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: filled
                              ? AppColors
                                  .ratingColors[session.qualityRating! - 1]
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (session.notes != null && session.notes!.isNotEmpty)
                    Expanded(
                      child: Text(
                        session.notes!,
                        style: AppTypography.bodySmall(isDark)
                            .copyWith(fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],

            // Factor Tags Badges
            if (session.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: session.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppTypography.fontFamily,
                        color: isDark
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFB45309),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'No Sleep Sessions Found',
              style: AppTypography.titleLarge(isDark),
            ),
            const SizedBox(height: 8),
            Text(
              _currentFilter == HistoryFilter.all
                  ? 'Your recorded sleep sessions will appear here chronologically.'
                  : 'No sleep entries found for the selected time filter.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(isDark),
            ),
            const SizedBox(height: 24),
            SomnaButton(
              text: 'Log Sleep Manually',
              icon: Icons.add_rounded,
              type: SomnaButtonType.secondary,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManualEntryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
