import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/pictograma.dart';
import '../services/tts_service.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'admin_panel_screen.dart';
import 'profile_screen.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/tutorial_overlay.dart';
import '../constants.dart';

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
  int? _indiceDestacado; // NUEVO: Controla qué tarjeta brilla

  late AnimationController _gridIntroController;
  final ScrollController _scrollController = ScrollController();
  static const _tutorialPrefKey = 'tutorial_completado';

  @override
  void initState() {
    super.initState();
    _carpetas = RepositorioVocabulario.obtenerCarpetas();
    _palabrasFrecuentes = RepositorioVocabulario.obtenerPalabrasFrecuentes();

    _gridIntroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _gridIntroController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cargarOracionGuardada();
      _precachePantallaActual();
      final prefs = await SharedPreferences.getInstance();
      final visto = prefs.getBool(_tutorialPrefKey) ?? false;
      if (!visto && mounted) {
        await mostrarTutorial(context, _pasosTutorial, _completarTutorial);
      }
    });
  }

  Future<void> _precacheImagenes(List<Pictograma> pictogramas) async {
    for (final pic in pictogramas) {
      if (pic.rutaImagen != null) {
        try {
          await precacheImage(AssetImage(pic.rutaImagen!), context);
        } catch (_) {}
      }
    }
  }

  Future<void> _precachePantallaActual() async {
    await _precacheImagenes(_palabrasFrecuentes);
    for (final carpeta in _carpetas) {
      if (carpeta.rutaImagen != null) {
        try {
          await precacheImage(AssetImage(carpeta.rutaImagen!), context);
        } catch (_) {}
      }
    }
  }

  Future<void> _guardarOracion() async {
    final prefs = await SharedPreferences.getInstance();
    final palabras = _oracionActual.map((p) => p.palabra).toList();
    await prefs.setStringList('oracion_actual', palabras);
  }

  Future<void> _cargarOracionGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    final palabras = prefs.getStringList('oracion_actual');
    if (palabras == null || palabras.isEmpty) return;

    final List<Pictograma> restaurados = [];
    for (final palabra in palabras) {
      final encontrado = _buscarPictograma(palabra);
      if (encontrado != null) {
        restaurados.add(encontrado);
      }
    }
    if (restaurados.isNotEmpty && mounted) {
      setState(() => _oracionActual.addAll(restaurados));
    }
  }

  Pictograma? _buscarPictograma(String palabra) {
    for (final pic in _palabrasFrecuentes) {
      if (pic.palabra == palabra) return pic;
    }
    for (final carpeta in _carpetas) {
      for (final pic in carpeta.pictogramas) {
        if (pic.palabra == palabra) return pic;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _gridIntroController.dispose();
    _scrollController.dispose(); 
    super.dispose();
  }

  void _abrirCarpeta(CarpetaCAA carpeta) {
    if (carpeta.esProOnly && !context.read<UserProvider>().isPro) {
      _mostrarPaywall();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _carpetaActual = carpeta);
    _gridIntroController.reset();
    _gridIntroController.forward();
    _precacheImagenes(carpeta.pictogramas);
  }

  void _volverACarpetas() {
    HapticFeedback.lightImpact();
    setState(() => _carpetaActual = null);
    _gridIntroController.reset();
    _gridIntroController.forward();
    _precachePantallaActual();
  }

  void _agregarPictograma(Pictograma pic) {
    HapticFeedback.lightImpact();

    if (_isSpeaking) {
      _motorVoz.detener();
      setState(() {
        _isSpeaking = false;
        _indiceDestacado = null; // Apaga el brillo
      });
    }

    setState(() => _oracionActual.add(pic));
    _motorVoz.encolarPalabra(pic.palabra);
    _guardarOracion();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _borrarUltimo() {
    if (_oracionActual.isNotEmpty) {
      HapticFeedback.mediumImpact();
      
      _motorVoz.detener();
      if (_isSpeaking) {
        setState(() {
          _isSpeaking = false;
          _indiceDestacado = null; // Apaga el brillo
        });
      }

      setState(() => _oracionActual.removeLast());
      _guardarOracion();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _borrarTodo() {
    if (_oracionActual.isNotEmpty) {
      HapticFeedback.heavyImpact();
      _motorVoz.detener();
      
      setState(() {
        _oracionActual.clear();
        _isSpeaking = false;
        _indiceDestacado = null;
      });
      _guardarOracion();
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
    
    setState(() {
      _isSpeaking = true;
      _indiceDestacado = null;
    });
    
    // Calculamos si es móvil para el auto-scroll
    final isMobile = context.isMobileScreen;
    final isMobileLandscape = context.isMobileLandscape;
    final double anchoTarjeta = isMobileLandscape ? 49.0 : (isMobile ? 61.0 : 110.0);

    final palabras = _oracionActual.map((p) => p.palabra).toList();
    
    // Reproduce la oración y recibe avisos en tiempo real
    await _motorVoz.hablarOracion(palabras, (index) {
      if (mounted) {
        setState(() => _indiceDestacado = index);
        
        // Auto-Scroll mágico para seguir a la tarjeta que brilla
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            (index * anchoTarjeta).clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      }
    });
    
    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _indiceDestacado = null; // Se apaga cuando termina
      });
    }
  }

  void _mostrarSelectorDeVoz() {
    HapticFeedback.mediumImpact();
    final voces = _motorVoz.vocesDisponibles;
    final isDark = context.read<ThemeProvider>().isDarkMode;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.record_voice_over, color: Colors.blueAccent.shade400, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Voces del dispositivo',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.5, 
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              if (_motorVoz.webSpeechDisponible)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _motorVoz.usandoWebSpeech
                        ? Colors.green.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _motorVoz.usandoWebSpeech
                          ? Colors.green.withOpacity(0.4)
                          : (isDark ? Colors.white10 : Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _motorVoz.usandoWebSpeech
                            ? Icons.check_circle
                            : Icons.language,
                        color: _motorVoz.usandoWebSpeech
                            ? Colors.green
                            : (isDark ? Colors.white54 : Colors.grey),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Motor nativo del navegador',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Recomendado si las voces no aparecen',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white38 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _motorVoz.usandoWebSpeech,
                        activeColor: Colors.green,
                        onChanged: (v) {
                          setState(() {
                            _motorVoz.setUsarWebSpeech(v);
                          });
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
              ...voces.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            _motorVoz.usandoWebSpeech
                                ? 'No se encontraron voces en español'
                                : 'Buscando voces...\n\n(Si la lista sigue vacía, activa el motor nativo arriba)',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, height: 1.5),
                          ),
                        ),
                      ),
                    ]
                  : voces.asMap().entries.map((entry) {
                    final voz = entry.value;
                    final locale = voz['locale'] ?? '';
                    final nombreStr = voz['name'] ?? 'Voz ${entry.key + 1}';
                    
                    final esActual = _motorVoz.vozActual?['name'] == voz['name'];
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: esActual 
                            ? Colors.blueAccent.withOpacity(0.15) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: esActual 
                              ? Colors.blueAccent.withOpacity(0.5) 
                              : (isDark ? Colors.white10 : Colors.grey.shade200),
                          width: esActual ? 2 : 1,
                        )
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        leading: Icon(
                          esActual ? Icons.check_circle : Icons.volume_up_outlined,
                          color: esActual ? Colors.blueAccent : (isDark ? Colors.white30 : Colors.grey),
                        ),
                        title: Text(
                          nombreStr,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.blueGrey.shade800,
                            fontWeight: esActual ? FontWeight.w900 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          locale, 
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.blueGrey.shade400,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await _motorVoz.cambiarVoz(voz);
                          await _motorVoz.hablar("Voz seleccionada: ${voz['name']}. Hola.");
                          setState(() {});
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cerrar', 
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
    final isDark = context.read<ThemeProvider>().isDarkMode;
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

  final List<TutorialStep> _pasosTutorial = const [
    TutorialStep(
      title: 'Arma tu frase',
      description: 'Los pictogramas que toques se acumulan aqui arriba. Despues escuchalos juntos.',
      icon: Icons.auto_awesome_mosaic_rounded,
    ),
    TutorialStep(
      title: 'Elige cada palabra',
      description: 'Cada tarjeta es una palabra. Toca las que quieras para construir tu oracion.',
      icon: Icons.grid_view_rounded,
    ),
    TutorialStep(
      title: 'Dale play',
      description: 'Cuando tu frase este lista toca este boton para escucharla en voz alta.',
      icon: Icons.play_circle_rounded,
    ),
    TutorialStep(
      title: 'Explora categorias',
      description: 'Las carpetas con candado son contenido PRO. Puedes solicitarlas con la administradora.',
      icon: Icons.folder_special_rounded,
    ),
  ];

  void _completarTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialPrefKey, true);
    if (mounted) HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileScreen;
    final isMobileLandscape = context.isMobileLandscape;

    final userProvider = context.watch<UserProvider>();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: AnimatedGradientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _construirCabecera(isDark, isMobile, isMobileLandscape, userProvider),
                  _construirBarraOracionGlass(isDark, isMobile, isMobileLandscape),
                  SizedBox(height: isMobileLandscape ? 2 : 8),
                  _construirBarraNavegacionInterna(isDark, isMobile, isMobileLandscape),
                  _construirGrillaPrincipal(isDark, isMobile, isMobileLandscape),
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

  Widget _construirCabecera(bool isDark, bool isMobile, bool isMobileLandscape, UserProvider userProvider) {
    final bool esAdmin = userProvider.esAdmin;
    final String primerNombre = userProvider.nombre.split(' ').first;
    final colorTextoPrincipal = isDark ? Colors.white : const Color(0xFF1E293B);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobileLandscape ? 2 : (isMobile ? 8 : 10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '¡Hola, $primerNombre! 👋',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: isMobileLandscape ? 15 : (isMobile ? 18 : 26),
                      color: colorTextoPrincipal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _BadgePlan(isPro: userProvider.isPro, isMobile: isMobile, isMobileLandscape: isMobileLandscape),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esAdmin)
                _HeaderButton(
                  isDark: isDark,
                  isMobile: isMobile,
                  isMobileLandscape: isMobileLandscape,
                  icon: Icons.admin_panel_settings,
                  label: isMobile ? null : 'Admin',
                  color: Colors.amber.shade600,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                  ),
                ),
                
              _HeaderButton(
                isDark: isDark,
                isMobile: isMobile,
                isMobileLandscape: isMobileLandscape,
                icon: Icons.record_voice_over,
                label: isMobile ? null : 'Voz',
                color: Colors.blueAccent.shade400,
                onTap: _mostrarSelectorDeVoz,
              ),

              const ThemeToggleButton(),
              _HeaderButton(
                isDark: isDark,
                isMobile: isMobile,
                isMobileLandscape: isMobileLandscape,
                icon: Icons.person_outline,
                label: isMobile ? null : 'Mi Perfil',
                color: colorTextoPrincipal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
              _HeaderButton(
                isDark: isDark,
                isMobile: isMobile,
                isMobileLandscape: isMobileLandscape,
                icon: Icons.power_settings_new_rounded,
                label: isMobile ? null : 'Salir',
                color: Colors.redAccent,
                borderColor: isDark
                    ? Colors.redAccent.withOpacity(0.4)
                    : Colors.red.shade200,
                bg: isDark
                    ? Colors.redAccent.withOpacity(0.12)
                    : Colors.red.shade50,
                onTap: () => userProvider.signOut(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BARRA DE ORACIÓN GLASS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _construirBarraOracionGlass(bool isDark, bool isMobile, bool isMobileLandscape) {
    return Container(
      height: isMobileLandscape ? 70 : (isMobile ? 100 : 165),
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobileLandscape ? 4 : (isMobile ? 8 : 14)),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(isMobileLandscape ? 20 : (isMobile ? 24 : 36)),
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
                  ? _EmptyPhraseHint(isDark: isDark, isMobile: isMobile, isMobileLandscape: isMobileLandscape, key: const ValueKey('empty'))
                  : ClipRRect(
                      key: const ValueKey('lista'),
                      borderRadius: BorderRadius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 24)),
                      child: ListView.builder(
                        controller: _scrollController,
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
                            child: _MiniTarjeta(
                              pic: _oracionActual[index], 
                              isDark: isDark, 
                              isMobile: isMobile, 
                              isMobileLandscape: isMobileLandscape,
                              isHighlighted: _indiceDestacado == index, // NUEVO: ¡Aquí conectamos el brillo!
                            ),
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
          _construirControlesBarra(isDark, isMobile, isMobileLandscape),
        ],
      ),
    );
  }

  Widget _construirControlesBarra(bool isDark, bool isMobile, bool isMobileLandscape) {
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
              isMobileLandscape: isMobileLandscape,
            ),
            SizedBox(width: isMobileLandscape ? 4 : (isMobile ? 4 : 8)),
            _BotonControlUltra(
              icono: Icons.delete_sweep,
              color: isDark ? Colors.grey.shade300 : Colors.blueGrey,
              onTap: _borrarTodo,
              isDark: isDark,
              isMobile: isMobile,
              isMobileLandscape: isMobileLandscape,
            ),
          ],
        ),
        GestureDetector(
          onTap: _isSpeaking ? null : _reproducirOracion,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            padding: EdgeInsets.symmetric(
              horizontal: isMobileLandscape ? 8 : (isMobile ? 12 : 22), 
              vertical: isMobileLandscape ? 4 : (isMobile ? 8 : 16)
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
              borderRadius: BorderRadius.circular(isMobileLandscape ? 12 : (isMobile ? 18 : 28)),
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
                          width: isMobileLandscape ? 12 : (isMobile ? 16 : 28),
                          height: isMobileLandscape ? 12 : (isMobile ? 16 : 28),
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
                          size: isMobileLandscape ? 16 : (isMobile ? 20 : 30),
                        ),
                ),
                SizedBox(width: isMobileLandscape ? 2 : (isMobile ? 4 : 6)),
                Text(
                  _isSpeaking ? 'HABLANDO' : 'HABLAR',
                  style: TextStyle(
                    fontSize: isMobileLandscape ? 9 : (isMobile ? 11 : 16),
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

  Widget _construirBarraNavegacionInterna(bool isDark, bool isMobile, bool isMobileLandscape) {
    if (_carpetaActual == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20, 
        vertical: isMobileLandscape ? 0 : 4
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _volverACarpetas,
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: isMobileLandscape ? 14 : (isMobile ? 18 : 24)),
            label: Text(isMobile ? 'Atrás' : 'Categorías',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobileLandscape ? 10 : (isMobile ? 12 : 14))),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white24
                  : Colors.blueGrey.shade400,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobileLandscape ? 8 : (isMobile ? 12 : 16), 
                vertical: isMobileLandscape ? 4 : (isMobile ? 6 : 12)
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobileLandscape ? 10 : (isMobile ? 14 : 18))),
            ),
          ),
          SizedBox(width: isMobileLandscape ? 6 : (isMobile ? 8 : 14)),
          if (_carpetaActual!.rutaImagen != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                _carpetaActual!.rutaImagen!,
                width: isMobileLandscape ? 16 : (isMobile ? 20 : 26),
                height: isMobileLandscape ? 16 : (isMobile ? 20 : 26),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  _carpetaActual!.icono ?? Icons.folder,
                  size: isMobileLandscape ? 16 : (isMobile ? 20 : 26),
                  color: isDark ? Colors.white : Colors.blueGrey,
                ),
              ),
            )
          else
            Icon(_carpetaActual!.icono ?? Icons.folder,
                color: isDark ? Colors.white : Colors.blueGrey, size: isMobileLandscape ? 16 : (isMobile ? 20 : 26)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _carpetaActual!.nombre,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobileLandscape ? 14 : (isMobile ? 16 : 20),
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

  Widget _construirGrillaPrincipal(bool isDark, bool isMobile, bool isMobileLandscape) {
    final int itemCount = _carpetaActual == null
        ? _palabrasFrecuentes.length + _carpetas.length
        : _carpetaActual!.pictogramas.length;

    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16, 
            vertical: isMobileLandscape ? 6 : 10
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: isMobileLandscape ? 20 : (isMobile ? 100 : 165),
          childAspectRatio: 1.0,
          crossAxisSpacing: isMobileLandscape ? 8 : (isMobile ? 10 : 16),
          mainAxisSpacing: isMobileLandscape ? 8 : (isMobile ? 12 : 18),
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
            child: _construirElementoGrilla(index, isDark, isMobile, isMobileLandscape),
          );
        },
      ),
    );
  }

  Widget _construirElementoGrilla(int index, bool isDark, bool isMobile, bool isMobileLandscape) {
    if (_carpetaActual != null) {
      final pic = _carpetaActual!.pictogramas[index];
      return TarjetaSquish3D(
        pic: pic,
        isLocked: false,
        onTap: () => _agregarPictograma(pic),
        isDark: isDark,
        isMobile: isMobile,
        isMobileLandscape: isMobileLandscape,
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
        isMobileLandscape: isMobileLandscape,
      );
    }
    final carpeta = _carpetas[index - _palabrasFrecuentes.length];
    return TarjetaCarpeta3D(
      carpeta: carpeta,
      isLocked: carpeta.esProOnly && !context.read<UserProvider>().isPro,
      onTap: () => _abrirCarpeta(carpeta),
      isDark: isDark,
      isMobile: isMobile,
      isMobileLandscape: isMobileLandscape,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS PRIVADOS
// ─────────────────────────────────────────────────────────────────────────────

class _BadgePlan extends StatelessWidget {
  final bool isPro;
  final bool isMobile;
  final bool isMobileLandscape;
  
  const _BadgePlan({required this.isPro, required this.isMobile, required this.isMobileLandscape});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 10, 
        vertical: isMobileLandscape ? 2 : 4
      ),
      decoration: BoxDecoration(
        color: isPro ? Colors.amber.shade400 : Colors.blueGrey.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPro ? 'PRO' : 'DEMO',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontSize: isMobileLandscape ? 9 : (isMobile ? 11 : 13),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final bool isMobileLandscape;
  final IconData icon;
  final String? label;
  final Color color;
  final Color? borderColor;
  final Color? bg;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.isDark,
    required this.isMobile,
    required this.isMobileLandscape,
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
        borderRadius: BorderRadius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 22)),
        border: Border.all(color: effectiveBorder, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 22)),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: label != null ? 14 : (isMobile ? 8 : 11),
              vertical: isMobileLandscape ? 4 : (isMobile ? 8 : 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: label != null ? 20 : (isMobileLandscape ? 16 : 18)),
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
  final bool isMobileLandscape;
  
  const _EmptyPhraseHint({super.key, required this.isDark, required this.isMobile, required this.isMobileLandscape});

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
            size: isMobileLandscape ? 26 : (isMobile ? 36 : 52),
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
        ),
        SizedBox(height: isMobileLandscape ? 2 : (isMobile ? 6 : 10)),
        Text(
          '¡Arma tu frase mágica!',
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey.shade500,
            fontSize: isMobileLandscape ? 11 : (isMobile ? 14 : 18),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NUEVO: TARJETA ANIMADA CON BRILLO MÁGICO
// ─────────────────────────────────────────────────────────────────────────────
class _MiniTarjeta extends StatelessWidget {
  final Pictograma pic;
  final bool isDark;
  final bool isMobile;
  final bool isMobileLandscape;
  final bool isHighlighted;

  const _MiniTarjeta({
    required this.pic, 
    required this.isDark, 
    required this.isMobile, 
    required this.isMobileLandscape,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isMobileLandscape ? 45 : (isMobile ? 55 : 100),
      height: isMobileLandscape ? 45 : (isMobile ? 55 : 100),
      margin: EdgeInsets.only(right: isMobileLandscape ? 4 : (isMobile ? 6 : 10), top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: pic.colorFondo,
        borderRadius: BorderRadius.circular(isMobileLandscape ? 10 : (isMobile ? 12 : 20)),
        // Destello visual al ser hablado
        border: Border.all(
          color: isHighlighted ? const Color.fromARGB(255, 48, 45, 253) : Colors.white, 
          width: isHighlighted ? 3.5 : (isMobile ? 1.5 : 2.5)
        ),
        boxShadow: [
          if (isHighlighted)
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
              blurRadius: 15,
              spreadRadius: 2,
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 6),
            )
        ],
      ),
      child: pic.rutaImagen != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 17)),
              child: Image.asset(
                pic.rutaImagen!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PictoFallback(pic: pic, isMobile: isMobile, isMobileLandscape: isMobileLandscape),
              ),
            )
          : _PictoFallback(pic: pic, isMobile: isMobile, isMobileLandscape: isMobileLandscape),
    );
  }
}

