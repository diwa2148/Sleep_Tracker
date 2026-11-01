import 'package:flutter/material.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';

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
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 768;

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

    if (isWide) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  right: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: _navigateToIndex,
                backgroundColor:
                    isDark ? AppColors.darkSurface : AppColors.lightSurface,
                labelType: NavigationRailLabelType.all,
                minWidth: 80,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.primary : AppColors.primaryDark)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (isDark ? AppColors.primary : AppColors.primaryDark)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.nights_stay_rounded,
                          color: isDark ? AppColors.primary : AppColors.primaryDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'SOMNA',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                selectedLabelTextStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                  letterSpacing: 0.2,
                ),
                unselectedLabelTextStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  letterSpacing: 0.2,
                ),
                selectedIconTheme: IconThemeData(
                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                  size: 24,
                ),
                unselectedIconTheme: IconThemeData(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  size: 22,
                ),
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.home_rounded),
                    selectedIcon: _buildActiveIcon(Icons.home_rounded, isDark),
                    label: const Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.history_rounded),
                    selectedIcon: _buildActiveIcon(Icons.history_rounded, isDark),
                    label: const Text('History'),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.insights_rounded),
                    selectedIcon: _buildActiveIcon(Icons.insights_rounded, isDark),
                    label: const Text('Analytics'),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.auto_awesome_rounded),
                    selectedIcon:
                        _buildActiveIcon(Icons.auto_awesome_rounded, isDark),
                    label: const Text('Insights'),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.settings_rounded),
                    selectedIcon: _buildActiveIcon(Icons.settings_rounded, isDark),
                    label: const Text('Settings'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
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
            selectedLabelStyle: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                activeIcon: _buildActiveIcon(Icons.home_rounded, isDark),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_rounded),
                activeIcon: _buildActiveIcon(Icons.history_rounded, isDark),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.insights_rounded),
                activeIcon: _buildActiveIcon(Icons.insights_rounded, isDark),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.auto_awesome_rounded),
                activeIcon: _buildActiveIcon(Icons.auto_awesome_rounded, isDark),
                label: 'Insights',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded),
                activeIcon: _buildActiveIcon(Icons.settings_rounded, isDark),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveIcon(IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.primary : AppColors.primaryDark)
            .withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon),
    );
  }
}
