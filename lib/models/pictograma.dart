import 'package:flutter/material.dart';

// 1. EL ENUMERADOR (La Clave Fitzgerald - Tonos Pastel Modernos)
enum CategoriaCAA {
  pronombre(Color.fromARGB(174, 255, 238, 0)),     // Amarillo suave (Sujetos y pronombres)
  persona(Color.fromARGB(174, 255, 238, 0)),     // Amarillo suave (Sujetos y pronombres)
  accion(Color.fromARGB(255, 251, 111, 239)),      // Verde menta (Verbos y acciones)
  alimento(Color(0xFFFDBA74)),    // Naranja melocotón (Comida/Bebida/Objetos)
  objeto(Color(0xFFFDBA74)),      // Naranja melocotón (Cosas inertes/Lugares)
  social(Color(0xFFF9A8D4)),      // Rosa chicle (Interacción social/cortesía/frases hechas)
  saludos(Color.fromARGB(255, 17, 0, 255)),  
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
      Pictograma(palabra: 'Yo', rutaImagen: "assets/images/INICIO/YO.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Tú', rutaImagen: "assets/images/INICIO/TU.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Él', rutaImagen: "assets/images/INICIO/EL.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Ella', rutaImagen: "assets/images/INICIO/ELLA.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Ellas', rutaImagen: "assets/images/INICIO/ELLAS.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Ellos', rutaImagen: "assets/images/INICIO/ELLOS.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Nosotros', rutaImagen: "assets/images/INICIO/NOSOTROS.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Ustedes', rutaImagen: "assets/images/INICIO/USTEDES.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Sí', rutaImagen: "assets/images/INICIO/SI.png", categoria: CategoriaCAA.social),
      Pictograma(palabra: 'No', rutaImagen: "assets/images/INICIO/NO.png", categoria: CategoriaCAA.social),
      Pictograma(palabra: 'Bien', rutaImagen: "assets/images/INICIO/BIEN.png", categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Mal', rutaImagen: "assets/images/INICIO/MAL.png", categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'YO QUIERO', rutaImagen: "assets/images/INICIO/YO_QUIERO.png", categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'YO NO QUIERO', rutaImagen: "assets/images/INICIO/YO_NO_QUIERO.png", categoria: CategoriaCAA.descriptivo),
    ];
  }

