import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracker/app/theme/app_theme.dart';
import 'package:sleep_tracker/features/dashboard/presentation/dashboard_screen.dart';
import 'package:sleep_tracker/features/history/presentation/history_screen.dart';
import 'package:sleep_tracker/features/history/presentation/session_detail_sheet.dart';
import 'package:sleep_tracker/features/insights/presentation/insights_screen.dart';
import 'package:sleep_tracker/features/onboarding/presentation/onboarding_screen.dart';
import 'package:sleep_tracker/features/settings/presentation/settings_screen.dart';
import 'package:sleep_tracker/features/sleep_tracking/presentation/wake_up_sheet.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/models/user_preferences.dart';
import 'package:sleep_tracker/shared/providers/settings_provider.dart';
import 'package:sleep_tracker/shared/providers/sleep_tracker_provider.dart';
import 'package:sleep_tracker/shared/repositories/preferences_repository.dart';
import 'package:sleep_tracker/shared/repositories/sleep_repository.dart';

class FakeSleepRepo implements SleepRepository {
  final List<SleepSession> sessions = [];
  SleepSession? active;

  @override
  Future<void> createSession(SleepSession session) async {
    sessions.add(session);
    if (session.isActive) active = session;
  }

  @override
  Future<void> updateSession(SleepSession session) async {
    final idx = sessions.indexWhere((s) => s.id == session.id);
    if (idx != -1) sessions[idx] = session;
    if (active?.id == session.id && !session.isActive) active = null;
  }

  @override
  Future<void> deleteSession(String id) async {
    sessions.removeWhere((s) => s.id == id);
    if (active?.id == id) active = null;
  }

  @override
  Future<List<SleepSession>> getAllSessions() async => List.from(sessions);

  @override
  Future<SleepSession?> getActiveSession() async => active;

  @override
  Future<SleepSession?> getSessionById(String id) async {
    return sessions.firstWhere((s) => s.id == id);
  }

  @override
  Future<List<SleepSession>> getSessionsBetween(
          DateTime start, DateTime end) async =>
      sessions
          .where((s) =>
              s.startTimestamp.isAfter(start) && s.startTimestamp.isBefore(end))
          .toList();

  @override
  Future<bool> hasOverlappingSession(DateTime start, DateTime end,
          {String? excludeId}) async =>
      false;

  @override
  Future<void> clearAllSessions() async {
    sessions.clear();
    active = null;
  }
}

class FakePrefsRepo implements PreferencesRepository {
  UserPreferences prefs;
  FakePrefsRepo({this.prefs = const UserPreferences(onboardingCompleted: false)});

  @override
  Future<UserPreferences> loadPreferences() async => prefs;

  @override
  Future<void> savePreferences(UserPreferences p) async => prefs = p;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    prefs = prefs.copyWith(onboardingCompleted: completed);
  }

  @override
  Future<void> resetAll() async {
    prefs = const UserPreferences();
  }
}

