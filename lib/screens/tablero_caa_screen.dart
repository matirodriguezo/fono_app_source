import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../models/pictograma.dart';
import '../services/tts_service.dart';
import 'admin_panel_screen.dart';
import 'dart:async';
import 'profile_screen.dart';
import '../main.dart'; // Import global

class TableroCAAScreen extends StatefulWidget {
  const TableroCAAScreen({super.key});

  @override
  State<TableroCAAScreen> createState() => _TableroCAAScreenState();
}

class _TableroCAAScreenState extends State<TableroCAAScreen> with TickerProviderStateMixin {
  final List<Pictograma> _oracionActual = [];
  late final List<CarpetaCAA> _carpetas;
  late final List<Pictograma> _palabrasFrecuentes;
  CarpetaCAA? _carpetaActual;

  final TtsService _motorVoz = TtsService();

  late AnimationController _gridIntroController;
  late AnimationController _bgAnimationController;

  bool _isPro = false;
  String _nombreUsuario = 'Amigo';
  StreamSubscription<DocumentSnapshot>? _perfilSubscription;

  @override
  void initState() {
    super.initState();
    _carpetas = RepositorioVocabulario.obtenerCarpetas();
    _palabrasFrecuentes = RepositorioVocabulario.obtenerPalabrasFrecuentes();

    _gridIntroController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _bgAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat(reverse: true);

    _cargarPerfilUsuario();
    _gridIntroController.forward();
  }

