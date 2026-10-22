import 'package:flutter_tts/flutter_tts.dart';

/// Device TTS narration for Seerah stories (Phase 2).
/// Zero cost, works offline on most devices. The no-TTS rule applies ONLY
/// to Quranic text — story narration via TTS is allowed (GAME_PLAN.md §6/§8).
class Narration {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool _speaking = false;

  /// BCP-47 codes per UI language. Pure const for testability.
  static const langCodes = {
    'en': 'en-US',
    'ur': 'ur-PK',
    'ar': 'ar-SA',
  };

  bool get isSpeaking => _speaking;

  Future<void> init() async {
    try {
      await _tts.setSpeechRate(0.45); // slower for kids
      await _tts.setPitch(1.1);
      await _tts.setVolume(1.0);
      _tts.setCompletionHandler(() => _speaking = false);
      _tts.setCancelHandler(() => _speaking = false);
      _tts.setErrorHandler((_) => _speaking = false);
      _ready = true;
    } catch (_) {
      // Narration is best-effort; the story text is always visible.
    }
  }

  Future<void> speak(String text, String lang) async {
    if (!_ready || text.isEmpty) return;
    try {
      await _tts.stop();
      await _tts.setLanguage(langCodes[lang] ?? 'en-US');
      _speaking = true;
      await _tts.speak(text);
    } catch (_) {
      _speaking = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _speaking = false;
  }
}
