import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/app/theme/app_theme.dart';
import 'package:sleep_tracker/features/analytics/presentation/widgets/sleep_debt_ledger_card.dart';
import 'package:sleep_tracker/shared/models/sleep_stats.dart';

void main() {
  group('SleepDebtLedgerCard Widget Tests', () {
    testWidgets('Renders solvent sleep debt ledger with positive surplus balance',
        (tester) async {
      final now = DateTime(2026, 10, 31);
      final stats = SleepStats(
        totalSessions: 3,
        averageDurationMinutes: 500,
        goalCompletionPercentage: 100.0,
        durationVariabilityMinutes: 10.0,
        bedtimeConsistencyScore: 95,
        sleepDebtMinutes: 0,
        dailySummaries: [
          DailySleepSummary(
            date: now.subtract(const Duration(days: 2)),
            durationMinutes: 500, // 8h 20m vs 8h (480m) -> +20m
            metGoal: true,
          ),
          DailySleepSummary(
            date: now.subtract(const Duration(days: 1)),
            durationMinutes: 510, // 8h 30m vs 8h (480m) -> +30m
            metGoal: true,
          ),
          DailySleepSummary(
            date: now,
            durationMinutes: 490, // 8h 10m vs 8h (480m) -> +10m
            metGoal: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SleepDebtLedgerCard(
              stats: stats,
              sleepGoalMinutes: 480, // 8h
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SLEEP DEBT & RESERVE LEDGER'), findsOneWidget);
      expect(find.text('SOLVENT'), findsOneWidget);
      expect(find.text('NET RESERVE BALANCE'), findsOneWidget);
      expect(find.text('+1h 00m'), findsOneWidget); // +20 + 30 + 10 = +60m = +1h 00m
      expect(find.text('SOLVENCY INDEX'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('RECORDED DAILY TALLIES'), findsOneWidget);
    });

    testWidgets('Renders deficit status when sleep debt exists',
        (tester) async {
      final now = DateTime(2026, 10, 31);
      final stats = SleepStats(
        totalSessions: 2,
        averageDurationMinutes: 420,
        goalCompletionPercentage: 50.0,
        durationVariabilityMinutes: 20.0,
        bedtimeConsistencyScore: 80,
        sleepDebtMinutes: 120, // 2 hours debt
        dailySummaries: [
          DailySleepSummary(
            date: now.subtract(const Duration(days: 1)),
            durationMinutes: 420, // 7h vs 8h (480m) -> -60m
            metGoal: false,
          ),
          DailySleepSummary(
            date: now,
            durationMinutes: 420, // 7h vs 8h (480m) -> -60m
            metGoal: false,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SleepDebtLedgerCard(
              stats: stats,
              sleepGoalMinutes: 480, // 8h
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DEFICIT'), findsOneWidget);
      expect(find.text('-2h 00m'), findsOneWidget);
      expect(find.textContaining('Cumulative deficit: 2h 0m'), findsOneWidget);
    });
  });
}

