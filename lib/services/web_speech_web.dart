import 'dart:async';
import 'dart:html';

class WebTts {
  static bool get isAvailable => true;

  static final List<Map<String, String>> _cachedVoices = [];
  static SpeechSynthesis? _synthesis;
  static bool _voicesLoaded = false;

  static SpeechSynthesis get _synth {
    _synthesis ??= window.speechSynthesis!;
    return _synthesis!;
  }

  static void initVoices(void Function() onReady) {
    _loadVoices();
    if (_cachedVoices.isNotEmpty) {
      onReady();
      return;
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      _loadVoices();
      if (_cachedVoices.isNotEmpty) {
        onReady();
      }
    });
  }

  static void _loadVoices() {
    if (_voicesLoaded) return;
    final raw = _synth.getVoices();
    if (raw.isEmpty) return;
    _voicesLoaded = true;
    _cachedVoices.clear();
    for (final v in raw) {
      final lang = v.lang;
      final name = v.name;
      if (lang != null && name != null && lang.startsWith('es')) {
        _cachedVoices.add({
          'name': name,
          'locale': lang,
        });
      }
    }
  }

  static List<Map<String, String>> getVoices() {
    _loadVoices();
    return List.unmodifiable(_cachedVoices);
  }

  static Future<bool> speak(
    String text, {
    Map<String, String>? voice,
    double rate = 0.85,
  }) async {
    final utterance = SpeechSynthesisUtterance(text);
    utterance.lang = voice?['locale'] ?? 'es-ES';
    utterance.rate = rate;
    utterance.volume = 1.0;

    if (voice != null) {
      final all = _synth.getVoices();
      for (final v in all) {
        if (v.name == voice['name']) {
          utterance.voice = v;
          break;
        }
      }
    }

    final completer = Completer<bool>();
    utterance.onEnd.listen((_) {
      if (!completer.isCompleted) completer.complete(true);
    });
    utterance.onError.listen((_) {
      if (!completer.isCompleted) completer.complete(false);
    });

    _synth.speak(utterance);
    return completer.future;
  }

  static void cancel() {
    _synth.cancel();
  }

  static void pause() {
    _synth.pause();
  }

  static void resume() {
    _synth.resume();
  }
}
