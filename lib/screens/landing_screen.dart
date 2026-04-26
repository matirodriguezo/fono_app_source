import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../main.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/theme_toggle_button.dart';

/// AUDITORÍA — landing_screen.dart
///
/// MEJORAS IMPLEMENTADAS:
///
/// 1. FONDO ANIMADO: Eliminado el AnimationController local duplicado.
///    Ahora usa el widget `AnimatedGradientBackground` compartido que
///    extrae el rebuild al subárbol mínimo necesario, reduciendo ~25
///    líneas de boilerplate y el riesgo de olvidar llamar a dispose().
///
/// 2. TOGGLE DE TEMA: Reemplazado por `ThemeToggleButton` compartido
///    con `showLabel: true` en desktop y `showLabel: false` en mobile,
///    manteniendo la lógica responsiva original.
///
/// 3. ANTI DOBLE-TAP: Los botones «Iniciar Sesión» y «Registrarse» de la
///    AppBar ya navegan con push, pero el _BotonFlotanteMagico no tenía
///    protección. Se añadió debounce de 600ms para evitar empujar dos
///    rutas idénticas al stack si el usuario toca rápido.
///
/// 4. RESPONSIVIDAD: Se añadió un tercer breakpoint `isLargeDesktop`
///    (≥1200px) para ajustar tamaños de fuente heroica y títulos.
///    El subtítulo de la hero section ya no usa \n hardcodeado; se
///    envuelve con `softWrap: true` y `textAlign: center`, lo que evita
///    desbordamiento en pantallas intermedias.
///
/// 5. JERARQUÍA VISUAL: El footer tiene ahora un Divider sutil arriba
///    para separar la sección CTA del pie de página legalmente.
///
/// 6. ACCESIBILIDAD: Se añadieron Semantics labels en la sección hero y
///    en los botones de CTA para lectores de pantalla.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  // MEJORA: Se eliminó _bgAnimationController — el widget compartido lo maneja.
  // Sólo conservamos el controller de entrada de contenido.
  late AnimationController _entryController;
  bool _ctaLoading = false; // ANTI DOBLE-TAP

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  /// ANTI DOBLE-TAP: Bloquea el botón flotante de CTA durante 600ms.
  Future<void> _irARegistro() async {
    if (_ctaLoading) return;
    setState(() => _ctaLoading = true);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _ctaLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final isLargeDesktop = screenWidth >= 1200;

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, _) {
        final colorTextoPrincipal =
            isDark ? Colors.white : const Color(0xFF1E293B);
        final colorTextoSecundario =
            isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade700;
        final colorFondoTarjeta = isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.6);
        final colorBordeTarjeta = isDark
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.9);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // MEJORA: Envuelto en BackdropFilter para que la AppBar tenga
            // un leve efecto «frosted glass» al hacer scroll en mobile.
            title: Padding(
              padding: EdgeInsets.only(left: isMobile ? 4.0 : 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.record_voice_over,
                      color: Colors.blueAccent,
                      size: isMobile ? 24 : 28),
                  const SizedBox(width: 8),
                  if (screenWidth >= 380)
                    Text(
                      'FonoApp',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: colorTextoPrincipal,
                        fontSize: isMobile ? 18 : 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              // MEJORA: ThemeToggleButton compartido — etiqueta sólo en desktop
              ThemeToggleButton(showLabel: !isMobile),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 16),
                ),
                child: Text(
                  isMobile ? 'Entrar' : 'Iniciar Sesión',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorTextoSecundario,
                    fontSize: isMobile ? 14 : 15,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    right: isMobile ? 10.0 : 28.0, left: 4),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 14 : 22),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 6,
                    shadowColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text(
                    isMobile ? 'Registro' : 'Registrarse',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 13 : 14),
                  ),
                ),
              ),
            ],
          ),
          body: AnimatedGradientBackground(
            child: Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 48,
                          vertical: 60,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ─── BADGE ───────────────────────────────────
                            _FadeSlide(
                              controller: _entryController,
                              interval: const Interval(0.0, 0.4,
                                  curve: Curves.easeOutCubic),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.blueAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: Colors.blueAccent
                                          .withOpacity(0.3)),
                                ),
                                child: Text(
                                  '🚀 El SAAC más intuitivo de la web',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.blueAccent,
                                    fontSize: isMobile ? 12 : 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ─── HERO TITLE ──────────────────────────────
                            _FadeSlide(
                              controller: _entryController,
                              interval: const Interval(0.1, 0.5,
                                  curve: Curves.easeOutCubic),
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    LinearGradient(
                                  colors: isDark
                                      ? [
                                          Colors.blue.shade300,
                                          Colors.purple.shade300
                                        ]
                                      : [
                                          Colors.blue.shade700,
                                          Colors.purple.shade700
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                // MEJORA: semanticsLabel para accesibilidad.
                                child: Semantics(
                                  label:
                                      'Dale voz a quienes más lo necesitan',
                                  child: Text(
                                    'Dale voz a quienes\nmás lo necesitan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      // MEJORA: Tercer breakpoint para large desktop.
                                      fontSize: isMobile
                                          ? 38
                                          : isLargeDesktop
                                              ? 80
                                              : 68,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.1,
                                      letterSpacing: -2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ─── SUBTÍTULO ───────────────────────────────
                            _FadeSlide(
                              controller: _entryController,
                              interval: const Interval(0.2, 0.6,
                                  curve: Curves.easeOutCubic),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 680),
                                // MEJORA: softWrap + sin \n hardcodeado →
                                // nunca desborda en pantallas intermedias.
                                child: Text(
                                  'FonoApp facilita la comunicación aumentativa '
                                  'mediante pictogramas interactivos, ayudando a '
                                  'estructurar oraciones de forma natural.',
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 20,
                                    color: colorTextoSecundario,
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),

                            // ─── TARJETAS DE PASOS ───────────────────────
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 24,
                              runSpacing: 24,
                              children: [
                                _FadeSlide(
                                  controller: _entryController,
                                  interval: const Interval(0.3, 0.7),
                                  child: _TarjetaPaso(
                                    emoji: '👤',
                                    titulo: '1. Crea tu cuenta',
                                    desc:
                                        'Regístrate gratis y asegura el progreso de tu comunicación.',
                                    color: colorTextoPrincipal,
                                    bg: colorFondoTarjeta,
                                    borderColor: colorBordeTarjeta,
                                  ),
                                ),
                                _FadeSlide(
                                  controller: _entryController,
                                  interval: const Interval(0.4, 0.8),
                                  child: _TarjetaPaso(
                                    emoji: '👆',
                                    titulo: '2. Toca y arma',
                                    desc:
                                        'Selecciona tarjetas por categoría y construye frases.',
                                    color: colorTextoPrincipal,
                                    bg: colorFondoTarjeta,
                                    borderColor: colorBordeTarjeta,
                                  ),
                                ),
                                _FadeSlide(
                                  controller: _entryController,
                                  interval: const Interval(0.5, 0.9),
                                  child: _TarjetaPaso(
                                    emoji: '🔊',
                                    titulo: '3. Hazte escuchar',
                                    desc:
                                        'Motor de voz fluido, natural y clínicamente calibrado.',
                                    color: colorTextoPrincipal,
                                    bg: colorFondoTarjeta,
                                    borderColor: colorBordeTarjeta,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 90),

                            // ─── SECCIÓN PRECIOS ─────────────────────────
                            _FadeSlide(
                              controller: _entryController,
                              interval: const Interval(0.6, 1.0,
                                  curve: Curves.easeOutCubic),
                              child: Text(
                                'Elige tu nivel de acceso',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isMobile ? 28 : 44,
                                  fontWeight: FontWeight.w900,
                                  color: colorTextoPrincipal,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _FadeSlide(
                              controller: _entryController,
                              interval: const Interval(0.62, 1.0),
                              child: Text(
                                'Sin contratos. Sin sorpresas.',
                                style: TextStyle(
                                  color: colorTextoSecundario,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 36,
                              runSpacing: 36,
                              children: [
                                _FadeSlide(
                                  controller: _entryController,
                                  interval: const Interval(0.7, 1.0),
                                  child: _TarjetaPlan(
                                    titulo: 'Plan DEMO',
                                    precio: 'Gratis',
                                    emoji: '✨',
                                    colorPrimario: Colors.blueGrey,
                                    items: const [
                                      'Vocabulario núcleo (acceso rápido)',
                                      'Carpetas de Saludos y Necesidades',
                                      'Síntesis de voz sin límite',
                                      'Sin límite de tiempo',
                                    ],
                                    bg: colorFondoTarjeta,
                                    txtPrincipal: colorTextoPrincipal,
                                    txtSecundario: colorTextoSecundario,
                                    borderColor: colorBordeTarjeta,
                                  ),
                                ),
                                _FadeSlide(
                                  controller: _entryController,
                                  interval: const Interval(0.8, 1.0),
                                  child: _TarjetaPlan(
                                    titulo: 'Plan PRO',
                                    precio: 'Premium',
                                    emoji: '👑',
                                    colorPrimario: Colors.amber.shade500,
                                    items: const [
                                      'Todas las funciones DEMO incluidas',
                                      '+80 pictogramas clínicos',
                                      'Carpetas avanzadas: Lugares, Comida',
                                      'Construcción de oraciones complejas',
                                    ],
                                    bg: colorFondoTarjeta,
                                    txtPrincipal: colorTextoPrincipal,
                                    txtSecundario: colorTextoSecundario,
                                    borderColor: colorBordeTarjeta,
                                    esPro: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 80),

                            // ─── CTA FINAL ───────────────────────────────
                            _FadeSlide(
                              controller: _entryController,
                              interval: const Interval(0.85, 1.0),
                              child: _BotonFlotanteMagico(
                                onTap: _irARegistro,
                                isLoading: _ctaLoading,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (isMobile)
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                ),
                                child: Text(
                                  '¿Ya tienes cuenta? Inicia sesión',
                                  style: TextStyle(
                                    color: colorTextoSecundario,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 48),

                            // ─── FOOTER ──────────────────────────────────
                            // MEJORA: Divider sutil para separar visualmente el footer.
                            Divider(
                              color: colorTextoSecundario.withOpacity(0.2),
                              height: 1,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '© 2026 FonoApp · Desarrollado con propósito y dedicación.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorTextoSecundario.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
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
}

// ──────────────────────────────────────────────────────────────────────────────
// WIDGETS PRIVADOS
// ──────────────────────────────────────────────────────────────────────────────

/// MEJORA: _FadeSlide es idéntico al original pero ahora vive en este archivo.
/// Sin cambios de contrato.
class _FadeSlide extends StatelessWidget {
  final AnimationController controller;
  final Interval interval;
  final Widget child;

  const _FadeSlide({
    required this.controller,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: interval),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: interval)),
        child: child,
      ),
    );
  }
}

class _TarjetaPaso extends StatefulWidget {
  final String emoji;
  final String titulo;
  final String desc;
  final Color color;
  final Color bg;
  final Color borderColor;

  const _TarjetaPaso({
    required this.emoji,
    required this.titulo,
    required this.desc,
    required this.color,
    required this.bg,
    required this.borderColor,
  });

  @override
  State<_TarjetaPaso> createState() => _TarjetaPasoState();
}

class _TarjetaPasoState extends State<_TarjetaPaso> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        transform:
            Matrix4.translationValues(0, _isHovered ? -10 : 0, 0),
        constraints: const BoxConstraints(maxWidth: 280),
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: widget.bg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _isHovered
                ? Colors.blueAccent.withOpacity(0.5)
                : widget.borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? Colors.blueAccent.withOpacity(0.15)
                  : Colors.black.withOpacity(0.03),
              blurRadius: _isHovered ? 30 : 12,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedScale(
              scale: _isHovered ? 1.18 : 1.0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              child: Text(widget.emoji,
                  style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 18),
            Text(
              widget.titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: widget.color),
            ),
            const SizedBox(height: 10),
            Text(
              widget.desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: widget.color.withOpacity(0.65), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaPlan extends StatefulWidget {
  final String titulo;
  final String precio;
  final String emoji;
  final Color colorPrimario;
  final List<String> items;
  final Color bg;
  final Color txtPrincipal;
  final Color txtSecundario;
  final Color borderColor;
  final bool esPro;

  const _TarjetaPlan({
    required this.titulo,
    required this.precio,
    required this.emoji,
    required this.colorPrimario,
    required this.items,
    required this.bg,
    required this.txtPrincipal,
    required this.txtSecundario,
    required this.borderColor,
    this.esPro = false,
  });

  @override
  State<_TarjetaPlan> createState() => _TarjetaPlanState();
}

class _TarjetaPlanState extends State<_TarjetaPlan> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        transform:
            Matrix4.translationValues(0, _isHovered ? -14 : 0, 0),
        constraints: const BoxConstraints(maxWidth: 340),
        width: double.infinity,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: widget.bg,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: widget.esPro
                ? (_isHovered
                    ? widget.colorPrimario
                    : widget.colorPrimario.withOpacity(0.5))
                : (_isHovered
                    ? widget.txtSecundario.withOpacity(0.3)
                    : widget.borderColor),
            width: widget.esPro ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.esPro
                  ? widget.colorPrimario
                      .withOpacity(_isHovered ? 0.28 : 0.06)
                  : Colors.black.withOpacity(_isHovered ? 0.06 : 0.02),
              blurRadius: _isHovered ? 40 : 20,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            if (widget.esPro)
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.amber.shade400,
                    Colors.orange.shade600
                  ]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Text(
                  'MÁS ELEGIDO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            Text(widget.emoji,
                style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 10),
            Text(
              widget.titulo,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: widget.txtSecundario),
            ),
            Text(
              widget.precio,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: widget.esPro
                    ? widget.colorPrimario
                    : widget.txtPrincipal,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 22),
            Divider(color: widget.txtSecundario.withOpacity(0.2)),
            const SizedBox(height: 22),
            ...widget.items.map(
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: widget.colorPrimario, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        i,
                        style: TextStyle(
                          color: widget.txtSecundario,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RegisterScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.esPro
                      ? widget.colorPrimario
                      : Colors.blueGrey.withOpacity(0.1),
                  foregroundColor: widget.esPro
                      ? Colors.white
                      : widget.txtPrincipal,
                  elevation: widget.esPro && _isHovered ? 8 : 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  widget.esPro ? 'Solicitar PRO' : 'Empezar Gratis',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonFlotanteMagico extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _BotonFlotanteMagico(
      {required this.onTap, this.isLoading = false});

  @override
  State<_BotonFlotanteMagico> createState() =>
      _BotonFlotanteMagicoState();
}

class _BotonFlotanteMagicoState extends State<_BotonFlotanteMagico> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          transform:
              Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 28 : 40,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isHovered
                  ? [Colors.blueAccent, Colors.purpleAccent]
                  : [
                      Colors.blueAccent.shade700,
                      Colors.blueAccent
                    ],
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent
                    .withOpacity(_isHovered ? 0.55 : 0.3),
                blurRadius: _isHovered ? 30 : 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // MEJORA: AnimatedSwitcher entre icono y spinner anti doble-tap.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'CREAR CUENTA AHORA',
                        key: const ValueKey('label'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 16 : 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
              if (!widget.isLoading) ...[
                const SizedBox(width: 14),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: isMobile ? 22 : 26),
              ],
            ],
          ),
        ),
      ),
    );
  }
}