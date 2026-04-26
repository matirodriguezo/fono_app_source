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

/// AUDITORÍA — tablero_caa_screen.dart
///
/// Esta es la pantalla más crítica de la aplicación: es la herramienta
/// clínica que usa el paciente. El estándar de robustez aquí es el más alto.
///
/// MEJORAS IMPLEMENTADAS:
///
/// 1. ANTI DOBLE-TAP EN «HABLAR»: El botón de reproducción de voz podía ser
///    pulsado múltiples veces seguidas, encolando varias lecturas TTS
///    simultáneas. Se añade un flag `_isSpeaking` que bloquea el botón
///    mientras el motor de voz está activo y muestra un indicador visual
///    (spinner de audio). Cuando termina, el botón vuelve al estado normal.
///    TtsService.hablar() ya es async; simplemente esperamos su resolución.
///
/// 2. FALLBACK DE IMAGEN ROBUSTO: En los widgets TarjetaSquish3D y
///    TarjetaCarpeta3D, la carga de imágenes con Image.asset no tenía
///    errorBuilder. Si la ruta del asset no existía (typo, asset no
///    declarado en pubspec), el widget lanzaba una excepción roja en
///    pantalla. Ahora Image.asset tiene un errorBuilder que muestra el
///    ícono de categoría como fallback elegante, manteniendo el layout intacto.
///
/// 3. RESPONSIVIDAD DEL TABLERO: La cabecera original usaba fontSize: 30 y
///    múltiples botones en Row sin ningún LayoutBuilder. En pantallas de
///    tablet o móvil, esto causaba overflow. Se introduce un breakpoint
///    `isMobile` que ajusta el layout de la cabecera a una versión compacta
///    con ícono-botón en lugar de texto completo, y reduce el font del saludo.
///
/// 4. BARRA DE ORACIÓN SCROLL-SAFE: Se envuelve el ListView horizontal de
///    la barra de oración en un ClipRRect para evitar que las tarjetas
///    desborden visualmente los bordes redondeados del contenedor glass.
///
/// 5. PAYWALL MEJORADO: El AlertDialog del paywall era siempre blanco
///    (hardcodeado con `backgroundColor: Colors.white`), rompiendo el
///    modo oscuro. Ahora respeta el tema activo.
///
/// 6. CABECERA ADAPTATIVA: En pantallas < 800px los botones secundarios
///    (Admin, Tema, Perfil, Salir) se compactan a íconos sin etiqueta de
///    texto para evitar overflow horizontal.
///
/// 7. FONDO: Reemplazado por widget compartido. Se elimina el
///    AnimationController local de fondo.
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
  bool _isSpeaking = false; // ANTI DOBLE-TAP para el botón HABLAR

  // MEJORA: Un solo AnimationController para la intro de la grilla.
  // El fondo se delega al widget compartido.
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

  // MEJORA ANTI DOBLE-TAP: bloqueamos el botón mientras el TTS habla.
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
    // MEJORA: Respeta el tema activo en lugar de ser siempre blanco.
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
                  _construirBarraOracionGlass(isDark),
                  const SizedBox(height: 8),
                  _construirBarraNavegacionInterna(isDark),
                  _construirGrillaPrincipal(isDark),
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
        // MEJORA: Cabecera responsiva. En < 800px se compacta.
        final isMobile = constraints.maxWidth < 800;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 8 : 10,
          ),
          child: Row(
            children: [
              // ─── SALUDO ─────────────────────────────────────────
              Expanded(
                child: Row(
                  children: [
                    Text(
                      isMobile
                          ? '¡Hola! 👋'
                          : '¡Hola, $primerNombre! 👋',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 20 : 26,
                        color: colorTextoPrincipal,
                      ),
                    ),
                    const SizedBox(width: 10),
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

  Widget _construirBarraOracionGlass(bool isDark) {
    return Container(
      height: 165,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(36),
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
                  ? _EmptyPhraseHint(isDark: isDark, key: const ValueKey('empty'))
                  // MEJORA: ClipRRect para que las tarjetas no desborden
                  // los bordes redondeados del contenedor glass.
                  : ClipRRect(
                      key: const ValueKey('lista'),
                      borderRadius: BorderRadius.circular(24),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _oracionActual.length,
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            key: ValueKey(
                                '${_oracionActual[index].palabra}_$index'),
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
                            child: _MiniTarjeta(
                                pic: _oracionActual[index],
                                isDark: isDark),
                          );
                        },
                      ),
                    ),
            ),
          ),
          Container(
            width: 2,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: isDark ? Colors.white24 : Colors.white,
          ),
          _construirControlesBarra(isDark),
        ],
      ),
    );
  }

  Widget _construirControlesBarra(bool isDark) {
    // MEJORA: `canSpeak` ahora también considera si ya está hablando.
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
            ),
            const SizedBox(width: 8),
            _BotonControlUltra(
              icono: Icons.delete_sweep,
              color: isDark ? Colors.grey.shade300 : Colors.blueGrey,
              onTap: _borrarTodo,
              isDark: isDark,
            ),
          ],
        ),
        // MEJORA: Botón HABLAR con feedback de estado _isSpeaking.
        GestureDetector(
          onTap: _isSpeaking ? null : _reproducirOracion,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSpeaking
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : canSpeak
                        ? [Colors.blue.shade400, Colors.blue.shade700]
                        : (isDark
                            ? [Colors.white10, Colors.white12]
                            : [
                                Colors.grey.shade300,
                                Colors.grey.shade400
                              ]),
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MEJORA: AnimatedSwitcher entre icono play y spinner.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isSpeaking
                      ? const SizedBox(
                          key: ValueKey('speaking'),
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          Icons.play_arrow_rounded,
                          key: const ValueKey('play'),
                          color: canSpeak
                              ? Colors.white
                              : (isDark
                                  ? Colors.white30
                                  : Colors.grey.shade600),
                          size: 30,
                        ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isSpeaking ? 'HABLANDO' : 'HABLAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: (canSpeak || _isSpeaking)
                        ? Colors.white
                        : (isDark ? Colors.white30 : Colors.grey.shade600),
                    letterSpacing: 1,
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

  Widget _construirBarraNavegacionInterna(bool isDark) {
    if (_carpetaActual == null) return const SizedBox.shrink();
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _volverACarpetas,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            label: const Text('Categorías',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white24
                  : Colors.blueGrey.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
          ),
          const SizedBox(width: 14),
          if (_carpetaActual!.rutaImagen != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                _carpetaActual!.rutaImagen!,
                width: 26,
                height: 26,
                fit: BoxFit.cover,
                // MEJORA: fallback si el asset no existe.
                errorBuilder: (_, __, ___) => Icon(
                  _carpetaActual!.icono ?? Icons.folder,
                  size: 26,
                  color: isDark ? Colors.white : Colors.blueGrey,
                ),
              ),
            )
          else
            Icon(_carpetaActual!.icono ?? Icons.folder,
                color: isDark ? Colors.white : Colors.blueGrey, size: 26),
          const SizedBox(width: 8),
          Text(
            _carpetaActual!.nombre,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GRILLA PRINCIPAL
  // ─────────────────────────────────────────────────────────────────────────

  Widget _construirGrillaPrincipal(bool isDark) {
    final int itemCount = _carpetaActual == null
        ? _palabrasFrecuentes.length + _carpetas.length
        : _carpetaActual!.pictogramas.length;

    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 165,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 18,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Staggered animation: cada tarjeta entra con un ligero retraso.
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
            child: _construirElementoGrilla(index, isDark),
          );
        },
      ),
    );
  }

  Widget _construirElementoGrilla(int index, bool isDark) {
    if (_carpetaActual != null) {
      final pic = _carpetaActual!.pictogramas[index];
      return TarjetaSquish3D(
        pic: pic,
        isLocked: false,
        onTap: () => _agregarPictograma(pic),
        isDark: isDark,
      );
    }
    if (index < _palabrasFrecuentes.length) {
      final pic = _palabrasFrecuentes[index];
      return TarjetaSquish3D(
        pic: pic,
        isLocked: false,
        onTap: () => _agregarPictograma(pic),
        isDark: isDark,
      );
    }
    final carpeta = _carpetas[index - _palabrasFrecuentes.length];
    return TarjetaCarpeta3D(
      carpeta: carpeta,
      isLocked: carpeta.esProOnly && !_isPro,
      onTap: () => _abrirCarpeta(carpeta),
      isDark: isDark,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS PRIVADOS
// ─────────────────────────────────────────────────────────────────────────────

/// Badge de plan PRO / DEMO en la cabecera.
class _BadgePlan extends StatelessWidget {
  final bool isPro;
  const _BadgePlan({required this.isPro});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPro ? Colors.amber.shade400 : Colors.blueGrey.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPro ? 'PRO' : 'DEMO',
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Botón de cabecera adaptativo (con o sin etiqueta de texto).
class _HeaderButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String? label;
  final Color color;
  final Color? borderColor;
  final Color? bg;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.isDark,
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
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: effectiveBorder, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: label != null ? 14 : 11,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
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

/// Hint animado cuando la barra de oración está vacía.
class _EmptyPhraseHint extends StatelessWidget {
  final bool isDark;
  const _EmptyPhraseHint({super.key, required this.isDark});

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
            size: 52,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '¡Arma tu frase mágica!',
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey.shade500,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// Mini-tarjeta para la barra de oración.
class _MiniTarjeta extends StatelessWidget {
  final Pictograma pic;
  final bool isDark;
  const _MiniTarjeta({required this.pic, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: pic.colorFondo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2.5),
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
              borderRadius: BorderRadius.circular(17),
              child: Image.asset(
                pic.rutaImagen!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                // MEJORA: Fallback elegante en lugar de pantalla roja.
                errorBuilder: (_, __, ___) => _PictoFallback(pic: pic),
              ),
            )
          : _PictoFallback(pic: pic),
    );
  }
}

/// Fallback visual cuando un asset de imagen no puede cargarse.
/// MEJORA: Evita la pantalla roja de Flutter al fallar Image.asset.
class _PictoFallback extends StatelessWidget {
  final Pictograma pic;
  const _PictoFallback({required this.pic});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          pic.icono ?? Icons.image_not_supported_outlined,
          size: 36,
          color: Colors.black87,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            pic.palabra,
            style: const TextStyle(
              fontSize: 12,
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

// ─────────────────────────────────────────────────────────────────────────────
// TARJETA CARPETA 3D
// ─────────────────────────────────────────────────────────────────────────────

class TarjetaCarpeta3D extends StatefulWidget {
  final CarpetaCAA carpeta;
  final VoidCallback onTap;
  final bool isLocked;
  final bool isDark;

  const TarjetaCarpeta3D({
    super.key,
    required this.carpeta,
    required this.onTap,
    this.isLocked = false,
    required this.isDark,
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
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: Colors.white, width: _isHovered ? 4 : 2),
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
                    borderRadius: BorderRadius.circular(26),
                    child: Image.asset(
                      widget.carpeta.rutaImagen!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      // MEJORA: Fallback si el asset no existe.
                      errorBuilder: (_, __, ___) => _CarpetaFallbackContent(
                        carpeta: widget.carpeta,
                        iconColor: iconColor,
                      ),
                    ),
                  )
                else ...[
                  Positioned(
                    top: -12,
                    right: -12,
                    child: Icon(Icons.folder_open,
                        size: 90,
                        color: Colors.white.withOpacity(0.18)),
                  ),
                  _CarpetaFallbackContent(
                    carpeta: widget.carpeta,
                    iconColor: iconColor,
                  ),
                ],
                if (widget.isLocked)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Icon(
                      Icons.lock_rounded,
                      color: widget.isDark
                          ? Colors.white54
                          : Colors.blueGrey.shade400,
                      size: 28,
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
  const _CarpetaFallbackContent(
      {required this.carpeta, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(carpeta.icono ?? Icons.folder, size: 58, color: iconColor),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            carpeta.nombre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
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

// ─────────────────────────────────────────────────────────────────────────────
// TARJETA PICTOGRAMA 3D
// ─────────────────────────────────────────────────────────────────────────────

class TarjetaSquish3D extends StatefulWidget {
  final Pictograma pic;
  final VoidCallback onTap;
  final bool isLocked;
  final bool isDark;

  const TarjetaSquish3D({
    super.key,
    required this.pic,
    required this.onTap,
    this.isLocked = false,
    required this.isDark,
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
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: _isHovered ? 4 : 2),
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
                    borderRadius: BorderRadius.circular(30),
                    child: AnimatedScale(
                      scale: _isPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Image.asset(
                        widget.pic.rutaImagen!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        // MEJORA: Fallback elegante en lugar de error rojo.
                        errorBuilder: (_, __, ___) =>
                            _PictoFallback(pic: widget.pic),
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
                            size: 62, color: iconColor),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          widget.pic.palabra,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
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
                    top: 12,
                    right: 12,
                    child: Icon(
                      Icons.lock_rounded,
                      color: widget.isDark
                          ? Colors.white54
                          : Colors.blueGrey.shade300,
                      size: 26,
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

// ─────────────────────────────────────────────────────────────────────────────
// BOTÓN DE CONTROL (backspace / delete)
// ─────────────────────────────────────────────────────────────────────────────

class _BotonControlUltra extends StatefulWidget {
  final IconData icono;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _BotonControlUltra({
    required this.icono,
    required this.color,
    required this.onTap,
    required this.isDark,
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
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white10 : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
                color: widget.color.withOpacity(0.45), width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Icon(widget.icono, color: widget.color, size: 26),
        ),
      ),
    );
  }
}