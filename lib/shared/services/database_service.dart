import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../../app/app_config.dart';
import '../models/sleep_session.dart';

/// Database service managing SQLite storage for SOMNA.
/// Supports mobile, web, and desktop/unit-test environments via FFI.
class DatabaseService {
  static DatabaseService? _instance;
  Database? _db;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Optional custom database for testing.
  @visibleForTesting
  static void setMockDatabase(Database database) {
    instance._db = database;
  }

  /// Initializes and returns the SQLite database instance.
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String path;
    if (kIsWeb) {
      path = AppConfig.databaseName;
    } else {
      final dbPath = await getDatabasesPath();
      path = p.join(dbPath, AppConfig.databaseName);
    }

    return await openDatabase(
      path,
      version: AppConfig.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

    // Create indexes for efficient time-range querying and sorting
    await db.execute(
      'CREATE INDEX idx_sleep_sessions_start ON sleep_sessions(start_timestamp DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_sleep_sessions_end ON sleep_sessions(end_timestamp DESC)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration handling for future schema versions
  }

  // --- CRUD Operations ---

  /// Inserts a new sleep session.
  Future<void> insertSession(SleepSession session) async {
    final db = await database;
    await db.insert(
      'sleep_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing sleep session.
  Future<void> updateSession(SleepSession session) async {
    final db = await database;
    await db.update(
      'sleep_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  /// Deletes a session by ID.
  Future<void> deleteSession(String id) async {
    final db = await database;
    await db.delete(
      'sleep_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves a session by its unique ID.
  Future<SleepSession?> getSessionById(String id) async {
    final db = await database;
    final results = await db.query(
      'sleep_sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return SleepSession.fromMap(results.first);
  }

  /// Retrieves the currently active session (end_timestamp IS NULL), if any.
  Future<SleepSession?> getActiveSession() async {
    final db = await database;
    final results = await db.query(
      'sleep_sessions',
      where: 'end_timestamp IS NULL',
      orderBy: 'start_timestamp DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return SleepSession.fromMap(results.first);
  }

  /// Retrieves all recorded sessions sorted by start time descending.
  Future<List<SleepSession>> getAllSessions() async {
    final db = await database;
    final results = await db.query(
      'sleep_sessions',
      orderBy: 'start_timestamp DESC',
    );
    return results.map((map) => SleepSession.fromMap(map)).toList();
  }

  /// Retrieves completed sessions within a specified start date range.
  Future<List<SleepSession>> getSessionsBetween(
      DateTime start, DateTime end) async {
    final db = await database;
    final startMs = start.toUtc().millisecondsSinceEpoch;
    final endMs = end.toUtc().millisecondsSinceEpoch;

    final results = await db.query(
      'sleep_sessions',
      where:
          'start_timestamp >= ? AND start_timestamp <= ? AND end_timestamp IS NOT NULL',
      whereArgs: [startMs, endMs],
      orderBy: 'start_timestamp DESC',
    );
    return results.map((map) => SleepSession.fromMap(map)).toList();
  }

  /// Checks if any existing session overlaps with the interval [start, end].
  Future<bool> hasOverlappingSession(
    DateTime start,
    DateTime end, {
    String? excludeId,
  }) async {
    final db = await database;
    final startMs = start.toUtc().millisecondsSinceEpoch;
    final endMs = end.toUtc().millisecondsSinceEpoch;

    // Overlap condition: (s.start < end AND s.end > start)
    String whereClause =
        'start_timestamp < ? AND end_timestamp > ? AND end_timestamp IS NOT NULL';
    List<dynamic> whereArgs = [endMs, startMs];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final results = await db.query(
      'sleep_sessions',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    return results.isNotEmpty;
  }

  /// Clears all sleep sessions from the database.
  Future<void> clearAllSessions() async {
    final db = await database;
    await db.delete('sleep_sessions');
  }

  /// Closes database connection.
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
