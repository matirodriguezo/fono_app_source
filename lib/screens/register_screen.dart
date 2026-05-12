import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../main.dart';
import '../widgets/theme_toggle_button.dart'; // Importamos el botón del tema

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _bgController;
  late AnimationController _pulseController;
  bool _isButtonHovered = false;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bgController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
            ],
          ),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  int _passwordStrength(String password) {
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9!@#\$%^&*]'))) score++;
    return score;
  }

  Color _strengthColor(int score) {
    switch (score) {
      case 0:
      case 1: return Colors.redAccent;
      case 2: return Colors.orange;
      case 3: return Colors.amber;
      case 4: return Colors.greenAccent.shade400;
      default: return Colors.grey;
    }
  }

  String _strengthLabel(int score) {
    switch (score) {
      case 0:
      case 1: return 'Débil';
      case 2: return 'Regular';
      case 3: return 'Buena';
      case 4: return 'Muy segura';
      default: return '';
    }
  }

  Future<void> _crearCuenta() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await FirebaseFirestore.instance.collection('usuarios').doc(credential.user!.uid).set({
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'isPro': false,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'email-already-in-use' => 'Este correo ya está registrado. ¿Ya tienes cuenta?',
        'weak-password' => 'Contraseña demasiado débil. Usa al menos 6 caracteres.',
        'network-request-failed' => 'Sin conexión. Verifica tu red e intenta de nuevo.',
        _ => 'Error al crear la cuenta. Verifica tus datos.',
      };
      _mostrarError(msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, _) {
        final colorTexto = isDark ? Colors.white : const Color(0xFF1E293B);
        final colorTarjeta = isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7);
        final colorBorde = isDark ? Colors.white.withOpacity(0.1) : Colors.white;
        final int strength = _passwordStrength(_passwordController.text);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? Colors.black26 : Colors.white54, shape: BoxShape.circle),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: colorTexto, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            // AÑADIDO: Botón del tema oscuro/claro
            actions: const [
              ThemeToggleButton(),
              SizedBox(width: 16),
            ],
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
                        Positioned(
                          top: -100 + (math.sin(_bgController.value * math.pi * 2) * 50),
                          left: -50 + (math.cos(_bgController.value * math.pi) * 30),
                          child: _LuzFondo(color: Colors.tealAccent.withOpacity(isDark ? 0.3 : 0.15)),
                        ),
                        Positioned(
                          bottom: -150 + (math.cos(_bgController.value * math.pi * 2) * 60),
                          right: -100 + (math.sin(_bgController.value * math.pi) * 40),
                          child: _LuzFondo(color: Colors.blueAccent.withOpacity(isDark ? 0.3 : 0.15)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 440,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      decoration: BoxDecoration(
                        color: colorTarjeta,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: colorBorde, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.4 : 0.1), blurRadius: 40, offset: const Offset(0, 20))
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // CORRECCIÓN: LOGO ANIMADO (Usando CircleAvatar para no recortar ni temblar)
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + (_pulseController.value * 0.05),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.tealAccent.withOpacity(0.25), 
                                            blurRadius: 20,
                                            spreadRadius: 5
                                          )
                                        ]
                                      ),
                                      child: CircleAvatar(
                                        radius: 45,
                                        backgroundColor: Colors.tealAccent.withOpacity(0.15),
                                        child: Icon(Icons.person_add_alt_1_rounded, size: 45, color: Colors.tealAccent.shade400),
                                      ),
                                    ),
                                  );
                                }
                              ),
                              const SizedBox(height: 24),
                              Text('Crear Cuenta', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: colorTexto, letterSpacing: -1)),
                              const SizedBox(height: 8),
                              Text('Únete a FonoApp Pro', style: TextStyle(color: isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade600, fontSize: 16)),
                              const SizedBox(height: 32),

                              _ConstruirCampoDeTexto(
                                controller: _nombreController,
                                isDark: isDark,
                                icono: Icons.badge_outlined,
                                label: 'Nombre o Alias',
                                validador: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                              ),
                              const SizedBox(height: 16),

                              _ConstruirCampoDeTexto(
                                controller: _emailController,
                                isDark: isDark,
                                icono: Icons.email_outlined,
                                label: 'Correo electrónico',
                                tipo: TextInputType.emailAddress,
                                validador: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                                  if (!v.contains('@') || !v.contains('.')) return 'Correo inválido';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _ConstruirCampoDeTexto(
                                controller: _passwordController,
                                isDark: isDark,
                                icono: Icons.lock_outline,
                                label: 'Contraseña (mínimo 6)',
                                isPassword: _obscurePassword,
                                onPasswordToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                validador: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                                onChanged: (_) => setState(() {}),
                              ),
                              if (_passwordController.text.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ...List.generate(4, (i) => Expanded(
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        height: 4,
                                        margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                                        decoration: BoxDecoration(
                                          color: i < strength ? _strengthColor(strength) : Colors.grey.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    )),
                                    const SizedBox(width: 10),
                                    Text(_strengthLabel(strength), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _strengthColor(strength))),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),

                              _ConstruirCampoDeTexto(
                                controller: _confirmPasswordController,
                                isDark: isDark,
                                icono: Icons.lock_reset_rounded,
                                label: 'Confirmar contraseña',
                                isPassword: _obscureConfirm,
                                onPasswordToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                validador: (v) => v != _passwordController.text ? 'No coinciden' : null,
                              ),
                              const SizedBox(height: 40),

                              _isLoading
                                  ? const CircularProgressIndicator(color: Colors.tealAccent)
                                  : MouseRegion(
                                      onEnter: (_) => setState(() => _isButtonHovered = true),
                                      onExit: (_) => setState(() => _isButtonHovered = false),
                                      child: GestureDetector(
                                        onTapDown: (_) => setState(() => _isButtonPressed = true),
                                        onTapUp: (_) {
                                          setState(() => _isButtonPressed = false);
                                          _crearCuenta();
                                        },
                                        onTapCancel: () => setState(() => _isButtonPressed = false),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          width: double.infinity,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            gradient: LinearGradient(
                                              colors: _isButtonHovered
                                                  ? [Colors.tealAccent.shade400, Colors.teal.shade400]
                                                  : [Colors.teal.shade400, Colors.teal.shade700],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.tealAccent.withOpacity(_isButtonHovered ? 0.6 : 0.3),
                                                blurRadius: _isButtonHovered ? 20 : 10,
                                                offset: Offset(0, _isButtonPressed ? 2 : 6),
                                              )
                                            ],
                                          ),
                                          transform: Matrix4.translationValues(0, _isButtonPressed ? 4 : 0, 0),
                                          child: const Center(
                                            child: Text('REGISTRARSE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                                          ),
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 24),

                              if (!_isLoading)
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Text('¿Ya tienes cuenta? Inicia sesión', 
                                      style: TextStyle(color: isDark ? Colors.tealAccent.shade200 : Colors.teal.shade700, fontWeight: FontWeight.w800, decoration: TextDecoration.underline)
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Reutilizamos el widget de Luz
class _LuzFondo extends StatelessWidget {
  final Color color;
  const _LuzFondo({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }
}

// Widget Campo de Texto con Validación
class _ConstruirCampoDeTexto extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final IconData icono;
  final String label;
  final bool isPassword;
  final TextInputType tipo;
  final VoidCallback? onPasswordToggle;
  final String? Function(String?)? validador;
  final void Function(String)? onChanged;

  const _ConstruirCampoDeTexto({
    required this.controller, required this.isDark, required this.icono, required this.label,
    this.isPassword = false, this.tipo = TextInputType.text, this.onPasswordToggle, this.validador, this.onChanged,
  });

  @override
  State<_ConstruirCampoDeTexto> createState() => _ConstruirCampoDeTextoState();
}

class _ConstruirCampoDeTextoState extends State<_ConstruirCampoDeTexto> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.black.withOpacity(0.25) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _isFocused ? Colors.tealAccent : (widget.isDark ? Colors.white12 : Colors.black12), width: _isFocused ? 2 : 1.5),
          boxShadow: [if (_isFocused) BoxShadow(color: Colors.tealAccent.withOpacity(0.15), blurRadius: 12)]
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword,
          keyboardType: widget.tipo,
          validator: widget.validador,
          onChanged: widget.onChanged,
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(color: _isFocused ? Colors.tealAccent : (widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600), fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal),
            prefixIcon: Icon(widget.icono, color: _isFocused ? Colors.tealAccent : Colors.grey),
            suffixIcon: widget.onPasswordToggle != null 
                ? IconButton(icon: Icon(widget.isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey), onPressed: widget.onPasswordToggle) 
                : null,
            border: InputBorder.none,
            errorStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ),
    );
  }
}