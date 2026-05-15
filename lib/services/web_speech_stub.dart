class WebTts {
  static bool get isAvailable => false;

  static List<Map<String, String>> getVoices() => [];

  static void initVoices(void Function() onReady) {}

  static Future<bool> speak(
    String text, {
    Map<String, String>? voice,
    double rate = 0.85,
  }) async => false;

  static void cancel() {}

  static void pause() {}

  static void resume() {}
}
