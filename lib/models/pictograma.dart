import 'package:flutter/material.dart';

// 1. EL ENUMERADOR (La Clave Fitzgerald - Tonos Pastel Modernos)
enum CategoriaCAA {
  persona(Color.fromARGB(103, 12, 130, 63)),     // Amarillo suave (Sujetos y pronombres)
  accion(Color(0xFF86EFAC)),      // Verde menta (Verbos y acciones)
  alimento(Color(0xFFFDBA74)),    // Naranja melocotón (Comida/Bebida/Objetos)
  objeto(Color(0xFFFDBA74)),      // Naranja melocotón (Cosas inertes/Lugares)
  social(Color(0xFFF9A8D4)),      // Rosa chicle (Interacción social/cortesía/frases hechas)
  descriptivo(Color(0xFF93C5FD)); // Azul cielo (Adjetivos, emociones, tiempos, preguntas)

  final Color colorFondo;
  const CategoriaCAA(this.colorFondo);
}

// 2. EL MODELO DE PICTOGRAMA
class Pictograma {
  final String palabra;
  final IconData? icono;       // Ahora es opcional (tiene ?)
  final String? rutaImagen;    // NUEVO: Ruta de la foto física
  final CategoriaCAA categoria;

  Pictograma({
    required this.palabra,
    this.icono,
    this.rutaImagen,
    required this.categoria,
  });

  Color get colorFondo => categoria.colorFondo;
}

// 3. EL MODELO DE CARPETA (Contextos)
class CarpetaCAA {
  final String nombre;
  final IconData? icono;       // Ahora es opcional
  final String? rutaImagen;    // NUEVO: Ruta de la foto de la carpeta
  final Color colorFondo;
  final bool esProOnly;
  final List<Pictograma> pictogramas;

  CarpetaCAA({
    required this.nombre,
    this.icono,
    this.rutaImagen,
    required this.colorFondo,
    this.esProOnly = false,
    required this.pictogramas,
  });
}

// 4. LA BASE DE DATOS ESTRUCTURADA
class RepositorioVocabulario {
  
  // --- NUEVO: VOCABULARIO NÚCLEO (Pantalla Principal) ---
  static List<Pictograma> obtenerPalabrasFrecuentes() {
    return [
      Pictograma(palabra: 'Yo', rutaImagen: "assets/images/YO.png", categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Tú', rutaImagen: "assets/images/TU.png", categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Él', rutaImagen: "assets/images/EL.png", categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Ella', rutaImagen: "assets/images/ELLA.png", categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Ellas', rutaImagen: "assets/images/ELLAS.png", categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Ellos', rutaImagen: "assets/images/ELLOS.png", categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Nosotros', rutaImagen: "assets/images/NOSOTROS.png", categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Profesora', rutaImagen: "assets/images/profesora.png", categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Papá', rutaImagen: "assets/images/papa.png", categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Mamá', rutaImagen: "assets/images/mama.png", categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Amigos', rutaImagen: "assets/images/amigos.png", categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Quiero', icono: Icons.pan_tool, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Sí', icono: Icons.check_circle, categoria: CategoriaCAA.social),
      Pictograma(palabra: 'No', icono: Icons.cancel, categoria: CategoriaCAA.social),
    ];
  }

