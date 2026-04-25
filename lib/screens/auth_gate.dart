import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'landing_screen.dart'; // <-- AHORA IMPORTAMOS LA LANDING PAGE
import 'tablero_caa_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder escucha los cambios de sesión en tiempo real
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras verifica, mostramos carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.blue)));
        }
        
        // Si NO hay datos de usuario, lo mandamos a la presentación comercial
        if (!snapshot.hasData) {
          return const LandingScreen(); // <-- CAMBIO APLICADO AQUÍ
        }
        
        // Si SÍ hay usuario, lo dejamos pasar directamente al Tablero
        return const TableroCAAScreen();
      },
    );
  }
}