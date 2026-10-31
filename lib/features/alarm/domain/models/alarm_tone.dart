import 'package:flutter/material.dart';

/// Predefined procedural retro synthesizer wake-up alarm tones.
class AlarmTone {
  final String id;
  final String name;
  final String badge;
  final String subtitle;
  final IconData icon;

  const AlarmTone({
    required this.id,
    required this.name,
    required this.badge,
    required this.subtitle,
    required this.icon,
  });

  static const List<AlarmTone> all = [
    AlarmTone(
      id: '8bit_dawn',
      name: '8-Bit Dawn',
      badge: 'CHIP-8',
      subtitle: 'Rising Game Boy pentatonic arpeggios',
      icon: Icons.videogame_asset_rounded,
    ),
    AlarmTone(
      id: 'fm_chime',
      name: 'FM Chime',
      badge: 'DX-7',
      subtitle: 'Warm 2-operator electric piano bells',
      icon: Icons.piano_rounded,
    ),
    AlarmTone(
      id: 'analog_sunrise',
      name: 'Analog Sunrise',
      badge: 'VCO-SWEEP',
      subtitle: 'Warm resonant lowpass synthesizer sweep',
      icon: Icons.wb_sunny_rounded,
    ),
    AlarmTone(
      id: 'quartz_beep',
      name: 'Quartz Beep',
      badge: 'F-91W',
      subtitle: 'Authentic 2048Hz digital watch chirp',
      icon: Icons.alarm_rounded,
    ),
  ];
}

