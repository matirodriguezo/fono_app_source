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
  }

  // Método principal para hablar
  Future<bool> hablar(String texto) async {
    if (texto.trim().isEmpty) return false;

    try {
      // AQUÍ ESTÁ EL CAMBIO: Ya no exigimos que el resultado sea "1"
      await _flutterTts.speak(texto);
      return true; // Si llega a esta línea sin errores, es un éxito garantizado
    } catch (e) {
      print("Error en el motor de voz: $e");
      return false;
    }
  }

  Future<void> detener() async {
    await _flutterTts.stop();
  }
}