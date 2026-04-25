import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _nombreController = TextEditingController(); // NUEVO: Campo de nombre
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
      SnackBar(
        content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
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
      
      // NUEVO: Guardamos el nombre en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombre': _nombreController.text.trim(), 
        'email': _emailController.text.trim(),
        'isPro': false, 
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
      
      if (mounted) Navigator.pop(context);
      
    } on FirebaseAuthException catch (e) {
      _mostrarError('Error: Verifica tu correo o usa una contraseña de 6+ letras.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueGrey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _bgAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.lerp(const Color(0xFFF3E8FF), const Color(0xFFE0F2FE), _bgAnimationController.value)!,
                  Color.lerp(const Color(0xFFE0E7FF), const Color(0xFFF1F5F9), _bgAnimationController.value)!,
                  Color.lerp(const Color(0xFFDBEAFE), const Color(0xFFE2E8F0), _bgAnimationController.value)!,
                ],
                stops: const [0.0, 0.5, 1.0],
                transform: GradientRotation(_bgAnimationController.value * 2 * math.pi),
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 15))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1_rounded, size: 60, color: Colors.teal.shade400),
                  const SizedBox(height: 16),
                  const Text('Crear Cuenta', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -1)),
                  const SizedBox(height: 8),
                  Text('Únete a FonoApp Pro', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  const SizedBox(height: 32),
                  
                  // NUEVO CAMPO: Nombre
                  TextField(
                    controller: _nombreController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Nombre o Alias',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña (Mínimo 6 letras)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _isLoading 
                    ? const CircularProgressIndicator(color: Colors.teal)
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
                      child: Text('¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: Colors.blueGrey.shade600, fontWeight: FontWeight.w600)),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}