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
import '../main.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/theme_toggle_button.dart';

class TableroCAAScreen extends StatefulWidget {
  const TableroCAAScreen({super.key});

  @override
  State<TableroCAAScreen> createState() => _TableroCAAScreenState();
}

class _TableroCAAScreenState extends State<TableroCAAScreen>
    with SingleTickerProviderStateMixin {
  final List<Pictograma> _oracionActual = [];
  late final List<CarpetaCAA> _carpetas;
  late final List<Pictograma> _palabrasFrecuentes;
  CarpetaCAA? _carpetaActual;

  final TtsService _motorVoz = TtsService();
  bool _isSpeaking = false; 

  late AnimationController _gridIntroController;

  bool _isPro = false;
  String _nombreUsuario = 'Amigo';
  StreamSubscription<DocumentSnapshot>? _perfilSubscription;

  @override
  void initState() {
    super.initState();
    _carpetas = RepositorioVocabulario.obtenerCarpetas();
    _palabrasFrecuentes = RepositorioVocabulario.obtenerPalabrasFrecuentes();

    _gridIntroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cargarPerfilUsuario();
    _gridIntroController.forward();
  }

  void _cargarPerfilUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _perfilSubscription = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists && mounted) {
        setState(() {
          _isPro = doc.data()?['isPro'] ?? false;
          _nombreUsuario = doc.data()?['nombre'] ?? 'Amigo';
        });
      }
    });
  }

  @override
  void dispose() {
    _perfilSubscription?.cancel();
    _gridIntroController.dispose();
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

  Future<void> _reproducirOracion() async {
    if (_isSpeaking) return;
    if (_oracionActual.isEmpty) {
      HapticFeedback.vibrate();
      _mostrarErrorUltra();
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => _isSpeaking = true);
    final frase = _oracionActual.map((p) => p.palabra).join(' ');
    await _motorVoz.hablar(frase);
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _mostrarErrorUltra() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: TweenAnimationBuilder<double>(
            tween: Tween(begin: -20, end: 0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, val, child) => Transform.translate(
              offset: Offset(val, 0),
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.redAccent.shade200,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 28),
                  SizedBox(width: 14),
                  Text(
                    '¡Arma una frase primero!',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 36, left: 20, right: 20),
        ),
      );
  }

  void _mostrarPaywall() {
    HapticFeedback.heavyImpact();
    final isDark = isDarkModeGlobal.value;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF1E293B)
            : Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Column(
          children: [
            Icon(Icons.workspace_premium_rounded,
                color: Colors.amber.shade400, size: 60),
            const SizedBox(height: 10),
            Text(
              'Desbloquea FonoApp Pro',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: Text(
          'Accede a carpetas avanzadas como Lugares, Comida y Acciones '
          'para construir oraciones completas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.blueGrey.shade300 : Colors.blueGrey,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Quizás más tarde',
              style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Contacta con la administradora para activar tu cuenta PRO.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.amber.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              elevation: 4,
            ),
            child: const Text('CÓMO MEJORAR',
                style: TextStyle(
                    fontWeight: FontWeight.w900, letterSpacing: 0.8)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: AnimatedGradientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _construirCabecera(isDark),
                  _construirBarraOracionGlass(isDark, isMobile),
                  const SizedBox(height: 8),
                  _construirBarraNavegacionInterna(isDark, isMobile),
                  _construirGrillaPrincipal(isDark, isMobile),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CABECERA
  // ─────────────────────────────────────────────────────────────────────────

  Widget _construirCabecera(bool isDark) {
    final user = FirebaseAuth.instance.currentUser;
    final String correoSeguro =
        user?.email?.toLowerCase().trim() ?? '';
    final bool esAdmin = correoSeguro == 'fonoaudiologia41@gmail.com';
    final String primerNombre = _nombreUsuario.split(' ').first;
    final colorTextoPrincipal =
        isDark ? Colors.white : const Color(0xFF1E293B);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: isMobile ? 8 : 10,
          ),
          child: Row(
            children: [
              // ─── SALUDO ─────────────────────────────────────────
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        '¡Hola, $primerNombre! 👋',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: isMobile ? 18 : 26,
                          color: colorTextoPrincipal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _BadgePlan(isPro: _isPro),
                  ],
                ),
              ),

              // ─── BOTONES ACCIÓN ──────────────────────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (esAdmin)
                    _HeaderButton(
                      isDark: isDark,
                      isMobile: isMobile,
                      icon: Icons.admin_panel_settings,
                      label: isMobile ? null : 'Admin',
                      color: Colors.amber.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminPanelScreen()),
                      ),
                    ),
                  const ThemeToggleButton(),
                  _HeaderButton(
                    isDark: isDark,
                    isMobile: isMobile,
                    icon: Icons.person_outline,
                    label: isMobile ? null : 'Mi Perfil',
                    color: colorTextoPrincipal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfileScreen()),
                    ),
                  ),
                  _HeaderButton(
                    isDark: isDark,
                    isMobile: isMobile,
                    icon: Icons.power_settings_new_rounded,
                    label: isMobile ? null : 'Salir',
                    color: Colors.redAccent,
                    borderColor: isDark
                        ? Colors.redAccent.withOpacity(0.4)
                        : Colors.red.shade200,
                    bg: isDark
                        ? Colors.redAccent.withOpacity(0.12)
                        : Colors.red.shade50,
                    onTap: () => FirebaseAuth.instance.signOut(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BARRA DE ORACIÓN GLASS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _construirBarraOracionGlass(bool isDark, bool isMobile) {
    return Container(
      // Altura súper reducida para celular
      height: isMobile ? 100 : 165,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 8 : 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(isMobile ? 24 : 36),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.85),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 28,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutBack,
              child: _oracionActual.isEmpty
                  ? _EmptyPhraseHint(isDark: isDark, isMobile: isMobile, key: const ValueKey('empty'))
                  : ClipRRect(
                      key: const ValueKey('lista'),
                      borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _oracionActual.length,
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            key: ValueKey('${_oracionActual[index].palabra}_$index'),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.elasticOut,
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, val, child) =>
                                Transform.translate(
                              offset: Offset(0, 36 * (1 - val)),
                              child: Opacity(
                                opacity: val.clamp(0.0, 1.0),
                                child: Transform.scale(
                                    scale: val.clamp(0.0, 1.0),
                                    child: child),
                              ),
                            ),
                            child: _MiniTarjeta(pic: _oracionActual[index], isDark: isDark, isMobile: isMobile),
                          );
                        },
                      ),
                    ),
            ),
          ),
          Container(
            width: 2,
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10),
            color: isDark ? Colors.white24 : Colors.white,
          ),
          _construirControlesBarra(isDark, isMobile),
        ],
      ),
    );
  }

  Widget _construirControlesBarra(bool isDark, bool isMobile) {
    final bool canSpeak = _oracionActual.isNotEmpty && !_isSpeaking;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            _BotonControlUltra(
              icono: Icons.backspace,
              color: Colors.redAccent,
              onTap: _borrarUltimo,
              isDark: isDark,
              isMobile: isMobile,
            ),
            SizedBox(width: isMobile ? 4 : 8),
            _BotonControlUltra(
              icono: Icons.delete_sweep,
              color: isDark ? Colors.grey.shade300 : Colors.blueGrey,
              onTap: _borrarTodo,
              isDark: isDark,
              isMobile: isMobile,
            ),
          ],
        ),
        GestureDetector(
          onTap: _isSpeaking ? null : _reproducirOracion,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            // Padding extra delgado en celular para no robar espacio
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 22, 
              vertical: isMobile ? 8 : 16
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSpeaking
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : canSpeak
                        ? [Colors.blue.shade400, Colors.blue.shade700]
                        : (isDark
                            ? [Colors.white10, Colors.white12]
                            : [Colors.grey.shade300, Colors.grey.shade400]),
              ),
              borderRadius: BorderRadius.circular(isMobile ? 18 : 28),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isSpeaking
                      ? SizedBox(
                          key: const ValueKey('speaking'),
                          width: isMobile ? 16 : 28,
                          height: isMobile ? 16 : 28,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          Icons.play_arrow_rounded,
                          key: const ValueKey('play'),
                          color: canSpeak
                              ? Colors.white
                              : (isDark ? Colors.white30 : Colors.grey.shade600),
                          size: isMobile ? 20 : 30,
                        ),
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Text(
                  _isSpeaking ? 'HABLANDO' : 'HABLAR',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 16,
                    fontWeight: FontWeight.w900,
                    color: (canSpeak || _isSpeaking)
                        ? Colors.white
                        : (isDark ? Colors.white30 : Colors.grey.shade600),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BARRA NAVEGACIÓN INTERNA
  // ─────────────────────────────────────────────────────────────────────────

  Widget _construirBarraNavegacionInterna(bool isDark, bool isMobile) {
    if (_carpetaActual == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20, 
        vertical: 4
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _volverACarpetas,
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: isMobile ? 18 : 24),
            label: Text(isMobile ? 'Atrás' : 'Categorías',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white24
                  : Colors.blueGrey.shade400,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 6 : 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 14 : 18)),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 14),
          if (_carpetaActual!.rutaImagen != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                _carpetaActual!.rutaImagen!,
                width: isMobile ? 20 : 26,
                height: isMobile ? 20 : 26,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  _carpetaActual!.icono ?? Icons.folder,
                  size: isMobile ? 20 : 26,
                  color: isDark ? Colors.white : Colors.blueGrey,
                ),
              ),
            )
          else
            Icon(_carpetaActual!.icono ?? Icons.folder,
                color: isDark ? Colors.white : Colors.blueGrey, size: isMobile ? 20 : 26),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _carpetaActual!.nombre,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GRILLA PRINCIPAL
  // ─────────────────────────────────────────────────────────────────────────

  Widget _construirGrillaPrincipal(bool isDark, bool isMobile) {
    final int itemCount = _carpetaActual == null
        ? _palabrasFrecuentes.length + _carpetas.length
        : _carpetaActual!.pictogramas.length;

    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16, 
            vertical: 10
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          // Grilla ajustada: más respiro en celular (100px aprox)
          maxCrossAxisExtent: isMobile ? 100 : 165,
          childAspectRatio: 1.0,
          crossAxisSpacing: isMobile ? 10 : 16,
          mainAxisSpacing: isMobile ? 12 : 18,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final double start = (index / itemCount).clamp(0.0, 0.7);
          final double end = (start + 0.3).clamp(0.0, 1.0);
          return AnimatedBuilder(
            animation: _gridIntroController,
            builder: (context, child) {
              final double t = Curves.elasticOut.transform(
                Interval(start, end, curve: Curves.easeOut)
                    .transform(_gridIntroController.value),
              );
              return Opacity(
                opacity: _gridIntroController.value.clamp(0.0, 1.0),
                child: Transform.scale(
                    scale: t.clamp(0.0, 1.15), child: child),
              );
            },
            child: _construirElementoGrilla(index, isDark, isMobile),
          );
        },
      ),
    );
  }

  Widget _construirElementoGrilla(int index, bool isDark, bool isMobile) {
    if (_carpetaActual != null) {
      final pic = _carpetaActual!.pictogramas[index];
      return TarjetaSquish3D(
        pic: pic,
        isLocked: false,
        onTap: () => _agregarPictograma(pic),
        isDark: isDark,
        isMobile: isMobile,
      );
    }
    if (index < _palabrasFrecuentes.length) {
      final pic = _palabrasFrecuentes[index];
      return TarjetaSquish3D(
        pic: pic,
        isLocked: false,
        onTap: () => _agregarPictograma(pic),
        isDark: isDark,
        isMobile: isMobile,
      );
    }
    final carpeta = _carpetas[index - _palabrasFrecuentes.length];
    return TarjetaCarpeta3D(
      carpeta: carpeta,
      isLocked: carpeta.esProOnly && !_isPro,
      onTap: () => _abrirCarpeta(carpeta),
      isDark: isDark,
      isMobile: isMobile,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS PRIVADOS
// ─────────────────────────────────────────────────────────────────────────────

class _BadgePlan extends StatelessWidget {
  final bool isPro;
  const _BadgePlan({required this.isPro});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPro ? Colors.amber.shade400 : Colors.blueGrey.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPro ? 'PRO' : 'DEMO',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontSize: isMobile ? 11 : 13,
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final IconData icon;
  final String? label;
  final Color color;
  final Color? borderColor;
  final Color? bg;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.isDark,
    required this.isMobile,
    required this.icon,
    required this.color,
    required this.onTap,
    this.label,
    this.borderColor,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = bg ??
        (isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.7));
    final effectiveBorder = borderColor ??
        (isDark ? Colors.white.withOpacity(0.2) : Colors.blueGrey.withOpacity(0.25));

    return Container(
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 22),
        border: Border.all(color: effectiveBorder, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isMobile ? 16 : 22),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: label != null ? 14 : (isMobile ? 8 : 11),
              vertical: isMobile ? 8 : 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: label != null ? 20 : 18),
                if (label != null) ...[
                  const SizedBox(width: 6),
                  Text(label!,
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPhraseHint extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  const _EmptyPhraseHint({super.key, required this.isDark, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2),
          builder: (ctx, v, child) => Transform.translate(
            offset: Offset(0, math.sin(v * math.pi * 2) * 5),
            child: child,
          ),
          child: Icon(
            Icons.auto_awesome,
            size: isMobile ? 36 : 52,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
        ),
        SizedBox(height: isMobile ? 6 : 10),
        Text(
          '¡Arma tu frase mágica!',
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey.shade500,
            fontSize: isMobile ? 14 : 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MiniTarjeta extends StatelessWidget {
  final Pictograma pic;
  final bool isDark;
  final bool isMobile;

  const _MiniTarjeta({required this.pic, required this.isDark, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? 55 : 100,
      height: isMobile ? 55 : 100,
      margin: EdgeInsets.only(right: isMobile ? 6 : 10, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: pic.colorFondo,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
        border: Border.all(color: Colors.white, width: isMobile ? 1.5 : 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: pic.rutaImagen != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 10 : 17),
              child: Image.asset(
                pic.rutaImagen!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PictoFallback(pic: pic, isMobile: isMobile),
              ),
            )
          : _PictoFallback(pic: pic, isMobile: isMobile),
    );
  }
}

class _PictoFallback extends StatelessWidget {
  final Pictograma pic;
  final bool isMobile;
  const _PictoFallback({required this.pic, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          pic.icono ?? Icons.image_not_supported_outlined,
          size: isMobile ? 22 : 36,
          color: Colors.black87,
        ),
        SizedBox(height: isMobile ? 2 : 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            pic.palabra,
            style: TextStyle(
              fontSize: isMobile ? 9 : 12,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class TarjetaCarpeta3D extends StatefulWidget {
  final CarpetaCAA carpeta;
  final VoidCallback onTap;
  final bool isLocked;
  final bool isDark;
  final bool isMobile;

  const TarjetaCarpeta3D({
    super.key,
    required this.carpeta,
    required this.onTap,
    this.isLocked = false,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<TarjetaCarpeta3D> createState() => _TarjetaCarpeta3DState();
}

class _TarjetaCarpeta3DState extends State<TarjetaCarpeta3D>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isLocked
        ? (widget.isDark ? Colors.white24 : Colors.grey.shade300)
        : widget.carpeta.colorFondo;
    final Color iconColor = widget.isLocked
        ? (widget.isDark ? Colors.white54 : Colors.grey.shade400)
        : Colors.black.withOpacity(0.85);

    return MouseRegion(
      cursor:
          widget.isLocked ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) {
        if (!widget.isLocked) {
          setState(() => _isHovered = true);
          _floatController.repeat(reverse: true);
        }
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _isPressed = false;
        });
        _floatController.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (!widget.isLocked) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                (_isHovered && !_isPressed)
                    ? math.sin(_floatController.value * math.pi) * -6
                    : 0,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                transform: Matrix4.diagonal3Values(
                  _isPressed ? 0.95 : 1.0,
                  _isPressed ? 0.95 : 1.0,
                  1.0,
                ),
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(widget.isMobile ? 20 : 28),
              border: Border.all(
                  color: Colors.white, width: widget.isMobile ? 2 : (_isHovered ? 4 : 2)),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.55),
                  blurRadius:
                      _isPressed ? 4 : (_isHovered ? 18 : 8),
                  offset: Offset(
                      0, _isPressed ? 2 : (_isHovered ? 10 : 5)),
                )
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.carpeta.rutaImagen != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(widget.isMobile ? 18 : 26),
                    child: Image.asset(
                      widget.carpeta.rutaImagen!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _CarpetaFallbackContent(
                        carpeta: widget.carpeta,
                        iconColor: iconColor,
                        isMobile: widget.isMobile,
                      ),
                    ),
                  )
                else ...[
                  Positioned(
                    top: widget.isMobile ? -6 : -12,
                    right: widget.isMobile ? -6 : -12,
                    child: Icon(Icons.folder_open,
                        size: widget.isMobile ? 50 : 90,
                        color: Colors.white.withOpacity(0.18)),
                  ),
                  _CarpetaFallbackContent(
                    carpeta: widget.carpeta,
                    iconColor: iconColor,
                    isMobile: widget.isMobile,
                  ),
                ],
                if (widget.isLocked)
                  Positioned(
                    top: widget.isMobile ? 8 : 12,
                    right: widget.isMobile ? 8 : 12,
                    child: Icon(
                      Icons.lock_rounded,
                      color: widget.isDark
                          ? Colors.white54
                          : Colors.blueGrey.shade400,
                      size: widget.isMobile ? 20 : 28,
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

class _CarpetaFallbackContent extends StatelessWidget {
  final CarpetaCAA carpeta;
  final Color iconColor;
  final bool isMobile;
  const _CarpetaFallbackContent(
      {required this.carpeta, required this.iconColor, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(carpeta.icono ?? Icons.folder, size: isMobile ? 36 : 58, color: iconColor),
        SizedBox(height: isMobile ? 4 : 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            carpeta.nombre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }
}

class TarjetaSquish3D extends StatefulWidget {
  final Pictograma pic;
  final VoidCallback onTap;
  final bool isLocked;
  final bool isDark;
  final bool isMobile;

  const TarjetaSquish3D({
    super.key,
    required this.pic,
    required this.onTap,
    this.isLocked = false,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<TarjetaSquish3D> createState() => _TarjetaSquish3DState();
}

class _TarjetaSquish3DState extends State<TarjetaSquish3D>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isLocked
        ? (widget.isDark ? Colors.white24 : Colors.grey.shade200)
        : widget.pic.colorFondo;
    final Color iconColor = widget.isLocked
        ? (widget.isDark ? Colors.white54 : Colors.grey.shade400)
        : Colors.black.withOpacity(0.75);
    final Color textColor = widget.isLocked
        ? (widget.isDark ? Colors.white54 : Colors.grey.shade500)
        : Colors.black.withOpacity(0.85);

    return MouseRegion(
      cursor: widget.isLocked
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) {
        if (!widget.isLocked) {
          setState(() => _isHovered = true);
          _floatController.repeat(reverse: true);
        }
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _isPressed = false;
        });
        _floatController.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (!widget.isLocked) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                (_isHovered && !_isPressed)
                    ? math.sin(_floatController.value * math.pi) * -6
                    : 0,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                transform: Matrix4.diagonal3Values(
                  _isPressed ? 1.04 : (_isHovered ? 1.04 : 1.0),
                  _isPressed ? 0.92 : (_isHovered ? 1.04 : 1.0),
                  1.0,
                ),
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.45), bgColor],
                center: const Alignment(-0.5, -0.5),
                radius: 1.5,
              ),
              borderRadius: BorderRadius.circular(widget.isMobile ? 22 : 32),
              border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: widget.isMobile ? 2 : (_isHovered ? 4 : 2)),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.55),
                  blurRadius:
                      _isPressed ? 4 : (_isHovered ? 22 : 12),
                  offset: Offset(
                      0, _isPressed ? 2 : (_isHovered ? 10 : 7)),
                )
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.pic.rutaImagen != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(widget.isMobile ? 20 : 30),
                    child: AnimatedScale(
                      scale: _isPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Image.asset(
                        widget.pic.rutaImagen!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _PictoFallback(pic: widget.pic, isMobile: widget.isMobile),
                      ),
                    ),
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: _isPressed ? 0.9 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: Icon(widget.pic.icono,
                            size: widget.isMobile ? 40 : 62, color: iconColor),
                      ),
                      SizedBox(height: widget.isMobile ? 4 : 8),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          widget.pic.palabra,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: widget.isMobile ? 12 : 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (widget.isLocked)
                  Positioned(
                    top: widget.isMobile ? 8 : 12,
                    right: widget.isMobile ? 8 : 12,
                    child: Icon(
                      Icons.lock_rounded,
                      color: widget.isDark
                          ? Colors.white54
                          : Colors.blueGrey.shade300,
                      size: widget.isMobile ? 18 : 26,
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
  final bool isDark;
  final bool isMobile;

  const _BotonControlUltra({
    required this.icono,
    required this.color,
    required this.onTap,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<_BotonControlUltra> createState() => _BotonControlUltraState();
}

class _BotonControlUltraState extends State<_BotonControlUltra> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.82 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.isMobile ? 36 : 52,
          height: widget.isMobile ? 36 : 52,
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white10 : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
                color: widget.color.withOpacity(0.45), width: widget.isMobile ? 1.5 : 2),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Icon(widget.icono, color: widget.color, size: widget.isMobile ? 18 : 26),
        ),
      ),
    );
  }
}