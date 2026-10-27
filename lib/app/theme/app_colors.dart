import 'package:flutter/material.dart';

/// Premium color palette for SOMNA.
/// Designed for a calm, luxury wellness aesthetic with midnight navies,
/// soothing lavenders, soft sky accents, and restorative mint tones.
class AppColors {
  AppColors._();

  // Dark Theme Palette (Primary experience)
  static const Color darkBackground = Color(0xFF0B1020);
  static const Color darkSurface = Color(0xFF141B2D);
  static const Color darkElevated = Color(0xFF1C2540);
  static const Color darkCard = Color(0xFF182038);
  static const Color darkBorder = Color(0xFF263354);
  static const Color darkSubtle = Color(0xFF1E293B);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF6F7FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightSubtle = Color(0xFFF8FAFC);

  // Accents & Functional Colors
  static const Color primary = Color(0xFF9B8CFF); // Lavender / Violet
  static const Color primaryLight = Color(0xFFB4A7FF);
  static const Color primaryDark = Color(0xFF7B66FF);

  static const Color secondary = Color(0xFF7DD3FC); // Sky / Cyan
  static const Color secondaryLight = Color(0xFFBAE6FD);
  static const Color secondaryDark = Color(0xFF38BDF8);

  static const Color positive = Color(0xFF86D9B2); // Mint Green
  static const Color positiveLight = Color(0xFFA7F3D0);
  static const Color positiveDark = Color(0xFF34D399);

  static const Color warning = Color(0xFFFCD34D); // Soft Amber
  static const Color warningLight = Color(0xFFFDE68A);

  static const Color error = Color(0xFFF87171); // Coral / Rose
  static const Color errorLight = Color(0xFFFCA5A5);

  // Sleep Quality Scale Colors (1 to 5)
  static const Color rating1 = Color(0xFFF87171); // Poor - Red/Coral
  static const Color rating2 = Color(0xFFFB923C); // Fair - Orange
  static const Color rating3 = Color(0xFFFBBF24); // Good - Amber
  static const Color rating4 = Color(0xFF60A5FA); // Great - Blue
  static const Color rating5 = Color(0xFF86D9B2); // Excellent - Mint

  static const List<Color> ratingColors = [
    rating1,
    rating2,
    rating3,
    rating4,
    rating5,
  ];

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF4F5FF);
  static const Color textSecondaryDark = Color(0xFFA6AEC8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9B8CFF), Color(0xFF7B66FF)],
  );

  static const LinearGradient sleepGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x339B8CFF), Color(0x000B1020)],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E284A), Color(0xFF141B2D)],
  );

  static const LinearGradient activeTimerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2342), Color(0xFF0D1429)],
  );
}
