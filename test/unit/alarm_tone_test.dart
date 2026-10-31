import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/features/alarm/domain/models/alarm_tone.dart';
import 'package:sleep_tracker/features/alarm/presentation/alarm_provider.dart';
import 'package:sleep_tracker/features/sound_machine/domain/services/audio_synthesizer.dart';

class MockAudioSynthesizer implements AudioSynthesizer {
  String? playedAlarmId;
  double? playedAlarmVolume;
  bool isAlarmStopped = false;
  double volume = 0.5;

  @override
  void play(String trackId, double volume) {}

  @override
  void stop() {}

  @override
  void setVolume(double vol) {
    volume = vol;
  }

  @override
  void playAlarm(String alarmId, double vol) {
    playedAlarmId = alarmId;
    playedAlarmVolume = vol;
    isAlarmStopped = false;
  }

  @override
  void stopAlarm() {
    isAlarmStopped = true;
  }
}

void main() {
  group('AlarmTone Model Tests', () {
    test('AlarmTone.all contains 4 unique retro synth alarm tones', () {
      expect(AlarmTone.all.length, equals(4));
      final ids = AlarmTone.all.map((t) => t.id).toSet();
      expect(ids.length, equals(4));
      expect(ids, contains('8bit_dawn'));
      expect(ids, contains('fm_chime'));
      expect(ids, contains('analog_sunrise'));
      expect(ids, contains('quartz_beep'));
    });
  });

  group('AlarmProvider State Tests', () {
    late MockAudioSynthesizer mockSynth;
    late AlarmProvider provider;

    setUp(() {
      mockSynth = MockAudioSynthesizer();
      provider = AlarmProvider(synthesizer: mockSynth);
    });

    test('Initializes with default 8bit_dawn and stopped state', () {
      expect(provider.selectedToneId, equals('8bit_dawn'));
      expect(provider.isPreviewing, isFalse);
      expect(provider.previewingToneId, isNull);
      expect(provider.gentleRampEnabled, isTrue);
    });

    test('selectTone updates selected tone', () {
      provider.selectTone('fm_chime');
      expect(provider.selectedToneId, equals('fm_chime'));
      expect(provider.selectedTone.name, equals('FM Chime'));
    });

    test('playPreview and stopPreview control synthesizer correctly', () {
      provider.playPreview('analog_sunrise');
      expect(provider.isPreviewing, isTrue);
      expect(provider.previewingToneId, equals('analog_sunrise'));
      expect(mockSynth.playedAlarmId, equals('analog_sunrise'));

      provider.stopPreview();
      expect(provider.isPreviewing, isFalse);
      expect(provider.previewingToneId, isNull);
      expect(mockSynth.isAlarmStopped, isTrue);
    });

    test('togglePreview toggles preview on and off for same tone', () {
      provider.togglePreview('quartz_beep');
      expect(provider.isPreviewing, isTrue);
      expect(mockSynth.playedAlarmId, equals('quartz_beep'));

      provider.togglePreview('quartz_beep');
      expect(provider.isPreviewing, isFalse);
      expect(mockSynth.isAlarmStopped, isTrue);
    });

    test('setGentleRamp toggles gentle 30s ramp', () {
      provider.setGentleRamp(false);
      expect(provider.gentleRampEnabled, isFalse);

      provider.setGentleRamp(true);
      expect(provider.gentleRampEnabled, isTrue);
    });
  });
}

