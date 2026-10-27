import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracker/app/theme/app_theme.dart';
import 'package:sleep_tracker/features/sleep_tracking/presentation/manual_entry_screen.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/models/user_preferences.dart';
import 'package:sleep_tracker/shared/providers/settings_provider.dart';
import 'package:sleep_tracker/shared/providers/sleep_tracker_provider.dart';
import 'package:sleep_tracker/shared/repositories/preferences_repository.dart';
import 'package:sleep_tracker/shared/repositories/sleep_repository.dart';

class MockSleepRepository implements SleepRepository {
  final List<SleepSession> sessions = [];

  @override
  Future<void> createSession(SleepSession session) async =>
      sessions.add(session);
  @override
  Future<void> updateSession(SleepSession session) async {}
  @override
  Future<void> deleteSession(String id) async {}
  @override
  Future<List<SleepSession>> getAllSessions() async => sessions;
  @override
  Future<SleepSession?> getActiveSession() async => null;
  @override
  Future<SleepSession?> getSessionById(String id) async => null;
  @override
  Future<List<SleepSession>> getSessionsBetween(
          DateTime start, DateTime end) async =>
      [];
  @override
  Future<bool> hasOverlappingSession(DateTime start, DateTime end,
          {String? excludeId}) async =>
      false;
  @override
  Future<void> clearAllSessions() async => sessions.clear();
}

class MockPreferencesRepository implements PreferencesRepository {
  @override
  Future<UserPreferences> loadPreferences() async => const UserPreferences();
  @override
  Future<void> savePreferences(UserPreferences preferences) async {}
  @override
  Future<void> setOnboardingCompleted(bool completed) async {}
  @override
  Future<void> resetAll() async {}
}

void main() {
  testWidgets('ManualEntryScreen renders duration preview and pickers',
      (tester) async {
    final sleepRepo = MockSleepRepository();
    final prefsRepo = MockPreferencesRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => SettingsProvider(prefsRepo: prefsRepo)),
          ChangeNotifierProvider(
              create: (_) => SleepTrackerProvider(sleepRepo: sleepRepo)),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const ManualEntryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Record Sleep'), findsOneWidget);
    expect(find.text('BEDTIME (SLEEP START)'), findsOneWidget);
    expect(find.text('WAKE-UP TIME (SLEEP END)'), findsOneWidget);
    expect(find.text('Save Session'), findsOneWidget);

    // Scroll and Tap Save Session
    await tester.ensureVisible(find.text('Save Session'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Session'));
    await tester.pumpAndSettle();

    // Verify session was added to repository
    expect(sleepRepo.sessions.isNotEmpty, isTrue);
  });
}
