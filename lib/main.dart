import 'package:flutter/material.dart';
import 'screens/tablero_caa_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FonoApp());
}

class FonoApp extends StatelessWidget {
  const FonoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAAC App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Roboto', // Una fuente limpia para lectura
      ),
      home: const TableroCAAScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}