  void _cargarPerfilUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _perfilSubscription = FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots().listen((doc) {
        if (doc.exists && mounted) {
          setState(() {
            _isPro = doc.data()?['isPro'] ?? false;
            _nombreUsuario = doc.data()?['nombre'] ?? 'Amigo';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _perfilSubscription?.cancel();
    _gridIntroController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  void _abrirCarpeta(CarpetaCAA carpeta) {
    if (carpeta.esProOnly && !_isPro) {
      _mostrarPaywall();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _carpetaActual = carpeta);
    _gridIntroController.reset();
    _gridIntroController.forward();
  }

  void _volverACarpetas() {
    HapticFeedback.lightImpact();
    setState(() => _carpetaActual = null);
    _gridIntroController.reset();
    _gridIntroController.forward();
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
                decoration: BoxDecoration(color: Colors.redAccent.shade200, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]),
                child: const Row(children: [Icon(Icons.warning, color: Colors.white, size: 30), SizedBox(width: 15), Text('¡Arma una frase primero!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white))]),
              ),
            );
          },
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
      ),
    );
  }

  void _mostrarPaywall() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Column(children: [Icon(Icons.workspace_premium_rounded, color: Colors.amber.shade400, size: 60), const SizedBox(height: 10), const Text('Desbloquea FonoApp Pro', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))]),
        content: const Text('Accede a carpetas avanzadas como Entorno, Personas y Acciones complejas para armar oraciones completas.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Quizás más tarde', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contacta con la administradora para activar tu cuenta PRO")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade500, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 4),
            child: const Text('CÓMO MEJORAR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
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
              SafeArea(
                child: Column(
                  children: [
                    _construirCabecera(isDark),
                    _construirBarraOracionGlass(isDark),
                    const SizedBox(height: 10),
                    _construirBarraNavegacionInterna(isDark), 
                    _construirGrillaPrincipal(isDark), 
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _construirCabecera(bool isDark) {
    final user = FirebaseAuth.instance.currentUser;
    final String correoSeguro = user?.email?.toLowerCase().trim() ?? '';
    final bool esAdmin = correoSeguro == 'fonoaudiologia41@gmail.com';
    final String primerNombre = _nombreUsuario.split(' ').first;
    final colorTextoPrincipal = isDark ? Colors.white : const Color(0xFF1E293B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('¡Hola $primerNombre! 👋 ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30, color: colorTextoPrincipal)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _isPro ? Colors.amber.shade400 : Colors.blueGrey.shade200, borderRadius: BorderRadius.circular(12)),
                child: Text(_isPro ? 'PRO' : 'DEMO', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14)),
              )
            ],
          ),
          Row(
            children: [
              if (esAdmin)
                Container(
                  margin: const EdgeInsets.only(right: 15),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.admin_panel_settings, color: Color.fromARGB(255, 255, 255, 255)),
                    label: const Text('PANEL ADMIN', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade600, foregroundColor: Colors.white, elevation: 4),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen())),
                  ),
                ),
              
              // Botón Tema
              GestureDetector(
                onTap: () => isDarkModeGlobal.value = !isDarkModeGlobal.value,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.transparent)
                    ),
                    child: Text(isDark ? '🌙' : '☀️', style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ),

              // BOTÓN CERRAR SESIÓN (Rediseñado y robusto)
              Container(
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  color: isDark ? Colors.redAccent.withOpacity(0.15) : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: isDark ? Colors.redAccent.withOpacity(0.4) : Colors.red.shade200, width: 2),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () => FirebaseAuth.instance.signOut(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.power_settings_new_rounded, color: isDark ? Colors.redAccent.shade200 : Colors.redAccent, size: 22),
                          const SizedBox(width: 6),
                          Text('Salir', style: TextStyle(color: isDark ? Colors.redAccent.shade200 : Colors.redAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Botón Mi Perfil
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.blueGrey.withOpacity(0.3), width: 2),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, color: colorTextoPrincipal, size: 24),
                          const SizedBox(width: 8),
                          Text('Mi Perfil', style: TextStyle(color: colorTextoPrincipal, fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _construirBarraOracionGlass(bool isDark) {
    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6), 
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8), width: 3),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 30, offset: const Offset(0, 15))],
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
                        builder: (ctx, double v, child) => Transform.translate(offset: Offset(0, math.sin(v * math.pi * 2) * 5), child: child),
                        child: Icon(Icons.auto_awesome, size: 55, color: isDark ? Colors.white24 : Colors.grey.shade400),
                      ),
                      const SizedBox(height: 12),
                      Text('¡Arma tu frase mágica!', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade500, fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _oracionActual.length,
                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder(
                        key: ValueKey('${_oracionActual[index].palabra}_$index'), 
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut, 
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double val, child) {
                          return Transform.translate(offset: Offset(0, 40 * (1 - val)), child: Opacity(opacity: val.clamp(0.0, 1.0), child: Transform.scale(scale: val.clamp(0.0, 1.0), child: child)));
                        },
                        child: _construirMiniTarjeta(_oracionActual[index], isDark),
                      );
                    },
                  ),
            ),
          ),
          Container(width: 3, margin: const EdgeInsets.symmetric(horizontal: 10), color: isDark ? Colors.white24 : Colors.white),
          _construirControlesBarra(isDark),
        ],
      ),
    );
  }

  Widget _construirControlesBarra(bool isDark) {
    bool canSpeak = _oracionActual.isNotEmpty;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            _BotonControlUltra(icono: Icons.backspace, color: Colors.redAccent, onTap: _borrarUltimo, isDark: isDark),
            const SizedBox(width: 8),
            _BotonControlUltra(icono: Icons.delete_sweep, color: isDark ? Colors.grey.shade300 : Colors.blueGrey, onTap: _borrarTodo, isDark: isDark),
          ],
        ),
        GestureDetector(
          onTap: _reproducirOracion,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: canSpeak 
                  ? [Colors.blue.shade400, Colors.blue.shade600] 
                  : (isDark ? [Colors.white10, Colors.white12] : [Colors.grey.shade300, Colors.grey.shade400]),
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2), 
            ),
            child: Row(
              children: [
                Icon(Icons.play_arrow, color: canSpeak ? Colors.white : (isDark ? Colors.white30 : Colors.grey.shade600), size: 32),
                const SizedBox(width: 5),
                Text('HABLAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: canSpeak ? Colors.white : (isDark ? Colors.white30 : Colors.grey.shade600), letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirBarraNavegacionInterna(bool isDark) {
    if (_carpetaActual == null) return const SizedBox.shrink(); 
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 5.0),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _volverACarpetas,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            label: const Text('Volver a Categorías', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.white24 : Colors.blueGrey.shade400, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          ),
          const SizedBox(width: 15),
          _carpetaActual!.rutaImagen != null
              ? ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.asset(_carpetaActual!.rutaImagen!, width: 28, height: 28, fit: BoxFit.cover))
              : Icon(_carpetaActual!.icono, color: isDark ? Colors.white : Colors.blueGrey, size: 28),
          const SizedBox(width: 8),
          Text(_carpetaActual!.nombre, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _construirGrillaPrincipal(bool isDark) {
    final int itemCount = _carpetaActual == null ? _palabrasFrecuentes.length + _carpetas.length : _carpetaActual!.pictogramas.length;
    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 160, childAspectRatio: 1.00, crossAxisSpacing: 18, mainAxisSpacing: 22),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final double start = (index / itemCount) * 0.7; 
          final double end = start + 0.3; 
          return AnimatedBuilder(
            animation: _gridIntroController,
            builder: (context, child) {
              final double animationVal = Curves.elasticOut.transform(Interval(start, end, curve: Curves.easeOut).transform(_gridIntroController.value));
              return Opacity(opacity: _gridIntroController.value.clamp(0.0, 1.0), child: Transform.scale(scale: animationVal.clamp(0.0, 1.2), child: child));
            },
            child: _construirElementoGrilla(index, isDark), 
          );
        },
      ),
    );
  }

  Widget _construirElementoGrilla(int index, bool isDark) {
    if (_carpetaActual != null) {
      return TarjetaSquish3D(pic: _carpetaActual!.pictogramas[index], isLocked: false, onTap: () => _agregarPictograma(_carpetaActual!.pictogramas[index]), isDark: isDark);
    }
    if (index < _palabrasFrecuentes.length) {
      return TarjetaSquish3D(pic: _palabrasFrecuentes[index], isLocked: false, onTap: () => _agregarPictograma(_palabrasFrecuentes[index]), isDark: isDark);
    }
    final int carpetaIndex = index - _palabrasFrecuentes.length;
    final carpeta = _carpetas[carpetaIndex];
    return TarjetaCarpeta3D(carpeta: carpeta, isLocked: carpeta.esProOnly && !_isPro, onTap: () => _abrirCarpeta(carpeta), isDark: isDark);
  }

  Widget _construirMiniTarjeta(Pictograma pic, bool isDark) {
    return Container(
      width: 100, height: 100, 
      margin: const EdgeInsets.only(right: 12, top: 5, bottom: 5), 
      decoration: BoxDecoration(
        color: pic.colorFondo,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 8))]
      ),
      child: pic.rutaImagen != null
          ? ClipRRect(borderRadius: BorderRadius.circular(19), child: Image.asset(pic.rutaImagen!, width: double.infinity, height: double.infinity, fit: BoxFit.cover))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(pic.icono, size: 40, color: Colors.black87),
                const SizedBox(height: 4),
                Text(pic.palabra, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.black87), overflow: TextOverflow.ellipsis),
              ],
            ),
    );
  } 
}

