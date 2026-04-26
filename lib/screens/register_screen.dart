import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/theme_toggle_button.dart';

/// AUDITORÍA — register_screen.dart
///
/// MEJORAS IMPLEMENTADAS:
///
/// 1. ANTI DOBLE-TAP: Idéntico al LoginScreen — el flag `_isLoading` evita
///    que el usuario cree múltiples cuentas si pulsa el botón dos veces
///    rápidamente mientras Firebase procesa.
///
/// 2. VALIDACIÓN CON FORMULARIO (Form + GlobalKey): En el código original,
///    las validaciones se hacían manualmente con ifs dentro de _crearCuenta().
///    Ahora se usan `TextFormField` + `validator` con un `GlobalKey<FormState>`,
///    lo que activa la visualización automática de errores inline debajo de
///    cada campo incorrecto, antes de tocar la API.
///
/// 3. VISIBILIDAD DE CONTRASEÑA: Se añade el botón de ojo en ambos campos
///    de contraseña, reduciendo errores de tipeo.
///
/// 4. FORTALEZA DE CONTRASEÑA VISUAL: Un indicador de barras de colores que
///    evalúa en tiempo real la longitud y complejidad de la contraseña.
///    Mejora la seguridad del usuario de forma pedagógica y sin intrusión.
///
/// 5. MENSAJES DE ERROR FIREBASE GRANULARES: Se distingue entre
///    email-already-in-use, weak-password, y errores de red para darle al
///    usuario información accionable.
///
/// 6. FONDO Y TOGGLE: Reemplazados por widgets compartidos.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
              Expanded(
                child: Text(
                  mensaje,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  // MEJORA: Puntaje de fortaleza de contraseña (0-4).
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
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _strengthLabel(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Débil';
      case 2:
        return 'Regular';
      case 3:
        return 'Buena';
      case 4:
        return 'Muy segura';
      default:
        return '';
    }
  }

  Future<void> _crearCuenta() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(credential.user!.uid)
          .set({
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'isPro': false,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } on FirebaseAuthException catch (e) {
      // MEJORA: Errores granulares según el código de Firebase.
      final msg = switch (e.code) {
        'email-already-in-use' =>
          'Este correo ya está registrado. ¿Ya tienes cuenta?',
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
        final colorTextoPrincipal =
            isDark ? Colors.white : const Color(0xFF1E293B);
        final colorFondoTarjeta = isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.88);
        final colorCampo = isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.grey.shade50;
        final colorLabel =
            isDark ? Colors.grey.shade400 : Colors.grey.shade600;
        final colorIcono =
            isDark ? Colors.tealAccent : Colors.grey.shade500;

        // Evaluamos fortaleza en tiempo real.
        final int strength =
            _passwordStrength(_passwordController.text);

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
            actions: [
              const ThemeToggleButton(),
              const SizedBox(width: 8),
            ],
          ),
          body: AnimatedGradientBackground(
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    width: 440,
                    padding: const EdgeInsets.all(36),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 48),
                    decoration: BoxDecoration(
                      color: colorFondoTarjeta,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.18)
                            : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ─── ICONO ──────────────────────────────────────
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_add_alt_1_rounded,
                              size: 38, color: Colors.tealAccent.shade400),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: colorTextoPrincipal,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Únete a FonoApp Pro',
                          style: TextStyle(color: colorLabel, fontSize: 15),
                        ),
                        const SizedBox(height: 30),

                        // ─── NOMBRE ──────────────────────────────────────
                        TextFormField(
                          controller: _nombreController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: colorTextoPrincipal),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Por favor ingresa tu nombre o alias.'
                              : null,
                          decoration: _inputDeco(
                            label: 'Nombre o Alias',
                            icon: Icons.badge_outlined,
                            labelColor: colorLabel,
                            iconColor: colorIcono,
                            fillColor: colorCampo,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── EMAIL ───────────────────────────────────────
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          style: TextStyle(color: colorTextoPrincipal),
                          onChanged: (v) {
                            if (v != v.trimLeft()) {
                              _emailController.value =
                                  _emailController.value.copyWith(
                                text: v.trimLeft(),
                                selection: TextSelection.collapsed(
                                    offset: v.trimLeft().length),
                              );
                            }
                          },
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Por favor ingresa tu correo.';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Ingresa un correo válido.';
                            }
                            return null;
                          },
                          decoration: _inputDeco(
                            label: 'Correo electrónico',
                            icon: Icons.email_outlined,
                            labelColor: colorLabel,
                            iconColor: colorIcono,
                            fillColor: colorCampo,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── CONTRASEÑA ──────────────────────────────────
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: colorTextoPrincipal),
                          onChanged: (_) => setState(() {}), // rebuild indicador
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Por favor ingresa una contraseña.';
                            }
                            if (v.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres.';
                            }
                            return null;
                          },
                          decoration: _inputDeco(
                            label: 'Contraseña (mínimo 6 caracteres)',
                            icon: Icons.lock_outline,
                            labelColor: colorLabel,
                            iconColor: colorIcono,
                            fillColor: colorCampo,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: colorLabel,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              tooltip: _obscurePassword
                                  ? 'Mostrar contraseña'
                                  : 'Ocultar contraseña',
                            ),
                          ),
                        ),

                        // MEJORA: INDICADOR DE FORTALEZA DE CONTRASEÑA.
                        if (_passwordController.text.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ...List.generate(
                                4,
                                (i) => Expanded(
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 300),
                                    height: 4,
                                    margin: EdgeInsets.only(
                                        right: i < 3 ? 4 : 0),
                                    decoration: BoxDecoration(
                                      color: i < strength
                                          ? _strengthColor(strength)
                                          : Colors.grey.withOpacity(0.3),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  _strengthLabel(strength),
                                  key: ValueKey(strength),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _strengthColor(strength),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),

                        // ─── CONFIRMAR CONTRASEÑA ────────────────────────
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _crearCuenta(),
                          style: TextStyle(color: colorTextoPrincipal),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Por favor confirma tu contraseña.';
                            }
                            if (v != _passwordController.text) {
                              return 'Las contraseñas no coinciden.';
                            }
                            return null;
                          },
                          decoration: _inputDeco(
                            label: 'Confirmar contraseña',
                            icon: Icons.lock_reset_rounded,
                            labelColor: colorLabel,
                            iconColor: colorIcono,
                            fillColor: colorCampo,
                            suffix: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: colorLabel,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                              tooltip: _obscureConfirm
                                  ? 'Mostrar contraseña'
                                  : 'Ocultar contraseña',
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ─── BOTÓN REGISTRAR ─────────────────────────────
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _isLoading
                              ? const Padding(
                                  key: ValueKey('spinner'),
                                  padding:
                                      EdgeInsets.symmetric(vertical: 14),
                                  child: CircularProgressIndicator(
                                      color: Colors.tealAccent),
                                )
                              : SizedBox(
                                  key: const ValueKey('btn'),
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _crearCuenta,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade500,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18)),
                                      elevation: 6,
                                      shadowColor:
                                          Colors.teal.withOpacity(0.4),
                                    ),
                                    child: const Text(
                                      'REGISTRARSE',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // ─── LINK LOGIN ──────────────────────────────────
                        if (!_isLoading)
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              '¿Ya tienes cuenta? Inicia sesión',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.tealAccent
                                    : Colors.blueGrey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDeco({
    required String label,
    required IconData icon,
    required Color labelColor,
    required Color iconColor,
    required Color fillColor,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: labelColor, fontSize: 13),
      prefixIcon: Icon(icon, color: iconColor, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:
            BorderSide(color: Colors.tealAccent.withOpacity(0.6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.redAccent.shade200, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}