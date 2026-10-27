import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracker/app/theme/app_theme.dart';
import 'package:sleep_tracker/features/dashboard/presentation/dashboard_screen.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/models/user_preferences.dart';
import 'package:sleep_tracker/shared/providers/settings_provider.dart';
import 'package:sleep_tracker/shared/providers/sleep_tracker_provider.dart';
import 'package:sleep_tracker/shared/repositories/preferences_repository.dart';
import 'package:sleep_tracker/shared/repositories/sleep_repository.dart';

class MockSleepRepository implements SleepRepository {
  final List<SleepSession> _sessions = [];
  SleepSession? _active;

  @override
  Future<void> createSession(SleepSession session) async {
    _sessions.add(session);
    if (session.isActive) _active = session;
  }

  @override
  Future<void> updateSession(SleepSession session) async {
    final idx = _sessions.indexWhere((s) => s.id == session.id);
    if (idx != -1) _sessions[idx] = session;
    if (_active?.id == session.id && !session.isActive) _active = null;
  }

  @override
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    if (_active?.id == id) _active = null;
  }

  @override
  Future<List<SleepSession>> getAllSessions() async => List.from(_sessions);

  @override
  Future<SleepSession?> getActiveSession() async => _active;

  @override
  Future<SleepSession?> getSessionById(String id) async {
    return _sessions.firstWhere((s) => s.id == id);
  }

  @override
  Future<List<SleepSession>> getSessionsBetween(
          DateTime start, DateTime end) async =>
      [];

  @override
  Future<bool> hasOverlappingSession(DateTime start, DateTime end,
          {String? excludeId}) async =>
      false;

  @override
  Future<void> clearAllSessions() async {
    _sessions.clear();
    _active = null;
  }
}

class MockPreferencesRepository implements PreferencesRepository {
  UserPreferences _prefs = const UserPreferences(onboardingCompleted: true);

  @override
  Future<UserPreferences> loadPreferences() async => _prefs;

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    _prefs = preferences;
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    _prefs = _prefs.copyWith(onboardingCompleted: completed);
  }

  @override
  Future<void> resetAll() async {
    _prefs = const UserPreferences();
  }
}

void main() {
  testWidgets('Dashboard displays empty state when no sessions recorded',
      (tester) async {
    final mockSleepRepo = MockSleepRepository();
    final mockPrefsRepo = MockPreferencesRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => SettingsProvider(prefsRepo: mockPrefsRepo)),
          ChangeNotifierProvider(
              create: (_) => SleepTrackerProvider(sleepRepo: mockSleepRepo)),
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

    expect(find.text('No Sleep Recorded Yet'), findsOneWidget);
    expect(find.text('Start Sleep'), findsOneWidget);
  });

  testWidgets('Starting sleep timer activates in-progress tracking state',
      (tester) async {
    final mockSleepRepo = MockSleepRepository();
    final mockPrefsRepo = MockPreferencesRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => SettingsProvider(prefsRepo: mockPrefsRepo)),
          ChangeNotifierProvider(
              create: (_) => SleepTrackerProvider(sleepRepo: mockSleepRepo)),
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

    // Tap 'Start Sleep'
    await tester.tap(find.text('Start Sleep'));
    await tester.pumpAndSettle();

    // Active session card must be rendered
    expect(find.text('SLEEP TRACKING ACTIVE'), findsOneWidget);
    expect(find.text('Wake Up & Record'), findsOneWidget);
  });
}
