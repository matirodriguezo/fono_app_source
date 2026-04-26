import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget reutilizable de fondo animado con gradiente rotante.
///
/// MEJORA ARQUITECTURAL: En el código original, el bloque idéntico de
/// AnimatedBuilder + AnimatedContainer con GradientRotation se repetía
/// en CINCO pantallas (Landing, Login, Register, Profile, AdminPanel).
/// Extraerlo aquí elimina ~80 líneas de código duplicado, centraliza
/// el control visual y garantiza consistencia perfecta entre pantallas.
///
/// MEJORA DE RENDIMIENTO: Al ser un widget independiente, Flutter puede
/// acotar el rebuild al subárbol del fondo, evitando reconstruir
/// innecesariamente los hijos de la pantalla.
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // MEJORA: Duración de 20s (vs 15s original) para un movimiento más
    // orgánico y menos «mecánico» al ojo del usuario.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Leemos el tema del contexto para reaccionar automáticamente al
    // cambio de tema sin necesidad de ValueListenableBuilder propio.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF020617),
                          const Color(0xFF1E1B4B),
                          const Color(0xFF0F172A),
                        ]
                      : [
                          const Color(0xFFE0F2FE),
                          const Color(0xFFF3E8FF),
                          const Color(0xFFE2E8F0),
                        ],
                  stops: const [0.0, 0.5, 1.0],
                  transform:
                      GradientRotation(_controller.value * 2 * math.pi),
                ),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}