import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../main.dart';
import '../widgets/theme_toggle_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  bool _isSendingReset = false;
  late AnimationController _bgController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _enviarCorreoPassword(String email) async {
    if (_isSendingReset) return;
    setState(() => _isSendingReset = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Expanded(child: Text('¡Correo enviado! Revisa tu bandeja.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text('Error al enviar el correo.', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: Colors.redAccent.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  Future<void> _confirmarCerrarSesion() async {
    final isDark = isDarkModeGlobal.value;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('¿Cerrar sesión?', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
        content: Text('Se cerrará tu sesión en este dispositivo.', style: TextStyle(color: isDark ? Colors.white70 : Colors.blueGrey)),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Sin sesión activa')));

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, _) {
        final colorTexto = isDark ? Colors.white : const Color(0xFF1E293B);
        final colorTarjeta = isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.85);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDark ? Colors.black26 : Colors.white54, shape: BoxShape.circle), child: Icon(Icons.arrow_back_ios_new_rounded, color: colorTexto, size: 18)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [ThemeToggleButton(), SizedBox(width: 16)],
          ),
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                    child: Stack(
                      children: [
                        Positioned(top: -100 + (math.sin(_bgController.value * math.pi * 2) * 50), left: -50 + (math.cos(_bgController.value * math.pi) * 30), child: _LuzFondo(color: Colors.amber.withOpacity(isDark ? 0.2 : 0.1))),
                        Positioned(bottom: -150 + (math.cos(_bgController.value * math.pi * 2) * 60), right: -100 + (math.sin(_bgController.value * math.pi) * 40), child: _LuzFondo(color: Colors.blueAccent.withOpacity(isDark ? 0.2 : 0.1))),
                      ],
                    ),
                  );
                }
              ),
              BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
              
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final data = snapshot.data?.data() as Map<String, dynamic>?;
                  final String nombre = data?['nombre'] ?? 'Usuario';
                  final bool isPro = data?['isPro'] ?? false;
                  final String email = user.email ?? 'Sin correo';

                  return Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        width: 420,
                        padding: const EdgeInsets.all(40),
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorTarjeta,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: isDark ? Colors.white.withOpacity(0.18) : Colors.white, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // CORRECCIÓN: Animación aislada que no deforma la tarjeta
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: isPro ? 1.0 + (_pulseController.value * 0.05) : 1.0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8), // Padding FIJO
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle, 
                                          color: isPro ? Colors.amber.withOpacity(0.3) : Colors.blueAccent.withOpacity(0.2),
                                          boxShadow: [
                                            if (isPro)
                                              BoxShadow(
                                                color: Colors.amber.withOpacity(0.3 * _pulseController.value),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              )
                                          ]
                                        ),
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundColor: isPro ? Colors.amber.shade100 : Colors.blue.shade100,
                                          child: Icon(
                                            isPro ? Icons.workspace_premium_rounded : Icons.person, 
                                            size: 48, 
                                            color: isPro ? Colors.amber.shade700 : Colors.blueAccent.shade700
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                ),
                                const SizedBox(height: 24),
                                Text(nombre, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colorTexto, letterSpacing: -0.5)),
                                const SizedBox(height: 6),
                                Text(email, style: TextStyle(fontSize: 15, color: isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade600)),
                                const SizedBox(height: 24),
                                
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: isPro ? [Colors.amber.shade400, Colors.amber.shade600] : [Colors.blueGrey.shade300, Colors.blueGrey.shade500]),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: (isPro ? Colors.amber : Colors.blueGrey).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                                  ),
                                  child: Text(isPro ? 'CUENTA PRO ACTIVA' : 'CUENTA DEMO', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13, letterSpacing: 1)),
                                ),
                                
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 32),
                                  child: Divider(color: isDark ? Colors.white24 : Colors.black12, thickness: 1.5),
                                ),

                                SizedBox(
                                  width: double.infinity, height: 55,
                                  child: OutlinedButton.icon(
                                    onPressed: _isSendingReset ? null : () => _enviarCorreoPassword(email),
                                    icon: _isSendingReset ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lock_reset),
                                    label: Text(_isSendingReset ? 'Enviando...' : 'Cambiar Contraseña', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: isDark ? Colors.white : Colors.blueGrey.shade800,
                                      side: BorderSide(color: isDark ? Colors.white24 : Colors.black12, width: 2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                SizedBox(
                                  width: double.infinity, height: 55,
                                  child: ElevatedButton.icon(
                                    onPressed: _confirmarCerrarSesion,
                                    icon: const Icon(Icons.power_settings_new_rounded),
                                    label: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent.shade400,
                                      foregroundColor: Colors.white,
                                      elevation: 6,
                                      shadowColor: Colors.redAccent.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LuzFondo extends StatelessWidget {
  final Color color;
  const _LuzFondo({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }
}