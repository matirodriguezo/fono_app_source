import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:video_player/video_player.dart'; // NUEVA IMPORTACIÓN
import 'login_screen.dart';
import 'register_screen.dart';
import '../providers/theme_provider.dart';
import '../constants.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/glass_layout.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late AnimationController _entryController;
  bool _ctaLoading = false;
  final ScrollController _scrollController = ScrollController();
  bool _showStickyCta = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _irARegistro() async {
    if (_ctaLoading) return;
    setState(() => _ctaLoading = true);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _ctaLoading = false);
  }

  void _onScroll() {
    final show = _scrollController.hasClients && _scrollController.offset > 400;
    if (show != _showStickyCta) {
      setState(() => _showStickyCta = show);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileWidth;
    final isLargeDesktop = context.isDesktopWidth;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        final colorTexto = isDark ? Colors.white : const Color(0xFF1E293B);
        final colorTextoSec = isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade700;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Padding(
              padding: EdgeInsets.only(left: isMobile ? 4.0 : 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.record_voice_over, color: Colors.blueAccent, size: isMobile ? 24 : 28),
                  const SizedBox(width: 8),
                  if (MediaQuery.of(context).size.width >= 380) Text('FonoApp', style: TextStyle(fontWeight: FontWeight.w900, color: colorTexto, fontSize: isMobile ? 18 : 22, letterSpacing: -0.5)),
                ],
              ),
            ),
            actions: [
              ThemeToggleButton(showLabel: !isMobile),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Text(isMobile ? 'Entrar' : 'Iniciar Sesión', style: TextStyle(fontWeight: FontWeight.bold, color: colorTextoSec, fontSize: isMobile ? 14 : 15)),
              ),
              Padding(
                padding: EdgeInsets.only(right: isMobile ? 10.0 : 28.0, left: 4),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 6, shadowColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text(isMobile ? 'Registro' : 'Registrarse', style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 13 : 14)),
                ),
              ),
            ],
          ),
          body: GlassLayout(
            sphereSize: 600,
            sphere1: const SphereStyle(
              color: Colors.blueAccent,
              darkOpacity: 0.3,
              lightOpacity: 0.15,
              horizontalAmplitude: 80,
              verticalAmplitude: 100,
            ),
            sphere2: const SphereStyle(
              color: Colors.purpleAccent,
              darkOpacity: 0.2,
              lightOpacity: 0.1,
              horizontalAmplitude: 80,
              verticalAmplitude: 120,
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: 60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _FadeSlide(
                                controller: _entryController, interval: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
                                  child: Text('🚀 El SAAC más intuitivo de la web', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: isMobile ? 12 : 14, letterSpacing: 0.5)),
                                ),
                              ),
                              const SizedBox(height: 28),
                              _FadeSlide(
                                controller: _entryController, interval: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: isDark ? [Colors.blue.shade300, Colors.purple.shade300] : [Colors.blue.shade700, Colors.purple.shade700],
                                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Text('Dale voz a quienes\nmás lo necesitan', textAlign: TextAlign.center, style: TextStyle(fontSize: isMobile ? 38 : isLargeDesktop ? 80 : 68, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -2)),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _FadeSlide(
                                controller: _entryController, interval: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 680),
                                  child: Text('FonoApp facilita la comunicación aumentativa mediante pictogramas interactivos, ayudando a estructurar oraciones de forma natural.', textAlign: TextAlign.center, softWrap: true, style: TextStyle(fontSize: isMobile ? 16 : 20, color: colorTextoSec, height: 1.6, fontWeight: FontWeight.w500)),
                                ),
                              ),
                              const SizedBox(height: 60),

                              // TARJETAS GLASS DE PASOS
                              Wrap(
                                alignment: WrapAlignment.center, spacing: 24, runSpacing: 24,
                                children: [
                                  _FadeSlide(controller: _entryController, interval: const Interval(0.3, 0.7), child: _TarjetaPasoGlass(emoji: '👤', titulo: '1. Crea tu cuenta', desc: 'Regístrate gratis y asegura tu progreso.', isDark: isDark)),
                                  _FadeSlide(controller: _entryController, interval: const Interval(0.4, 0.8), child: _TarjetaPasoGlass(emoji: '👆', titulo: '2. Toca y arma', desc: 'Selecciona tarjetas y construye frases.', isDark: isDark)),
                                  _FadeSlide(controller: _entryController, interval: const Interval(0.5, 0.9), child: _TarjetaPasoGlass(emoji: '🔊', titulo: '3. Hazte escuchar', desc: 'Motor de voz fluido y clínicamente calibrado.', isDark: isDark)),
                                ],
                              ),
                              const SizedBox(height: 60),

                              // DEMO SHOWCASE
                              _FadeSlide(
                                controller: _entryController, interval: const Interval(0.55, 0.9, curve: Curves.easeOutCubic),
                                child: _DemoShowcase(
                                  isDark: isDark,
                                  isMobile: isMobile,
                                  onTap: _irARegistro,
                                ),
                              ),
                              const SizedBox(height: 90),

                              // PRECIOS
                              _FadeSlide(
                                controller: _entryController, interval: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                                child: Text('Elige tu nivel de acceso', textAlign: TextAlign.center, style: TextStyle(fontSize: isMobile ? 28 : 44, fontWeight: FontWeight.w900, color: colorTexto, letterSpacing: -1)),
                              ),
                              const SizedBox(height: 12),
                              _FadeSlide(
                                controller: _entryController, interval: const Interval(0.62, 1.0),
                                child: Text('Sin contratos. Sin sorpresas.', style: TextStyle(color: colorTextoSec, fontSize: 16)),
                              ),
                              const SizedBox(height: 40),
                              Wrap(
                                alignment: WrapAlignment.center, spacing: 36, runSpacing: 36,
                                children: [
                                  _FadeSlide(controller: _entryController, interval: const Interval(0.7, 1.0), child: _TarjetaPlanGlass(titulo: 'Plan DEMO', precio: 'Gratis', emoji: '✨', colorPrimario: Colors.blueGrey, items: const ['Vocabulario núcleo (acceso rápido)', 'Carpetas de Saludos y Necesidades', 'Síntesis de voz sin límite', 'Sin límite de tiempo'], isDark: isDark)),
                                  _FadeSlide(controller: _entryController, interval: const Interval(0.8, 1.0), child: _TarjetaPlanGlass(titulo: 'Plan PRO', precio: 'Premium', emoji: '👑', colorPrimario: Colors.amber.shade500, items: const ['Todas las funciones DEMO incluidas', '+80 pictogramas clínicos', 'Carpetas avanzadas: Lugares, Comida', 'Construcción de oraciones complejas'], isDark: isDark, esPro: true)),
                                ],
                              ),
                              const SizedBox(height: 40),

                              // CTA FINAL
                              _FadeSlide(controller: _entryController, interval: const Interval(0.85, 1.0), child: _BotonFlotanteMagico(onTap: _irARegistro, isLoading: _ctaLoading)),
                              const SizedBox(height: 20),
                              if (isMobile) TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: Text('¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: colorTextoSec, fontWeight: FontWeight.bold))),
                              const SizedBox(height: 48),

                              Divider(color: colorTextoSec.withOpacity(0.2), height: 1),
                              const SizedBox(height: 24),
                              Text('© 2026 FonoApp · Desarrollado con propósito y dedicación.', textAlign: TextAlign.center, style: TextStyle(color: colorTextoSec.withOpacity(0.7), fontSize: 13)),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
              if (_showStickyCta)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: _StickyCtaButton(
                    isLoading: _ctaLoading,
                    onTap: _irARegistro,
                    isDark: isDark,
                    isMobile: isMobile,
                  ),
                ),
              ],
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

