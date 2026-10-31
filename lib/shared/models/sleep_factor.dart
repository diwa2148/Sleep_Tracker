import '../../core/utils/date_time_formatter.dart';

/// Expected health direction of a sleep factor.
enum FactorImpactType { positive, negative, neutral }

/// Predefined lifestyle habit factors affecting sleep.
class SleepFactor {
  final String key;
  final String name;
  final String label;
  final String emoji;
  final FactorImpactType expectedImpact;

  const SleepFactor({
    required this.key,
    required this.name,
    required this.label,
    required this.emoji,
    this.expectedImpact = FactorImpactType.neutral,
  });

  static const List<SleepFactor> all = [
    SleepFactor(
      key: 'caffeine',
      name: 'Caffeine',
      label: '☕ Caffeine',
      emoji: '☕',
      expectedImpact: FactorImpactType.negative,
    ),
    SleepFactor(
      key: 'workout',
      name: 'Workout',
      label: '🏃 Workout',
      emoji: '🏃',
      expectedImpact: FactorImpactType.positive,
    ),
    SleepFactor(
      key: 'screen',
      name: 'Late Screen',
      label: '📱 Late Screen',
      emoji: '📱',
      expectedImpact: FactorImpactType.negative,
    ),
    SleepFactor(
      key: 'reading',
      name: 'Reading',
      label: '📖 Reading',
      emoji: '📖',
      expectedImpact: FactorImpactType.positive,
    ),
    SleepFactor(
      key: 'meditated',
      name: 'Meditated',
      label: '🧘 Meditated',
      emoji: '🧘',
      expectedImpact: FactorImpactType.positive,
    ),
    SleepFactor(
      key: 'cool_room',
      name: 'Cool Room',
      label: '❄️ Cool Room',
      emoji: '❄️',
      expectedImpact: FactorImpactType.positive,
    ),
    SleepFactor(
      key: 'alcohol',
      name: 'Alcohol',
      label: '🍷 Alcohol',
      emoji: '🍷',
      expectedImpact: FactorImpactType.negative,
    ),
    SleepFactor(
      key: 'stress',
      name: 'Stress',
      label: '⚡ Stress',
      emoji: '⚡',
      expectedImpact: FactorImpactType.negative,
    ),
  ];
}

/// Statistical correlation between a habit factor and sleep duration / quality.
class FactorCorrelation {
  final SleepFactor factor;
  final int occurrences;
  final int avgDurationMinutesWith;
  final int avgDurationMinutesWithout;
  final double avgQualityWith;
  final double avgQualityWithout;

  const FactorCorrelation({
    required this.factor,
    required this.occurrences,
    required this.avgDurationMinutesWith,
    required this.avgDurationMinutesWithout,
    required this.avgQualityWith,
    required this.avgQualityWithout,
  });

  /// Net duration delta: positive = more sleep with factor, negative = less sleep.
  int get durationDiffMinutes =>
      avgDurationMinutesWith - avgDurationMinutesWithout;

  /// Net quality rating delta (e.g. +0.8 or -0.5 stars).
  double get qualityDiff => avgQualityWith - avgQualityWithout;

  /// Human-readable impact summary string.
  String get formattedDurationDiff {
    final diff = durationDiffMinutes;
    if (diff == 0) return '±0m';
    final prefix = diff > 0 ? '+' : '-';
    return '$prefix${DateTimeFormatter.formatMinutes(diff.abs())}';
  }

  /// Whether this correlation had a positive overall impact.
  bool get isPositiveImpact => durationDiffMinutes > 15 || qualityDiff >= 0.3;

  /// Whether this correlation had a negative overall impact.
  bool get isNegativeImpact => durationDiffMinutes < -15 || qualityDiff <= -0.3;
}

