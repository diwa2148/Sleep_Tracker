import 'package:flutter/material.dart';

/// Represents a recommended sleep target based on 90-minute ultradian sleep cycles.
class SleepCycleTarget {
  final int cycles;
  final DateTime targetTime;
  final Duration sleepDuration;
  final bool isOptimal;
  final String note;

  const SleepCycleTarget({
    required this.cycles,
    required this.targetTime,
    required this.sleepDuration,
    this.isOptimal = false,
    required this.note,
  });

  String get formattedDuration {
    final h = sleepDuration.inHours;
    final m = sleepDuration.inMinutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String get formattedTime {
    final hour = targetTime.hour;
    final minute = targetTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    return '$displayHour:$minute $period';
  }
}

/// Computes scientific 90-minute ultradian sleep cycles to avoid sleep inertia.
///
/// Human sleep cycles through light, deep, and REM sleep in approximately 90-minute intervals.
/// Waking up at the completion of a cycle leaves a person feeling refreshed rather than groggy.
/// Also incorporates standard 15-minute sleep latency (average time to fall asleep).
class SleepCycleCalculator {
  SleepCycleCalculator._();

  static const int cycleMinutes = 90;
  static const int fallAsleepLatencyMinutes = 15;

  /// Calculates the best times to wake up if going to bed at [bedtime].
  /// Default cycle counts: 6 cycles (9h), 5 cycles (7.5h - optimal), 4 cycles (6h), 3 cycles (4.5h).
  static List<SleepCycleTarget> calculateWakeTimes(DateTime bedtime) {
    final sleepStart =
        bedtime.add(const Duration(minutes: fallAsleepLatencyMinutes));

    return [
      SleepCycleTarget(
        cycles: 6,
        targetTime: sleepStart.add(const Duration(minutes: 6 * cycleMinutes)),
        sleepDuration: const Duration(minutes: 6 * cycleMinutes),
        isOptimal: false,
        note: 'Full Rest • 9.0h',
      ),
      SleepCycleTarget(
        cycles: 5,
        targetTime: sleepStart.add(const Duration(minutes: 5 * cycleMinutes)),
        sleepDuration: const Duration(minutes: 5 * cycleMinutes),
        isOptimal: true,
        note: 'Optimal Rhythm • 7.5h',
      ),
      SleepCycleTarget(
        cycles: 4,
        targetTime: sleepStart.add(const Duration(minutes: 4 * cycleMinutes)),
        sleepDuration: const Duration(minutes: 4 * cycleMinutes),
        isOptimal: false,
        note: 'Standard Rest • 6.0h',
      ),
      SleepCycleTarget(
        cycles: 3,
        targetTime: sleepStart.add(const Duration(minutes: 3 * cycleMinutes)),
        sleepDuration: const Duration(minutes: 3 * cycleMinutes),
        isOptimal: false,
        note: 'Short Rest • 4.5h',
      ),
    ];
  }

  /// Calculates the best times to go to bed to wake up refreshed at [wakeTime].
  static List<SleepCycleTarget> calculateBedtimes({
    required TimeOfDay wakeTime,
    DateTime? referenceDate,
  }) {
    final base = referenceDate ?? DateTime.now();
    var targetWake = DateTime(
      base.year,
      base.month,
      base.day,
      wakeTime.hour,
      wakeTime.minute,
    );

    // If target wake time is already in the past today, target tomorrow morning
    if (targetWake.isBefore(base)) {
      targetWake = targetWake.add(const Duration(days: 1));
    }

    return [
      SleepCycleTarget(
        cycles: 6,
        targetTime: targetWake
            .subtract(const Duration(minutes: 6 * cycleMinutes + fallAsleepLatencyMinutes)),
        sleepDuration: const Duration(minutes: 6 * cycleMinutes),
        isOptimal: false,
        note: 'Full Rest • 9.0h',
      ),
      SleepCycleTarget(
        cycles: 5,
        targetTime: targetWake
            .subtract(const Duration(minutes: 5 * cycleMinutes + fallAsleepLatencyMinutes)),
        sleepDuration: const Duration(minutes: 5 * cycleMinutes),
        isOptimal: true,
        note: 'Optimal Rhythm • 7.5h',
      ),
      SleepCycleTarget(
        cycles: 4,
        targetTime: targetWake
            .subtract(const Duration(minutes: 4 * cycleMinutes + fallAsleepLatencyMinutes)),
        sleepDuration: const Duration(minutes: 4 * cycleMinutes),
        isOptimal: false,
        note: 'Standard Rest • 6.0h',
      ),
      SleepCycleTarget(
        cycles: 3,
        targetTime: targetWake
            .subtract(const Duration(minutes: 3 * cycleMinutes + fallAsleepLatencyMinutes)),
        sleepDuration: const Duration(minutes: 3 * cycleMinutes),
        isOptimal: false,
        note: 'Short Rest • 4.5h',
      ),
    ];
  }
}