void main() {
  testWidgets('E2E Journey: Onboarding completes and persists preferences',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final prefsRepo = FakePrefsRepo();
    final settingsProvider = SettingsProvider(prefsRepo: prefsRepo);

    bool completed = false;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settingsProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: OnboardingScreen(
            onFinish: () => completed = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Screen 1: Welcome
    expect(find.textContaining('Understand Your Sleep'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Screen 2: Sleep Goal
    expect(find.text('What is your sleep goal?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Screen 3: Schedule
    expect(find.text('Your Ideal Schedule'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Screen 4: Completion / Reminders
    expect(find.text('You are all set!'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(prefsRepo.prefs.onboardingCompleted, isTrue);
  });

  testWidgets('E2E Journey: Start Sleep timer, Wake Up, rate, and save session',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final sleepRepo = FakeSleepRepo();
    final prefsRepo = FakePrefsRepo(
        prefs: const UserPreferences(onboardingCompleted: true));
    final settings = SettingsProvider(prefsRepo: prefsRepo);
    final tracker = SleepTrackerProvider(sleepRepo: sleepRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: tracker),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: DashboardScreen(
            onNavigateToAnalytics: () {},
            onNavigateToInsights: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Start tracking
    await tester.tap(find.text('Start Sleep'));
    await tester.pumpAndSettle();

    expect(tracker.isTracking, isTrue);
    expect(find.text('SLEEP TRACKING ACTIVE'), findsOneWidget);

    // Stop tracking via Wake Up
    final wakeUpButton = find.text('Wake Up & Record');
    expect(wakeUpButton, findsOneWidget);
    await tester.tap(wakeUpButton);
    await tester.pumpAndSettle();

    // WakeUpSheet dialog is presented
    expect(find.byType(WakeUpSheet), findsOneWidget);
    expect(find.text('Good Morning!'), findsOneWidget);

    // Enter note and save
    await tester.enterText(
        find.byType(TextField), 'E2E automated test notes');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Sleep Session'));
    await tester.pumpAndSettle();

    expect(tracker.isTracking, isFalse);
    expect(sleepRepo.sessions.length, 1);
    expect(sleepRepo.sessions.first.notes, 'E2E automated test notes');
  });

  testWidgets('E2E Journey: History tab displays recorded sessions and details',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final sleepRepo = FakeSleepRepo();
    final now = DateTime.now();
    await sleepRepo.createSession(
      SleepSession(
        id: 'sess-1',
        startTimestamp: now.subtract(const Duration(hours: 8)),
        endTimestamp: now,
        qualityRating: 5,
        notes: 'Restful 8 hours sleep',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final prefsRepo = FakePrefsRepo(
        prefs: const UserPreferences(onboardingCompleted: true));
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
          home: const HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sleep History'), findsOneWidget);
    expect(find.text('8h 0m'), findsOneWidget);
    expect(find.text('Restful 8 hours sleep'), findsOneWidget);

    // Tap to open session detail sheet
    await tester.tap(find.text('8h 0m'));
    await tester.pumpAndSettle();

    expect(find.text('Recorded via manual'), findsOneWidget);
    expect(find.text('Sleep Quality'), findsOneWidget);
    expect(find.text('BEDTIME'), findsOneWidget);
    expect(find.text('WAKE UP'), findsOneWidget);
    expect(find.text('LIFESTYLE FACTORS & HABITS'), findsOneWidget);
    expect(find.text('Caffeine'), findsOneWidget);
    expect(find.text('Workout'), findsOneWidget);

    // Toggle Caffeine chip in-place
    await tester.tap(find.text('Caffeine'));
    await tester.pumpAndSettle();
    expect(find.text('1 active'), findsOneWidget);
    expect(sleepRepo.sessions.first.notes, contains('☕ Caffeine'));

    // Adjust quality rating in-place (tap 4th star to change from 5 to 4)
    final sheetStars = find.descendant(
      of: find.byType(SessionDetailSheet),
      matching: find.byIcon(Icons.star_rounded),
    );
    expect(sheetStars, findsNWidgets(5));
    expect(find.text('Excellent (5/5)'), findsOneWidget);
    expect(find.text('50% Restorative'), findsOneWidget);

    await tester.tap(sheetStars.at(3));
    await tester.pumpAndSettle();

    expect(find.text('Great (4/5)'), findsOneWidget);
    expect(find.text('44% Restorative'), findsOneWidget);
    expect(sleepRepo.sessions.first.qualityRating, equals(4));

    // Edit notes in-place
    expect(find.text('Edit'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(
        find.byType(TextField), 'Deep restorative REM cycles');
    await tester.tap(find.text('Save Note'));
    await tester.pumpAndSettle();

    // Verify session notes updated with both the factor tag and new observation
    expect(sleepRepo.sessions.first.notes, contains('☕ Caffeine'));
    expect(sleepRepo.sessions.first.notes,
        contains('Deep restorative REM cycles'));
    expect(find.text('Deep restorative REM cycles'), findsOneWidget);
  });

  testWidgets('E2E Journey: Settings allows toggling theme and haptics',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final sleepRepo = FakeSleepRepo();
    final prefsRepo = FakePrefsRepo(
        prefs: const UserPreferences(onboardingCompleted: true));
    final settings = SettingsProvider(prefsRepo: prefsRepo);
    final tracker = SleepTrackerProvider(sleepRepo: sleepRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: tracker),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('APPEARANCE & FEEDBACK'), findsOneWidget);

    // Open theme dialog
    await tester.tap(find.text('Theme Mode'));
    await tester.pumpAndSettle();

    expect(find.text('Select Theme'), findsOneWidget);

    // Select Light Mode
    await tester.tap(find.text('Light Mode'));
    await tester.pumpAndSettle();
    expect(settings.preferences.themeMode, ThemeMode.light);

    // Reopen and select Dark Mode
    await tester.tap(find.text('Theme Mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark Mode (Recommended)'));
    await tester.pumpAndSettle();
    expect(settings.preferences.themeMode, ThemeMode.dark);
  });

  testWidgets('E2E Journey: Insights screen renders deterministic cards',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final sleepRepo = FakeSleepRepo();
    final prefsRepo = FakePrefsRepo(
        prefs: const UserPreferences(onboardingCompleted: true));
    final settings = SettingsProvider(prefsRepo: prefsRepo);
    final tracker = SleepTrackerProvider(sleepRepo: sleepRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: tracker),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const InsightsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sleep Insights'), findsOneWidget);
    expect(find.text('PERSONALIZED PATTERNS'), findsOneWidget);
    expect(find.text('FOUNDATIONAL SLEEP HABITS'), findsOneWidget);
    expect(find.text('Anchor Your Wake Time'), findsOneWidget);
    expect(find.text('Wind-Down Buffer Zone'), findsOneWidget);
  });
}
