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

/// Represents a cycle-aware wake window calculating the optimal time within a leeway window
/// to wake up at the conclusion of a 90-minute REM cycle.
class SmartWakeWindow {
  final TimeOfDay targetWakeTime;
  final TimeOfDay windowStart;
  final TimeOfDay windowEnd;
  final TimeOfDay optimalWakeTime;
  final int targetCycles;
  final int leewayMinutes;
  final String statusSummary;
  final String syncNote;

  const SmartWakeWindow({
    required this.targetWakeTime,
    required this.windowStart,
    required this.windowEnd,
    required this.optimalWakeTime,
    required this.targetCycles,
    required this.leewayMinutes,
    required this.statusSummary,
    required this.syncNote,
  });

  String get formattedRange {
    if (leewayMinutes == 0) {
      return '${formatTime(targetWakeTime)} (FIXED)';
    }
    return '[ ${formatTime(windowStart)} ↔ ${formatTime(windowEnd)} ]';
  }

  static String formatTime(TimeOfDay tod) {
    final h = tod.hour;
    final m = tod.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final dh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$dh:$m $period';
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

  /// Calculates a Cycle-Aware Smart Wake Window for [targetWakeTime] relative to [bedtime]
  /// and user-selected [leewayMinutes] (0 for OFF, 15m, or 30m).
  static SmartWakeWindow calculateSmartWakeWindow({
    required TimeOfDay targetWakeTime,
    required TimeOfDay bedtime,
    required int leewayMinutes,
  }) {
    if (leewayMinutes <= 0) {
      return SmartWakeWindow(
        targetWakeTime: targetWakeTime,
        windowStart: targetWakeTime,
        windowEnd: targetWakeTime,
        optimalWakeTime: targetWakeTime,
        targetCycles: 5,
        leewayMinutes: 0,
        statusSummary: 'OFF • EXACT ALARM',
        syncNote: 'Alarm sounds strictly at set target without cycle leeway.',
      );
    }

    final targetWakeMins = targetWakeTime.hour * 60 + targetWakeTime.minute;
    int bedMins = bedtime.hour * 60 + bedtime.minute;
    if (targetWakeMins <= bedMins) {
      bedMins -= 1440; // overnight
    }

    // Sleep onset after standard fall-asleep latency
    final sleepOnsetMins = bedMins + fallAsleepLatencyMinutes;
    final windowStartMins = targetWakeMins - leewayMinutes;

    // Evaluate cycles 3, 4, 5, 6
    int bestCycle = 5;
    int bestCompletionMins = sleepOnsetMins + (5 * cycleMinutes);
    int bestDiff = 999999;

    for (final c in [6, 5, 4, 3]) {
      final completion = sleepOnsetMins + (c * cycleMinutes);
      if (completion >= windowStartMins && completion <= targetWakeMins) {
        bestCycle = c;
        bestCompletionMins = completion;
        break;
      }
      final diff = (targetWakeMins - completion).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestCycle = c;
        bestCompletionMins = completion;
      }
    }

    // Clamp within the leeway window
    final clampedOptimalMins =
        bestCompletionMins.clamp(windowStartMins, targetWakeMins);
    final optH = (clampedOptimalMins ~/ 60) % 24;
    final optM = clampedOptimalMins % 60;
    final startH = (windowStartMins ~/ 60) % 24;
    final startM = windowStartMins % 60;

    final optTod =
        TimeOfDay(hour: (optH + 24) % 24, minute: (optM + 60) % 60);
    final startTod =
        TimeOfDay(hour: (startH + 24) % 24, minute: (startM + 60) % 60);

    final durationHours = (bestCycle * 1.5).toStringAsFixed(1);

    return SmartWakeWindow(
      targetWakeTime: targetWakeTime,
      windowStart: startTod,
      windowEnd: targetWakeTime,
      optimalWakeTime: optTod,
      targetCycles: bestCycle,
      leewayMinutes: leewayMinutes,
      statusSummary: '±${leewayMinutes}M CYCLE HARMONIC',
      syncNote:
          'Targets $bestCycle cycles ($durationHours h) completion at ${SmartWakeWindow.formatTime(optTod)} to avoid REM interruption.',
    );
  }
}

