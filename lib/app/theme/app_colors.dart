import 'package:flutter/material.dart';

/// Pure Black & White / Monochromatic color palette for SOMNA.
/// Built with stark high-contrast pure black, pure white, and refined grayscale steps.
class AppColors {
  AppColors._();

  // Dark Theme Palette ("Pure Noir & Obsidian Glass")
  static const Color darkBackground = Color(0xFF000000); // True pitch black
  static const Color darkSurface = Color(0xFF0D0D0D); // Deep black surface plate
  static const Color darkElevated = Color(0xFF171717); // Raised dark card
  static const Color darkCard = Color(0xFF121212); // Matte black card
  static const Color darkBorder = Color(0xFF262626); // Clean grayscale border
  static const Color darkSubtle = Color(0xFF141414);

  // Light Theme Palette ("Pure Stark White & Slate-Gray")
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure white
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white plate
  static const Color lightElevated = Color(0xFFF2F2F2); // Soft light gray
  static const Color lightCard = Color(0xFFFFFFFF); // Crisp card
  static const Color lightBorder = Color(0xFFE5E5E5); // Minimal clean border
  static const Color lightSubtle = Color(0xFFF8F8F8);

  // Modern Monochromatic Accents & Functional Colors
  // High contrast: Pure White in dark mode, Pure Black in light mode
  static const Color primary = Color(0xFFFFFFFF); // High-contrast White
  static const Color primaryLight = Color(0xFFD4D4D4); // Soft silver
  static const Color primaryDark = Color(0xFF000000); // Pure Black

  static const Color secondary = Color(0xFFA3A3A3); // Clean silver-gray
  static const Color secondaryLight = Color(0xFFE5E5E5);
  static const Color secondaryDark = Color(0xFF525252);

  static const Color positive = Color(0xFFFFFFFF); // Monochrome highlight
  static const Color positiveLight = Color(0xFFE5E5E5);
  static const Color positiveDark = Color(0xFF737373);

  static const Color warning = Color(0xFFA3A3A3); // Neutral silver gray
  static const Color warningLight = Color(0xFFD4D4D4);

  static const Color error = Color(0xFF737373); // Charcoal
  static const Color errorLight = Color(0xFFA3A3A3);

  // Sleep Quality Scale Colors (1 to 5) - Pure grayscale gradient
  static const Color rating1 = Color(0xFF404040); // Deep charcoal
  static const Color rating2 = Color(0xFF666666); // Dark gray
  static const Color rating3 = Color(0xFF8C8C8C); // Medium gray
  static const Color rating4 = Color(0xFFB8B8B8); // Light silver
  static const Color rating5 = Color(0xFFFFFFFF); // Pure white

  static const List<Color> ratingColors = [
    rating1,
    rating2,
    rating3,
    rating4,
    rating5,
  ];

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondaryDark = Color(0xFFA3A3A3); // Neutral silver
  static const Color textMutedDark = Color(0xFF737373); // Muted gray

  static const Color textPrimaryLight = Color(0xFF000000); // Pure black
  static const Color textSecondaryLight = Color(0xFF525252); // Charcoal
  static const Color textMutedLight = Color(0xFF888888); // Muted gray

  // Modern Monochromatic Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFD4D4D4)],
  );

  static const LinearGradient sleepGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x33FFFFFF), Color(0x00000000)],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
  );

  static const LinearGradient activeTimerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C1C1C), Color(0xFF0F0F0F)],
  );
}
