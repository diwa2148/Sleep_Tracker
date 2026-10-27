import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/services/export_service.dart';

void main() {
  group('ExportService RFC-4180 CSV & JSON Tests', () {
    final now = DateTime(2026, 10, 26, 8, 0);

    test(
        'Generates RFC-4180 compliant CSV escaping commas, quotes, and newlines in notes',
        () {
      final session = SleepSession(
        id: 'test_123',
        startTimestamp: DateTime.utc(2026, 10, 25, 23, 0),
        endTimestamp: DateTime.utc(2026, 10, 26, 7, 0),
        qualityRating: 4,
        notes: 'Read "Atomic Habits", had tea,\nwent to sleep.',
        source: 'manual',
        createdAt: now,
        updatedAt: now,
      );

      final csv = ExportService.generateCsv([session]);
      final lines = csv.split('\n');

      expect(lines.first.trim(),
          'ID,Start Time (UTC),End Time (UTC),Duration (Minutes),Duration Formatted,Quality Rating,Source,Notes');

      // Check escaped cell for quotes and newline
      expect(
          csv, contains('"Read ""Atomic Habits"", had tea,\nwent to sleep."'));
    });

    test('Generates valid JSON structure with metadata', () {
      final session = SleepSession(
        id: 'json_1',
        startTimestamp: DateTime.utc(2026, 10, 25, 22, 0),
        endTimestamp: DateTime.utc(2026, 10, 26, 6, 0),
        qualityRating: 5,
        source: 'timer',
        createdAt: now,
        updatedAt: now,
      );

      final jsonStr = ExportService.generateJson([session]);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded['application'], 'SOMNA');
      expect(decoded['totalSessions'], 1);
      final sessionsList = decoded['sessions'] as List;
      expect(sessionsList.length, 1);
      expect(sessionsList.first['id'], 'json_1');
      expect(sessionsList.first['durationMinutes'], 480);
    });
  });
}
