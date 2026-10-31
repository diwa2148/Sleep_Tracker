import 'audio_synthesizer.dart';

AudioSynthesizer createAudioSynthesizer() => _StubAudioSynthesizer();

class _StubAudioSynthesizer implements AudioSynthesizer {
  @override
  void play(String trackId, double volume) {}

  @override
  void stop() {}

  @override
  void setVolume(double volume) {}

  @override
  void playAlarm(String alarmId, double volume) {}

  @override
  void stopAlarm() {}
}

