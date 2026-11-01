import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/sound_machine/presentation/sound_machine_provider.dart';
import '../features/alarm/presentation/alarm_provider.dart';
import '../shared/providers/settings_provider.dart';
import '../shared/providers/sleep_tracker_provider.dart';
import 'app_config.dart';
import 'main_screen.dart';
import 'theme/app_colors.dart';
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
        ChangeNotifierProvider(create: (_) => SoundMachineProvider()),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
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
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final isOled = isDark && settings.oledModeEnabled;
              final width = MediaQuery.sizeOf(context).width;
              final isWide = width >= 768;

              return Container(
                decoration: BoxDecoration(
                  gradient: isOled || !isWide
                      ? null
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [
                                  Color(0xFF000000),
                                  Color(0xFF080808),
                                  Color(0xFF000000),
                                ]
                              : const [
                                  Color(0xFFFFFFFF),
                                  Color(0xFFF0F0F0),
                                  Color(0xFFFFFFFF),
                                ],
                        ),
                  color: isOled
                      ? const Color(0xFF000000)
                      : (isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isOled
                            ? const Color(0xFF000000)
                            : (isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground),
                        boxShadow: isOled || !isWide
                            ? null
                            : [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.55)
                                      : Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 36,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                        border: isWide
                            ? Border.symmetric(
                                vertical: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF262626)
                                      : const Color(0xFFE5E5E5),
                                  width: 1,
                                ),
                              )
                            : null,
                      ),
                      child: child ?? const SizedBox(),
                    ),
                  ),
                ),
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
