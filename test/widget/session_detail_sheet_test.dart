import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracker/app/theme/app_theme.dart';
import 'package:sleep_tracker/core/widgets/star_rating_bar.dart';
import 'package:sleep_tracker/features/history/presentation/session_detail_sheet.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/models/user_preferences.dart';
import 'package:sleep_tracker/shared/providers/settings_provider.dart';
import 'package:sleep_tracker/shared/providers/sleep_tracker_provider.dart';
import 'package:sleep_tracker/shared/repositories/preferences_repository.dart';
import 'package:sleep_tracker/shared/repositories/sleep_repository.dart';

class MockSleepRepo implements SleepRepository {
  final List<SleepSession> sessions = [];

  @override
  Future<void> createSession(SleepSession session) async =>
      sessions.add(session);

  @override
  Future<void> updateSession(SleepSession session) async {
    final idx = sessions.indexWhere((s) => s.id == session.id);
    if (idx != -1) {
      sessions[idx] = session;
    } else {
      sessions.add(session);
    }
  }

  @override
  Future<void> deleteSession(String id) async =>
      sessions.removeWhere((s) => s.id == id);

  @override
  Future<List<SleepSession>> getAllSessions() async => sessions;

  @override
  Future<SleepSession?> getActiveSession() async => null;

  @override
  Future<SleepSession?> getSessionById(String id) async =>
      sessions.cast<SleepSession?>().firstWhere(
            (s) => s?.id == id,
            orElse: () => null,
          );

  @override
  Future<List<SleepSession>> getSessionsBetween(
          DateTime start, DateTime end) async =>
      sessions;

  @override
  Future<bool> hasOverlappingSession(DateTime start, DateTime end,
          {String? excludeId}) async =>
      false;

  @override
  Future<void> clearAllSessions() async => sessions.clear();
}

class MockPrefsRepo implements PreferencesRepository {
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
  testWidgets('SessionDetailSheet renders in-place factor chips and toggles tags',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final sleepRepo = MockSleepRepo();
    final prefsRepo = MockPrefsRepo();

    final now = DateTime(2026, 10, 31, 8, 0);
    final initialSession = SleepSession(
      id: 'session_test_1',
      startTimestamp: now.subtract(const Duration(hours: 8)),
      endTimestamp: now,
      qualityRating: 4,
      notes: '🧘 Meditated, Slept deeply',
      source: 'manual',
      createdAt: now,
      updatedAt: now,
    );
    sleepRepo.sessions.add(initialSession);

    final settings = SettingsProvider(prefsRepo: prefsRepo);
    final tracker = SleepTrackerProvider(sleepRepo: sleepRepo);
    await tracker.loadSessions();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: tracker),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SessionDetailSheet(session: initialSession),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial factors & notes rendered
    expect(find.text('LIFESTYLE FACTORS & HABITS'), findsOneWidget);
    expect(find.text('Caffeine'), findsOneWidget);
    expect(find.text('Meditated'), findsOneWidget);
    expect(find.text('1 active'), findsOneWidget);
    expect(find.text('Slept deeply'), findsOneWidget);

    // Tap Caffeine chip to toggle it on
    await tester.tap(find.text('Caffeine'));
    await tester.pumpAndSettle();

    // Should now have 2 active tags and updated notes in memory/repo
    expect(find.text('2 active'), findsOneWidget);
    final updated = sleepRepo.sessions.firstWhere((s) => s.id == initialSession.id);
    expect(updated.notes, contains('☕ Caffeine'));
    expect(updated.notes, contains('🧘 Meditated'));
    expect(updated.notes, contains('Slept deeply'));

    // Tap Meditated chip to untag it
    await tester.tap(find.text('Meditated'));
    await tester.pumpAndSettle();

