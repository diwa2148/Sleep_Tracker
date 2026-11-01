import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/features/chronotype/domain/models/chronotype.dart';

void main() {
  group('ChronotypeProfile Tests', () {
    test('contains all 4 Dr. Michael Breus archetypes', () {
      expect(ChronotypeProfile.all.length, equals(4));

      final ids = ChronotypeProfile.all.map((c) => c.id).toList();
      expect(ids, containsAll(['lion', 'bear', 'wolf', 'dolphin']));
    });

    test('findById returns correct profile and defaults to bear', () {
      final lion = ChronotypeProfile.findById('lion');
      expect(lion.name, equals('Lion'));
      expect(lion.emoji, equals('🦁'));
      expect(lion.sleepGateFormatted, contains('9:00 PM'));

      final bear = ChronotypeProfile.findById('bear');
      expect(bear.name, equals('Bear'));
      expect(bear.emoji, equals('🐻'));
      expect(bear.sleepGateFormatted, contains('10:30 PM'));

      final wolf = ChronotypeProfile.findById('wolf');
      expect(wolf.name, equals('Wolf'));
      expect(wolf.emoji, equals('🐺'));
      expect(wolf.sleepGateFormatted, contains('12:00 AM'));

      final dolphin = ChronotypeProfile.findById('dolphin');
      expect(dolphin.name, equals('Dolphin'));
      expect(dolphin.emoji, equals('🐬'));
      expect(dolphin.sleepGateFormatted, contains('11:15 PM'));

      // Unknown id fallback
      final fallback = ChronotypeProfile.findById('unknown_creature');
      expect(fallback.id, equals('bear'));
    });

    test('all archetypes have non-empty guidance, traits, and schedules', () {
      for (final profile in ChronotypeProfile.all) {
        expect(profile.name.isNotEmpty, isTrue);
        expect(profile.tagline.isNotEmpty, isTrue);
        expect(profile.description.isNotEmpty, isTrue);
        expect(profile.sleepGateFormatted.isNotEmpty, isTrue);
        expect(profile.energyPeak.isNotEmpty, isTrue);
        expect(profile.sleepDrive.isNotEmpty, isTrue);
        expect(profile.idealBedtime.hour >= 0, isTrue);
        expect(profile.idealWakeTime.hour >= 0, isTrue);
      }
    });
  });
}
