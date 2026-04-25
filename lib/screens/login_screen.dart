import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'register_screen.dart'; 
import '../main.dart'; // Import global

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    _emailController.dispose();
    _passwordController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _iniciarSesion() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException {
      _mostrarError('Error al entrar: Credenciales incorrectas.');
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
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
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
                        Icon(Icons.record_voice_over, size: 70, color: Colors.blueAccent.shade400),
                        const SizedBox(height: 16),
                        Text('FonoApp Pro', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: colorTextoPrincipal, letterSpacing: -1)),
                        const SizedBox(height: 8),
                        Text('Inicia sesión para comunicar', style: TextStyle(color: isDark ? Colors.blueGrey.shade300 : Colors.grey.shade600, fontSize: 16)),
                        const SizedBox(height: 32),
                        
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: colorTextoPrincipal),
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                            prefixIcon: Icon(Icons.email, color: isDark ? Colors.blueAccent : Colors.grey),
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
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                            prefixIcon: Icon(Icons.lock, color: isDark ? Colors.blueAccent : Colors.grey),
                            filled: true,
                            fillColor: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        _isLoading 
                          ? const CircularProgressIndicator(color: Colors.blueAccent)
                          : SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _iniciarSesion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 8,
                                ),
                                child: const Text('ENTRAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                            ),
                        const SizedBox(height: 16),
                        
                        if (!_isLoading)
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                            child: Text('¿No tienes cuenta? Regístrate aquí', style: TextStyle(color: Colors.blueAccent.shade200, fontWeight: FontWeight.bold)),
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