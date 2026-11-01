import 'package:flutter/material.dart';

/// Modern Cosmic Aurora & Twilight Lavender color palette for SOMNA.
/// Engineered with harmonious sleep-wellness gradients, glittering starlight accents,
/// and luminous dark/light modes.
class AppColors {
  AppColors._();

  // Dark Theme Palette ("Cosmic Obsidian & Deep Nebula")
  static const Color darkBackground = Color(0xFF090D16); // Deep space obsidian
  static const Color darkSurface = Color(0xFF0F172A); // Slate obsidian glass plate
  static const Color darkElevated = Color(0xFF1E293B); // Raised slate card
  static const Color darkCard = Color(0xFF131C31); // Luminous cosmic navy card
  static const Color darkBorder = Color(0xFF24334D); // Soft translucent indigo border
  static const Color darkSubtle = Color(0xFF1A243B);

  // Light Theme Palette ("Luminous Cloud & Twilight Frost")
  static const Color lightBackground = Color(0xFFF8FAFC); // Clean luminous off-white
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure frosted white plate
  static const Color lightElevated = Color(0xFFF1F5F9); // Soft light gray-slate
  static const Color lightCard = Color(0xFFFFFFFF); // Clean white card
  static const Color lightBorder = Color(0xFFE2E8F0); // Minimal clean border
  static const Color lightSubtle = Color(0xFFF8FAFC);

  // Modern Wellness Brand Accents
  static const Color primary = Color(0xFF8B5CF6); // Electric Lavender Violet
  static const Color primaryLight = Color(0xFFA78BFA); // Soft Lilac
  static const Color primaryDark = Color(0xFF6366F1); // Royal Indigo (Light mode primary)

  static const Color secondary = Color(0xFF38BDF8); // Luminous Celestial Cyan
  static const Color secondaryLight = Color(0xFF7DD3FC);
  static const Color secondaryDark = Color(0xFF0284C7); // Deep Ocean Blue

  static const Color accent = Color(0xFF7C3AED); // Deep Violet
  static const Color starlightGold = Color(0xFFFBBF24); // Twinkling Starlight Gold

  static const Color positive = Color(0xFF10B981); // Restorative Aurora Emerald
  static const Color positiveLight = Color(0xFF34D399); // Luminous Mint
  static const Color positiveDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B); // Warm Twilight Amber
  static const Color warningLight = Color(0xFFFCD34D);

  static const Color error = Color(0xFFF43F5E); // Sunset Coral / Rose
  static const Color errorLight = Color(0xFFFDA4AF);

  // Sleep Architecture Hypnogram Stage Colors
  static const Color deepSleep = Color(0xFF6366F1); // Deep Royal Indigo (20-25%)
  static const Color remSleep = Color(0xFF38BDF8); // Luminous Electric Cyan (20-25%)
  static const Color lightSleep = Color(0xFFA78BFA); // Soft Dream Lavender (45-55%)
  static const Color awake = Color(0xFFFB7185); // Morning Coral Glow (5-10%)

  // Sleep Quality Scale Colors (1 to 5) - Vibrant Chromatic Spectrum
  static const Color rating1 = Color(0xFFF43F5E); // Poor - Vivid Rose Coral
  static const Color rating2 = Color(0xFFFB923C); // Fair - Sunset Tangerine
  static const Color rating3 = Color(0xFFFBBF24); // Good - Golden Amber
  static const Color rating4 = Color(0xFF34D399); // Great - Aurora Mint
  static const Color rating5 = Color(0xFF8B5CF6); // Excellent - Celestial Starlight Violet

  static const List<Color> ratingColors = [
    rating1,
    rating2,
    rating3,
    rating4,
    rating5,
  ];

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Crisp white
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Soft slate silver
  static const Color textMutedDark = Color(0xFF64748B); // Muted slate gray

  static const Color textPrimaryLight = Color(0xFF0F172A); // Deep slate charcoal
  static const Color textSecondaryLight = Color(0xFF475569); // Medium slate
  static const Color textMutedLight = Color(0xFF94A3B8); // Muted gray

  // Modern Luminous Gradients & Glitter Glows
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF38BDF8)],
  );

  static const LinearGradient auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF38BDF8), Color(0xFF10B981)],
  );

  static const LinearGradient starlightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFF43F5E)],
  );

  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF38BDF8)],
  );

  static const LinearGradient sleepGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x338B5CF6), Color(0x00000000)],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A233D), Color(0xFF131C31)],
  );

  static const LinearGradient activeTimerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
  );
}