class _FadeSlide extends StatelessWidget {
  final AnimationController controller;
  final Interval interval;
  final Widget child;
  const _FadeSlide({required this.controller, required this.interval, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: CurvedAnimation(parent: controller, curve: interval), child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: controller, curve: interval)), child: child));
  }
}

// Tarjeta Glassmorphism para Pasos
class _TarjetaPasoGlass extends StatefulWidget {
  final String emoji; final String titulo; final String desc; final bool isDark;
  const _TarjetaPasoGlass({required this.emoji, required this.titulo, required this.desc, required this.isDark});

  @override
  State<_TarjetaPasoGlass> createState() => _TarjetaPasoGlassState();
}

class _TarjetaPasoGlassState extends State<_TarjetaPasoGlass> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorTexto = widget.isDark ? Colors.white : const Color(0xFF1E293B);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -10 : 0, 0),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _isHovered ? Colors.blueAccent.withOpacity(0.5) : (widget.isDark ? Colors.white12 : Colors.white), width: 2),
          boxShadow: [BoxShadow(color: _isHovered ? Colors.blueAccent.withOpacity(0.15) : Colors.black.withOpacity(0.05), blurRadius: _isHovered ? 30 : 20, offset: const Offset(0, 10))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  AnimatedScale(scale: _isHovered ? 1.18 : 1.0, duration: const Duration(milliseconds: 280), curve: Curves.easeOutBack, child: Text(widget.emoji, style: const TextStyle(fontSize: 48))),
                  const SizedBox(height: 18),
                  Text(widget.titulo, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: colorTexto)),
                  const SizedBox(height: 10),
                  Text(widget.desc, textAlign: TextAlign.center, style: TextStyle(color: colorTexto.withOpacity(0.65), height: 1.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Tarjeta Glassmorphism para Precios
class _TarjetaPlanGlass extends StatefulWidget {
  final String titulo, precio, emoji;
  final Color colorPrimario;
  final List<String> items;
  final bool isDark, esPro;

  const _TarjetaPlanGlass({required this.titulo, required this.precio, required this.emoji, required this.colorPrimario, required this.items, required this.isDark, this.esPro = false});

  @override
  State<_TarjetaPlanGlass> createState() => _TarjetaPlanGlassState();
}

class _TarjetaPlanGlassState extends State<_TarjetaPlanGlass> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorTexto = widget.isDark ? Colors.white : const Color(0xFF1E293B);
    final colorSecundario = widget.isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade700;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -14 : 0, 0),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: widget.esPro ? (_isHovered ? widget.colorPrimario : widget.colorPrimario.withOpacity(0.5)) : (_isHovered ? colorSecundario.withOpacity(0.3) : (widget.isDark ? Colors.white12 : Colors.white)), width: widget.esPro ? 3 : 2),
          boxShadow: [BoxShadow(color: widget.esPro ? widget.colorPrimario.withOpacity(_isHovered ? 0.28 : 0.06) : Colors.black.withOpacity(_isHovered ? 0.06 : 0.05), blurRadius: _isHovered ? 40 : 20, offset: const Offset(0, 15))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                children: [
                  if (widget.esPro) Container(margin: const EdgeInsets.only(bottom: 18), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade600]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]), child: const Text('MÁS ELEGIDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5))),
                  Text(widget.emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  Text(widget.titulo, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorSecundario)),
                  Text(widget.precio, style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: widget.esPro ? widget.colorPrimario : colorTexto, letterSpacing: -1)),
                  const SizedBox(height: 22),
                  Divider(color: colorSecundario.withOpacity(0.2)),
                  const SizedBox(height: 22),
                  ...widget.items.map((i) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.check_circle_rounded, color: widget.colorPrimario, size: 20), const SizedBox(width: 10), Expanded(child: Text(i, style: TextStyle(color: colorSecundario, fontSize: 15, height: 1.4)))]) )),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      style: ElevatedButton.styleFrom(backgroundColor: widget.esPro ? widget.colorPrimario : Colors.blueGrey.withOpacity(0.1), foregroundColor: widget.esPro ? Colors.white : colorTexto, elevation: widget.esPro && _isHovered ? 8 : 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                      child: Text(widget.esPro ? 'Solicitar PRO' : 'Empezar Gratis', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonFlotanteMagico extends StatefulWidget {
  final VoidCallback onTap; final bool isLoading;
  const _BotonFlotanteMagico({required this.onTap, this.isLoading = false});
  @override
  State<_BotonFlotanteMagico> createState() => _BotonFlotanteMagicoState();
}

class _BotonFlotanteMagicoState extends State<_BotonFlotanteMagico> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileWidth;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 28 : 40, vertical: 20),
          decoration: BoxDecoration(gradient: LinearGradient(colors: _isHovered ? [Colors.blueAccent, Colors.purpleAccent] : [Colors.blueAccent.shade700, Colors.blueAccent]), borderRadius: BorderRadius.circular(40), boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(_isHovered ? 0.55 : 0.3), blurRadius: _isHovered ? 30 : 15, offset: const Offset(0, 10))]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: widget.isLoading ? const SizedBox(key: ValueKey('loading'), width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Text('CREAR CUENTA AHORA', key: const ValueKey('label'), style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
              if (!widget.isLoading) ...[const SizedBox(width: 14), Icon(Icons.arrow_forward_rounded, color: Colors.white, size: isMobile ? 22 : 26)],
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyCtaButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;
  final bool isDark;
  final bool isMobile;

  const _StickyCtaButton({
    required this.onTap,
    this.isLoading = false,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<_StickyCtaButton> createState() => _StickyCtaButtonState();
}

class _StickyCtaButtonState extends State<_StickyCtaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _animController,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: widget.isMobile ? 20 : 48,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isMobile ? 4 : 8,
              vertical: widget.isMobile ? 4 : 8,
            ),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF1E293B).withOpacity(0.95)
                  : Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Crea tu cuenta gratis',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: widget.isMobile ? 14 : 16,
                        color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isMobile ? 20 : 28,
                      vertical: widget.isMobile ? 12 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                    shadowColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Registrarse',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: widget.isMobile ? 13 : 15,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// NUEVO: DEMO SHOWCASE (Mockup de teléfono CON VIDEO)
// ──────────────────────────────────────────────────────────────────────────────
class _DemoShowcase extends StatefulWidget {
  final bool isDark;
  final bool isMobile;
  final VoidCallback onTap;

  const _DemoShowcase({
    required this.isDark,
    required this.isMobile,
    required this.onTap,
  });

  @override
  State<_DemoShowcase> createState() => _DemoShowcaseState();
}

class _DemoShowcaseState extends State<_DemoShowcase> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // Reemplaza con la ruta real de tu archivo de video
    _videoController = VideoPlayerController.asset('assets/images/demo/demo_video.mp4')
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController.setVolume(0.0); // Opcional: reproduce el video sin sonido
        _videoController.setLooping(true); // Opcional: reproduce el video en bucle
        _videoController.play();
      }).catchError((error) {
        debugPrint('Error inicializando video: $error');
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorSecundario = widget.isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade700;

    return Column(
      children: [
        // Badge de la sección
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'ASÍ FUNCIONA',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.5,
              color: Colors.blueAccent,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Toca, arma y escucha',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: widget.isMobile ? 26 : 36,
            fontWeight: FontWeight.w900,
            color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Así de simple se construye una frase en FonoApp',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorSecundario,
            fontSize: widget.isMobile ? 14 : 16,
          ),
        ),
        const SizedBox(height: 36),

        // Mockup de teléfono
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: widget.isMobile ? 220 : 280,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(widget.isMobile ? 32 : 40),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.isMobile ? 24 : 32),
                  color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barra superior del teléfono
                    Container(
                      height: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 6,
                            decoration: BoxDecoration(
                              color: widget.isDark ? Colors.white24 : Colors.black12,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // REPRODUCTOR DE VIDEO
                    // ════════════════════════════════════════════════════════
                    SizedBox(
                      width: double.infinity,
                      height: widget.isMobile ? 440 : 570,
                      child: _isVideoInitialized
                          ? SizedBox.expand(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _videoController.value.size.width,
                                  height: _videoController.value.size.height,
                                  child: VideoPlayer(_videoController),
                                ),
                              ),
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                    // ════════════════════════════════════════════════════════
                    
                    // Barra inferior del teléfono
                    Container(
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isDark ? Colors.white24 : Colors.black12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

