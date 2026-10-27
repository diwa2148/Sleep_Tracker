import 'package:flutter/material.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'theme/app_colors.dart';

/// Primary root screen running inside an authentic Android mobile environment.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      DashboardScreen(
        onNavigateToAnalytics: () => _navigateToIndex(2),
        onNavigateToInsights: () => _navigateToIndex(3),
      ),
      const HistoryScreen(),
      const AnalyticsScreen(),
      const InsightsScreen(),
      const SettingsScreen(),
    ];

    final mobileApp = Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _navigateToIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            selectedItemColor:
                isDark ? AppColors.primary : AppColors.primaryDark,
            unselectedItemColor:
                isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                activeIcon: Icon(Icons.history_rounded),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights_rounded),
                activeIcon: Icon(Icons.insights_rounded),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_rounded),
                activeIcon: Icon(Icons.auto_awesome_rounded),
                label: 'Insights',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );

    return mobileApp;
  }
}
