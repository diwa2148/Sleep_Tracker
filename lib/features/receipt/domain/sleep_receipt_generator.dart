import 'package:intl/intl.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../shared/models/sleep_session.dart';
import '../../../shared/models/sleep_stats.dart';
import '../../../shared/models/user_preferences.dart';
import '../../../shared/services/analytics_service.dart';

/// Formats sleep session data and weekly stats into a retro dot-matrix thermal register receipt.
class SleepReceiptGenerator {
  SleepReceiptGenerator._();

  static String generateTextReceipt({
    required List<SleepSession> sessions,
    required SleepStats stats,
    required UserPreferences preferences,
  }) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final timeStr = DateFormat('HH:mm').format(now);

    final totalMinutes = sessions.fold<int>(
      0,
      (sum, s) => sum + s.durationMinutes(),
    );
    final totalHours = totalMinutes ~/ 60;
    final remMins = totalMinutes % 60;
    final totalDurationStr = '${totalHours}h ${remMins}m';

    final correlations = AnalyticsService.computeFactorCorrelations(sessions);

    final buffer = StringBuffer();
    buffer.writeln('====================================');
    buffer.writeln('      SOMNA SLEEP CLINIC & LAB      ');
    buffer.writeln('    * * * 8-BIT BIO-STATION * * *   ');
    buffer.writeln('====================================');
    buffer.writeln('DATE: $dateStr       TIME: $timeStr');
    buffer.writeln('TERMINAL: ST-84        SYS: HI-FI OS');
    buffer.writeln('------------------------------------');
    buffer.writeln('QTY  METRIC                     STAT');
    buffer.writeln('------------------------------------');

    final sessionCountStr = sessions.length.toString().padLeft(2, '0');
    buffer.writeln('$sessionCountStr   SESSIONS RECORDED     ${sessions.length} SESS');

    final consistencyStr = stats.hasData
        ? '${stats.bedtimeConsistencyScore}%'
        : '100%';
    buffer.writeln('01   CIRCADIAN STABILITY     $consistencyStr');

    final avgDurationStr = stats.hasData
        ? stats.formattedAverageDuration
        : (sessions.isNotEmpty ? DateTimeFormatter.formatMinutes(totalMinutes ~/ sessions.length) : '0h 00m');
    buffer.writeln('01   7-DAY AVG DURATION     $avgDurationStr');

    final goalStr = preferences.formattedSleepGoal;
    buffer.writeln('01   DAILY TARGET GOAL      $goalStr');

    final efficiencyStr = stats.hasData
        ? '${stats.sleepEfficiencyPercentage}%'
        : '92%';
    buffer.writeln('01   REST EFFICIENCY         $efficiencyStr');

    final debtStr = stats.hasData ? stats.formattedSleepDebt : '0m';
    buffer.writeln('01   CUMULATIVE SLEEP DEBT    $debtStr');

    if (correlations.isNotEmpty) {
      buffer.writeln('------------------------------------');
      buffer.writeln('HABIT FACTOR ADJUSTMENTS:');
      for (final c in correlations.take(4)) {
        final sign = c.durationDiffMinutes >= 0 ? '+' : '-';
        final mins = c.durationDiffMinutes.abs();
        final label = c.factor.label.padRight(18);
        buffer.writeln(' [$sign] $label $sign${mins}m');
      }
    }

    buffer.writeln('------------------------------------');
    buffer.writeln('TOTAL LOGGED SLEEP:         $totalDurationStr');
    final status = stats.bedtimeConsistencyScore >= 80 ? 'OPTIMAL' : 'MODERATE';
    buffer.writeln('SYSTEM RECOVERY STATE:       $status');
    buffer.writeln('====================================');
    buffer.writeln('  THANK YOU FOR SLEEPING WITH SOMNA ');
    buffer.writeln('      * * * REST WELL * * *         ');
    buffer.writeln('====================================');
    buffer.writeln('||| || |||| | ||| |||| || | |||| |||');
    buffer.writeln('           * SOMNA-84-LAB *         ');

    return buffer.toString();
  }
}