  // --- CARPETAS DE CONTEXTO ---
  static List<CarpetaCAA> obtenerCarpetas() {
    return [
      // CARPETA 1: SOCIAL Y SALUDOS
      CarpetaCAA(
        nombre: 'Saludos',
        rutaImagen: "assets/images/SALUDOS/saludos.png",
        colorFondo: const Color.fromARGB(255, 79, 66, 255),
        esProOnly: false,
        pictogramas: [
          Pictograma(palabra: 'Hola', rutaImagen: "assets/images/SALUDOS/HOLA.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Buenos Días', rutaImagen: "assets/images/SALUDOS/BUENOS_DIAS.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Buenas Tardes', rutaImagen: "assets/images/SALUDOS/BUENAS_TARDES.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Buenas Noches', rutaImagen: "assets/images/SALUDOS/BUENAS_NOCHES.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: '¿Cómo estás?', rutaImagen: "assets/images/SALUDOS/COMO_ESTAS.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Adiós', rutaImagen: "assets/images/SALUDOS/ADIOS.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Nos Vemos', rutaImagen: "assets/images/SALUDOS/NOS_VEMOS.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Hasta Pronto', rutaImagen: "assets/images/SALUDOS/HASTA_PRONTO.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Hasta Mañana', rutaImagen: "assets/images/SALUDOS/HASTA_MAÑANA.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Que Estes Bien', rutaImagen: "assets/images/SALUDOS/QUE_ESTES_BIEN.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Gusto en Verte', rutaImagen: "assets/images/SALUDOS/GUSTO_EN_VERTE.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Abrazo', rutaImagen: "assets/images/SALUDOS/ABRAZO.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Beso', rutaImagen: "assets/images/SALUDOS/BESO.png", categoria: CategoriaCAA.saludos),
          Pictograma(palabra: 'Mucho Gusto', rutaImagen: "assets/images/SALUDOS/MUCHO_GUSTO.png", categoria: CategoriaCAA.saludos),        ],
      ),

      CarpetaCAA(
        nombre: 'Personas',
        rutaImagen: "assets/images/PERSONAS/personas.png",
        colorFondo: const Color.fromARGB(255, 209, 248, 57),
        esProOnly: false,
        pictogramas: [
          Pictograma(palabra: 'MAMÁ', rutaImagen: "assets/images/PERSONAS/MAMA.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'PAPÁ', rutaImagen: "assets/images/PERSONAS/PAPA.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'ABUELA', rutaImagen: "assets/images/PERSONAS/ABUELA.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'ABUELO', rutaImagen: "assets/images/PERSONAS/ABUELO.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'HERMANA', rutaImagen: "assets/images/PERSONAS/HERMANA.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'HERMANO', rutaImagen: "assets/images/PERSONAS/HERMANO.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'TÍO', rutaImagen: "assets/images/PERSONAS/TIO.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'TÍA', rutaImagen: "assets/images/PERSONAS/TIA.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'PRIMO', rutaImagen: "assets/images/PERSONAS/PRIMO.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'PRIMA', rutaImagen: "assets/images/PERSONAS/PRIMA.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'AMIGO', rutaImagen: "assets/images/PERSONAS/AMIGO.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'AMIGA', rutaImagen: "assets/images/PERSONAS/AMIGA.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'AMIGOS', rutaImagen: "assets/images/PERSONAS/AMIGOS.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'MAESTRA', rutaImagen: "assets/images/PERSONAS/MAESTRA.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'MAESTRO', rutaImagen: "assets/images/PERSONAS/MAESTRO.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'DOCTOR', rutaImagen: "assets/images/PERSONAS/DOCTOR.png", categoria: CategoriaCAA.persona),
          Pictograma(palabra: 'ENFERMERA', rutaImagen: "assets/images/PERSONAS/ENFERMERA.png", categoria: CategoriaCAA.persona),
        ],
      ),

       CarpetaCAA(
        nombre: 'Acciones',
        rutaImagen: "assets/images/ACCIONES/acciones.png",
        colorFondo: const Color.fromARGB(255, 248, 25, 218),
        esProOnly: true,
        pictogramas: [
          Pictograma(palabra: 'Ir', rutaImagen: "assets/images/ACCIONES/IR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'ABRAZAR', rutaImagen: "assets/images/ACCIONES/ABRAZAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'BAILAR', rutaImagen: "assets/images/ACCIONES/BAILAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'BEBER', rutaImagen: "assets/images/ACCIONES/BEBER.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'BUSCAR', rutaImagen: "assets/images/ACCIONES/BUSCAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'COMER', rutaImagen: "assets/images/ACCIONES/COMER.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'DAR', rutaImagen: "assets/images/ACCIONES/DAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'DESCANSAR', rutaImagen: "assets/images/ACCIONES/DESCANSAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'DIBUJAR', rutaImagen: "assets/images/ACCIONES/DIBUJAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'DORMIR', rutaImagen: "assets/images/ACCIONES/DORMIR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'ESCUCHAR', rutaImagen: "assets/images/ACCIONES/ESCUCHAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'ESPERAR', rutaImagen: "assets/images/ACCIONES/ESPERAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'ESTAR', rutaImagen: "assets/images/ACCIONES/ESTAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'GUARDAR', rutaImagen: "assets/images/ACCIONES/GUARDAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'JUGAR', rutaImagen: "assets/images/ACCIONES/JUGAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'MAS', rutaImagen: "assets/images/ACCIONES/MAS.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'PARAR', rutaImagen: "assets/images/ACCIONES/PARAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'QUERER', rutaImagen: "assets/images/ACCIONES/QUERER.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'SER', rutaImagen: "assets/images/ACCIONES/SER.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'TRABAJAR', rutaImagen: "assets/images/ACCIONES/TRABAJAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'VER', rutaImagen: "assets/images/ACCIONES/VER.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'VESTIR', rutaImagen: "assets/images/ACCIONES/VESTIR.png", categoria: CategoriaCAA.accion),        ],
      ),

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

      CarpetaCAA(
        nombre: 'Alimentos',
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
    ];
  }
}