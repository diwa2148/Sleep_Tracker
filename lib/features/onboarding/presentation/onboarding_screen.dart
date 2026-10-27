import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/somna_button.dart';
import '../../../core/widgets/somna_card.dart';
import '../../../shared/providers/settings_provider.dart';

/// Multi-step onboarding experience introducing SOMNA, configuring sleep goals,
/// preferred schedule, and reminder options.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  int _selectedGoalMinutes = AppConfig.defaultSleepGoalMinutes;
  int _selectedBedtimeMinutes = AppConfig.defaultBedtimeMinutes;
  int _selectedWakeMinutes = AppConfig.defaultWakeMinutes;
  bool _enableBedtimeReminder = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final settings = context.read<SettingsProvider>();
    await settings.completeOnboarding(
      sleepGoalMinutes: _selectedGoalMinutes,
      bedtimeMinutes: _selectedBedtimeMinutes,
      wakeMinutes: _selectedWakeMinutes,
      enableBedtimeReminder: _enableBedtimeReminder,
    );
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Brand
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.nights_stay_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppConfig.appName,
                        style: AppTypography.titleLarge(isDark).copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < 3)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTypography.labelLarge(isDark).copyWith(
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(isDark),
                  _buildGoalPage(isDark),
                  _buildSchedulePage(isDark),
                  _buildCompletionPage(isDark),
                ],
              ),
            ),

            // Bottom Navigation & Progress Indicator
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Progress Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SomnaButton(
                    text: _currentPage == 3 ? 'Get Started' : 'Continue',
                    width: double.infinity,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Page 1: Welcome ---
  Widget _buildWelcomePage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.secondary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(Icons.bedtime_rounded,
                size: 54, color: AppColors.primary),
          ),
          const SizedBox(height: 32),
          Text(
            'Understand Your Sleep.\nRestore Your Energy.',
            textAlign: TextAlign.center,
            style: AppTypography.headlineLarge(isDark)
                .copyWith(fontSize: 28, height: 1.25),
          ),
          const SizedBox(height: 16),
          Text(
            'A calm, private sleep companion designed to help you build consistent sleep rhythms and actionable wellness insights.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(isDark)
                .copyWith(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 36),
          SomnaCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined,
                    color: AppColors.positive, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Local & Private',
                        style: AppTypography.titleSmall(isDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'No account required. Your sleep logs stay strictly on your device.',
                        style: AppTypography.bodySmall(isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Page 2: Sleep Goal ---
  Widget _buildGoalPage(bool isDark) {
    final hours = _selectedGoalMinutes ~/ 60;
    final mins = _selectedGoalMinutes % 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'What is your sleep goal?',
            style: AppTypography.headlineMedium(isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Most adults function best with 7 to 9 hours of sleep per night.',
            style: AppTypography.bodyMedium(isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Large Visual Display
          SomnaCard(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$hours',
                      style: AppTypography.displayLarge(isDark)
                          .copyWith(color: AppColors.primary),
                    ),
                    Text(
                      'h ',
                      style: AppTypography.headlineMedium(isDark)
                          .copyWith(color: AppColors.primary),
                    ),
                    if (mins > 0) ...[
                      Text(
                        '$mins',
                        style: AppTypography.displayLarge(isDark)
                            .copyWith(color: AppColors.primary),
                      ),
                      Text(
                        'm',
                        style: AppTypography.headlineMedium(isDark)
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'per night',
                  style: AppTypography.labelMedium(isDark),
                ),
                const SizedBox(height: 32),
                Slider(
                  value: _selectedGoalMinutes.toDouble(),
                  min: AppConfig.minSleepGoalMinutes.toDouble(),
                  max: AppConfig.maxSleepGoalMinutes.toDouble(),
                  divisions: 16, // 30-minute intervals
                  label: mins == 0 ? '${hours}h' : '${hours}h ${mins}m',
                  onChanged: (val) {
                    setState(() {
                      _selectedGoalMinutes = val.round();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('4h', style: AppTypography.bodySmall(isDark)),
                    Text('8h (Recommended)',
                        style: AppTypography.bodySmall(isDark)
                            .copyWith(color: AppColors.positive)),
                    Text('12h', style: AppTypography.bodySmall(isDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Page 3: Bedtime & Wake Schedule ---
  Widget _buildSchedulePage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Your Ideal Schedule',
              style: AppTypography.headlineMedium(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Consistent bedtimes train your internal clock for deeper rest.',
              style: AppTypography.bodyMedium(isDark),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 36),

          // Bedtime Picker Row
          _buildTimePickerTile(
            title: 'Target Bedtime',
            icon: Icons.nightlight_round,
            minutes: _selectedBedtimeMinutes,
            isDark: isDark,
            onChanged: (newMinutes) =>
                setState(() => _selectedBedtimeMinutes = newMinutes),
          ),
          const SizedBox(height: 16),

          // Wake Time Picker Row
          _buildTimePickerTile(
            title: 'Target Wake-Up',
            icon: Icons.wb_sunny_rounded,
            minutes: _selectedWakeMinutes,
            isDark: isDark,
            onChanged: (newMinutes) =>
                setState(() => _selectedWakeMinutes = newMinutes),
          ),
          const SizedBox(height: 24),

          // Optional Reminder Switch
          SomnaCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Bedtime Reminder',
                  style: AppTypography.titleSmall(isDark)),
              subtitle: Text(
                'Receive a gentle notification 30m before target bedtime.',
                style: AppTypography.bodySmall(isDark),
              ),
              value: _enableBedtimeReminder,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _enableBedtimeReminder = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerTile({
    required String title,
    required IconData icon,
    required int minutes,
    required bool isDark,
    required ValueChanged<int> onChanged,
  }) {
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    final time = TimeOfDay(hour: h, minute: m);

    return SomnaCard(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onChanged(picked.hour * 60 + picked.minute);
        }
      },
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium(isDark)),
                const SizedBox(height: 4),
                Text(
                  time.format(context),
                  style: AppTypography.headlineMedium(isDark)
                      .copyWith(fontSize: 22),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color:
                  isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
        ],
      ),
    );
  }

  // --- Page 4: Completion ---
  Widget _buildCompletionPage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.positive.withValues(alpha: 0.15),
              border: Border.all(
                  color: AppColors.positive.withValues(alpha: 0.4), width: 2),
            ),
            child: const Icon(Icons.check_circle_rounded,
                size: 56, color: AppColors.positive),
          ),
          const SizedBox(height: 28),
          Text(
            'You are all set!',
            style: AppTypography.headlineLarge(isDark),
          ),
          const SizedBox(height: 12),
          Text(
            'Your sleep profile is personalized. You can record sessions automatically with the timer or log them manually anytime.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(isDark)
                .copyWith(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 36),
          SomnaCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSummaryRow(
                    'Sleep Goal',
                    '${_selectedGoalMinutes ~/ 60}h ${_selectedGoalMinutes % 60}m',
                    isDark),
                const Divider(),
                _buildSummaryRow(
                  'Bedtime Schedule',
                  TimeOfDay(
                          hour: _selectedBedtimeMinutes ~/ 60,
                          minute: _selectedBedtimeMinutes % 60)
                      .format(context),
                  isDark,
                ),
                const Divider(),
                _buildSummaryRow(
                  'Wake Schedule',
                  TimeOfDay(
                          hour: _selectedWakeMinutes ~/ 60,
                          minute: _selectedWakeMinutes % 60)
                      .format(context),
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium(isDark)),
          Text(
            value,
            style: AppTypography.titleSmall(isDark)
                .copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
