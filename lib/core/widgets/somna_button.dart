import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

enum SomnaButtonType {
  primary,
  secondary,
  destructive,
}

/// Modern button with smooth rounded styling, haptic feedback, and responsive states.
class SomnaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final SomnaButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;

  const SomnaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = SomnaButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Border? border;
    Gradient? gradient;

    switch (type) {
      case SomnaButtonType.primary:
        bg = isDark ? Colors.white : Colors.black;
        fg = isDark ? Colors.black : Colors.white;
        border = null;
        gradient = LinearGradient(
          colors: isDark
              ? [const Color(0xFFFFFFFF), const Color(0xFFD4D4D4)]
              : [const Color(0xFF1E1E1E), const Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case SomnaButtonType.secondary:
        bg = isDark ? AppColors.darkElevated : AppColors.lightElevated;
        fg = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        border = Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        );
        break;
      case SomnaButtonType.destructive:
        bg = isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5);
        fg = isDark ? Colors.white : Colors.black;
        border = Border.all(
          color: isDark ? const Color(0xFF404040) : const Color(0xFFCCCCCC),
          width: 1.0,
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
          borderRadius: BorderRadius.circular(borderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            decoration: BoxDecoration(
              color: gradient == null
                  ? (isEnabled ? bg : bg.withValues(alpha: 0.4))
                  : null,
              gradient: isEnabled ? gradient : null,
              border: border,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: isEnabled && type == SomnaButtonType.primary
                  ? [
                      BoxShadow(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: fg),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: AppTypography.labelLarge(isDark).copyWith(
                          color: fg,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.2,
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
