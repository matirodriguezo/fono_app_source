import 'package:flutter/material.dart';
import '../main.dart';

/// Botón de toggle de tema reutilizable.
class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;

  const ThemeToggleButton({super.key, this.showLabel = false});

  @override
  Widget build(BuildContext context) {
    // Detectamos si es celular para achicar este botón en específico
    final isMobile = MediaQuery.of(context).size.width < 800;

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
                // Márgenes más pequeños en celular
                margin: EdgeInsets.symmetric(
                    vertical: isMobile ? 6 : 10, 
                    horizontal: isMobile ? 4 : 8),
                // Relleno más pequeño en celular
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 14, 
                    vertical: isMobile ? 4 : 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.blueGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 20 : 30),
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
                        // Ícono más pequeño en celular
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                      ),
                    ),
                    if (showLabel && !isMobile) ...[
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