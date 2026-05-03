import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  
  final List<String> _colaPalabras = [];
  bool _procesandoCola = false;

  List<Map<String, String>> vocesDisponibles = [];
  Map<String, String>? vozActual;

  TtsService() {
    _configurarMotor();
  }

  Future<void> _configurarMotor() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.85); 
    await _flutterTts.setVolume(1.2);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
    
    _flutterTts.setErrorHandler((msg) {
      _procesandoCola = false;
      _colaPalabras.clear();
      _flutterTts.setProgressHandler((_, __, ___, ____) {});
    });
    _flutterTts.setCancelHandler(() {
      _procesandoCola = false;
      _flutterTts.setProgressHandler((_, __, ___, ____) {});
    });

    await _cargarVocesLocales();
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
    } catch (e) {
      print("Error cargando voces locales: $e");
    }
  }

  Future<void> cambiarVoz(Map<String, String> voz) async {
    try {
      await _flutterTts.setVoice({"name": voz['name']!, "locale": voz['locale']!});
      vozActual = voz;
    } catch (e) {
      print("Error al cambiar la voz: $e");
    }
  }

  // MÉTODO ORIGINAL (Palabras sueltas)
  Future<bool> hablar(String texto) async {
    if (texto.trim().isEmpty) return false;
    await detener(); 
    try {
      await _flutterTts.speak(texto).timeout(
        const Duration(seconds: 15), 
        onTimeout: () => null,
      );
      return true; 
    } catch (e) {
      print("Error en el motor de voz: $e");
      return false;
    }
  }

  // NUEVO MÉTODO: Lee la oración y avisa QUÉ tarjeta está leyendo
  Future<bool> hablarOracion(List<String> palabras, void Function(int) onProgress) async {
    if (palabras.isEmpty) return false;
    await detener();

    String frase = palabras.join(" ");
    
    // Mapeamos en qué posición (índice de caracteres) empieza cada palabra
    List<int> posiciones = [];
    int posicionActual = 0;
    for (String w in palabras) {
      posiciones.add(posicionActual);
      posicionActual += w.length + 1; // +1 por el espacio
    }

    // Le decimos a Flutter TTS que nos avise a medida que avanza
    _flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      int indiceTarjeta = 0;
      // Comparamos la posición actual del audio con nuestro mapa
      for (int i = 0; i < posiciones.length; i++) {
        if (startOffset >= posiciones[i]) {
          indiceTarjeta = i;
        }
      }
      onProgress(indiceTarjeta);
    });

    try {
      await _flutterTts.speak(frase).timeout(
        const Duration(seconds: 15), 
        onTimeout: () => null,
      );
      return true; 
    } catch (e) {
      print("Error leyendo oración: $e");
      return false;
    } finally {
      // Limpiamos el rastreador al terminar para no dejar basura en memoria
      _flutterTts.setProgressHandler((_, __, ___, ____) {});
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

    while (_colaPalabras.isNotEmpty) {
      final texto = _colaPalabras.removeAt(0);
      try {
        await _flutterTts.speak(texto).timeout(
          const Duration(seconds: 3), 
          onTimeout: () => null,
        );
      } catch (e) {
        print("Error al hablar palabra en cola: $e");
      }
    }
    _procesandoCola = false;
  }

  Future<void> detener() async {
    _colaPalabras.clear();
    _procesandoCola = false; 
    try {
      _flutterTts.setProgressHandler((_, __, ___, ____) {});
      await _flutterTts.stop();
    } catch (e) {
      print("Error al detener TTS: $e");
    }
  }
}