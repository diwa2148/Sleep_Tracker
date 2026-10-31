import 'audio_synthesizer_stub.dart'
    if (dart.library.js) 'audio_synthesizer_web.dart'
    as impl;

/// Cross-platform interface for ambient sleep sound synthesis.
abstract class AudioSynthesizer {
  factory AudioSynthesizer() => impl.createAudioSynthesizer();

  void play(String trackId, double volume);
  void stop();
  void setVolume(double volume);
  void playAlarm(String alarmId, double volume);
  void stopAlarm();
}
