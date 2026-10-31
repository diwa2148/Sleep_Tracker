import 'package:flutter/material.dart';

/// Available ambient sleep sound channels in the vintage cassette sound machine.
enum SoundTrackType {
  tapeHiss,
  midnightRain,
  synth432,
  dreamwave,
}

/// Represents an authentic analog sleep sound channel.
class SoundTrack {
  final SoundTrackType type;
  final String id;
  final String title;
  final String subtitle;
  final String frequencyLabel;
  final IconData icon;

  const SoundTrack({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.frequencyLabel,
    required this.icon,
  });

  static const List<SoundTrack> all = [
    SoundTrack(
      type: SoundTrackType.tapeHiss,
      id: 'tape_hiss',
      title: 'TAPE HISS',
      subtitle: 'Type-II Cassette Flutter',
      frequencyLabel: '2.2 kHz BP',
      icon: Icons.album_rounded,
    ),
    SoundTrack(
      type: SoundTrackType.midnightRain,
      id: 'midnight_rain',
      title: 'MIDNIGHT RAIN',
      subtitle: 'Vinyl & Soft Downpour',
      frequencyLabel: '950 Hz LP',
      icon: Icons.grain_rounded,
    ),
    SoundTrack(
      type: SoundTrackType.synth432,
      id: 'synth_432',
      title: '432HZ DRONE',
      subtitle: 'Binaural Theta Carrier',
      frequencyLabel: '432 Hz + 4Hz',
      icon: Icons.graphic_eq_rounded,
    ),
    SoundTrack(
      type: SoundTrackType.dreamwave,
      id: 'dreamwave',
      title: 'FM DREAMWAVE',
      subtitle: '80s Analog Poly Pad',
      frequencyLabel: 'Tri-Osc Sweep',
      icon: Icons.waves_rounded,
    ),
  ];
}

