import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/theme_provider.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/glass_layout.dart';
import '../widgets/shimmer_loading.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final Set<String> _pendingUpdates = {};

  Future<void> _cambiarEstadoPro(BuildContext ctx, String docId, String email, bool nuevoValor) async {
    if (_pendingUpdates.contains(docId)) return;

    if (!nuevoValor) {
      final isDark = ctx.read<ThemeProvider>().isDarkMode;
      final confirm = await showDialog<bool>(
        context: ctx,
        builder: (dlg) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('¿Degradar a DEMO?', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
          content: Text('$email perderá acceso a las carpetas PRO.\nEsta acción afecta su comunicación inmediatamente.', style: TextStyle(color: isDark ? Colors.white70 : Colors.blueGrey, height: 1.5)),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(onPressed: () => Navigator.pop(dlg, false), child: const Text('Cancelar', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold))),
            ElevatedButton(
              onPressed: () => Navigator.pop(dlg, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Degradar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _pendingUpdates.add(docId));
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(docId).update({'isPro': nuevoValor});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Error al guardar. Verifica la conexión.', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              backgroundColor: Colors.redAccent.shade700, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), margin: const EdgeInsets.all(16),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _pendingUpdates.remove(docId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        final colorTexto = isDark ? Colors.white : const Color(0xFF1E293B);
        final colorTarjeta = isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.85);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDark ? Colors.black26 : Colors.white54, shape: BoxShape.circle), child: Icon(Icons.arrow_back_ios_new_rounded, color: colorTexto, size: 18)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Gestión de Usuarios', style: TextStyle(fontWeight: FontWeight.w900, color: colorTexto)),
            centerTitle: true,
            actions: const [ThemeToggleButton(), SizedBox(width: 16)],
          ),
          body: GlassLayout(
            sphere1: const SphereStyle(
              color: Colors.orangeAccent,
              darkOpacity: 0.3,
              lightOpacity: 0.15,
            ),
            sphere2: const SphereStyle(
              color: Colors.blueAccent,
              darkOpacity: 0.3,
              lightOpacity: 0.15,
            ),
            child: SafeArea(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('usuarios').orderBy('fechaRegistro', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text('Error al cargar datos', style: TextStyle(color: colorTexto)));
                  if (snapshot.connectionState == ConnectionState.waiting) return const SkeletonAdminList();
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      builder: (context, val, child) => Opacity(
                        opacity: val.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - val)),
                          child: child,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.orange.withOpacity(0.12) : Colors.orange.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.group_off_rounded, size: 72, color: isDark ? Colors.orange.shade300 : Colors.orange.shade700),
                            ),
                            const SizedBox(height: 20),
                            Text('No hay usuarios registrados aún',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: colorTexto,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Los nuevos usuarios aparecerán aquí\ncuando se registren en la app',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorTexto.withOpacity(0.5),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final String docId = docs[index].id;
                      final bool isPro = data['isPro'] ?? false;
                      final String email = data['email'] ?? 'Sin correo';
                      final String nombre = data['nombre'] ?? 'Sin nombre';
                      final bool isPending = _pendingUpdates.contains(docId);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: colorTarjeta,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isPending ? Colors.blueAccent : (isDark ? Colors.white12 : Colors.white), width: isPending ? 2 : 1.5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                leading: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: isPro ? Colors.amber.withOpacity(0.2) : Colors.blueGrey.withOpacity(0.15),
                                  child: Icon(isPro ? Icons.star_rounded : Icons.person_rounded, color: isPro ? Colors.amber.shade600 : Colors.blueGrey, size: 28),
                                ),
                                title: Text(nombre, style: TextStyle(fontWeight: FontWeight.w900, color: colorTexto, fontSize: 18, letterSpacing: -0.5)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(email, style: TextStyle(color: colorTexto.withOpacity(0.6), fontSize: 14)),
                                    const SizedBox(height: 8),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPro ? Colors.amber.withOpacity(0.15) : Colors.blueGrey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(isPro ? 'PLAN PRO' : 'PLAN DEMO', style: TextStyle(color: isPro ? Colors.amber.shade700 : (isDark ? Colors.blueGrey.shade300 : Colors.blueGrey), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                                    ),
                                  ],
                                ),
                                trailing: isPending
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                                    : Switch(
                                        value: isPro,
                                        activeColor: Colors.amber.shade500,
                                        activeTrackColor: Colors.amber.withOpacity(0.3),
                                        inactiveThumbColor: Colors.blueGrey.shade300,
                                        inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade300,
                                        onChanged: (nuevoValor) => _cambiarEstadoPro(context, docId, email, nuevoValor),
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ),
          ),
        );
      },
    );
  }
}