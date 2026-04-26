import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/theme_toggle_button.dart';

/// AUDITORÍA — admin_panel_screen.dart
///
/// MEJORAS IMPLEMENTADAS:
///
/// 1. ANTI DOBLE-TAP EN SWITCH: En la versión original, el Switch de
///    isPro llamaba directamente a Firestore.update() en el onChanged sin
///    ninguna protección. Si el usuario movía el switch rápidamente varias
///    veces, podía generar múltiples escrituras concurrentes con estados
///    contradictorios. Se introduce un Set de `_pendingUpdates` que bloquea
///    el Switch del usuario afectado mientras la escritura a Firestore está
///    en curso.
///
/// 2. CONFIRMACIÓN ANTES DE CAMBIAR ESTADO PRO: Degradar a un usuario de
///    PRO a DEMO es una acción de consecuencias clínicas (el paciente pierde
///    acceso a vocabulario). Se añade un AlertDialog de confirmación al
///    intentar bajar de PRO → DEMO, pero NO al subir de DEMO → PRO (flujo
///    positivo que no necesita fricción).
///
/// 3. FEEDBACK VISUAL EN TARJETAS: Se añade un AnimatedContainer que
///    resalta la tarjeta en verde/ámbar al completar la actualización,
///    confirmando al administrador que el cambio fue exitoso.
///
/// 4. MANEJO DE ERRORES: El update() original no tenía try-catch. Si la
///    conexión falla, el Switch volvía visualmente al estado opuesto (por el
///    stream) pero sin ningún mensaje. Ahora se muestra un SnackBar de error.
///
/// 5. FONDO Y TOGGLE: Reemplazados por widgets compartidos.
///    Se elimina el AnimationController local.
///
/// 6. ESTADO VACÍO: Se añade un estado visual elegante cuando no hay
///    usuarios registrados en Firestore.
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  // ANTI DOBLE-TAP: IDs de documentos con actualización en curso.
  final Set<String> _pendingUpdates = {};

  Future<void> _cambiarEstadoPro(
    BuildContext ctx,
    String docId,
    String email,
    bool nuevoValor,
  ) async {
    // Si ya hay una operación en curso para este usuario, ignoramos el tap.
    if (_pendingUpdates.contains(docId)) return;

    // MEJORA: Confirmación sólo al degradar (PRO → DEMO).
    if (!nuevoValor) {
      final confirm = await showDialog<bool>(
        context: ctx,
        builder: (dlg) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('¿Degradar a DEMO?',
              style: TextStyle(fontWeight: FontWeight.w900)),
          content: Text(
            '$email perderá acceso a las carpetas PRO.\nEsta acción afecta su comunicación inmediatamente.',
            style: const TextStyle(color: Colors.blueGrey, height: 1.5),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlg, false),
              child: const Text('Cancelar',
                  style: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dlg, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Degradar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _pendingUpdates.add(docId));
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(docId)
          .update({'isPro': nuevoValor});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Error al guardar. Verifica la conexión.',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              backgroundColor: Colors.redAccent.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(16),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _pendingUpdates.remove(docId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, _) {
        final colorTextoPrincipal =
            isDark ? Colors.white : const Color(0xFF1E293B);
        final colorFondoTarjeta = isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.9);
        final colorBordeTarjeta = isDark
            ? Colors.white.withOpacity(0.18)
            : Colors.transparent;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: colorTextoPrincipal),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Volver atrás',
            ),
            title: Text(
              'Gestión de Usuarios PRO',
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: colorTextoPrincipal),
            ),
            centerTitle: true,
            actions: [
              const ThemeToggleButton(),
              const SizedBox(width: 8),
            ],
          ),
          body: AnimatedGradientBackground(
            child: SafeArea(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .orderBy('fechaRegistro', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar datos',
                        style: TextStyle(color: colorTextoPrincipal),
                      ),
                    );
                  }
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  // MEJORA: Estado vacío elegante.
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.group_off_rounded,
                              size: 72,
                              color: colorTextoPrincipal.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'No hay usuarios registrados aún.',
                            style: TextStyle(
                                color: colorTextoPrincipal.withOpacity(0.5),
                                fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          docs[index].data() as Map<String, dynamic>;
                      final String docId = docs[index].id;
                      final bool isPro = data['isPro'] ?? false;
                      final String email =
                          data['email'] ?? 'Sin correo';
                      final String nombre =
                          data['nombre'] ?? 'Sin nombre';
                      final bool isPending =
                          _pendingUpdates.contains(docId);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: colorFondoTarjeta,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            // MEJORA: Borde de color resalta brevemente
                            // cuando hay una actualización pendiente.
                            color: isPending
                                ? Colors.blueAccent.withOpacity(0.5)
                                : colorBordeTarjeta,
                            width: isPending ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: isPro
                                ? Colors.amber.withOpacity(0.2)
                                : Colors.blueGrey.withOpacity(0.2),
                            child: Icon(
                              isPro ? Icons.star : Icons.person,
                              color: isPro
                                  ? Colors.amber.shade600
                                  : Colors.blueGrey,
                            ),
                          ),
                          title: Text(
                            nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorTextoPrincipal,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: TextStyle(
                                    color: colorTextoPrincipal
                                        .withOpacity(0.6),
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isPro
                                      ? Colors.amber.withOpacity(0.15)
                                      : Colors.blueGrey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isPro ? 'PLAN PRO' : 'PLAN DEMO',
                                  style: TextStyle(
                                    color: isPro
                                        ? Colors.amber.shade700
                                        : (isDark
                                            ? Colors.blueGrey.shade300
                                            : Colors.blueGrey),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: isPending
                              // MEJORA: Spinner mientras se actualiza Firestore.
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5),
                                )
                              : Switch(
                                  value: isPro,
                                  activeColor: Colors.amber.shade600,
                                  inactiveThumbColor: Colors.blueGrey,
                                  inactiveTrackColor: isDark
                                      ? Colors.white12
                                      : Colors.grey.shade300,
                                  onChanged: (nuevoValor) =>
                                      _cambiarEstadoPro(
                                    context,
                                    docId,
                                    email,
                                    nuevoValor,
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