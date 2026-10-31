import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/features/achievements/domain/badge_engine.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/services/analytics_service.dart';

void main() {
  group('BadgeEngine Milestone Tests', () {
    test('Evaluates 6 achievement badges with accurate unlocks', () {
      final now = DateTime(2026, 10, 26, 8, 0);

      // Create 5 completed sessions
      final sessions = [
        SleepSession(
          id: 's1',
          startTimestamp: now.subtract(const Duration(hours: 9)),
          endTimestamp: now,
          qualityRating: 5,
          notes: '🧘 Meditated, ❄️ Cool Room',
          createdAt: now,
          updatedAt: now,
        ),
        SleepSession(
          id: 's2',
          startTimestamp: now.subtract(const Duration(days: 1, hours: 8)),
          endTimestamp: now.subtract(const Duration(days: 1)),
          qualityRating: 4,
          notes: '🧘 Meditated, feeling calm',
          createdAt: now,
          updatedAt: now,
        ),
        SleepSession(
          id: 's3',
          startTimestamp: now.subtract(const Duration(days: 2, hours: 7)),
          endTimestamp: now.subtract(const Duration(days: 2)),
          qualityRating: 4,
          notes: 'Regular rest',
          createdAt: now,
          updatedAt: now,
        ),
        SleepSession(
          id: 's4',
          startTimestamp: now.subtract(const Duration(days: 3, hours: 8)),
          endTimestamp: now.subtract(const Duration(days: 3)),
          qualityRating: 4,
          notes: '❄️ Cool Room',
          createdAt: now,
          updatedAt: now,
        ),
        SleepSession(
          id: 's5',
          startTimestamp: now.subtract(const Duration(days: 4, hours: 8)),
          endTimestamp: now.subtract(const Duration(days: 4)),
          qualityRating: 4,
          notes: 'Good sleep',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final stats = AnalyticsService.computeStats(
        sessions: sessions,
        sleepGoalMinutes: 480,
      );

      final badges = BadgeEngine.evaluateBadges(
        sessions: sessions,
        stats: stats,
      );

      expect(badges.length, equals(6));

      // 5 sessions logged -> Night Pioneer unlocked
      final pioneer = badges.firstWhere((b) => b.id == 'night_pioneer');
      expect(pioneer.isUnlocked, isTrue);

      // 2 meditation sessions logged -> Zen Protocol unlocked
      final zen = badges.firstWhere((b) => b.id == 'zen_protocol');
      expect(zen.isUnlocked, isTrue);

      // 2 cool room sessions logged -> Cryo Chamber unlocked
      final cryo = badges.firstWhere((b) => b.id == 'cryo_chamber');
      expect(cryo.isUnlocked, isTrue);

      // 9 hour 5-star session logged -> Battery Overcharge unlocked
      final overcharge = badges.firstWhere((b) => b.id == 'battery_overcharge');
      expect(overcharge.isUnlocked, isTrue);
    });
  });
}

