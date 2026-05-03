import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  
  // 1. GESTIÓN DE COLA
  final List<String> _colaPalabras = [];
  bool _procesandoCola = false;
  
  // 2. MUTEX (Candado de Hardware): Evita colisiones en el puente nativo.
  bool _motorOcupado = false; 

  // 3. TOKEN DE CANCELACIÓN: Identificador único por cada evento de habla.
  int _sesionId = 0; 

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
    // CRÍTICO: Obliga a Flutter a esperar la finalización del audio
    await _flutterTts.awaitSpeakCompletion(true);
    
    // Handlers de limpieza en caso de que el navegador aborte la operación
    _flutterTts.setErrorHandler((msg) {
      print("TTS Error Nativo: $msg");
      _liberarRecursos();
    });
    _flutterTts.setCancelHandler(() {
      _liberarRecursos();
    });

    await _cargarVocesLocales();
  }

  // Limpieza segura de estados
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

  Future<bool> hablar(String texto) async {
    if (texto.trim().isEmpty) return false;
    await detener(); 
    try {
      _motorOcupado = true;
      await _flutterTts.speak(texto).timeout(
        const Duration(seconds: 15), 
        onTimeout: () => null,
      );
      return true; 
    } catch (e) {
      print("Error en el motor de voz: $e");
      return false;
    } finally {
      _motorOcupado = false; // Always libera el Mutex
    }
  }

  // MÉTODO BLINDADO PARA WEB (Lectura palabra por palabra guiada)
  Future<bool> hablarOracion(List<String> palabras, void Function(int) onProgress) async {
    if (palabras.isEmpty) return false;
    
    // Freno de emergencia previo
    await detener();
    
    // Generamos el Token Inmutable para ESTA ejecución exacta
    _sesionId++;
    final int miToken = _sesionId;

    try {
      for (int i = 0; i < palabras.length; i++) {
        // CHEQUEO 1: Antes de mover la interfaz gráfica
        if (_sesionId != miToken) break;

        onProgress(i); // Enciende la tarjeta 'i'
        
        // Esperamos activamente si el motor quedó enganchado procesando algo anterior
        int intentosDeEspera = 0;
        while (_motorOcupado && intentosDeEspera < 10) {
          await Future.delayed(const Duration(milliseconds: 50));
          intentosDeEspera++;
        }

        // CHEQUEO 2: Antes de enviar la instrucción al navegador
        if (_sesionId != miToken) break;
        
        _motorOcupado = true;
        await _flutterTts.speak(palabras[i]).timeout(
          const Duration(seconds: 4), 
          onTimeout: () => null,
        );
        _motorOcupado = false; // Liberamos el puente
        
        // CHEQUEO 3: Después de que el audio terminó
        if (_sesionId != miToken) break;
        
        // Micro-pausa clínica
        await Future.delayed(const Duration(milliseconds: 150));
      }
      return true; 
    } catch (e) {
      print("Error crítico leyendo oración: $e");
      return false;
    } finally {
      _motorOcupado = false; // Garantiza no dejar deadlocks
    }
  }

  // Gestión de Cola Blindada
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
      // Chequeo de token para palabras individuales
      if (_sesionId != miToken) break;

      final texto = _colaPalabras.removeAt(0);
      
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
      } catch (e) {
        print("Error al hablar palabra en cola: $e");
      } finally {
        _motorOcupado = false;
      }
    }
    _procesandoCola = false;
  }

  // APAGADO RADICAL (Hard Stop)
  Future<void> detener() async {
    // 1. Invalidar cualquier token activo inmediatamente
    _sesionId++; 
    
    // 2. Limpiar memoria de cola
    _colaPalabras.clear();
    _procesandoCola = false; 
    
    // 3. Orden nativa de apagado
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("Error al detener TTS: $e");
    } finally {
      // Forzamos la liberación del Mutex
      _motorOcupado = false; 
    }
    
    // 4. Pausa de hardware: Le damos 150ms al navegador para limpiar su memoria 
    // interna de Javascript antes de dejar pasar la siguiente orden de Dart.
    await Future.delayed(const Duration(milliseconds: 150));
  }
}