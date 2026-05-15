import 'package:flutter_tts/flutter_tts.dart';
import 'web_speech.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _usarWebSpeech = false;

  List<Map<String, String>> vocesDisponibles = [];
  Map<String, String>? vozActual;

  final List<String> _colaPalabras = [];
  bool _procesandoCola = false;
  bool _motorOcupado = false;
  int _sesionId = 0;

  bool get usandoWebSpeech => _usarWebSpeech && WebTts.isAvailable;
  bool get webSpeechDisponible => WebTts.isAvailable;

  TtsService() {
    _configurarMotor();
  }

  void setUsarWebSpeech(bool value) {
    if (value && !WebTts.isAvailable) return;
    detener();
    _usarWebSpeech = value;
    if (value) {
      WebTts.initVoices(() {
        vocesDisponibles = WebTts.getVoices();
        if (vocesDisponibles.isNotEmpty) {
          vozActual = vocesDisponibles.first;
        }
      });
      vocesDisponibles = WebTts.getVoices();
      if (vocesDisponibles.isNotEmpty) {
        vozActual = vocesDisponibles.first;
      }
    } else {
      _cargarVocesLocales();
    }
  }

  Future<void> _configurarMotor() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.85);
    await _flutterTts.setVolume(1.2);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setErrorHandler((msg) {
      _liberarRecursos();
    });
    _flutterTts.setCancelHandler(() {
      _liberarRecursos();
    });

    await _cargarVocesLocales();
  }

  void _liberarRecursos() {
    _procesandoCola = false;
    _motorOcupado = false;
    _colaPalabras.clear();
  }

  Future<void> _cargarVocesLocales() async {
    try {
      final voces = await _flutterTts.getVoices;
      if (voces != null) {
        List<Map<String, String>> listaFiltrada = [];
        for (var v in voces) {
          final Map<String, String> vozMap = Map<String, String>.from(v as Map);
          if (vozMap['locale'] != null && vozMap['locale']!.startsWith('es')) {
            listaFiltrada.add(vozMap);
          }
        }
        vocesDisponibles = listaFiltrada;
        if (vocesDisponibles.isNotEmpty) {
          vozActual = vocesDisponibles.first;
        }
      }
    } catch (_) {}
  }

  Future<void> cambiarVoz(Map<String, String> voz) async {
    if (usandoWebSpeech) {
      vozActual = voz;
      return;
    }
    try {
      await _flutterTts.setVoice({"name": voz['name']!, "locale": voz['locale']!});
      vozActual = voz;
    } catch (_) {}
  }

  Future<bool> hablar(String texto) async {
    if (texto.trim().isEmpty) return false;
    await detener();
    if (usandoWebSpeech) {
      return WebTts.speak(texto, voice: vozActual, rate: 0.85);
    }
    try {
      _motorOcupado = true;
      await _flutterTts.speak(texto).timeout(
        const Duration(seconds: 15),
        onTimeout: () => null,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _motorOcupado = false;
    }
  }

  Future<bool> hablarOracion(List<String> palabras, void Function(int) onProgress) async {
    if (palabras.isEmpty) return false;

    if (usandoWebSpeech) {
      _sesionId++;
      final int miToken = _sesionId;
      try {
        for (int i = 0; i < palabras.length; i++) {
          if (_sesionId != miToken) break;
          onProgress(i);
          final ok = await WebTts.speak(palabras[i], voice: vozActual, rate: 0.85).timeout(
            const Duration(seconds: 4),
            onTimeout: () => false,
          );
          if (!ok) break;
          if (_sesionId != miToken) break;
          await Future.delayed(const Duration(milliseconds: 120));
        }
        return true;
      } catch (_) {
        return false;
      }
    }

    await detener();
    _sesionId++;
    final int miToken = _sesionId;

    try {
      for (int i = 0; i < palabras.length; i++) {
        if (_sesionId != miToken) break;
        onProgress(i);

        int intentosDeEspera = 0;
        while (_motorOcupado && intentosDeEspera < 10) {
          await Future.delayed(const Duration(milliseconds: 50));
          intentosDeEspera++;
        }

        if (_sesionId != miToken) break;
        _motorOcupado = true;
        await _flutterTts.speak(palabras[i]).timeout(
          const Duration(seconds: 4),
          onTimeout: () => null,
        );
        _motorOcupado = false;

        if (_sesionId != miToken) break;
        await Future.delayed(const Duration(milliseconds: 150));
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      _motorOcupado = false;
    }
  }

  Future<void> encolarPalabra(String palabra) async {
    if (palabra.trim().isEmpty) return;
    _colaPalabras.add(palabra);
    _procesarCola();
  }

  Future<void> _procesarCola() async {
    if (_procesandoCola) return;
    _procesandoCola = true;

    _sesionId++;
    final int miToken = _sesionId;

    while (_colaPalabras.isNotEmpty) {
      if (_sesionId != miToken) break;

      final texto = _colaPalabras.removeAt(0);

      if (usandoWebSpeech) {
        await WebTts.speak(texto, voice: vozActual, rate: 0.85);
        continue;
      }

      try {
        int intentosDeEspera = 0;
        while (_motorOcupado && intentosDeEspera < 10) {
          await Future.delayed(const Duration(milliseconds: 50));
          intentosDeEspera++;
        }

        if (_sesionId != miToken) break;

        _motorOcupado = true;
        await _flutterTts.speak(texto).timeout(
          const Duration(seconds: 3),
          onTimeout: () => null,
        );
      } catch (_) {
      } finally {
        _motorOcupado = false;
      }
    }
    _procesandoCola = false;
  }

  Future<void> detener() async {
    _sesionId++;
    _colaPalabras.clear();
    _procesandoCola = false;

    if (usandoWebSpeech) {
      WebTts.cancel();
      _motorOcupado = false;
      return;
    }

    try {
      await _flutterTts.stop();
    } catch (_) {
    } finally {
      _motorOcupado = false;
    }
    await Future.delayed(const Duration(milliseconds: 150));
  }
}