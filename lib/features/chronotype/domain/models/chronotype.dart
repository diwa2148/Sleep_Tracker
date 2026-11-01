import 'package:flutter/material.dart';

enum ChronotypeType { lion, bear, wolf, dolphin }

/// Domain model representing one of Dr. Michael Breus's 4 circadian chronotypes.
class ChronotypeProfile {
  final ChronotypeType type;
  final String name;
  final String emoji;
  final String tagline;
  final String description;
  final int idealBedtimeMinutes; // Minutes from midnight
  final int idealWakeMinutes; // Minutes from midnight
  final int sleepGateStartMinutes;
  final int sleepGateEndMinutes;
  final String energyPeak;
  final String sleepDrive;

  const ChronotypeProfile({
    required this.type,
    required this.name,
    required this.emoji,
    required this.tagline,
    required this.description,
    required this.idealBedtimeMinutes,
    required this.idealWakeMinutes,
    required this.sleepGateStartMinutes,
    required this.sleepGateEndMinutes,
    required this.energyPeak,
    required this.sleepDrive,
  });

  String get id => type.name;

  String get sleepGateFormatted {
    final startH = sleepGateStartMinutes ~/ 60;
    final startM = sleepGateStartMinutes % 60;
    final endH = sleepGateEndMinutes ~/ 60;
    final endM = sleepGateEndMinutes % 60;

    String fmt(int h, int m) {
      final period = h >= 12 ? 'PM' : 'AM';
      final dh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$dh:${m.toString().padLeft(2, '0')} $period';
    }

    return '${fmt(startH, startM)} – ${fmt(endH, endM)}';
  }

  TimeOfDay get idealBedtime {
    final h = idealBedtimeMinutes ~/ 60;
    final m = idealBedtimeMinutes % 60;
    return TimeOfDay(hour: h % 24, minute: m);
  }

  TimeOfDay get idealWakeTime {
    final h = idealWakeMinutes ~/ 60;
    final m = idealWakeMinutes % 60;
    return TimeOfDay(hour: h % 24, minute: m);
  }

  static const ChronotypeProfile lion = ChronotypeProfile(
    type: ChronotypeType.lion,
    name: 'Lion',
    emoji: '🦁',
    tagline: 'The Early Riser & Dawn Hunter',
    description:
        'Wakes effortlessly before dawn, achieves maximum cognitive focus in early morning, and requires early sleep onset before 10:00 PM.',
    idealBedtimeMinutes: 1290, // 21:30 (09:30 PM)
    idealWakeMinutes: 330, // 05:30 (05:30 AM)
    sleepGateStartMinutes: 1260, // 21:00
    sleepGateEndMinutes: 1320, // 22:00
    energyPeak: '08:00 AM – 12:00 PM (Morning Surge)',
    sleepDrive: 'Early evening melatonin rise with high morning alertness',
  );

  static const ChronotypeProfile bear = ChronotypeProfile(
    type: ChronotypeType.bear,
    name: 'Bear',
    emoji: '🐻',
    tagline: 'The Solar Circadian Anchor',
    description:
        'Follows natural solar daylight cycles. Steady productivity across midday with natural sleep pressure peaking between 10:30 PM and 11:30 PM.',
    idealBedtimeMinutes: 1380, // 23:00 (11:00 PM)
    idealWakeMinutes: 420, // 07:00 (07:00 AM)
    sleepGateStartMinutes: 1350, // 22:30
    sleepGateEndMinutes: 1410, // 23:30
    energyPeak: '10:00 AM – 02:00 PM (Midday Focus)',
    sleepDrive: 'Balanced solar melatonin curve; ~55% of population',
  );

  static const ChronotypeProfile wolf = ChronotypeProfile(
    type: ChronotypeType.wolf,
    name: 'Wolf',
    emoji: '🐺',
    tagline: 'The Night Stalker & Creative Owl',
    description:
        'Slow morning onset with delayed phase rhythm. Reaches peak creative focus in late evening and thrives with post-midnight bedtimes.',
    idealBedtimeMinutes: 30, // 00:30 (12:30 AM)
    idealWakeMinutes: 510, // 08:30 (08:30 AM)
    sleepGateStartMinutes: 0, // 00:00
    sleepGateEndMinutes: 60, // 01:00
    energyPeak: '05:00 PM – 10:00 PM (Evening Flow)',
    sleepDrive: 'Delayed circadian phase melatonin; ~15% of population',
  );

  static const ChronotypeProfile dolphin = ChronotypeProfile(
    type: ChronotypeType.dolphin,
    name: 'Dolphin',
    emoji: '🐬',
    tagline: 'The Sensitive Unihemispheric Sleeper',
    description:
        'Light sleeper with heightened sensitivity to noise and light. Experiences nervous evening energy and sporadic afternoon alertness peaks.',
    idealBedtimeMinutes: 1410, // 23:30 (11:30 PM)
    idealWakeMinutes: 390, // 06:30 (06:30 AM)
    sleepGateStartMinutes: 1395, // 23:15
    sleepGateEndMinutes: 15, // 00:15
    energyPeak: '03:00 PM – 06:00 PM (Afternoon Alertness)',
    sleepDrive: 'Fragmented sleep pressure with lighter REM thresholds',
  );

  static List<ChronotypeProfile> get all => [lion, bear, wolf, dolphin];

  static ChronotypeProfile fromType(ChronotypeType type) {
    switch (type) {
      case ChronotypeType.lion:
        return lion;
      case ChronotypeType.bear:
        return bear;
      case ChronotypeType.wolf:
        return wolf;
      case ChronotypeType.dolphin:
        return dolphin;
    }
  }

  static ChronotypeProfile fromString(String? key) {
    switch (key?.toLowerCase()) {
      case 'lion':
        return lion;
      case 'wolf':
        return wolf;
      case 'dolphin':
        return dolphin;
      case 'bear':
      default:
        return bear;
    }
  }

  static ChronotypeProfile findById(String? key) => fromString(key);
}
