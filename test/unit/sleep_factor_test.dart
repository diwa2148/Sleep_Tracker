import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/shared/models/sleep_factor.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/services/analytics_service.dart';

void main() {
  group('SleepFactor and Session Tag Tests', () {
    test('SleepFactor.all contains 8 lifestyle tags', () {
      expect(SleepFactor.all.length, equals(8));
      expect(SleepFactor.all.any((f) => f.label == '☕ Caffeine'), isTrue);
      expect(SleepFactor.all.any((f) => f.label == '🏃 Workout'), isTrue);
      expect(SleepFactor.all.any((f) => f.label == '📱 Late Screen'), isTrue);
    });

    test('SleepSession tags extracts factors from notes correctly', () {
      final now = DateTime.now();
      final session = SleepSession(
        id: 's1',
        startTimestamp: now.subtract(const Duration(hours: 8)),
        endTimestamp: now,
        notes: '☕ Caffeine, 🏃 Workout, feeling great',
        createdAt: now,
        updatedAt: now,
      );

      final tags = session.tags;
      expect(tags, contains('☕ Caffeine'));
      expect(tags, contains('🏃 Workout'));
      expect(tags, isNot(contains('📱 Late Screen')));
    });

    test('SleepSession tags returns empty list for session without notes', () {
      final now = DateTime.now();
      final session = SleepSession(
        id: 's2',
        startTimestamp: now.subtract(const Duration(hours: 7)),
        endTimestamp: now,
        notes: null,
        createdAt: now,
        updatedAt: now,
      );

      expect(session.tags, isEmpty);
    });
  });

  group('AnalyticsService computeFactorCorrelations Tests', () {
    test('Calculates positive and negative correlations accurately', () {
      final base = DateTime(2026, 10, 20, 23, 0);

      final sessions = [
        // 2 sessions with workout (8 hours = 480 mins, quality 5)
        SleepSession(
          id: 'w1',
          startTimestamp: base,
          endTimestamp: base.add(const Duration(hours: 8)),
          qualityRating: 5,
          notes: '🏃 Workout, high energy',
          createdAt: base,
          updatedAt: base,
        ),
        SleepSession(
          id: 'w2',
          startTimestamp: base.add(const Duration(days: 1)),
          endTimestamp: base.add(const Duration(days: 1, hours: 8)),
          qualityRating: 5,
          notes: '🏃 Workout',
          createdAt: base,
          updatedAt: base,
        ),
        // 2 sessions without workout (6 hours = 360 mins, quality 3)
        SleepSession(
          id: 'nw1',
          startTimestamp: base.add(const Duration(days: 2)),
          endTimestamp: base.add(const Duration(days: 2, hours: 6)),
          qualityRating: 3,
          notes: 'Regular night',
          createdAt: base,
          updatedAt: base,
        ),
        SleepSession(
          id: 'nw2',
          startTimestamp: base.add(const Duration(days: 3)),
          endTimestamp: base.add(const Duration(days: 3, hours: 6)),
          qualityRating: 3,
          notes: 'Regular night 2',
          createdAt: base,
          updatedAt: base,
        ),
      ];

      final correlations = AnalyticsService.computeFactorCorrelations(sessions);
      final workoutCorr =
          correlations.firstWhere((c) => c.factor.name == 'Workout');

      expect(workoutCorr.occurrences, equals(2));
      // With workout: 480m, Without workout: 360m -> Delta +120m
      expect(workoutCorr.durationDiffMinutes, equals(120));
      // With workout: 5.0, Without workout: 3.0 -> Delta +2.0
      expect(workoutCorr.qualityDiff, equals(2.0));
    });
  });
}
