import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/features/receipt/domain/sleep_receipt_generator.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/models/user_preferences.dart';
import 'package:sleep_tracker/shared/services/analytics_service.dart';

void main() {
  group('SleepReceiptGenerator Tests', () {
    test('generateTextReceipt formats ASCII register ticket with stats', () {
      final now = DateTime(2026, 10, 26, 8, 0);

      final sessions = [
        SleepSession(
          id: 's1',
          startTimestamp: now.subtract(const Duration(hours: 8)),
          endTimestamp: now,
          qualityRating: 5,
          notes: '🧘 Meditated, ❄️ Cool Room, Restful',
          createdAt: now,
          updatedAt: now,
        ),
        SleepSession(
          id: 's2',
          startTimestamp: now.subtract(const Duration(days: 1, hours: 8)),
          endTimestamp: now.subtract(const Duration(days: 1)),
          qualityRating: 4,
          notes: '🏃 Workout',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final stats = AnalyticsService.computeStats(
        sessions: sessions,
        sleepGoalMinutes: 480,
      );
      const preferences = UserPreferences(sleepGoalMinutes: 480);

      final receipt = SleepReceiptGenerator.generateTextReceipt(
        sessions: sessions,
        stats: stats,
        preferences: preferences,
      );

      expect(receipt, contains('SOMNA SLEEP CLINIC & LAB'));
      expect(receipt, contains('TERMINAL: ST-84'));
      expect(receipt, contains('02   SESSIONS RECORDED'));
      expect(receipt, contains('TOTAL LOGGED SLEEP:'));
      expect(receipt, contains('SOMNA-84-LAB'));
    });
  });
}
