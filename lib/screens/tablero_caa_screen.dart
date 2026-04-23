import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/pictograma.dart';
import '../services/tts_service.dart';

class TableroCAAScreen extends StatefulWidget {
  const TableroCAAScreen({super.key});

  @override
  State<TableroCAAScreen> createState() => _TableroCAAScreenState();
}

class _TableroCAAScreenState extends State<TableroCAAScreen> with TickerProviderStateMixin {
  final List<Pictograma> _oracionActual = [];
  late final List<Pictograma> _vocabulario;
  final TtsService _motorVoz = TtsService();

  late AnimationController _gridIntroController;
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _vocabulario = RepositorioVocabulario.obtenerVocabularioBase();

    _gridIntroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Un poco más rápida la entrada inicial
    );
    
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Más lento para que consuma menos CPU
    )..repeat(reverse: true);

    _gridIntroController.forward();
  }

  @override
  void dispose() {
    _gridIntroController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  void _agregarPictograma(Pictograma pic) {
    HapticFeedback.lightImpact(); 
    setState(() => _oracionActual.add(pic));
  }

  void _borrarUltimo() {
    if (_oracionActual.isNotEmpty) {
      HapticFeedback.mediumImpact();
      setState(() => _oracionActual.removeLast());
    }
  }

  void _borrarTodo() {
    if (_oracionActual.isNotEmpty) {
      HapticFeedback.heavyImpact();
      setState(() => _oracionActual.clear());
    }
  }

  void _reproducirOracion() async {
    if (_oracionActual.isEmpty) {
      HapticFeedback.vibrate(); 
      _mostrarErrorUltra();
      return;
    }
    
    HapticFeedback.heavyImpact();
    String fraseCompleta = _oracionActual.map((pic) => pic.palabra).join(" ");
    await _motorVoz.hablar(fraseCompleta);
  }

  void _mostrarErrorUltra() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: TweenAnimationBuilder(
          tween: Tween<double>(begin: -20, end: 0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, double val, child) {
            return Transform.translate(
              offset: Offset(val, 0), 
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade200,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.white, size: 30),
                    SizedBox(width: 15),
                    Text('¡Arma una frase primero!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
                  ],
                ),
              ),
            );
          },
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _bgAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFFE0F2FE), const Color(0xFFF3E8FF), _bgAnimationController.value)!,
                  Color.lerp(const Color(0xFFF1F5F9), const Color(0xFFE0E7FF), _bgAnimationController.value)!,
                  Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFDBEAFE), _bgAnimationController.value)!,
                ],
                stops: const [0.0, 0.5, 1.0],
                transform: GradientRotation(_bgAnimationController.value * 2 * math.pi),
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              _construirCabecera(),
              _construirBarraOracionGlass(),
              const SizedBox(height: 15),
              _construirGrillaVocabulario(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCabecera() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'FonoApp Pro', 
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 34, 
              letterSpacing: -1.5,
              color: Color(0xFF1E293B), 
            )
          ),
          _construirVoiceIndicator()
        ],
      ),
    );
  }

  Widget _construirVoiceIndicator() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOutSine,
      builder: (context, double val, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2), 
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.2 + (val * 0.3)), 
                blurRadius: 15 + (val * 15), 
                spreadRadius: val * 5,
              ),
            ]
          ),
          child: Icon(Icons.waves_rounded, color: Colors.blueAccent.shade400, size: 28),
        );
      },
    );
  }

  Widget _construirBarraOracionGlass() {
    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), 
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutBack,
              child: _oracionActual.isEmpty 
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(seconds: 2),
                        builder: (ctx, double v, child) => Transform.translate(
                          offset: Offset(0, math.sin(v * math.pi * 2) * 5), 
                          child: child,
                        ),
                        child: Icon(Icons.auto_awesome_rounded, size: 55, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 12),
                      Text('¡Arma tu frase mágica!', 
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _oracionActual.length,
                    itemBuilder: (context, index) {
                      // NUEVA ANIMACIÓN DE INSERCIÓN (Pop & Drop)
                      return TweenAnimationBuilder(
                        // ValueKey es clave: Le dice a Flutter que es una tarjeta nueva para que dispare la animación
                        key: ValueKey('${_oracionActual[index].palabra}_$index'), 
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut, 
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double val, child) {
                          return Transform.translate(
                            // La tarjeta "salta" desde 40 píxeles más abajo hacia su posición 0
                            offset: Offset(0, 40 * (1 - val)), 
                            child: Opacity(
                              opacity: val.clamp(0.0, 1.0), 
                              child: Transform.scale(
                                scale: val.clamp(0.0, 1.0), 
                                child: child
                              ),
                            ),
                          );
                        },
                        child: _construirMiniTarjeta(_oracionActual[index]),
                      );
                    },
                  ),
            ),
          ),
          Container(width: 3, margin: const EdgeInsets.symmetric(horizontal: 10), color: Colors.white),
          _construirControlesBarra(),
        ],
      ),
    );
  }

  Widget _construirControlesBarra() {
    bool canSpeak = _oracionActual.isNotEmpty;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            _BotonControlUltra(
              icono: Icons.backspace_rounded, 
              color: Colors.redAccent, 
              onTap: _borrarUltimo
            ),
            const SizedBox(width: 8),
            _BotonControlUltra(
              icono: Icons.delete_sweep_rounded, 
              color: Colors.blueGrey, 
              onTap: _borrarTodo
            ),
          ],
        ),
        GestureDetector(
          onTap: _reproducirOracion,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: canSpeak ? [Colors.blue.shade400, Colors.blue.shade600] : [Colors.grey.shade300, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2), 
              boxShadow: [
                BoxShadow(
                  color: canSpeak ? Colors.blue.shade300.withOpacity(0.6) : Colors.transparent,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            ),
            child: Row(
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                const SizedBox(width: 5),
                Text('HABLAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirGrillaVocabulario() {
    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160,
          childAspectRatio: 0.85, 
          crossAxisSpacing: 18,
          mainAxisSpacing: 22, 
        ),
        itemCount: _vocabulario.length,
        itemBuilder: (context, index) {
          final double start = (index / _vocabulario.length) * 0.7; 
          final double end = start + 0.3; 

          return AnimatedBuilder(
            animation: _gridIntroController,
            builder: (context, child) {
              final double animationVal = Curves.elasticOut.transform(
                Interval(start, end, curve: Curves.easeOut).transform(_gridIntroController.value)
              );
              
              return Opacity(
                opacity: _gridIntroController.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: animationVal.clamp(0.0, 1.2), 
                  child: child,
                ),
              );
            },
            child: TarjetaSquish3D(
              pic: _vocabulario[index],
              onTap: () => _agregarPictograma(_vocabulario[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _construirMiniTarjeta(Pictograma pic) {
    return Container(
      width: 95,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: pic.colorFondo,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 8)),
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(pic.icono, size: 40, color: Colors.black87),
          const SizedBox(height: 6),
          Text(pic.palabra, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.5), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// --- WIDGET OPTIMIZADO: TARJETA "SQUISH 3D" ON-DEMAND ---
class TarjetaSquish3D extends StatefulWidget {
  final Pictograma pic;
  final VoidCallback onTap;

  const TarjetaSquish3D({super.key, required this.pic, required this.onTap});

  @override
  State<TarjetaSquish3D> createState() => _TarjetaSquish3DState();
}

class _TarjetaSquish3DState extends State<TarjetaSquish3D> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    // Controlador más rápido (1.5s ida y vuelta) pero que NO arranca automáticamente
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _startHover() {
    setState(() => _isHovered = true);
    // Solo cuando hay hover, la tarjeta empieza a respirar
    _floatController.repeat(reverse: true);
  }

  void _stopHover() {
    setState(() { 
      _isHovered = false; 
      _isPressed = false; 
    });
    // Al sacar el ratón, se detiene el ciclo y vuelve suavemente a su posición base 0
    _floatController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _onInteractionStart() {
    setState(() { _isPressed = true; });
  }

  void _onInteractionEnd() {
    setState(() { _isPressed = false; });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _startHover(),
      onExit: (_) => _stopHover(),
      child: GestureDetector(
        onTapDown: (_) => _onInteractionStart(),
        onTapUp: (_) {
          _onInteractionEnd();
          widget.onTap(); 
        },
        onTapCancel: () => _onInteractionEnd(),
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            // La tarjeta solo flota si está hovered pero NO si la estamos presionando
            double floatY = (_isHovered && !_isPressed) ? math.sin(_floatController.value * math.pi) * -6 : 0;
            
            double scaleX = _isPressed ? 1.05 : (_isHovered ? 1.05 : 1.0);
            double scaleY = _isPressed ? 0.90 : (_isHovered ? 1.05 : 1.0);

            return Transform.translate(
              offset: Offset(0, floatY),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                transformAlignment: Alignment.center,
                transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.5),
                  widget.pic.colorFondo,
                ],
                center: const Alignment(-0.5, -0.5),
                radius: 1.5,
              ),
              borderRadius: BorderRadius.circular(35), 
              border: Border.all(color: Colors.white.withOpacity(0.9), width: _isHovered ? 4 : 2),
              boxShadow: [
                BoxShadow(
                  color: widget.pic.colorFondo.withOpacity(0.6).withBlue(100), 
                  blurRadius: _isPressed ? 5 : (_isHovered ? 25 : 15),
                  offset: Offset(0, _isPressed ? 3 : (_isHovered ? 12 : 8)),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: _isPressed ? 0.9 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Icon(widget.pic.icono, size: 65, color: Colors.black.withOpacity(0.75)),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.pic.palabra,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: -0.5,
                    color: Colors.black.withOpacity(0.85),
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

class _BotonControlUltra extends StatefulWidget {
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const _BotonControlUltra({required this.icono, required this.color, required this.onTap});

  @override
  State<_BotonControlUltra> createState() => _BotonControlUltraState();
}

class _BotonControlUltraState extends State<_BotonControlUltra> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 55, height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: widget.color.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: _isPressed ? 5 : 15, offset: Offset(0, _isPressed ? 2 : 5))
            ]
          ),
          child: Icon(widget.icono, color: widget.color, size: 28),
        ),
      ),
    );
  }
}