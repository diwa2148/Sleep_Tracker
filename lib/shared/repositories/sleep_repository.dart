import '../models/sleep_session.dart';
import '../services/database_service.dart';

/// Repository interface and implementation for SleepSession data operations.
abstract class SleepRepository {
  Future<void> createSession(SleepSession session);
  Future<void> updateSession(SleepSession session);
  Future<void> deleteSession(String id);
  Future<SleepSession?> getSessionById(String id);
  Future<SleepSession?> getActiveSession();
  Future<List<SleepSession>> getAllSessions();
  Future<List<SleepSession>> getSessionsBetween(DateTime start, DateTime end);
  Future<bool> hasOverlappingSession(DateTime start, DateTime end,
      {String? excludeId});
  Future<void> clearAllSessions();
}

/// SQLite-backed implementation of [SleepRepository].
class SqliteSleepRepository implements SleepRepository {
  final DatabaseService _dbService;

  SqliteSleepRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  @override
  Future<void> createSession(SleepSession session) =>
      _dbService.insertSession(session);

  @override
  Future<void> updateSession(SleepSession session) =>
      _dbService.updateSession(session);

  @override
  Future<void> deleteSession(String id) => _dbService.deleteSession(id);

  @override
  Future<SleepSession?> getSessionById(String id) =>
      _dbService.getSessionById(id);

  @override
  Future<SleepSession?> getActiveSession() => _dbService.getActiveSession();

  @override
  Future<List<SleepSession>> getAllSessions() => _dbService.getAllSessions();

  @override
  Future<List<SleepSession>> getSessionsBetween(DateTime start, DateTime end) =>
      _dbService.getSessionsBetween(start, end);

  @override
  Future<bool> hasOverlappingSession(DateTime start, DateTime end,
          {String? excludeId}) =>
      _dbService.hasOverlappingSession(start, end, excludeId: excludeId);

  @override
  Future<void> clearAllSessions() => _dbService.clearAllSessions();
}
