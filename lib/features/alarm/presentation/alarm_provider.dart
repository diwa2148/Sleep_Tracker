import 'package:flutter/material.dart';
import '../../sound_machine/domain/services/audio_synthesizer.dart';
import '../domain/models/alarm_tone.dart';

/// State management for retro wake alarm tones and live procedural preview.
class AlarmProvider with ChangeNotifier {
  final AudioSynthesizer _synthesizer;

  String _selectedToneId = '8bit_dawn';
  bool _isPreviewing = false;
  String? _previewingToneId;
  bool _gentleRampEnabled = true;
  double _volume = 0.6;

  AlarmProvider({AudioSynthesizer? synthesizer})
      : _synthesizer = synthesizer ?? AudioSynthesizer();

  String get selectedToneId => _selectedToneId;
  bool get isPreviewing => _isPreviewing;
  String? get previewingToneId => _previewingToneId;
  bool get gentleRampEnabled => _gentleRampEnabled;
  double get volume => _volume;

  AlarmTone get selectedTone => AlarmTone.all.firstWhere(
        (t) => t.id == _selectedToneId,
        orElse: () => AlarmTone.all.first,
      );

  void selectTone(String id) {
    if (_selectedToneId != id) {
      _selectedToneId = id;
      if (_isPreviewing) {
        stopPreview();
        playPreview(id);
      } else {
        notifyListeners();
      }
    }
  }

  void playPreview(String id) {
    _previewingToneId = id;
    _isPreviewing = true;
    _synthesizer.playAlarm(id, _volume);
    notifyListeners();
  }

  void stopPreview() {
    if (_isPreviewing) {
      _isPreviewing = false;
      _previewingToneId = null;
      _synthesizer.stopAlarm();
      notifyListeners();
    }
  }

  void togglePreview(String id) {
    if (_isPreviewing && _previewingToneId == id) {
      stopPreview();
    } else {
      playPreview(id);
    }
  }

  void setGentleRamp(bool enabled) {
    _gentleRampEnabled = enabled;
    notifyListeners();
  }

  void setVolume(double val) {
    _volume = val.clamp(0.0, 1.0);
    _synthesizer.setVolume(_volume);
    notifyListeners();
  }

  @override
  void dispose() {
    stopPreview();
    super.dispose();
  }
}

