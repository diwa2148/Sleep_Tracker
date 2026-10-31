import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/features/sound_machine/domain/models/sound_track.dart';
import 'package:sleep_tracker/features/sound_machine/domain/services/audio_synthesizer.dart';
import 'package:sleep_tracker/features/sound_machine/presentation/sound_machine_provider.dart';

class MockAudioSynthesizer implements AudioSynthesizer {
  String? lastPlayedTrackId;
  double? lastVolume;
  bool isStopped = false;

  @override
  void play(String trackId, double volume) {
    lastPlayedTrackId = trackId;
    lastVolume = volume;
    isStopped = false;
  }

  @override
  void stop() {
    isStopped = true;
  }

  @override
  void setVolume(double volume) {
    lastVolume = volume;
  }

  @override
  void playAlarm(String alarmId, double volume) {}

  @override
  void stopAlarm() {}
}

void main() {
  group('SoundTrack Model Tests', () {
    test('SoundTrack.all contains 4 unique retro ambient tracks', () {
      expect(SoundTrack.all.length, 4);
      final ids = SoundTrack.all.map((t) => t.id).toSet();
      expect(ids.length, 4);
      expect(ids.contains('tape_hiss'), isTrue);
      expect(ids.contains('midnight_rain'), isTrue);
      expect(ids.contains('synth_432'), isTrue);
      expect(ids.contains('dreamwave'), isTrue);
    });
  });

  group('SoundMachineProvider State Tests', () {
    late MockAudioSynthesizer mockSynth;
    late SoundMachineProvider provider;

    setUp(() {
      mockSynth = MockAudioSynthesizer();
      provider = SoundMachineProvider(synthesizer: mockSynth);
    });

    tearDown(() {
      provider.dispose();
    });

    test('Initializes with stopped state and formatted zero counter', () {
      expect(provider.isPlaying, isFalse);
      expect(provider.volume, 0.65);
      expect(provider.sleepTimerMinutes, isNull);
      expect(provider.tapeCounter, 0);
      expect(provider.formattedTapeCounter, '0000');
      expect(provider.formattedTimerRemaining, '--:--');
    });

    test('playTrack sets isPlaying and forwards to synthesizer', () {
      final rain = SoundTrack.all.firstWhere((t) => t.id == 'midnight_rain');
      provider.playTrack(rain);

      expect(provider.isPlaying, isTrue);
      expect(provider.currentTrack.id, 'midnight_rain');
      expect(mockSynth.lastPlayedTrackId, 'midnight_rain');
      expect(mockSynth.lastVolume, 0.65);
      expect(mockSynth.isStopped, isFalse);
    });

    test('pause sets isPlaying to false and stops synthesizer', () {
      provider.playTrack(SoundTrack.all.first);
      expect(provider.isPlaying, isTrue);

      provider.pause();
      expect(provider.isPlaying, isFalse);
      expect(mockSynth.isStopped, isTrue);
    });

    test('togglePlay alternates between playing and paused', () {
      provider.togglePlay();
      expect(provider.isPlaying, isTrue);

      provider.togglePlay();
      expect(provider.isPlaying, isFalse);
    });

    test('setVolume clamps between 0.0 and 1.0', () {
      provider.setVolume(1.5);
      expect(provider.volume, 1.0);
      expect(mockSynth.lastVolume, 1.0);

      provider.setVolume(-0.2);
      expect(provider.volume, 0.0);
      expect(mockSynth.lastVolume, 0.0);

      provider.setVolume(0.42);
      expect(provider.volume, 0.42);
      expect(mockSynth.lastVolume, 0.42);
    });

    test('setSleepTimer updates timer minutes and formatted countdown', () {
      provider.setSleepTimer(15);
      expect(provider.sleepTimerMinutes, 15);
      expect(provider.timerSecondsRemaining, 900);
      expect(provider.formattedTimerRemaining, '15:00');

      provider.setSleepTimer(null);
      expect(provider.sleepTimerMinutes, isNull);
      expect(provider.timerSecondsRemaining, isNull);
      expect(provider.formattedTimerRemaining, '--:--');
    });
  });
}

