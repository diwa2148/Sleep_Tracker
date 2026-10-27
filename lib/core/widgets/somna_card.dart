import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Premium container card with subtle borders, gentle gradients, and rounded corners.
class SomnaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final Gradient? gradient;
  final double borderRadius;

  const SomnaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.gradient,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final defaultBorder = Border.all(
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      width: 1,
    );

    final cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? defaultBg) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? defaultBorder,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0x060F172A),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
