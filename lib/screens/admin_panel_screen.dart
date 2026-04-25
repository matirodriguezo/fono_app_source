import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../main.dart'; // Import global para el modo oscuro

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, child) {
        final colorTextoPrincipal = isDark ? Colors.white : const Color(0xFF1E293B);
        final colorFondoTarjeta = isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.9);
        final colorBordeTarjeta = isDark ? Colors.white.withOpacity(0.2) : Colors.transparent;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorTextoPrincipal),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Volver atrás', // Control de usuario
            ),
            title: Text('Gestión de Usuarios PRO', style: TextStyle(fontWeight: FontWeight.w900, color: colorTextoPrincipal)),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () => isDarkModeGlobal.value = !isDarkModeGlobal.value,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.blueGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.transparent)
                    ),
                    child: Row(
                      children: [
                        Text(isDark ? '🌙' : '☀️', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              // FONDO ANIMADO UNIFICADO
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('usuarios').orderBy('fechaRegistro', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text('Error al cargar datos', style: TextStyle(color: colorTextoPrincipal)));
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final String docId = docs[index].id;
                        final bool isPro = data['isPro'] ?? false;
                        final String email = data['email'] ?? 'Sin correo';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: colorFondoTarjeta,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorBordeTarjeta, width: 1),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                            ]
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            leading: CircleAvatar(
                              backgroundColor: isPro ? Colors.amber.withOpacity(0.2) : Colors.blueGrey.withOpacity(0.2),
                              child: Icon(isPro ? Icons.star : Icons.person, color: isPro ? Colors.amber.shade600 : Colors.blueGrey),
                            ),
                            title: Text(email, style: TextStyle(fontWeight: FontWeight.bold, color: colorTextoPrincipal, fontSize: 16)),
                            subtitle: Text(isPro ? 'Estado: PLAN PRO' : 'Estado: PLAN DEMO', style: TextStyle(color: isPro ? Colors.amber.shade600 : (isDark ? Colors.blueGrey.shade300 : Colors.blueGrey), fontWeight: FontWeight.bold)),
                            trailing: Switch(
                              value: isPro,
                              activeColor: Colors.amber.shade600,
                              inactiveThumbColor: Colors.blueGrey,
                              inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade300,
                              onChanged: (nuevoValor) {
                                FirebaseFirestore.instance.collection('usuarios').doc(docId).update({'isPro': nuevoValor});
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}