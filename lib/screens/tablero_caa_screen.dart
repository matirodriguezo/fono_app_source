import 'package:flutter/material.dart';

// 1. MODELO DE DATOS: Define qué tiene cada botón del tablero
class Pictograma {
  final String palabra;
  final IconData icono; // En el futuro cambiaremos esto por 'String rutaImagen' (assets)
  final Color colorFondo;

  Pictograma({required this.palabra, required this.icono, required this.colorFondo});
}

class TableroComunicacion extends StatefulWidget {
  const TableroComunicacion({super.key});

  @override
  State<TableroComunicacion> createState() => _TableroComunicacionState();
}

class _TableroComunicacionState extends State<TableroComunicacion> {
  // 2. EL ESTADO: Aquí se guardan los pictogramas que el niño va tocando
  final List<Pictograma> _oracionActual = [];

  // 3. EL VOCABULARIO: Categorizado usando la Clave de colores Fitzgerald
  final List<Pictograma> _vocabulario = [
    // Personas / Pronombres (Amarillo)
    Pictograma(palabra: 'Yo', icono: Icons.person, colorFondo: Colors.yellow.shade200),
    Pictograma(palabra: 'Tú', icono: Icons.person_outline, colorFondo: Colors.yellow.shade200),
    
    // Verbos / Acciones (Verde)
    Pictograma(palabra: 'Quiero', icono: Icons.pan_tool, colorFondo: Colors.green.shade200),
    Pictograma(palabra: 'No quiero', icono: Icons.do_not_disturb, colorFondo: Colors.green.shade200),
    Pictograma(palabra: 'Comer', icono: Icons.restaurant, colorFondo: Colors.green.shade200),
    Pictograma(palabra: 'Jugar', icono: Icons.sports_esports, colorFondo: Colors.green.shade200),
    Pictograma(palabra: 'Dormir', icono: Icons.bed, colorFondo: Colors.green.shade200),
    Pictograma(palabra: 'Ir al baño', icono: Icons.wc, colorFondo: Colors.green.shade200),
    
    // Sustantivos / Objetos (Naranja/Azul)
    Pictograma(palabra: 'Agua', icono: Icons.water_drop, colorFondo: Colors.blue.shade200),
    Pictograma(palabra: 'Manzana', icono: Icons.apple, colorFondo: Colors.orange.shade200),
    Pictograma(palabra: 'Televisión', icono: Icons.tv, colorFondo: Colors.orange.shade200),
    Pictograma(palabra: 'Pelota', icono: Icons.sports_soccer, colorFondo: Colors.orange.shade200),
  ];

  // Lógica para modificar la oración
  void _agregarPictograma(Pictograma pic) {
    setState(() {
      _oracionActual.add(pic);
    });
  }

  void _borrarUltimo() {
    if (_oracionActual.isNotEmpty) {
      setState(() {
        _oracionActual.removeLast();
      });
    }
  }

  void _borrarTodo() {
    setState(() {
      _oracionActual.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunicador de Alta Tecnología', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- 4. ZONA DE LA ORACIÓN (Donde se construye la frase) ---
          Container(
            height: 140,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 3)),
            ),
            child: Row(
              children: [
                // Lista horizontal que muestra los pictogramas seleccionados
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _oracionActual.length,
                    itemBuilder: (context, index) {
                      final pic = _oracionActual[index];
                      return _construirTarjetaMini(pic);
                    },
                  ),
                ),
                
                // Botones de control laterales
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.backspace, color: Colors.red, size: 30),
                      onPressed: _borrarUltimo,
                      tooltip: 'Borrar último',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep, color: Colors.grey, size: 35),
                      onPressed: _borrarTodo,
                      tooltip: 'Borrar todo',
                    ),
                  ],
                ),
                const SizedBox(width: 10),

                // Botón principal de ACCIÓN (Hablar)
                FloatingActionButton(
                  onPressed: () {
                    // Aquí integraremos el motor de voz (Text-To-Speech) más adelante
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🔊 ¡Pronto reproduciremos el audio de la frase!'))
                    );
                  },
                  backgroundColor: Colors.blue.shade600,
                  elevation: 4,
                  child: const Icon(Icons.volume_up, color: Colors.white, size: 35),
                ),
              ],
            ),
          ),

          // --- 5. EL TABLERO INTERACTIVO (Vocabulario) ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 columnas, ideal para simular una tablet horizontal
                childAspectRatio: 0.9, 
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: _vocabulario.length,
              itemBuilder: (context, index) {
                final pic = _vocabulario[index];
                return GestureDetector(
                  onTap: () => _agregarPictograma(pic),
                  child: Container(
                    decoration: BoxDecoration(
                      color: pic.colorFondo,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black12, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(pic.icono, size: 45, color: Colors.black87),
                        const SizedBox(height: 10),
                        Text(
                          pic.palabra,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Molde visual para los iconos que suben a la barra de oración
  Widget _construirTarjetaMini(Pictograma pic) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: pic.colorFondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(pic.icono, size: 35, color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            pic.palabra,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}