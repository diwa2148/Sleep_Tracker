import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/models/sleep_stats.dart';

/// 1980s Mechanical Banking & Dot-Matrix Sleep Debt Ledger Card.
/// Calculates cumulative sleep deficit, reserve liquidity run-rate, and daily debit/credit tallies.
class SleepDebtLedgerCard extends StatelessWidget {
  final SleepStats stats;
  final int sleepGoalMinutes;

  const SleepDebtLedgerCard({
    super.key,
    required this.stats,
    required this.sleepGoalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalDebtMinutes = stats.sleepDebtMinutes;

    // Net balance across recorded days (sum of daily diffs: actual - goal)
    final recordedDays =
        stats.dailySummaries.where((d) => d.durationMinutes > 0).toList();
    final netDiffMinutes = recordedDays.fold<int>(
      0,
      (sum, d) => sum + (d.durationMinutes - sleepGoalMinutes),
    );

    final isSolvent = netDiffMinutes >= 0;
    final absNet = netDiffMinutes.abs();
    final netHours = absNet ~/ 60;
    final netRemainingMins = absNet % 60;
    final formattedBalance =
        '${isSolvent ? '+' : '-'}${netHours}h ${netRemainingMins.toString().padLeft(2, '0')}m';

    // Solvency score: 100% when meeting or exceeding goal, scaling down with debt
    final solvencyScore =
        (100.0 - (totalDebtMinutes / 6.0)).clamp(0.0, 100.0).round();

    return SomnaCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 4,
      border: Border.all(
        color: isDark ? const Color(0xFF2B3346) : const Color(0xFFD5CCBF),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SLEEP DEBT & RESERVE LEDGER',
                    style: AppTypography.labelSmall(isDark).copyWith(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSolvent
                      ? (isDark
                          ? const Color(0xFF1E3A24)
                          : const Color(0xFFE8F5E9))
                      : (isDark
                          ? const Color(0xFF381E1E)
                          : const Color(0xFFFFEBEE)),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: isSolvent
                        ? (isDark
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFA5D6A7))
                        : (isDark
                            ? const Color(0xFFC62828)
                            : const Color(0xFFEF9A9A)),
                  ),
                ),
                child: Text(
                  isSolvent ? 'SOLVENT' : 'DEFICIT',
                  style: TextStyle(
                    color: isSolvent
                        ? (isDark
                            ? const Color(0xFF81C784)
                            : const Color(0xFF2E7D32))
                        : (isDark
                            ? const Color(0xFFE57373)
                            : const Color(0xFFC62828)),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.fontFamily,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Balance Display & Payoff Run-Rate
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161922) : const Color(0xFFF4EFE6),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF232A3B) : const Color(0xFFE2DACF),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NET RESERVE BALANCE',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedBalance,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SOLVENCY INDEX',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$solvencyScore%',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Recovery Guidance Note
          _buildRecoveryGuidance(isDark, totalDebtMinutes, recordedDays.length),
          const SizedBox(height: 14),

          // Daily Accounting Ledger Table
          Text(
            'RECORDED DAILY TALLIES',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          // Table Header
          _buildTableHeader(isDark),
          const SizedBox(height: 4),

          // Rows
          ...recordedDays.reversed
              .take(7)
              .map((d) => _buildTableRow(d, isDark)),

          if (recordedDays.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'No sessions recorded for ledger',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecoveryGuidance(
      bool isDark, int debtMinutes, int recordedCount) {
    String message;
    if (debtMinutes <= 0) {
      message =
          'Optimal reserve: Sleep balance fully solvent. Baseline sleep goal maintained.';
    } else {
      final hours = debtMinutes ~/ 60;
      final mins = debtMinutes % 60;
      final debtStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
      final nightsToClear = (debtMinutes / 45).ceil().clamp(1, 14);
      message =
          'Cumulative deficit: $debtStr. Adding +45m sleep nightly liquidates this debt in ~$nightsToClear night${nightsToClear > 1 ? 's' : ''}.';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          debtMinutes <= 0
              ? Icons.check_circle_outline_rounded
              : Icons.info_outline_rounded,
          size: 14,
          color: isDark ? AppColors.primary : AppColors.primaryDark,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              height: 1.35,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222D) : const Color(0xFFEBE5DC),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'DATE',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'ACTUAL',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'TARGET',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'NET TALLY',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(DailySleepSummary summary, bool isDark) {
    final diff = summary.durationMinutes - sleepGoalMinutes;
    final isSurplus = diff >= 0;
    final absDiff = diff.abs();
    final diffHours = absDiff ~/ 60;
    final diffMins = absDiff % 60;
    final diffStr = diffHours > 0
        ? '${isSurplus ? '+' : '-'}${diffHours}h ${diffMins}m'
        : '${isSurplus ? '+' : '-'}${diffMins}m';

    final actualHours = summary.durationMinutes ~/ 60;
    final actualMins = summary.durationMinutes % 60;
    final actualStr = actualHours > 0
        ? '${actualHours}h ${actualMins}m'
        : '${actualMins}m';

    final targetHours = sleepGoalMinutes ~/ 60;
    final targetMins = sleepGoalMinutes % 60;
    final targetStr = targetHours > 0
        ? '${targetHours}h ${targetMins}m'
        : '${targetMins}m';

    final month = summary.date.month;
    final day = summary.date.day;
    final dateStr = '$month/$day';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E222D) : const Color(0xFFEBE5DC),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              dateStr,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              actualStr,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF333333),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              targetStr,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF888888) : const Color(0xFF888888),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              diffStr,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSurplus
                    ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
                    : (isDark ? const Color(0xFFE57373) : const Color(0xFFC62828)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
