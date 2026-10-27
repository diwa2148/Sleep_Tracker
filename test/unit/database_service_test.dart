import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/services/database_service.dart';

void main() {
  late Database inMemoryDb;
  late DatabaseService dbService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    inMemoryDb = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE sleep_sessions (
              id TEXT PRIMARY KEY,
              start_timestamp INTEGER NOT NULL,
              end_timestamp INTEGER,
              quality_rating INTEGER,
              notes TEXT,
              source TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
          await db.execute(
            'CREATE INDEX idx_sleep_sessions_start ON sleep_sessions(start_timestamp DESC)',
          );
          await db.execute(
            'CREATE INDEX idx_sleep_sessions_end ON sleep_sessions(end_timestamp DESC)',
          );
        },
      ),
    );

    dbService = DatabaseService.instance;
    DatabaseService.setMockDatabase(inMemoryDb);
  });

  tearDown(() async {
    await inMemoryDb.close();
  });

  group('DatabaseService SQLite CRUD & Query Tests', () {
    final now = DateTime(2026, 10, 26, 8, 0);

    test('Creates, reads, updates, and deletes a sleep session', () async {
      final session = SleepSession(
        id: 'test_db_1',
        startTimestamp: DateTime(2026, 10, 25, 23, 0),
        endTimestamp: DateTime(2026, 10, 26, 7, 0),
        qualityRating: 4,
        notes: 'Peaceful night',
        source: 'manual',
        createdAt: now,
        updatedAt: now,
      );

      // Create
      await dbService.insertSession(session);

      // Read
      final fetched = await dbService.getSessionById('test_db_1');
      expect(fetched, isNotNull);
      expect(fetched!.id, 'test_db_1');
      expect(fetched.qualityRating, 4);

      // Update
      final updated =
          fetched.copyWith(qualityRating: 5, notes: 'Updated notes');
      await dbService.updateSession(updated);

      final fetchedUpdated = await dbService.getSessionById('test_db_1');
      expect(fetchedUpdated!.qualityRating, 5);
      expect(fetchedUpdated.notes, 'Updated notes');

      // Delete
      await dbService.deleteSession('test_db_1');
      final fetchedDeleted = await dbService.getSessionById('test_db_1');
      expect(fetchedDeleted, isNull);
    });

    test('Persists and retrieves active session (end_timestamp IS NULL)',
        () async {
      final active = SleepSession(
        id: 'active_session_1',
        startTimestamp: DateTime(2026, 10, 25, 23, 30),
        endTimestamp: null,
        source: 'timer',
        createdAt: now,
        updatedAt: now,
      );

      await dbService.insertSession(active);

      final retrievedActive = await dbService.getActiveSession();
      expect(retrievedActive, isNotNull);
      expect(retrievedActive!.id, 'active_session_1');
      expect(retrievedActive.isActive, isTrue);
    });

    test('Detects overlapping sessions in SQLite query', () async {
      final existing = SleepSession(
        id: 'existing_1',
        startTimestamp: DateTime(2026, 10, 25, 22, 0),
        endTimestamp: DateTime(2026, 10, 26, 6, 0),
        source: 'manual',
        createdAt: now,
        updatedAt: now,
      );
      await dbService.insertSession(existing);

      // Propose overlapping: 23:00 to 07:00
      final overlaps = await dbService.hasOverlappingSession(
        DateTime(2026, 10, 25, 23, 0),
        DateTime(2026, 10, 26, 7, 0),
      );
      expect(overlaps, isTrue);

      // Propose non-overlapping: 14:00 to 16:00
      final nonOverlapping = await dbService.hasOverlappingSession(
        DateTime(2026, 10, 25, 14, 0),
        DateTime(2026, 10, 25, 16, 0),
      );
      expect(nonOverlapping, isFalse);
    });
  });
}