    expect(find.text('1 active'), findsOneWidget);
    final updated2 = sleepRepo.sessions.firstWhere((s) => s.id == initialSession.id);
    expect(updated2.notes, contains('☕ Caffeine'));
    expect(updated2.notes, isNot(contains('🧘 Meditated')));
  });

  testWidgets('SessionDetailSheet allows editing custom notes in-place',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final sleepRepo = MockSleepRepo();
    final prefsRepo = MockPrefsRepo();

    final now = DateTime(2026, 10, 31, 8, 0);
    final initialSession = SleepSession(
      id: 'session_test_2',
      startTimestamp: now.subtract(const Duration(hours: 7)),
      endTimestamp: now,
      qualityRating: 3,
      notes: '🏃 Workout',
      source: 'manual',
      createdAt: now,
      updatedAt: now,
    );
    sleepRepo.sessions.add(initialSession);

    final settings = SettingsProvider(prefsRepo: prefsRepo);
    final tracker = SleepTrackerProvider(sleepRepo: sleepRepo);
    await tracker.loadSessions();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: tracker),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SessionDetailSheet(session: initialSession),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap 'Add Note' or 'Edit' to open inline editor
    await tester.tap(find.text('Add Note'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Woke up briefly around 3am');
    await tester.tap(find.text('Save Note'));
    await tester.pumpAndSettle();

    // Verify notes updated in repo
    final saved = sleepRepo.sessions.firstWhere((s) => s.id == initialSession.id);
    expect(saved.notes, contains('🏃 Workout'));
    expect(saved.notes, contains('Woke up briefly around 3am'));
    expect(find.text('Woke up briefly around 3am'), findsOneWidget);
  });

  testWidgets(
      'SessionDetailSheet displays quality rating label and interactive times card',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final sleepRepo = MockSleepRepo();
    final prefsRepo = MockPrefsRepo();

    final now = DateTime(2026, 10, 31, 7, 30);
    final initialSession = SleepSession(
      id: 'session_test_3',
      startTimestamp: now.subtract(const Duration(hours: 8)),
      endTimestamp: now,
      qualityRating: 4,
      notes: 'Good rest',
      source: 'manual',
      createdAt: now,
      updatedAt: now,
    );
    sleepRepo.sessions.add(initialSession);

    final settings = SettingsProvider(prefsRepo: prefsRepo);
    final tracker = SleepTrackerProvider(sleepRepo: sleepRepo);
    await tracker.loadSessions();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: tracker),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SessionDetailSheet(session: initialSession),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify time cards and tap hint
    expect(find.text('BEDTIME'), findsOneWidget);
    expect(find.text('WAKE UP'), findsOneWidget);
    expect(find.text('Tap times to adjust in-place'), findsOneWidget);

    // Verify rating label
    expect(find.text('Great (4/5)'), findsOneWidget);

    // Tap 5th star to upgrade rating
    final starTaps = find.descendant(
      of: find.byType(StarRatingBar),
      matching: find.byType(InkWell),
    );
    expect(starTaps, findsNWidgets(5));
    await tester.tap(starTaps.at(4));
    await tester.pumpAndSettle();

    // Verify updated rating label and repo
    expect(find.text('Excellent (5/5)'), findsOneWidget);
    final updated =
        sleepRepo.sessions.firstWhere((s) => s.id == initialSession.id);
    expect(updated.qualityRating, equals(5));
  });

  testWidgets(
      'SessionDetailSheet updates qualitative rating badge and recalculates restorative sleep architecture across ratings',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final sleepRepo = MockSleepRepo();
    final prefsRepo = MockPrefsRepo();

    final now = DateTime(2026, 10, 31, 8, 0);
    final unratedSession = SleepSession(
      id: 'session_test_unrated',
      startTimestamp: now.subtract(const Duration(hours: 8)),
      endTimestamp: now,
      qualityRating: null, // Unrated initially
      notes: null,
      source: 'manual',
      createdAt: now,
      updatedAt: now,
    );
    sleepRepo.sessions.add(unratedSession);

    final settings = SettingsProvider(prefsRepo: prefsRepo);
    final tracker = SleepTrackerProvider(sleepRepo: sleepRepo);
    await tracker.loadSessions();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: tracker),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SessionDetailSheet(session: unratedSession),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initially unrated: badge shows 'Tap stars to rate' and 40% Restorative
    expect(find.text('Tap stars to rate'), findsOneWidget);
    expect(find.text('40% Restorative'), findsOneWidget);

    final starTaps = find.descendant(
      of: find.byType(StarRatingBar),
      matching: find.byType(InkWell),
    );
    expect(starTaps, findsNWidgets(5));

    // 2. Tap 1st star: Poor (1/5), recalculates restorative architecture to 26%
    await tester.tap(starTaps.at(0));
    await tester.pumpAndSettle();

    expect(find.text('Poor (1/5)'), findsOneWidget);
    expect(find.text('26% Restorative'), findsOneWidget);
    expect(sleepRepo.sessions.first.qualityRating, equals(1));

    // 3. Tap 3rd star: Good (3/5), recalculates restorative architecture to 38%
    await tester.tap(starTaps.at(2));
    await tester.pumpAndSettle();

    expect(find.text('Good (3/5)'), findsOneWidget);
    expect(find.text('38% Restorative'), findsOneWidget);
    expect(sleepRepo.sessions.first.qualityRating, equals(3));

    // 4. Tap 5th star: Excellent (5/5), recalculates restorative architecture to 50%
    await tester.tap(starTaps.at(4));
    await tester.pumpAndSettle();

    expect(find.text('Excellent (5/5)'), findsOneWidget);
    expect(find.text('50% Restorative'), findsOneWidget);
    expect(sleepRepo.sessions.first.qualityRating, equals(5));
  });
}
