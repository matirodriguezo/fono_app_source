// Conditional export: on web (dart.library.html) uses web implementation, otherwise stub
export 'web_speech_stub.dart'
  if (dart.library.html) 'web_speech_web.dart';
