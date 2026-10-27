import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import 'somna_button.dart';

/// Standard confirmation dialog for destructive or critical actions.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
  });

  /// Displays the confirmation dialog and returns true if confirmed.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          if (isDestructive) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleLarge(isDark),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: AppTypography.bodyMedium(isDark),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: SomnaButton(
                text: cancelText,
                type: SomnaButtonType.secondary,
                height: 46,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SomnaButton(
                text: confirmText,
                type: isDestructive
                    ? SomnaButtonType.destructive
                    : SomnaButtonType.primary,
                height: 46,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
