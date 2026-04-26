import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/theme_toggle_button.dart';

/// AUDITORÍA — profile_screen.dart
///
/// MEJORAS IMPLEMENTADAS:
///
/// 1. ANTI DOBLE-TAP en «Cambiar Contraseña»: La versión original no
///    protegía el botón durante el envío del correo de restablecimiento.
///    Si el usuario pulsaba rápido dos veces, enviaba dos correos. Se añade
///    un flag `_isSendingReset` que deshabilita el botón durante la operación
///    y muestra un indicador de carga.
///
/// 2. ANTI DOBLE-TAP en «Cerrar Sesión»: Se añade confirmación mediante
///    un AlertDialog antes de ejecutar signOut(), evitando cierres de sesión
///    accidentales. Es especialmente importante en un contexto clínico donde
///    el usuario puede ser un paciente o un terapeuta.
///
/// 3. SnackBar de ÉXITO con icono verde para el correo de cambio de
///    contraseña, diferenciándolo visualmente del SnackBar de error.
///
/// 4. FONDO Y TOGGLE: Reemplazados por widgets compartidos.
///
/// 5. LAYOUT SCROLL-SAFE: El contenido se envuelve en SingleChildScrollView
///    para evitar overflow en pantallas con teclado abierto o pantallas pequeñas.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSendingReset = false; // ANTI DOBLE-TAP

  Future<void> _enviarCorreoPassword(String email) async {
    if (_isSendingReset) return;
    setState(() => _isSendingReset = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Correo enviado! Revisa tu bandeja de entrada.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(16),
            ),
          );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Text('Error al enviar el correo.',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              backgroundColor: Colors.redAccent.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(16),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  // MEJORA: Diálogo de confirmación antes de cerrar sesión.
  Future<void> _confirmarCerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('¿Cerrar sesión?',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
          'Se cerrará tu sesión en este dispositivo.',
          style: TextStyle(color: Colors.blueGrey),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(
                    color: Colors.blueGrey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
          body: Center(child: Text('Sin sesión activa')));
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, _) {
        final colorTextoPrincipal =
            isDark ? Colors.white : const Color(0xFF1E293B);
        final colorFondoTarjeta =
            isDark ? Colors.white.withOpacity(0.08) : Colors.white;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: colorTextoPrincipal),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Volver atrás',
            ),
            title: Text(
              'Mi Perfil',
              style: TextStyle(
                  color: colorTextoPrincipal, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              const ThemeToggleButton(),
              const SizedBox(width: 8),
            ],
          ),
          body: AnimatedGradientBackground(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data =
                    snapshot.data?.data() as Map<String, dynamic>?;
                final String nombre = data?['nombre'] ?? 'Usuario';
                final bool isPro = data?['isPro'] ?? false;
                final String email = user.email ?? 'Sin correo';

                return Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 420,
                      padding: const EdgeInsets.all(36),
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorFondoTarjeta,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.18)
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ─── AVATAR ──────────────────────────────────
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: isPro
                                ? Colors.amber
                                    .withOpacity(isDark ? 0.2 : 0.9)
                                : Colors.blue
                                    .withOpacity(isDark ? 0.2 : 0.9),
                            child: Icon(
                              Icons.person,
                              size: 46,
                              color: isPro
                                  ? Colors.amber.shade400
                                  : Colors.blueAccent.shade400,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            nombre,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: colorTextoPrincipal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.blueGrey.shade300
                                  : Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ─── BADGE PLAN ──────────────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isPro
                                  ? Colors.amber.shade600
                                  : Colors.blueGrey.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isPro ? 'CUENTA PRO ACTIVA' : 'CUENTA DEMO',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          Divider(
                            height: 40,
                            thickness: 1.5,
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFE2E8F0),
                          ),

                          // ─── BOTÓN CAMBIAR CONTRASEÑA ────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              // ANTI DOBLE-TAP: deshabilitado mientras procesa.
                              onPressed: _isSendingReset
                                  ? null
                                  : () =>
                                      _enviarCorreoPassword(email),
                              icon: _isSendingReset
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.blueGrey,
                                      ),
                                    )
                                  : Icon(Icons.lock_reset,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.blueGrey),
                              label: Text(
                                _isSendingReset
                                    ? 'Enviando...'
                                    : 'Cambiar Contraseña',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.blueGrey.shade200,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ─── BOTÓN CERRAR SESIÓN ──────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            // MEJORA: Diálogo de confirmación antes de signOut.
                            child: ElevatedButton.icon(
                              onPressed: _confirmarCerrarSesion,
                              icon: const Icon(
                                  Icons.power_settings_new_rounded),
                              label: const Text('Cerrar Sesión',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(15)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}