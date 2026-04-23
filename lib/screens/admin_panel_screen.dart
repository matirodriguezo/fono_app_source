import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios PRO', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Escuchamos la colección de usuarios en tiempo real
        stream: FirebaseFirestore.instance.collection('usuarios').orderBy('fechaRegistro', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error al cargar datos'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String docId = docs[index].id;
              final bool isPro = data['isPro'] ?? false;
              final String email = data['email'] ?? 'Sin correo';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(isPro ? 'Estado: PRO' : 'Estado: DEMO'),
                  trailing: Switch(
                    value: isPro,
                    activeColor: Colors.amber,
                    onChanged: (nuevoValor) {
                      // Actualización directa en la base de datos
                      FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(docId)
                          .update({'isPro': nuevoValor});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}