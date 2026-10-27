import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';

void main() {
  group('SleepSession Model Tests', () {
    final now = DateTime(2026, 10, 26, 8, 0);

    test('Identifies active vs completed session', () {
      final active = SleepSession(
        id: '1',
        startTimestamp: now.subtract(const Duration(hours: 8)),
        endTimestamp: null,
        createdAt: now,
        updatedAt: now,
      );
      expect(active.isActive, isTrue);

      final completed = active.copyWith(endTimestamp: now);
      expect(completed.isActive, isFalse);
    });

    test('Computes duration and formatted strings correctly', () {
      final session = SleepSession(
        id: '2',
        startTimestamp: DateTime(2026, 10, 25, 23, 15),
        endTimestamp: DateTime(2026, 10, 26, 7, 30), // 8h 15m
        createdAt: now,
        updatedAt: now,
      );
      expect(session.durationMinutes(), 495);
      expect(session.formattedDuration(), '8h 15m');
      expect(session.isOvernight, isTrue);
    });

    test('Serializes to and from SQLite Map with UTC timestamps', () {
      final session = SleepSession(
        id: '3',
        startTimestamp: DateTime(2026, 10, 25, 22, 30),
        endTimestamp: DateTime(2026, 10, 26, 6, 45),
        qualityRating: 5,
        notes: 'Had chamomile tea, read 20 mins',
        source: 'manual',
        createdAt: now,
        updatedAt: now,
      );

      final map = session.toMap();
      expect(map['id'], '3');
      expect(map['quality_rating'], 5);
      expect(map['notes'], 'Had chamomile tea, read 20 mins');

      final reconstructed = SleepSession.fromMap(map);
      expect(reconstructed.id, session.id);
      expect(reconstructed.startTimestamp.millisecondsSinceEpoch,
          session.startTimestamp.millisecondsSinceEpoch);
      expect(reconstructed.endTimestamp?.millisecondsSinceEpoch,
          session.endTimestamp?.millisecondsSinceEpoch);
      expect(reconstructed.qualityRating, 5);
      expect(reconstructed.notes, session.notes);
      expect(reconstructed.source, 'manual');
    });

    test('Enforces quality rating boundary [1, 5]', () {
      expect(
        () => SleepSession(
          id: '4',
          startTimestamp: now,
          qualityRating: 6,
          createdAt: now,
          updatedAt: now,
        ),
        throwsArgumentError,
      );

      expect(
        () => SleepSession(
          id: '5',
          startTimestamp: now,
          qualityRating: 0,
          createdAt: now,
          updatedAt: now,
        ),
        throwsArgumentError,
      );
    });
  });
}
