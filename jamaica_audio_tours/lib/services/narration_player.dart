import 'package:flutter_tts/flutter_tts.dart';

/// Speaks Spanish narration text using the on-device TTS engine.
///
/// On-device TTS works fully offline once the Spanish voice pack is
/// installed, which lets us ship the prototype without bundling large
/// pre-recorded audio files. Swapping in professionally recorded MP3s
/// later only requires replacing this class with an audio-file player
/// that points at cached files (see `docs/audio_pipeline.md`).
class NarrationPlayer {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    await _ensureInitialized();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
