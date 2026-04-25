import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _enviarCorreoPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Correo de cambio de contraseña enviado! Revisa tu bandeja de entrada.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar el correo.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Sin sesión activa')));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Fondo premium limpio
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueGrey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final String nombre = data?['nombre'] ?? 'Usuario';
          final bool isPro = data?['isPro'] ?? false;
          final String email = user.email ?? 'Sin correo';

          return Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 15))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: isPro ? Colors.amber.shade100 : Colors.blue.shade100,
                    child: Icon(Icons.person, size: 50, color: isPro ? Colors.amber.shade700 : Colors.blue.shade700),
                  ),
                  const SizedBox(height: 20),
                  Text(nombre, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  const SizedBox(height: 5),
                  Text(email, style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isPro ? Colors.amber.shade400 : Colors.blueGrey.shade200,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      isPro ? 'CUENTA PRO ACTIVA' : 'CUENTA DEMO', 
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14, letterSpacing: 1)
                    ),
                  ),
                  
                  const Divider(height: 50, thickness: 1.5, color: Color(0xFFE2E8F0)),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _enviarCorreoPassword(context, email),
                      icon: const Icon(Icons.lock_reset, color: Colors.blueGrey),
                      label: const Text('Cambiar Contraseña', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blueGrey.shade200, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}