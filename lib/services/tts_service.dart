import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  
  // Sistema de turnos seguro
  final List<String> _colaPalabras = [];
  bool _procesandoCola = false;

  TtsService() {
    _configurarMotor();
  }

  Future<void> _configurarMotor() async {
    // Configuramos español por defecto
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.85); 
    await _flutterTts.setVolume(1.2);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
    
    // ANILLO DE SEGURIDAD 1: Destraba la cola si el navegador lanza error
    _flutterTts.setErrorHandler((msg) {
      _procesandoCola = false;
      _colaPalabras.clear();
    });
    _flutterTts.setCancelHandler(() {
      _procesandoCola = false;
    });
  }

  // MÉTODO PARA EL BOTÓN GIGANTE "HABLAR" (Oración completa)
  Future<bool> hablar(String texto) async {
    if (texto.trim().isEmpty) return false;
    
    await detener(); // Limpia toda la basura antes de hablar

    try {
      // ANILLO DE SEGURIDAD 2: Timeout de 15 segundos. 
      // Si el navegador se queda mudo o no avisa que terminó, lo soltamos a la fuerza.
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

  // MÉTODO PARA TARJETAS SUELTAS (Fila de espera)
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
        // ANILLO DE SEGURIDAD 2.1: Timeout de 3 seg por palabra.
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

  // FUERZA EL APAGADO INMEDIATO
  Future<void> detener() async {
    _colaPalabras.clear();
    _procesandoCola = false; // ANILLO DE SEGURIDAD 3: La cura del Bug de Silencio
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("Error al detener TTS: $e");
    }
  }
}