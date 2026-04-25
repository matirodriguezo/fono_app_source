import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../main.dart'; // Import global

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _nombreController = TextEditingController(); 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); 
  bool _isLoading = false;

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
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _crearCuenta() async {
    if (_nombreController.text.trim().isEmpty) {
      _mostrarError('Por favor, ingresa un nombre o alias.');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _mostrarError('Las contraseñas no coinciden. Inténtalo de nuevo.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombre': _nombreController.text.trim(), 
        'email': _emailController.text.trim(),
        'isPro': false, 
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException {
      _mostrarError('Error: Verifica tu correo o usa una contraseña de 6+ letras.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, child) {
        final colorTextoPrincipal = isDark ? Colors.white : const Color(0xFF1E293B);
        final colorFondoTarjeta = isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.85);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorTextoPrincipal),
              onPressed: () => Navigator.pop(context),
            ),
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
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: isDark
                            ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A), const Color(0xFF020617)]
                            : [const Color(0xFFF3E8FF), const Color(0xFFE0F2FE), const Color(0xFFE2E8F0)],
                        stops: const [0.0, 0.5, 1.0],
                        transform: GradientRotation(_bgAnimationController.value * 2 * math.pi),
                      ),
                    ),
                  );
                },
              ),
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    decoration: BoxDecoration(
                      color: colorFondoTarjeta,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, size: 60, color: Colors.tealAccent.shade400),
                        const SizedBox(height: 16),
                        Text('Crear Cuenta', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: colorTextoPrincipal, letterSpacing: -1)),
                        const SizedBox(height: 8),
                        Text('Únete a FonoApp Pro', style: TextStyle(color: isDark ? Colors.blueGrey.shade300 : Colors.grey.shade600, fontSize: 16)),
                        const SizedBox(height: 32),
                        
                        TextField(
                          controller: _nombreController,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(color: colorTextoPrincipal),
                          decoration: InputDecoration(
                            labelText: 'Nombre o Alias',
                            labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                            prefixIcon: Icon(Icons.badge_outlined, color: isDark ? Colors.tealAccent : Colors.grey),
                            filled: true,
                            fillColor: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: colorTextoPrincipal),
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                            prefixIcon: Icon(Icons.email_outlined, color: isDark ? Colors.tealAccent : Colors.grey),
                            filled: true,
                            fillColor: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(color: colorTextoPrincipal),
                          decoration: InputDecoration(
                            labelText: 'Contraseña (Mínimo 6 letras)',
                            labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                            prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.tealAccent : Colors.grey),
                            filled: true,
                            fillColor: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: TextStyle(color: colorTextoPrincipal),
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña',
                            labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                            prefixIcon: Icon(Icons.lock_reset_rounded, color: isDark ? Colors.tealAccent : Colors.grey),
                            filled: true,
                            fillColor: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        _isLoading 
                          ? const CircularProgressIndicator(color: Colors.tealAccent)
                          : SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _crearCuenta,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade500, 
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 8,
                                ),
                                child: const Text('REGISTRARSE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                            ),
                        const SizedBox(height: 16),
                        
                        if (!_isLoading)
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: isDark ? Colors.tealAccent : Colors.blueGrey.shade600, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}