  // --- CARPETAS DE CONTEXTO ---
  static List<CarpetaCAA> obtenerCarpetas() {
    return [
      // CARPETA 1: SOCIAL Y SALUDOS
      CarpetaCAA(
        nombre: 'Saludos',
        icono: Icons.waving_hand_rounded,
        colorFondo: const Color(0xFFF9A8D4),
        esProOnly: false,
        pictogramas: [
          Pictograma(palabra: 'Hola', icono: Icons.waving_hand, categoria: CategoriaCAA.social),
          Pictograma(palabra: 'Adiós', icono: Icons.directions_run, categoria: CategoriaCAA.social),
          Pictograma(palabra: 'Mi nombre es', icono: Icons.badge, categoria: CategoriaCAA.social),
          Pictograma(palabra: '¿Cómo estás?', icono: Icons.forum, categoria: CategoriaCAA.social),
          Pictograma(palabra: 'Bien', icono: Icons.thumb_up, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'Mal', icono: Icons.thumb_down, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'Por favor', icono: Icons.volunteer_activism, categoria: CategoriaCAA.social),
          Pictograma(palabra: 'Gracias', icono: Icons.handshake, categoria: CategoriaCAA.social),
          Pictograma(palabra: 'Sí', icono: Icons.check_circle, categoria: CategoriaCAA.social),
          Pictograma(palabra: 'No', icono: Icons.cancel, categoria: CategoriaCAA.social),
        ],
      ),

      // CARPETA 2: NECESIDADES BÁSICAS
      CarpetaCAA(
        nombre: 'Necesidades',
        icono: Icons.notification_important_rounded,
        colorFondo: const Color(0xFFFEF08A),
        esProOnly: false,
        pictogramas: [
          Pictograma(palabra: 'Ayuda', icono: Icons.support, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Quiero ir al baño', icono: Icons.wc, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Tengo hambre', icono: Icons.restaurant, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Tengo sed', icono: Icons.local_drink, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Tengo sueño', icono: Icons.bed, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Necesito un descanso', icono: Icons.weekend, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Más', icono: Icons.add_circle, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'Ya está / Terminé', icono: Icons.done_all, categoria: CategoriaCAA.social),
          Pictograma(palabra: 'Pausa', icono: Icons.pause_circle, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'No quiero', icono: Icons.do_not_disturb, categoria: CategoriaCAA.accion),
        ],
      ),

      // CARPETA 3: SALUD Y EMOCIONES
      CarpetaCAA(
        nombre: 'Salud y Emoción',
        icono: Icons.favorite_rounded,
        colorFondo: const Color(0xFF93C5FD),
        esProOnly: false,
        pictogramas: [
          Pictograma(palabra: 'Me siento', icono: Icons.self_improvement, categoria: CategoriaCAA.social),
          Pictograma(palabra: 'Feliz', icono: Icons.sentiment_very_satisfied, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'Triste', icono: Icons.sentiment_very_dissatisfied, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'Asustado', icono: Icons.sentiment_dissatisfied, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'Enojado', icono: Icons.mood_bad, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'Me duele', icono: Icons.healing, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'La cabeza', icono: Icons.face, categoria: CategoriaCAA.objeto),
          Pictograma(palabra: 'El estómago', icono: Icons.coronavirus, categoria: CategoriaCAA.objeto), 
          Pictograma(palabra: 'Medicina', icono: Icons.medication, categoria: CategoriaCAA.objeto),
          Pictograma(palabra: 'Necesito un abrazo', icono: Icons.diversity_1, categoria: CategoriaCAA.social),
        ],
      ),

      // CARPETA 4: PREGUNTAS
      CarpetaCAA(
        nombre: 'Preguntas',
        icono: Icons.question_mark_rounded,
        colorFondo: const Color(0xFFD8B4E2),
        esProOnly: false,
        pictogramas: [
          Pictograma(palabra: '¿Qué?', icono: Icons.help_outline, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: '¿Quién?', icono: Icons.person_search, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: '¿Dónde?', icono: Icons.location_on, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: '¿Cuándo?', icono: Icons.event, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'No entiendo', icono: Icons.psychology_alt, categoria: CategoriaCAA.social),
          Pictograma(palabra: 'Repite, por favor', icono: Icons.replay, categoria: CategoriaCAA.social),
          Pictograma(palabra: 'Mira esto', icono: Icons.visibility, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Te toca a ti', icono: Icons.switch_account, categoria: CategoriaCAA.social),
          Pictograma(palabra: 'Me toca a mí', icono: Icons.pan_tool, categoria: CategoriaCAA.social),
        ],
      ),

      // CARPETA 5: COMIDA (PRO)
      CarpetaCAA(
        nombre: 'Comida',
        icono: Icons.fastfood_rounded,
        colorFondo: const Color(0xFFFDBA74),
        esProOnly: true,
        pictogramas: [
          Pictograma(palabra: 'Quiero comer', icono: Icons.restaurant, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Quiero beber', icono: Icons.local_drink, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Agua', icono: Icons.water_drop, categoria: CategoriaCAA.alimento),
          Pictograma(palabra: 'Jugo', icono: Icons.emoji_food_beverage, categoria: CategoriaCAA.alimento),
          Pictograma(palabra: 'Leche', icono: Icons.liquor, categoria: CategoriaCAA.alimento),
          Pictograma(palabra: 'Pan', icono: Icons.bakery_dining, categoria: CategoriaCAA.alimento),
          Pictograma(palabra: 'Fruta', icono: Icons.apple, categoria: CategoriaCAA.alimento),
          Pictograma(palabra: 'Comida', icono: Icons.restaurant_menu, categoria: CategoriaCAA.alimento),
          Pictograma(palabra: 'Está rico', icono: Icons.thumb_up, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'No me gusta', icono: Icons.thumb_down, categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'Estoy lleno', icono: Icons.battery_full, categoria: CategoriaCAA.descriptivo),
        ],
      ),

      // CARPETA 6: LUGARES Y OCIO (PRO)
      CarpetaCAA(
        nombre: 'Lugares y Ocio',
        icono: Icons.park_rounded,
        colorFondo: const Color(0xFF86EFAC),
        esProOnly: true,
        pictogramas: [
          Pictograma(palabra: 'Quiero ir a', icono: Icons.directions_walk, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'La casa', icono: Icons.home, categoria: CategoriaCAA.objeto),
          Pictograma(palabra: 'La escuela', icono: Icons.school, categoria: CategoriaCAA.objeto),
          Pictograma(palabra: 'El parque', icono: Icons.park, categoria: CategoriaCAA.objeto),
          Pictograma(palabra: 'El doctor', icono: Icons.medical_services, categoria: CategoriaCAA.objeto),
          Pictograma(palabra: 'Jugar', icono: Icons.sports_esports, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Ver televisión', icono: Icons.tv, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Escuchar música', icono: Icons.headphones, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Dibujar', icono: Icons.brush, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Con mis amigos', icono: Icons.groups, categoria: CategoriaCAA.persona),
        ],
      ),

      // CARPETA 7: ACCIONES LIBRES (PRO)
      CarpetaCAA(
        nombre: 'Acciones',
        rutaImagen: "assets/images/acciones.png",
        colorFondo: const Color(0xFF86EFAC),
        esProOnly: true,
        pictogramas: [
          Pictograma(palabra: 'Yo', icono: Icons.person, categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'Tú', icono: Icons.person_outline, categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'Hacer', icono: Icons.build, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Tener', icono: Icons.inventory_2, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Poner', icono: Icons.move_down, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Dar', icono: Icons.volunteer_activism, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Tomar', icono: Icons.back_hand, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Buscar', icono: Icons.search, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Esperar', icono: Icons.hourglass_empty, categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Parar', icono: Icons.front_hand, categoria: CategoriaCAA.accion),
        ],
      ),
    ];
  }
}