class TarjetaCarpeta3D extends StatefulWidget {
  final CarpetaCAA carpeta;
  final VoidCallback onTap;
  final bool isLocked;
  final bool isDark;

  const TarjetaCarpeta3D({super.key, required this.carpeta, required this.onTap, this.isLocked = false, required this.isDark});

  @override
  State<TarjetaCarpeta3D> createState() => _TarjetaCarpeta3DState();
}

class _TarjetaCarpeta3DState extends State<TarjetaCarpeta3D> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Los fondos de las carpetas/tarjetas respetan sus colores pastel, pero atenuamos el texto si bloqueadas en dark mode
    final Color bgColor = widget.isLocked ? (widget.isDark ? Colors.white24 : Colors.grey.shade300) : widget.carpeta.colorFondo;
    final Color iconColor = widget.isLocked ? (widget.isDark ? Colors.white54 : Colors.grey.shade400) : Colors.black.withOpacity(0.85);

    return MouseRegion(
      onEnter: (_) { if (!widget.isLocked) { setState(() => _isHovered = true); _floatController.repeat(reverse: true); }},
      onExit: (_) { setState(() { _isHovered = false; _isPressed = false; }); _floatController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (_isHovered && !_isPressed) ? math.sin(_floatController.value * math.pi) * -6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                transform: Matrix4.diagonal3Values(_isPressed ? 0.95 : 1.0, _isPressed ? 0.95 : 1.0, 1.0),
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(30), 
              border: Border.all(color: Colors.white, width: _isHovered ? 4 : 2),
              boxShadow: [BoxShadow(color: bgColor.withOpacity(0.6), blurRadius: _isPressed ? 5 : (_isHovered ? 20 : 10), offset: Offset(0, _isPressed ? 3 : (_isHovered ? 10 : 6)))],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.carpeta.rutaImagen != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: AnimatedScale(scale: _isPressed ? 0.95 : 1.0, duration: const Duration(milliseconds: 100), child: Image.asset(widget.carpeta.rutaImagen!, width: double.infinity, height: double.infinity, fit: BoxFit.cover)),
                  )
                else ...[
                  Positioned(top: -15, right: -15, child: Icon(Icons.folder_open, size: 100, color: Colors.white.withOpacity(0.2))),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.carpeta.icono, size: 60, color: iconColor),
                      const SizedBox(height: 10),
                      Text(widget.carpeta.nombre, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: iconColor)),
                    ],
                  ),
                ],
                if (widget.isLocked) Positioned(top: 15, right: 15, child: Icon(Icons.lock_rounded, color: widget.isDark ? Colors.white54 : Colors.blueGrey.shade400, size: 30))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TarjetaSquish3D extends StatefulWidget {
  final Pictograma pic;
  final VoidCallback onTap;
  final bool isLocked;
  final bool isDark;

  const TarjetaSquish3D({super.key, required this.pic, required this.onTap, this.isLocked = false, required this.isDark});

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
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isLocked ? (widget.isDark ? Colors.white24 : Colors.grey.shade200) : widget.pic.colorFondo;
    final Color iconColor = widget.isLocked ? (widget.isDark ? Colors.white54 : Colors.grey.shade400) : Colors.black.withOpacity(0.75);
    final Color textColor = widget.isLocked ? (widget.isDark ? Colors.white54 : Colors.grey.shade500) : Colors.black.withOpacity(0.85);

    return MouseRegion(
      onEnter: (_) { if (!widget.isLocked) { setState(() => _isHovered = true); _floatController.repeat(reverse: true); }},
      onExit: (_) { setState(() { _isHovered = false; _isPressed = false; }); _floatController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (_isHovered && !_isPressed) ? math.sin(_floatController.value * math.pi) * -6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                transform: Matrix4.diagonal3Values(_isPressed ? 1.05 : (_isHovered ? 1.05 : 1.0), _isPressed ? 0.90 : (_isHovered ? 1.05 : 1.0), 1.0),
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [Colors.white.withOpacity(0.5), bgColor], center: const Alignment(-0.5, -0.5), radius: 1.5),
              borderRadius: BorderRadius.circular(35), 
              border: Border.all(color: Colors.white.withOpacity(0.9), width: _isHovered ? 4 : 2),
              boxShadow: [BoxShadow(color: bgColor.withOpacity(0.6).withBlue(100), blurRadius: _isPressed ? 5 : (_isHovered ? 25 : 15), offset: Offset(0, _isPressed ? 3 : (_isHovered ? 12 : 8)))],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.pic.rutaImagen != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(33), 
                    child: AnimatedScale(scale: _isPressed ? 0.95 : 1.0, duration: const Duration(milliseconds: 100), child: Image.asset(widget.pic.rutaImagen!, width: double.infinity, height: double.infinity, fit: BoxFit.cover)),
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(scale: _isPressed ? 0.9 : 1.0, duration: const Duration(milliseconds: 100), child: Icon(widget.pic.icono, size: 65, color: iconColor)),
                      const SizedBox(height: 10),
                      Text(widget.pic.palabra, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: textColor)),
                    ],
                  ),
                if (widget.isLocked) Positioned(top: 15, right: 15, child: Icon(Icons.lock_rounded, color: widget.isDark ? Colors.white54 : Colors.blueGrey.shade300, size: 28))
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
  final bool isDark;

  const _BotonControlUltra({required this.icono, required this.color, required this.onTap, required this.isDark});

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
            color: widget.isDark ? Colors.white10 : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: widget.color.withOpacity(0.5), width: 2),
          ),
          child: Icon(widget.icono, color: widget.color, size: 28),
        ),
      ),
    );
  }
}