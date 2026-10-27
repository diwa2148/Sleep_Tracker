import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

enum SomnaButtonType {
  primary,
  secondary,
  destructive,
}

/// Custom button with haptic feedback, subtle gradients, and loading states.
class SomnaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final SomnaButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const SomnaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = SomnaButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Border? border;

    switch (type) {
      case SomnaButtonType.primary:
        bg = isDark ? AppColors.primary : AppColors.primaryDark;
        fg = isDark ? const Color(0xFF0B1020) : Colors.white;
        break;
      case SomnaButtonType.secondary:
        bg = isDark ? AppColors.darkElevated : AppColors.lightElevated;
        fg = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        border = Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        );
        break;
      case SomnaButtonType.destructive:
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        border = Border.all(
          color: AppColors.error.withValues(alpha: 0.4),
          width: 1,
        );
        break;
    }

    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                }
              : null,
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isEnabled ? bg : bg.withValues(alpha: 0.4),
              border: border,
              borderRadius: BorderRadius.circular(6),
              boxShadow: isEnabled && type == SomnaButtonType.primary
                  ? [
                      BoxShadow(
                        color: (isDark ? AppColors.primary : AppColors.primaryDark)
                            .withValues(alpha: isDark ? 0.3 : 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: fg),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: AppTypography.labelLarge(isDark).copyWith(
                          color: fg,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
