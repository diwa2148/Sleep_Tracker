import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../core/widgets/android_emulator_frame.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../shared/providers/settings_provider.dart';
import '../shared/providers/sleep_tracker_provider.dart';
import 'app_config.dart';
import 'main_screen.dart';
import 'theme/app_theme.dart';

/// Root application widget for SOMNA — Smart Sleep Tracker.
class SomnaApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const SomnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SleepTrackerProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
            ],
            builder: (context, child) {
              return AndroidEmulatorFrame(
                navigatorKey: navigatorKey,
                child: child ?? const SizedBox(),
              );
            },
            home: settings.isLoading
                ? const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : settings.onboardingCompleted
                    ? const MainScreen()
                    : OnboardingScreen(
                        onFinish: () {},
                      ),
          );
        },
      ),
    );
  }
}
