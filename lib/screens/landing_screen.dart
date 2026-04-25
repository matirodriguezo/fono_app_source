import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'login_screen.dart';
import 'register_screen.dart';
import '../main.dart'; // Importamos la variable global

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late AnimationController _bgAnimationController;
  late AnimationController _entryAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _entryAnimationController.forward();
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _entryAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final isTinyMobile = screenWidth < 380; 

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, child) {
        final colorTextoPrincipal = isDark ? Colors.white : const Color(0xFF1E293B);
        final colorTextoSecundario = isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade700;
        final colorFondoTarjeta = isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6);
        final colorBordeTarjeta = isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Padding(
              padding: EdgeInsets.only(left: isMobile ? 0 : 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.record_voice_over, color: Colors.blueAccent, size: isMobile ? 24 : 30),
                  const SizedBox(width: 8),
                  if (!isTinyMobile)
                    Text('FonoApp', style: TextStyle(fontWeight: FontWeight.w900, color: colorTextoPrincipal, fontSize: isMobile ? 18 : 22, letterSpacing: -0.5)),
                ],
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => isDarkModeGlobal.value = !isDarkModeGlobal.value,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.blueGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.transparent)
                    ),
                    child: Row(
                      children: [
                        Text(isDark ? '🌙' : '☀️', style: const TextStyle(fontSize: 16)),
                        if (!isMobile) ...[
                          const SizedBox(width: 8),
                          Text(isDark ? 'Oscuro' : 'Claro', style: TextStyle(fontWeight: FontWeight.bold, color: colorTextoPrincipal, fontSize: 13)),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16)),
                child: Text(isMobile ? 'Entrar' : 'Iniciar Sesión', style: TextStyle(fontWeight: FontWeight.bold, color: colorTextoSecundario, fontSize: isMobile ? 14 : 16)),
              ),
              Padding(
                padding: EdgeInsets.only(right: isMobile ? 10 : 30.0, left: 4),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 10,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                  child: Text(isMobile ? 'Registro' : 'Registrarse', style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 13 : 14)),
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
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), 
                  child: SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200), 
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: 60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _FadeSlide(
                                controller: _entryAnimationController,
                                interval: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.1), 
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3))
                                  ),
                                  child: Text('🚀 El SAAC más intuitivo de la web', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: isMobile ? 12 : 14, letterSpacing: 0.5)),
                                ),
                              ),
                              const SizedBox(height: 30),
                              _FadeSlide(
                                controller: _entryAnimationController,
                                interval: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: isDark ? [Colors.blue.shade300, Colors.purple.shade300] : [Colors.blue.shade700, Colors.purple.shade700],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Text(
                                    'Dale voz a quienes\nmás lo necesitan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isMobile ? 38 : 75,
                                      fontWeight: FontWeight.w900, 
                                      color: Colors.white, 
                                      height: 1.1, 
                                      letterSpacing: -1.5
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              _FadeSlide(
                                controller: _entryAnimationController,
                                interval: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
                                child: Text(
                                  'FonoApp facilita la comunicación aumentativa mediante\npictogramas interactivos, ayudando a estructurar oraciones de forma natural.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: isMobile ? 16 : 22, color: colorTextoSecundario, height: 1.5, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(height: 60),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 30,
                                runSpacing: 30,
                                children: [
                                  _FadeSlide(controller: _entryAnimationController, interval: const Interval(0.3, 0.7), child: _TarjetaPaso(emoji: '👤', titulo: '1. Crea tu cuenta', desc: 'Regístrate gratis y asegura el progreso.', color: colorTextoPrincipal, bg: colorFondoTarjeta, borderColor: colorBordeTarjeta)),
                                  _FadeSlide(controller: _entryAnimationController, interval: const Interval(0.4, 0.8), child: _TarjetaPaso(emoji: '👆', titulo: '2. Toca y arma', desc: 'Selecciona tarjetas categorizadas.', color: colorTextoPrincipal, bg: colorFondoTarjeta, borderColor: colorBordeTarjeta)),
                                  _FadeSlide(controller: _entryAnimationController, interval: const Interval(0.5, 0.9), child: _TarjetaPaso(emoji: '🔊', titulo: '3. Hazte escuchar', desc: 'Motor de voz fluido y natural.', color: colorTextoPrincipal, bg: colorFondoTarjeta, borderColor: colorBordeTarjeta)),
                                ],
                              ),
                              const SizedBox(height: 90),
                              _FadeSlide(
                                controller: _entryAnimationController,
                                interval: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                                child: Text('Elige tu nivel de acceso', textAlign: TextAlign.center, style: TextStyle(fontSize: isMobile ? 28 : 45, fontWeight: FontWeight.w900, color: colorTextoPrincipal, letterSpacing: -1)),
                              ),
                              const SizedBox(height: 40),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 40,
                                runSpacing: 40,
                                children: [
                                  _FadeSlide(
                                    controller: _entryAnimationController, 
                                    interval: const Interval(0.7, 1.0), 
                                    child: _TarjetaPlan(
                                      titulo: 'Plan DEMO', precio: 'Gratis', emoji: '✨', colorPrimario: Colors.blueGrey, items: const ['Vocabulario núcleo (Acceso rápido)', 'Carpetas de Saludos y Necesidades', 'Síntesis de voz básica', 'Sin límite de tiempo'], bg: colorFondoTarjeta, txtPrincipal: colorTextoPrincipal, txtSecundario: colorTextoSecundario, borderColor: colorBordeTarjeta
                                    )
                                  ),
                                  _FadeSlide(
                                    controller: _entryAnimationController, 
                                    interval: const Interval(0.8, 1.0), 
                                    child: _TarjetaPlan(
                                      titulo: 'Plan PRO', precio: 'Premium', emoji: '👑', colorPrimario: Colors.amber.shade500, items: const ['Todas las funciones DEMO', '+80 pictogramas clínicos', 'Carpetas avanzadas (Lugares, Comida)', 'Construcción de oraciones complejas'], bg: colorFondoTarjeta, txtPrincipal: colorTextoPrincipal, txtSecundario: colorTextoSecundario, borderColor: colorBordeTarjeta, esPro: true
                                    )
                                  ),
                                ],
                              ),
                              const SizedBox(height: 80),
                              _FadeSlide(
                                controller: _entryAnimationController,
                                interval: const Interval(0.8, 1.0),
                                child: _BotonFlotanteMagico(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (isMobile)
                                TextButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())), 
                                  child: Text("¿Ya tienes cuenta? Inicia Sesión", style: TextStyle(color: colorTextoSecundario, fontWeight: FontWeight.bold))
                                ),
                              const SizedBox(height: 40),
                              Text('© 2026 FonoApp. Desarrollado con propósito y dedicación.', textAlign: TextAlign.center, style: TextStyle(color: colorTextoSecundario, fontSize: 14)),
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
      }
    );
  }
}

