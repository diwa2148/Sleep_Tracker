// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'audio_synthesizer.dart';

AudioSynthesizer createAudioSynthesizer() => _WebAudioSynthesizer();

class _WebAudioSynthesizer implements AudioSynthesizer {
  @override
  void play(String trackId, double volume) {
    try {
      final synth = js.context['SomnaAudioSynth'];
      if (synth != null) {
        synth.callMethod('play', [trackId, volume]);
      }
    } catch (_) {}
  }

  @override
  void stop() {
    try {
      final synth = js.context['SomnaAudioSynth'];
      if (synth != null) {
        synth.callMethod('stop');
      }
    } catch (_) {}
  }

  @override
  void setVolume(double volume) {
    try {
      final synth = js.context['SomnaAudioSynth'];
      if (synth != null) {
        synth.callMethod('setVolume', [volume]);
      }
    } catch (_) {}
  }

  @override
  void playAlarm(String alarmId, double volume) {
    try {
      final synth = js.context['SomnaAudioSynth'];
      if (synth != null) {
        synth.callMethod('playAlarm', [alarmId, volume]);
      }
    } catch (_) {}
  }

  @override
  void stopAlarm() {
    try {
      final synth = js.context['SomnaAudioSynth'];
      if (synth != null) {
        synth.callMethod('stopAlarm');
      }
    } catch (_) {}
  }
}
