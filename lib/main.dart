import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'screens/auth_gate.dart'; 

// NUEVO: Variable global reactiva para controlar el tema en toda la aplicación
final ValueNotifier<bool> isDarkModeGlobal = ValueNotifier(true);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FonoApp());
}

class FonoApp extends StatelessWidget {
  const FonoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder reconstruye la app si el usuario cambia el tema
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'FonoApp Pro',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          home: const AuthGate(), 
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}