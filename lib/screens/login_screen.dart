import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'register_screen.dart';
import 'welcome_screen.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/glass_layout.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _pulseController;
  
  bool _isButtonHovered = false;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: Colors.redAccent.shade400, 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _iniciarSesion() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _mostrarError('Por favor, ingresa tus datos.');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
    } on FirebaseAuthException {
      _mostrarError('Error al entrar: Credenciales incorrectas.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        final colorTexto = isDark ? Colors.white : const Color(0xFF1E293B);
        final colorTarjeta = isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7);
        final colorBorde = isDark ? Colors.white.withOpacity(0.1) : Colors.white;

        return Scaffold(
          extendBodyBehindAppBar: true,
          // APPBAR MODERNA 
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: colorTexto, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            // CORRECCIÓN: Botón de tema oficial y bien espaciado
            actions: const [
              ThemeToggleButton(),
              SizedBox(width: 16),
            ],
          ),
          
          body: GlassLayout(
            sphere1: const SphereStyle(
              color: Colors.blueAccent,
              darkOpacity: 0.4,
              lightOpacity: 0.2,
            ),
            sphere2: const SphereStyle(
              color: Colors.purpleAccent,
              darkOpacity: 0.3,
              lightOpacity: 0.15,
            ),
            child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 420,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: colorTarjeta,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: colorBorde, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.4 : 0.1), 
                          blurRadius: 40, 
                          offset: const Offset(0, 20)
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // CORRECCIÓN: LOGO ANIMADO (Usando CircleAvatar para evitar recortes)
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
                                          color: Colors.blueAccent.withOpacity(0.25), 
                                          blurRadius: 20,
                                          spreadRadius: 5
                                        )
                                      ]
                                    ),
                                    child: CircleAvatar(
                                      radius: 45,
                                      backgroundColor: Colors.blueAccent.withOpacity(0.15),
                                      child: Icon(Icons.record_voice_over, size: 45, color: Colors.blueAccent.shade400),
                                    ),
                                  ),
                                );
                              }
                            ),
                            const SizedBox(height: 24),
                            
                            // TEXTOS
                            Text('FonoApp Pro', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: colorTexto, letterSpacing: -1)),
                            const SizedBox(height: 8),
                            Text('Bienvenido de vuelta', style: TextStyle(color: isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade600, fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 40),
                            
                            // CAMPO EMAIL
                            _ConstruirCampoDeTexto(
                              controller: _emailController,
                              isDark: isDark,
                              icono: Icons.email_rounded,
                              label: 'Correo electrónico',
                              tipo: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            
                            // CAMPO CONTRASEÑA
                            _ConstruirCampoDeTexto(
                              controller: _passwordController,
                              isDark: isDark,
                              icono: Icons.lock_rounded,
                              label: 'Contraseña',
                              isPassword: true,
                            ),
                            const SizedBox(height: 40),
                            
                            // BOTÓN ENTRAR ANIMADO
                            MouseRegion(
                              onEnter: (_) => setState(() => _isButtonHovered = true),
                              onExit: (_) => setState(() => _isButtonHovered = false),
                              child: GestureDetector(
                                onTapDown: _isLoading ? null : (_) => setState(() => _isButtonPressed = true),
                                onTapUp: _isLoading ? null : (_) {
                                  setState(() => _isButtonPressed = false);
                                  _iniciarSesion();
                                },
                                onTapCancel: () => setState(() => _isButtonPressed = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: _isButtonHovered && !_isLoading
                                          ? [Colors.blueAccent.shade200, Colors.blueAccent.shade400]
                                          : [Colors.blueAccent.shade400, Colors.blueAccent.shade700],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueAccent.withOpacity(_isButtonHovered && !_isLoading ? 0.6 : 0.3),
                                        blurRadius: _isButtonHovered && !_isLoading ? 20 : 10,
                                        offset: Offset(0, _isButtonPressed ? 2 : 6),
                                      )
                                    ],
                                  ),
                                  transform: Matrix4.translationValues(0, _isButtonPressed ? 4 : 0, 0),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 26,
                                            height: 26,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            'ENTRAR',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // BOTÓN REGISTRO
                            if (!_isLoading)
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                                  child: Text(
                                    '¿No tienes cuenta? Regístrate aquí', 
                                    style: TextStyle(
                                      color: isDark ? Colors.blueAccent.shade200 : Colors.blueAccent.shade700, 
                                      fontWeight: FontWeight.w800,
                                      decoration: TextDecoration.underline,
                                      decorationColor: isDark ? Colors.blueAccent.shade200 : Colors.blueAccent.shade700,
                                    )
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
        );
      }
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS PRIVADOS DE APOYO
// ─────────────────────────────────────────────────────────────────────────────

// Widget encapsulado para un TextField moderno
class _ConstruirCampoDeTexto extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final IconData icono;
  final String label;
  final bool isPassword;
  final TextInputType tipo;

  const _ConstruirCampoDeTexto({
    required this.controller,
    required this.isDark,
    required this.icono,
    required this.label,
    this.isPassword = false,
    this.tipo = TextInputType.text,
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
          border: Border.all(
            color: _isFocused 
                ? Colors.blueAccent 
                : (widget.isDark ? Colors.white12 : Colors.black12),
            width: _isFocused ? 2 : 1.5,
          ),
          boxShadow: [
            if (_isFocused)
              BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 12)
          ]
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.isPassword,
          keyboardType: widget.tipo,
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: _isFocused ? Colors.blueAccent : (widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal
            ),
            prefixIcon: Icon(widget.icono, color: _isFocused ? Colors.blueAccent : Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ),
    );
  }
}