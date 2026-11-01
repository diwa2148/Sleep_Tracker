import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/models/sleep_session.dart';
import '../../../../shared/models/sleep_stats.dart';
import '../../domain/badge_engine.dart';
import '../../domain/models/sleep_badge.dart';

/// Retro cyberdeck achievement vault card displaying unlocked badges & progress.
class CyberdeckTrophyCard extends StatelessWidget {
  final List<SleepSession> sessions;
  final SleepStats stats;

  const CyberdeckTrophyCard({
    super.key,
    required this.sessions,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badges = BadgeEngine.evaluateBadges(
      sessions: sessions,
      stats: stats,
    );

    final unlockedCount = badges.where((b) => b.isUnlocked).length;
    final totalCount = badges.length;
    final unlockPercentage = ((unlockedCount / totalCount) * 100).round();

    return SomnaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Retro Tag & Category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.military_tech_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'CYBERDECK TROPHY VAULT',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLarge(isDark).copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.2,
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
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFEEF2F6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF333D50)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Text(
                  '$unlockedCount/$totalCount UNLOCKED • $unlockPercentage%',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: unlockedCount > 0
                        ? AppColors.positive
                        : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569)),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Bio-station milestone badges and healthy sleep achievements',
            style: AppTypography.bodySmall(isDark),
          ),
          const SizedBox(height: 12),

          // Total progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: unlockedCount / totalCount,
              minHeight: 6,
              backgroundColor: isDark
                  ? const Color(0xFF222838)
                  : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),

          // Responsive Grid of Badges
          LayoutBuilder(
            builder: (context, constraints) {
              int columns = 2;
              double aspectRatio = 1.85;

              if (constraints.maxWidth < 360) {
                columns = 1;
                aspectRatio = 2.1;
              } else if (constraints.maxWidth >= 720) {
                columns = 3;
                aspectRatio = 1.95;
              } else if (constraints.maxWidth >= 1000) {
                columns = 4;
                aspectRatio = 2.0;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: badges.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, index) {
                  return _buildBadgeTile(context, badges[index], isDark);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTile(
      BuildContext context, SleepBadge badge, bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            title: Row(
              children: [
                Icon(badge.icon,
                    color: badge.isUnlocked
                        ? AppColors.primary
                        : const Color(0xFF94A3B8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    badge.title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.description,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STATUS:',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                    Text(
                      badge.isUnlocked ? '● UNLOCKED' : '○ IN PROGRESS',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badge.isUnlocked
                            ? AppColors.positive
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PROGRESS:',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                    Text(
                      badge.progressLabel,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('DISMISS'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: badge.isUnlocked
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.08))
              : (isDark
                  ? const Color(0xFF131722)
                  : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: badge.isUnlocked
                ? AppColors.primary
                : (isDark
                    ? const Color(0xFF262E40)
                    : const Color(0xFFE2E8F0)),
            width: badge.isUnlocked ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: badge.isUnlocked
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : (isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.05)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge.icon,
                    size: 14,
                    color: badge.isUnlocked
                        ? AppColors.primary
                        : (isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8)),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: badge.isUnlocked
                        ? AppColors.positive.withValues(alpha: 0.15)
                        : (isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: badge.isUnlocked
                          ? AppColors.positive.withValues(alpha: 0.4)
                          : (isDark
                              ? const Color(0xFF333D50)
                              : const Color(0xFFCBD5E1)),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    badge.isUnlocked ? 'UNLOCKED' : badge.code,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: badge.isUnlocked
                          ? AppColors.positive
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: badge.isUnlocked
                        ? (isDark ? Colors.white : Colors.black)
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  badge.description,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PROGRESS',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        badge.progressLabel,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: badge.isUnlocked
                              ? AppColors.positive
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: badge.progress.clamp(0.0, 1.0),
                    minHeight: 3,
                    backgroundColor: isDark
                        ? const Color(0xFF1E2638)
                        : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      badge.isUnlocked
                          ? AppColors.positive
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
