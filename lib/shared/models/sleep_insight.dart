import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum InsightType {
  positive,
  neutral,
  warning,
  recommendation,
}

enum InsightCategory {
  duration,
  consistency,
  schedule,
  quality,
}

/// A deterministic, explainable sleep insight.
class SleepInsight {
  final String id;
  final String title;
  final String message;
  final InsightType type;
  final InsightCategory category;
  final String calculationExplanation;
  final IconData icon;

  const SleepInsight({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.calculationExplanation,
    required this.icon,
  });

  Color get accentColor {
    switch (type) {
      case InsightType.positive:
        return AppColors.positive;
      case InsightType.warning:
        return AppColors.warning;
      case InsightType.recommendation:
        return AppColors.secondary;
      case InsightType.neutral:
        return AppColors.primary;
    }
  }
}
