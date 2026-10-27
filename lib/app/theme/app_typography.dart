import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized typographic styles for SOMNA.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Rajdhani';
  static const List<String> fontFallbacks = [
    'Barlow',
    'Space Grotesk',
    'Trebuchet MS',
    'Segoe UI',
    '-apple-system',
    'sans-serif',
  ];

  // Display Styles (Large Sleep Clock / Durations)
  static TextStyle displayLarge(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.1,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle displayMedium(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // Headlines
  static TextStyle headlineLarge(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle headlineMedium(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  // Titles
  static TextStyle titleLarge(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle titleMedium(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle titleSmall(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  // Body Text
  static TextStyle bodyLarge(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.45,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle bodyMedium(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.4,
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  static TextStyle bodySmall(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      );

  // Labels & Captions
  static TextStyle labelLarge(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle labelMedium(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  static TextStyle labelSmall(bool isDark) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      );

  // Numeric Stats / Badges
  static TextStyle statNumber(bool isDark, {double fontSize = 28}) => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );
}
