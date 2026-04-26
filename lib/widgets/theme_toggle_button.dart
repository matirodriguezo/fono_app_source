import 'package:flutter/material.dart';
import '../main.dart';

/// Botón de toggle de tema reutilizable.
///
/// MEJORA ARQUITECTURAL: Este botón también se repetía literalmente en
/// cinco pantallas. Al extraerlo aquí, cualquier cambio de diseño
/// (ej. tamaño, etiqueta, color) se aplica globalmente de inmediato.
///
/// MEJORA UX: Añadimos un Tooltip accesible para lectores de pantalla,
/// y el cursor «click» se conserva de la implementación original.
class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;

  const ThemeToggleButton({super.key, this.showLabel = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, _) {
        return Tooltip(
          message: isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => isDarkModeGlobal.value = !isDark,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.blueGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isDark ? '🌙' : '☀️',
                        key: ValueKey(isDark),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    if (showLabel) ...[
                      const SizedBox(width: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          isDark ? 'Oscuro' : 'Claro',
                          key: ValueKey(isDark),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}