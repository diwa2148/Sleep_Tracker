import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/somna_button.dart';
import '../../../core/widgets/somna_card.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/providers/sleep_tracker_provider.dart';
import '../../../shared/services/export_service.dart';
import 'privacy_policy_sheet.dart';

/// Settings screen for configuring goals, schedules, reminders, theme, and data export.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final tracker = context.watch<SleepTrackerProvider>();
    final prefs = settings.preferences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: [
            // --- SECTION 1: SLEEP GOAL & SCHEDULE ---
            _buildSectionHeader('SLEEP GOAL & SCHEDULE', isDark),
            const SizedBox(height: 6),
            SomnaCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.flag_rounded,
                        color: AppColors.primary),
                    title: Text('Daily Sleep Goal',
                        style: AppTypography.titleSmall(isDark)),
                    trailing: Text(
                      prefs.formattedSleepGoal,
                      style: AppTypography.titleMedium(isDark)
                          .copyWith(color: AppColors.primary),
                    ),
                    onTap: () => _showGoalDialog(context, settings),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.nightlight_round,
                        color: AppColors.primary),
                    title: Text('Target Bedtime',
                        style: AppTypography.titleSmall(isDark)),
                    trailing: Text(
                      prefs.preferredBedtime.format(context),
                      style: AppTypography.titleMedium(isDark),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: prefs.preferredBedtime,
                      );
                      if (picked != null) {
                        await settings.updateSchedule(
                          bedtimeMinutes: picked.hour * 60 + picked.minute,
                          wakeMinutes: prefs.preferredWakeMinutes,
                        );
                        tracker.refreshPreferences(settings.preferences);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.wb_sunny_rounded,
                        color: AppColors.secondary),
                    title: Text('Target Wake-Up',
                        style: AppTypography.titleSmall(isDark)),
                    trailing: Text(
                      prefs.preferredWakeTime.format(context),
                      style: AppTypography.titleMedium(isDark),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: prefs.preferredWakeTime,
                      );
                      if (picked != null) {
                        await settings.updateSchedule(
                          bedtimeMinutes: prefs.preferredBedtimeMinutes,
                          wakeMinutes: picked.hour * 60 + picked.minute,
                        );
                        tracker.refreshPreferences(settings.preferences);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 2: NOTIFICATIONS & REMINDERS ---
            _buildSectionHeader('REMINDERS', isDark),
            const SizedBox(height: 8),
            SomnaCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.notifications_active_outlined,
                        color: AppColors.primary),
                    title: Text('Bedtime Reminder',
                        style: AppTypography.titleSmall(isDark)),
                    subtitle: Text(
                        'Notification at ${prefs.preferredBedtime.format(context)}',
                        style: AppTypography.bodySmall(isDark)),
                    value: prefs.bedtimeReminderEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) async {
                      final success = await settings.setBedtimeReminder(val);
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Notification permission denied by device')),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.alarm_on_rounded,
                        color: AppColors.secondary),
                    title: Text('Wake-Up Reminder',
                        style: AppTypography.titleSmall(isDark)),
                    subtitle: Text(
                        'Notification at ${prefs.preferredWakeTime.format(context)}',
                        style: AppTypography.bodySmall(isDark)),
                    value: prefs.wakeReminderEnabled,
                    activeThumbColor: AppColors.secondary,
                    onChanged: (val) async {
                      final success = await settings.setWakeReminder(val);
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Notification permission denied by device')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 3: APPEARANCE & PREFERENCES ---
            _buildSectionHeader('APPEARANCE & FEEDBACK', isDark),
            const SizedBox(height: 8),
            SomnaCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.palette_outlined,
                        color: AppColors.primary),
                    title: Text('Theme Mode',
                        style: AppTypography.titleSmall(isDark)),
                    trailing: Text(
                      prefs.themeMode.name.toUpperCase(),
                      style: AppTypography.labelLarge(isDark)
                          .copyWith(color: AppColors.primary),
                    ),
                    onTap: () => _showThemeDialog(context, settings),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.vibration_rounded,
                        color: AppColors.positive),
                    title: Text('Haptic Feedback',
                        style: AppTypography.titleSmall(isDark)),
                    subtitle: Text('Vibrate on buttons and interactions',
                        style: AppTypography.bodySmall(isDark)),
                    value: prefs.hapticsEnabled,
                    activeThumbColor: AppColors.positive,
                    onChanged: (val) => settings.setHapticsEnabled(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 4: DATA MANAGEMENT ---
            _buildSectionHeader('DATA MANAGEMENT', isDark),
            const SizedBox(height: 8),
            SomnaCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.file_download_outlined,
                        color: AppColors.positive),
                    title: Text('Export Sleep History (CSV)',
                        style: AppTypography.titleSmall(isDark)),
                    subtitle: Text('RFC-4180 standard spreadsheet export',
                        style: AppTypography.bodySmall(isDark)),
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight),
                    onTap: () async {
                      final success = await ExportService.exportAndShare(
                        sessions: tracker.sessions,
                        isCsv: true,
                      );
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Export was cancelled or unavailable')),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.code_rounded,
                        color: AppColors.secondary),
                    title: Text('Export Raw Data (JSON)',
                        style: AppTypography.titleSmall(isDark)),
                    subtitle: Text('Complete machine-readable JSON backup',
                        style: AppTypography.bodySmall(isDark)),
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight),
                    onTap: () async {
                      final success = await ExportService.exportAndShare(
                        sessions: tracker.sessions,
                        isCsv: false,
                      );
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Export was cancelled or unavailable')),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_forever_rounded,
                        color: AppColors.error),
                    title: Text('Erase All Data',
                        style: AppTypography.titleSmall(isDark)
                            .copyWith(color: AppColors.error)),
                    subtitle: Text(
                        'Permanently delete all sessions and reset app',
                        style: AppTypography.bodySmall(isDark)),
                    onTap: () async {
                      final confirmed = await ConfirmDialog.show(
                        context: context,
                        title: 'Erase All Sleep Data?',
                        message:
                            'This action will permanently delete all recorded sleep sessions, preferences, and cached statistics. This cannot be undone.',
                        confirmText: 'Erase Everything',
                        isDestructive: true,
                      );
                      if (confirmed && context.mounted) {
                        await tracker.clearAllSessions();
                        await settings.resetAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('All data permanently erased')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 5: PRIVACY & ABOUT ---
            _buildSectionHeader('ABOUT & PRIVACY', isDark),
            const SizedBox(height: 8),
            SomnaCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.privacy_tip_outlined,
                        color: AppColors.primary),
                    title: Text('Privacy Charter',
                        style: AppTypography.titleSmall(isDark)),
                    subtitle: Text(
                        'Learn how your data is kept offline and secure',
                        style: AppTypography.bodySmall(isDark)),
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight),
                    onTap: () => PrivacyPolicySheet.show(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.info_outline_rounded,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight),
                    title: Text('About ${AppConfig.appName}',
                        style: AppTypography.titleSmall(isDark)),
                    subtitle: Text(
                        'v${AppConfig.appVersion} (${AppConfig.buildNumber}) • Flutter Local-First',
                        style: AppTypography.bodySmall(isDark)),
                    onTap: () => _showAboutDialog(context, isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.labelSmall(isDark).copyWith(
        letterSpacing: 1.1,
        color:
            isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      ),
    );
  }

  void _showGoalDialog(BuildContext context, SettingsProvider settings) {
    int tempGoal = settings.preferences.sleepGoalMinutes;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final hours = tempGoal ~/ 60;
          final mins = tempGoal % 60;

          return AlertDialog(
            title: const Text('Set Daily Sleep Goal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mins == 0 ? '${hours}h' : '${hours}h ${mins}m',
                  style: AppTypography.displayMedium(isDark)
                      .copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: tempGoal.toDouble(),
                  min: AppConfig.minSleepGoalMinutes.toDouble(),
                  max: AppConfig.maxSleepGoalMinutes.toDouble(),
                  divisions: 16,
                  onChanged: (val) => setState(() => tempGoal = val.round()),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              SomnaButton(
                text: 'Save',
                height: 44,
                onPressed: () {
                  settings.updateSleepGoal(tempGoal);
                  context
                      .read<SleepTrackerProvider>()
                      .refreshPreferences(settings.preferences);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Select Theme'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                settings.setThemeMode(ThemeMode.system);
                Navigator.of(ctx).pop();
              },
              child: const Text('System Default'),
            ),
            SimpleDialogOption(
              onPressed: () {
                settings.setThemeMode(ThemeMode.dark);
                Navigator.of(ctx).pop();
              },
              child: const Text('Dark Mode (Recommended)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                settings.setThemeMode(ThemeMode.light);
                Navigator.of(ctx).pop();
              },
              child: const Text('Light Mode'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.nights_stay_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Text(AppConfig.appName, style: AppTypography.titleLarge(isDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppConfig.appTagline} • Version ${AppConfig.appVersion}',
              style: AppTypography.titleSmall(isDark),
            ),
            const SizedBox(height: 12),
            Text(
              'SOMNA is a local-first mobile application built with Flutter & SQLite to deliver intuitive sleep tracking, circadian consistency analytics, and actionable wellness insights without compromising personal privacy.',
              style: AppTypography.bodyMedium(isDark).copyWith(height: 1.45),
            ),
          ],
        ),
        actions: [
          SomnaButton(
            text: 'Close',
            height: 44,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
