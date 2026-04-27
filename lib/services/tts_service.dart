import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _configurarMotor();
  }

  Future<void> _configurarMotor() async {
    // Configuramos español por defecto
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.85); // Velocidad moderada, ideal para fonoaudiología
    await _flutterTts.setVolume(1.2);
    await _flutterTts.setPitch(1.0);
    
    // MEJORA PROFESIONAL: Obliga a Flutter a esperar a que la voz termine 
    // físicamente de hablar antes de dar la tarea por completada. 
    // Esto sincroniza perfectamente tu botón "HABLANDO..." del tablero.
    await _flutterTts.awaitSpeakCompletion(true);
  }

  // Método principal para hablar
  Future<bool> hablar(String texto) async {
    if (texto.trim().isEmpty) return false;

    try {
      // SOLUCIÓN AL BLOQUEO ANTI DOBLE-TAP:
      // Detenemos tajantemente cualquier audio que esté sonando en este 
      // milisegundo antes de mandarle la nueva palabra. Esto limpia la 
      // memoria del motor de voz y evita que se trabe.
      await _flutterTts.stop();
      
      await _flutterTts.speak(texto);
      return true; 
    } catch (e) {
      print("Error en el motor de voz: $e");
      return false;
    }
  }

  Future<void> detener() async {
    await _flutterTts.stop();
  }
}