import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/core/utils/time_calculator.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';

void main() {
  group('TimeCalculator Duration Tests', () {
    test('Calculates exact duration in minutes for standard daytime session',
        () {
      final start = DateTime(2026, 10, 25, 14, 0);
      final end = DateTime(2026, 10, 25, 15, 30);
      expect(TimeCalculator.durationMinutes(start, end), 90);
    });

    test('Calculates exact duration for session crossing midnight', () {
      final start = DateTime(2026, 10, 25, 23, 15);
      final end = DateTime(2026, 10, 26, 7, 0); // 7h 45m = 465 mins
      expect(TimeCalculator.durationMinutes(start, end), 465);
    });

    test('Calculates duration across multiple calendar days', () {
      final start = DateTime(2026, 10, 24, 22, 0);
      final end = DateTime(2026, 10, 26, 6, 0); // 32 hours = 1920 mins
      expect(TimeCalculator.durationMinutes(start, end), 1920);
    });
  });

  group('TimeCalculator Overlap Detection Tests', () {
    final session1Start = DateTime(2026, 10, 25, 23, 0);
    final session1End = DateTime(2026, 10, 26, 7, 0);

    test('Detects strict overlap when session B is inside session A', () {
      final bStart = DateTime(2026, 10, 26, 1, 0);
      final bEnd = DateTime(2026, 10, 26, 5, 0);
      expect(
          TimeCalculator.doSessionsOverlap(
              session1Start, session1End, bStart, bEnd),
          isTrue);
    });

    test(
        'Detects overlap when session B starts before and ends during session A',
        () {
      final bStart = DateTime(2026, 10, 25, 22, 0);
      final bEnd = DateTime(2026, 10, 26, 2, 0);
      expect(
          TimeCalculator.doSessionsOverlap(
              session1Start, session1End, bStart, bEnd),
          isTrue);
    });

    test(
        'Detects overlap when session B starts during and ends after session A',
        () {
      final bStart = DateTime(2026, 10, 26, 6, 0);
      final bEnd = DateTime(2026, 10, 26, 9, 0);
      expect(
          TimeCalculator.doSessionsOverlap(
              session1Start, session1End, bStart, bEnd),
          isTrue);
    });

    test('Does NOT overlap when session B strictly precedes session A', () {
      final bStart = DateTime(2026, 10, 25, 14, 0);
      final bEnd = DateTime(2026, 10, 25, 22, 0);
      expect(
          TimeCalculator.doSessionsOverlap(
              session1Start, session1End, bStart, bEnd),
          isFalse);
    });

    test(
        'Does NOT overlap when session B begins exactly when session A ends (adjacent)',
        () {
      final bStart = DateTime(2026, 10, 26, 7, 0);
      final bEnd = DateTime(2026, 10, 26, 9, 0);
      expect(
          TimeCalculator.doSessionsOverlap(
              session1Start, session1End, bStart, bEnd),
          isFalse);
    });
  });

  group('TimeCalculator Circular Time Math Tests', () {
    test('Averages bedtimes clustering around midnight correctly', () {
      // 23:30 (1410 min) and 00:30 (30 min)
      // Linear mean would be (1410 + 30)/2 = 720 (12:00 PM noon - completely wrong!)
      // Circular mean must be 00:00 (midnight = 0 min)
      final bedtimes = [1410, 30];
      final avg = TimeCalculator.circularMeanMinutes(bedtimes);
      expect(avg, 0); // 00:00 midnight
    });

    test('Averages bedtimes of 23:45, 00:15, and 00:00 to 00:00', () {
      // 1425 (23:45), 15 (00:15), 0 (00:00)
      final bedtimes = [1425, 15, 0];
      final avg = TimeCalculator.circularMeanMinutes(bedtimes);
      expect(avg, 0);
    });

    test('Calculates circular consistency score of 100% for identical bedtimes',
        () {
      final now = DateTime(2026, 10, 26, 7, 0);
      final sessions = [
        SleepSession(
          id: '1',
          startTimestamp: DateTime(2026, 10, 24, 23, 0),
          endTimestamp: DateTime(2026, 10, 25, 7, 0),
          createdAt: now,
          updatedAt: now,
        ),
        SleepSession(
          id: '2',
          startTimestamp: DateTime(2026, 10, 25, 23, 0),
          endTimestamp: DateTime(2026, 10, 26, 7, 0),
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final score = TimeCalculator.calculateConsistencyScore(sessions);
      expect(score, 100);
    });
  });

  group('TimeCalculator Validation Tests', () {
    final fixedNow = DateTime(2026, 10, 26, 12, 0);

    test('Rejects wake time before bedtime', () {
      final start = DateTime(2026, 10, 26, 10, 0);
      final end = DateTime(2026, 10, 26, 8, 0);
      expect(TimeCalculator.validateSessionTimes(start, end, fixedNow),
          contains('after bedtime'));
    });

    test('Rejects future bedtime', () {
      final start = DateTime(2026, 10, 26, 14, 0); // 2 hours in future
      final end = DateTime(2026, 10, 26, 16, 0);
      expect(TimeCalculator.validateSessionTimes(start, end, fixedNow),
          contains('cannot be in the future'));
    });

    test('Rejects duration greater than 24 hours', () {
      final start = DateTime(2026, 10, 24, 8, 0);
      final end = DateTime(2026, 10, 25, 9, 0); // 25 hours
      expect(TimeCalculator.validateSessionTimes(start, end, fixedNow),
          contains('cannot exceed 24 hours'));
    });

    test('Accepts valid overnight session', () {
      final start = DateTime(2026, 10, 25, 23, 0);
      final end = DateTime(2026, 10, 26, 7, 0);
      expect(TimeCalculator.validateSessionTimes(start, end, fixedNow), isNull);
    });
  });
}
