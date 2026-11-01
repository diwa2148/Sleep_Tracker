import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/features/sleep_cycle/domain/sleep_cycle_calculator.dart';

void main() {
  group('SleepCycleCalculator Tests', () {
    test('calculateWakeTimes calculates 4 target cycles with 15m latency', () {
      final bedtime = DateTime(2026, 10, 26, 23, 0); // 11:00 PM
      final targets = SleepCycleCalculator.calculateWakeTimes(bedtime);

      expect(targets.length, equals(4));

      // 6 cycles = 9 hours + 15m -> 08:15 AM
      final c6 = targets.firstWhere((t) => t.cycles == 6);
      expect(c6.targetTime, equals(DateTime(2026, 10, 27, 8, 15)));
      expect(c6.sleepDuration.inMinutes, equals(540));
      expect(c6.isOptimal, isFalse);

      // 5 cycles = 7.5 hours + 15m -> 06:45 AM (optimal)
      final c5 = targets.firstWhere((t) => t.cycles == 5);
      expect(c5.targetTime, equals(DateTime(2026, 10, 27, 6, 45)));
      expect(c5.sleepDuration.inMinutes, equals(450));
      expect(c5.isOptimal, isTrue);

      // 4 cycles = 6 hours + 15m -> 05:15 AM
      final c4 = targets.firstWhere((t) => t.cycles == 4);
      expect(c4.targetTime, equals(DateTime(2026, 10, 27, 5, 15)));

      // 3 cycles = 4.5 hours + 15m -> 03:45 AM
      final c3 = targets.firstWhere((t) => t.cycles == 3);
      expect(c3.targetTime, equals(DateTime(2026, 10, 27, 3, 45)));
    });

    test('calculateBedtimes calculates ideal bedtimes for target wake-up', () {
      const wakeTime = TimeOfDay(hour: 7, minute: 0); // 7:00 AM
      final ref = DateTime(2026, 10, 26, 12, 0); // noon
      final targets = SleepCycleCalculator.calculateBedtimes(
        wakeTime: wakeTime,
        referenceDate: ref,
      );

      expect(targets.length, equals(4));

      // Target wake: 2026-10-27 07:00
      // 5 cycles = 7.5h + 15m = 7h 45m before 7:00 AM -> 11:15 PM previous night
      final c5 = targets.firstWhere((t) => t.cycles == 5);
      expect(c5.targetTime, equals(DateTime(2026, 10, 26, 23, 15)));
      expect(c5.formattedTime, equals('11:15 PM'));
      expect(c5.isOptimal, isTrue);

      // 6 cycles = 9h + 15m = 9h 15m before 7:00 AM -> 09:45 PM previous night
      final c6 = targets.firstWhere((t) => t.cycles == 6);
      expect(c6.targetTime, equals(DateTime(2026, 10, 26, 21, 45)));
      expect(c6.formattedTime, equals('9:45 PM'));
    });

    test('calculateSmartWakeWindow calculates cycle-aligned window with leeway', () {
      const bedtime = TimeOfDay(hour: 23, minute: 0); // 11:00 PM
      const targetWake = TimeOfDay(hour: 7, minute: 0); // 7:00 AM

      // 1. Leeway 0 (Disabled) -> exact wake time
      final w0 = SleepCycleCalculator.calculateSmartWakeWindow(
        bedtime: bedtime,
        targetWakeTime: targetWake,
        leewayMinutes: 0,
      );
      expect(w0.leewayMinutes, equals(0));
      expect(w0.optimalWakeTime.hour, equals(7));
      expect(w0.optimalWakeTime.minute, equals(0));
      expect(w0.formattedRange, contains('7:00 AM'));

      // 2. Leeway 15 -> checks cycle end within [6:45 AM, 7:00 AM]
      // 5 cycles from 11:00 PM with 15m latency = 11:00 PM + 15m + 450m = 06:45 AM
      final w15 = SleepCycleCalculator.calculateSmartWakeWindow(
        bedtime: bedtime,
        targetWakeTime: targetWake,
        leewayMinutes: 15,
      );
      expect(w15.leewayMinutes, equals(15));
      expect(w15.optimalWakeTime.hour, equals(6));
      expect(w15.optimalWakeTime.minute, equals(45));
      expect(w15.formattedRange, contains('6:45 AM'));

      // 3. Leeway 30 -> checks cycle end within [6:30 AM, 7:00 AM]
      final w30 = SleepCycleCalculator.calculateSmartWakeWindow(
        bedtime: bedtime,
        targetWakeTime: targetWake,
        leewayMinutes: 30,
      );
      expect(w30.leewayMinutes, equals(30));
      expect(w30.targetCycles, equals(5));
      expect(w30.formattedRange, contains('6:30 AM'));
    });
  });
}