class _PictoFallback extends StatelessWidget {
  final Pictograma pic;
  final bool isMobile;
  final bool isMobileLandscape;
  
  const _PictoFallback({required this.pic, this.isMobile = false, this.isMobileLandscape = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          pic.icono ?? Icons.image_not_supported_outlined,
          size: isMobileLandscape ? 18 : (isMobile ? 22 : 36),
          color: Colors.black87,
        ),
        SizedBox(height: isMobileLandscape ? 1 : (isMobile ? 2 : 4)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            pic.palabra,
            style: TextStyle(
              fontSize: isMobileLandscape ? 8 : (isMobile ? 9 : 12),
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
  final bool isMobileLandscape;

  const TarjetaCarpeta3D({
    super.key,
    required this.carpeta,
    required this.onTap,
    this.isLocked = false,
    required this.isDark,
    required this.isMobile,
    required this.isMobileLandscape,
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
              borderRadius: BorderRadius.circular(widget.isMobileLandscape ? 16 : (widget.isMobile ? 20 : 28)),
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
                    borderRadius: BorderRadius.circular(widget.isMobileLandscape ? 14 : (widget.isMobile ? 18 : 26)),
                    child: Image.asset(
                      widget.carpeta.rutaImagen!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _CarpetaFallbackContent(
                        carpeta: widget.carpeta,
                        iconColor: iconColor,
                        isMobile: widget.isMobile,
                        isMobileLandscape: widget.isMobileLandscape,
                      ),
                    ),
                  )
                else ...[
                  Positioned(
                    top: widget.isMobile ? -6 : -12,
                    right: widget.isMobile ? -6 : -12,
                    child: Icon(Icons.folder_open,
                        size: widget.isMobileLandscape ? 40 : (widget.isMobile ? 50 : 90),
                        color: Colors.white.withOpacity(0.18)),
                  ),
                  _CarpetaFallbackContent(
                    carpeta: widget.carpeta,
                    iconColor: iconColor,
                    isMobile: widget.isMobile,
                    isMobileLandscape: widget.isMobileLandscape,
                  ),
                ],
                if (widget.isLocked)
                  Positioned(
                    top: widget.isMobileLandscape ? 6 : (widget.isMobile ? 8 : 12),
                    right: widget.isMobileLandscape ? 6 : (widget.isMobile ? 8 : 12),
                    child: Icon(
                      Icons.lock_rounded,
                      color: widget.isDark
                          ? Colors.white54
                          : Colors.blueGrey.shade400,
                      size: widget.isMobileLandscape ? 16 : (widget.isMobile ? 20 : 28),
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
  final bool isMobileLandscape;
  
  const _CarpetaFallbackContent({
    required this.carpeta, 
    required this.iconColor, 
    required this.isMobile,
    required this.isMobileLandscape
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(carpeta.icono ?? Icons.folder, size: isMobileLandscape ? 30 : (isMobile ? 36 : 58), color: iconColor),
        SizedBox(height: isMobileLandscape ? 2 : (isMobile ? 4 : 8)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            carpeta.nombre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobileLandscape ? 12 : (isMobile ? 14 : 20),
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
  final bool isMobileLandscape;

  const TarjetaSquish3D({
    super.key,
    required this.pic,
    required this.onTap,
    this.isLocked = false,
    required this.isDark,
    required this.isMobile,
    required this.isMobileLandscape,
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
              borderRadius: BorderRadius.circular(widget.isMobileLandscape ? 16 : (widget.isMobile ? 22 : 32)),
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
                    borderRadius: BorderRadius.circular(widget.isMobileLandscape ? 14 : (widget.isMobile ? 20 : 30)),
                    child: AnimatedScale(
                      scale: _isPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Image.asset(
                        widget.pic.rutaImagen!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _PictoFallback(pic: widget.pic, isMobile: widget.isMobile, isMobileLandscape: widget.isMobileLandscape),
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
                            size: widget.isMobileLandscape ? 30 : (widget.isMobile ? 40 : 62), color: iconColor),
                      ),
                      SizedBox(height: widget.isMobileLandscape ? 2 : (widget.isMobile ? 4 : 8)),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          widget.pic.palabra,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: widget.isMobileLandscape ? 10 : (widget.isMobile ? 12 : 17),
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
                    top: widget.isMobileLandscape ? 6 : (widget.isMobile ? 8 : 12),
                    right: widget.isMobileLandscape ? 6 : (widget.isMobile ? 8 : 12),
                    child: Icon(
                      Icons.lock_rounded,
                      color: widget.isDark
                          ? Colors.white54
                          : Colors.blueGrey.shade300,
                      size: widget.isMobileLandscape ? 14 : (widget.isMobile ? 18 : 26),
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
  final bool isMobileLandscape;

  const _BotonControlUltra({
    required this.icono,
    required this.color,
    required this.onTap,
    required this.isDark,
    required this.isMobile,
    required this.isMobileLandscape,
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
          width: widget.isMobileLandscape ? 30 : (widget.isMobile ? 36 : 52),
          height: widget.isMobileLandscape ? 30 : (widget.isMobile ? 36 : 52),
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
          child: Icon(widget.icono, color: widget.color, size: widget.isMobileLandscape ? 15 : (widget.isMobile ? 18 : 26)),
        ),
      ),
    );
  }
}