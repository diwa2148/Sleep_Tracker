import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleep_tracker/app/app_config.dart';
import 'package:sleep_tracker/app/main_screen.dart';
import 'package:sleep_tracker/app/theme/app_theme.dart';
import 'package:sleep_tracker/shared/models/sleep_session.dart';
import 'package:sleep_tracker/shared/models/user_preferences.dart';
import 'package:sleep_tracker/shared/providers/settings_provider.dart';
import 'package:sleep_tracker/shared/providers/sleep_tracker_provider.dart';
import 'package:sleep_tracker/shared/repositories/preferences_repository.dart';
import 'package:sleep_tracker/shared/repositories/sleep_repository.dart';

class _MockSleepRepo implements SleepRepository {
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
  }

  @override
  Future<void> deleteSession(String id) async =>
      _sessions.removeWhere((s) => s.id == id);

  @override
  Future<List<SleepSession>> getAllSessions() async => List.from(_sessions);

  @override
  Future<SleepSession?> getActiveSession() async => _active;

  @override
  Future<SleepSession?> getSessionById(String id) async =>
      _sessions.firstWhere((s) => s.id == id);

  @override
  Future<List<SleepSession>> getSessionsBetween(DateTime s, DateTime e) async =>
      [];

  @override
  Future<bool> hasOverlappingSession(DateTime s, DateTime e,
          {String? excludeId}) async =>
      false;

  @override
  Future<void> clearAllSessions() async {
    _sessions.clear();
    _active = null;
  }
}

class _MockPrefsRepo implements PreferencesRepository {
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
  setUp(() {
    SharedPreferences.setMockInitialValues({
      AppConfig.keyOnboardingCompleted: true,
      AppConfig.keySleepGoal: 480,
    });
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => SettingsProvider(prefsRepo: _MockPrefsRepo())),
        ChangeNotifierProvider(
            create: (_) => SleepTrackerProvider(sleepRepo: _MockSleepRepo())),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const MainScreen(),
      ),
    );
  }

  testWidgets('Renders without overflow on narrow/micro viewport (320px)',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify BottomNavigationBar is used on narrow/mobile
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    // Verify key elements render
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Start Sleep'), findsOneWidget);
    expect(find.text('Consistency'), findsOneWidget);

    // Switch to Analytics tab and verify no overflow
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(find.text('Analytics'), findsWidgets);

    // Switch to Insights tab and verify no overflow
    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('Insights'), findsWidgets);

    // Switch to History tab and verify no overflow
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Sleep History'), findsOneWidget);
  });

  testWidgets('Renders tablet foldable layout on 840px viewport',
      (tester) async {
    tester.view.physicalSize = const Size(840, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // On >=768px, NavigationRail is active
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);

    // Verify 2-column layout renders
    expect(find.text('Start Sleep'), findsOneWidget);
    expect(find.text('SOMNA'), findsOneWidget);
  });

  testWidgets('Renders adaptive NavigationRail on wide desktop viewport (1200px)',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify NavigationRail is displayed instead of BottomNavigationBar
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);

    // Brand and destinations render
    expect(find.text('SOMNA'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Start Sleep'), findsOneWidget);
    expect(find.text('Consistency'), findsOneWidget);
  });
}
