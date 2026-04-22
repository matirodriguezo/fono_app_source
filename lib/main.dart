import 'package:flutter/material.dart';
import 'screens/tablero_caa_screen.dart'; // Importamos tu nueva pantalla

// El punto de entrada de la aplicación
void main() {
  runApp(const FonoApp());
}

// El widget principal
class FonoApp extends StatelessWidget {
  const FonoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comunicador CAA',
      theme: ThemeData(
        // Un color base profesional y amigable
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // Le decimos a la app que arranque DIRECTAMENTE en el Tablero CAA
      home: const TableroComunicacion(),
      debugShowCheckedModeBanner: false, 
    );
  }
}