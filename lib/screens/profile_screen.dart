import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../main.dart'; // Import global

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  Future<void> _enviarCorreoPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Correo de cambio enviado! Revisa tu bandeja.'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el correo.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Sin sesión activa')));

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, child) {
        final colorTextoPrincipal = isDark ? Colors.white : const Color(0xFF1E293B);
        final colorFondoTarjeta = isDark ? Colors.white.withOpacity(0.08) : Colors.white;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorTextoPrincipal),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Volver atrás',
            ),
            title: Text('Mi Perfil', style: TextStyle(color: colorTextoPrincipal, fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () => isDarkModeGlobal.value = !isDarkModeGlobal.value,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.blueGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.transparent)
                    ),
                    child: Row(
                      children: [
                        Text(isDark ? '🌙' : '☀️', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _bgAnimationController,
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF020617), const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                            : [const Color(0xFFE0F2FE), const Color(0xFFF3E8FF), const Color(0xFFE2E8F0)],
                        stops: const [0.0, 0.5, 1.0],
                        transform: GradientRotation(_bgAnimationController.value * 2 * math.pi),
                      ),
                    ),
                  );
                },
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

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
                        color: colorFondoTarjeta,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.transparent, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: isPro ? Colors.amber.withOpacity(isDark ? 0.2 : 1) : Colors.blue.withOpacity(isDark ? 0.2 : 1),
                            child: Icon(Icons.person, size: 50, color: isPro ? Colors.amber.shade400 : Colors.blueAccent.shade400),
                          ),
                          const SizedBox(height: 20),
                          Text(nombre, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colorTextoPrincipal)),
                          const SizedBox(height: 5),
                          Text(email, style: TextStyle(fontSize: 16, color: isDark ? Colors.blueGrey.shade300 : Colors.blueGrey)),
                          const SizedBox(height: 20),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isPro ? Colors.amber.shade600 : Colors.blueGrey.shade400,
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(
                              isPro ? 'CUENTA PRO ACTIVA' : 'CUENTA DEMO', 
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14, letterSpacing: 1)
                            ),
                          ),
                          
                          Divider(height: 40, thickness: 1.5, color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () => _enviarCorreoPassword(context, email),
                              icon: Icon(Icons.lock_reset, color: isDark ? Colors.white70 : Colors.blueGrey),
                              label: Text('Cambiar Contraseña', style: TextStyle(color: isDark ? Colors.white70 : Colors.blueGrey, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isDark ? Colors.white24 : Colors.blueGrey.shade200, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                                Navigator.of(context).popUntil((route) => route.isFirst); // Lo devuelve limpio al inicio
                              },
                              icon: const Icon(Icons.power_settings_new_rounded),
                              label: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
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
            ],
          ),
        );
      }
    );
  }
}