class _FadeSlide extends StatelessWidget {
  final AnimationController controller;
  final Interval interval;
  final Widget child;

  const _FadeSlide({required this.controller, required this.interval, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: interval),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: controller, curve: interval),
        ),
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

  const _TarjetaPaso({required this.emoji, required this.titulo, required this.desc, required this.color, required this.bg, required this.borderColor});

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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, _isHovered ? -10 : 0, 0),
        constraints: const BoxConstraints(maxWidth: 280), 
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: widget.bg, 
          borderRadius: BorderRadius.circular(35), 
          border: Border.all(color: _isHovered ? Colors.blueAccent.withOpacity(0.5) : widget.borderColor, width: 2),
          boxShadow: [
            BoxShadow(color: _isHovered ? Colors.blueAccent.withOpacity(0.15) : Colors.black.withOpacity(0.02), blurRadius: _isHovered ? 30 : 15, offset: const Offset(0, 10))
          ]
        ),
        child: Column(
          children: [
            AnimatedScale(
              scale: _isHovered ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Text(widget.emoji, style: const TextStyle(fontSize: 50)),
            ),
            const SizedBox(height: 20),
            Text(widget.titulo, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: widget.color)),
            const SizedBox(height: 10),
            Text(widget.desc, textAlign: TextAlign.center, style: TextStyle(color: widget.color.withOpacity(0.7), height: 1.4)),
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

  const _TarjetaPlan({required this.titulo, required this.precio, required this.emoji, required this.colorPrimario, required this.items, required this.bg, required this.txtPrincipal, required this.txtSecundario, required this.borderColor, this.esPro = false});

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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -15 : 0, 0),
        constraints: const BoxConstraints(maxWidth: 350), 
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: widget.bg,
          borderRadius: BorderRadius.circular(45),
          border: Border.all(
            color: widget.esPro 
              ? (_isHovered ? widget.colorPrimario : widget.colorPrimario.withOpacity(0.5)) 
              : (_isHovered ? widget.txtSecundario.withOpacity(0.3) : widget.borderColor), 
            width: widget.esPro ? 3 : 2
          ),
          boxShadow: [
            BoxShadow(
              color: widget.esPro ? widget.colorPrimario.withOpacity(_isHovered ? 0.3 : 0.05) : Colors.black.withOpacity(_isHovered ? 0.05 : 0.01),
              blurRadius: _isHovered ? 40 : 20,
              offset: const Offset(0, 15)
            )
          ]
        ),
        child: Column(
          children: [
            if (widget.esPro)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade600]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                ),
                child: const Text('MÁS ELEGIDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
              ),
            Text(widget.emoji, style: const TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            Text(widget.titulo, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.txtSecundario)),
            Text(widget.precio, style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: widget.esPro ? widget.colorPrimario : widget.txtPrincipal, letterSpacing: -1)),
            const SizedBox(height: 25),
            Divider(color: widget.txtSecundario.withOpacity(0.2)),
            const SizedBox(height: 25),
            ...widget.items.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, color: widget.colorPrimario, size: 22), 
                  const SizedBox(width: 12), 
                  Expanded(child: Text(i, style: TextStyle(color: widget.txtSecundario, fontSize: 16, height: 1.3)))
                ]
              ),
            )),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.esPro ? widget.colorPrimario : Colors.blueGrey.withOpacity(0.1),
                  foregroundColor: widget.esPro ? Colors.white : widget.txtPrincipal,
                  elevation: widget.esPro && _isHovered ? 10 : 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(widget.esPro ? 'Solicitar PRO' : 'Empezar Gratis', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _BotonFlotanteMagico extends StatefulWidget {
  final VoidCallback onTap;
  const _BotonFlotanteMagico({required this.onTap});

  @override
  State<_BotonFlotanteMagico> createState() => _BotonFlotanteMagicoState();
}

class _BotonFlotanteMagicoState extends State<_BotonFlotanteMagico> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 30 : 40, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isHovered ? [Colors.blueAccent, Colors.purpleAccent] : [Colors.blueAccent.shade700, Colors.blueAccent],
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(_isHovered ? 0.6 : 0.3),
                blurRadius: _isHovered ? 30 : 15,
                offset: const Offset(0, 10),
              )
            ]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('CREAR CUENTA AHORA', style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(width: 15),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: isMobile ? 24 : 28),
            ],
          ),
        ),
      ),
    );
  }
}