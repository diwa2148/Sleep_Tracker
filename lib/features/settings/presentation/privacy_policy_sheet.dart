import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/somna_button.dart';

/// Bottom sheet presenting the transparent privacy charter for SOMNA.
class PrivacyPolicySheet extends StatelessWidget {
  const PrivacyPolicySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PrivacyPolicySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.positive.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded,
                    color: AppColors.positive, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Privacy & Data Charter',
                style: AppTypography.titleLarge(isDark),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildPrivacyPoint(
            icon: Icons.phonelink_lock_rounded,
            title: '100% Local-First Storage',
            description:
                'All sleep sessions, timestamps, quality ratings, and notes are stored strictly in an encrypted/private SQLite database on your device.',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildPrivacyPoint(
            icon: Icons.cloud_off_rounded,
            title: 'No Mandatory Accounts or Cloud Telemetry',
            description:
                'SOMNA functions entirely offline. No tracking SDKs, no advertising identifiers, and no user registration.',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildPrivacyPoint(
            icon: Icons.file_download_outlined,
            title: 'Full Data Portability',
            description:
                'You own your sleep data. You can export complete logs to RFC-4180 CSV or JSON anytime, or permanently erase your database.',
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          SomnaButton(
            text: 'I Understand',
            width: double.infinity,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildPrivacyPoint({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleSmall(isDark)),
              const SizedBox(height: 2),
              Text(description,
                  style: AppTypography.bodySmall(isDark).copyWith(height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
