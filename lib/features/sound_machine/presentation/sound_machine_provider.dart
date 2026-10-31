import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/models/sound_track.dart';
import '../domain/services/audio_synthesizer.dart';

/// State management for the Vintage Cassette Ambient Sound Deck.
class SoundMachineProvider extends ChangeNotifier {
  final AudioSynthesizer _synthesizer;

  bool _isPlaying = false;
  SoundTrack _currentTrack = SoundTrack.all.first;
  double _volume = 0.65;
  int? _sleepTimerMinutes;
  int? _timerSecondsRemaining;
  int _tapeCounter = 0;
  Timer? _ticker;

  SoundMachineProvider({AudioSynthesizer? synthesizer})
      : _synthesizer = synthesizer ?? AudioSynthesizer();

  bool get isPlaying => _isPlaying;
  SoundTrack get currentTrack => _currentTrack;
  double get volume => _volume;
  int? get sleepTimerMinutes => _sleepTimerMinutes;
  int? get timerSecondsRemaining => _timerSecondsRemaining;
  int get tapeCounter => _tapeCounter;

  String get formattedTapeCounter {
    return _tapeCounter.toString().padLeft(4, '0');
  }

  String get formattedTimerRemaining {
    if (_timerSecondsRemaining == null) return '--:--';
    final m = (_timerSecondsRemaining! ~/ 60).toString().padLeft(2, '0');
    final s = (_timerSecondsRemaining! % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void playTrack(SoundTrack track) {
    _currentTrack = track;
    _isPlaying = true;
    _synthesizer.play(track.id, _volume);
    _startTicker();
    notifyListeners();
  }

  void togglePlay() {
    if (_isPlaying) {
      pause();
    } else {
      playTrack(_currentTrack);
    }
  }

  void pause() {
    _isPlaying = false;
    _synthesizer.stop();
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }

  void setVolume(double val) {
    _volume = val.clamp(0.0, 1.0);
    _synthesizer.setVolume(_volume);
    notifyListeners();
  }

  void setSleepTimer(int? minutes) {
    _sleepTimerMinutes = minutes;
    if (minutes != null) {
      _timerSecondsRemaining = minutes * 60;
    } else {
      _timerSecondsRemaining = null;
    }
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }

      _tapeCounter++;

      if (_timerSecondsRemaining != null) {
        _timerSecondsRemaining = _timerSecondsRemaining! - 1;
        if (_timerSecondsRemaining! <= 0) {
          pause();
          _timerSecondsRemaining = null;
          _sleepTimerMinutes = null;
        }
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _synthesizer.stop();
    super.dispose();
  }
}

