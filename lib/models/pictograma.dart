import 'package:flutter/material.dart';

// 1. EL ENUMERADOR (La Clave Fitzgerald - Tonos Pastel Modernos)
enum CategoriaCAA {

  accion(Color.fromARGB(255, 251, 111, 239)),
  emocion(Color(0xFFF9A8D4)),
  necesidad(Color(0xFFFEF08A)),
  personas(Color.fromARGB(174, 255, 238, 0)),
  afYnegativa(Color.fromARGB(255, 105, 248, 136)),
  saludos(Color.fromARGB(255, 113, 202, 243)),
  pronombre(Color.fromARGB(249, 253, 210, 116)),     // Amarillo suave (Sujetos y pronombres)
  
        // Amarillo suave (Sujetos y pronombres)
       // Verde menta/Rosa (Verbos y acciones)
  alimento(Color(0xFFFDBA74)),                     // Naranja melocotón (Comida/Bebida/Objetos)
  objeto(Color(0xFFFDBA74)),     
                    // Naranja melocotón (Cosas inertes/Lugares)
                         // Rosa chicle (Interacción social/cortesía/frases hechas)
    
  descriptivo(Color(0xFF93C5FD));                  // Azul cielo (Adjetivos, emociones, tiempos, preguntas)

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
      // GRUPO 1: PRONOMBRES (Sujetos)
      Pictograma(palabra: 'Yo', rutaImagen: "assets/images/INICIO/YO.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Tú', rutaImagen: "assets/images/INICIO/TU.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Él', rutaImagen: "assets/images/INICIO/EL.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Ella', rutaImagen: "assets/images/INICIO/ELLA.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Ellas', rutaImagen: "assets/images/INICIO/ELLAS.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Ellos', rutaImagen: "assets/images/INICIO/ELLOS.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Nosotros', rutaImagen: "assets/images/INICIO/NOSOTROS.png", categoria: CategoriaCAA.pronombre),
      Pictograma(palabra: 'Ustedes', rutaImagen: "assets/images/INICIO/USTEDES.png", categoria: CategoriaCAA.pronombre),
      
      // GRUPO 2: ACCIONES / VERBOS
      Pictograma(palabra: 'QUIERO', rutaImagen: "assets/images/INICIO/QUIERO.png", categoria: CategoriaCAA.afYnegativa),
      Pictograma(palabra: 'NO QUIERO', rutaImagen: "assets/images/INICIO/NO_QUIERO.png", categoria: CategoriaCAA.afYnegativa),
      
      // GRUPO 3: SOCIAL / AFIRMACIÓN
      Pictograma(palabra: 'Sí', rutaImagen: "assets/images/INICIO/SI.png", categoria: CategoriaCAA.afYnegativa),
      Pictograma(palabra: 'No', rutaImagen: "assets/images/INICIO/NO.png", categoria: CategoriaCAA.afYnegativa),
      
      // GRUPO 4: DESCRIPTIVOS / ADJETIVOS
      Pictograma(palabra: 'Bien', rutaImagen: "assets/images/INICIO/BIEN.png", categoria: CategoriaCAA.afYnegativa),
      Pictograma(palabra: 'Mal', rutaImagen: "assets/images/INICIO/MAL.png", categoria: CategoriaCAA.afYnegativa),
    ];
  }

  // --- CARPETAS DE CONTEXTO ---
  static List<CarpetaCAA> obtenerCarpetas() {
    return [
      CarpetaCAA(
        nombre: 'Saludos',
        rutaImagen: "assets/images/SALUDOS/saludos.png",
        colorFondo: const Color.fromARGB(255, 113, 187, 248),
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
          Pictograma(palabra: 'Mucho Gusto', rutaImagen: "assets/images/SALUDOS/MUCHO_GUSTO.png", categoria: CategoriaCAA.saludos),        
        ],
      ),

      CarpetaCAA(
        nombre: 'Personas',
        rutaImagen: "assets/images/PERSONAS/PERSONAS.png",
        colorFondo: const Color.fromARGB(255, 250, 186, 68),
        esProOnly: false,
        pictogramas: [
          Pictograma(palabra: 'MAMÁ', rutaImagen: "assets/images/PERSONAS/MAMA.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'PAPÁ', rutaImagen: "assets/images/PERSONAS/PAPA.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'ABUELA', rutaImagen: "assets/images/PERSONAS/ABUELA.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'ABUELO', rutaImagen: "assets/images/PERSONAS/ABUELO.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'HERMANA', rutaImagen: "assets/images/PERSONAS/HERMANA.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'HERMANO', rutaImagen: "assets/images/PERSONAS/HERMANO.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'TÍO', rutaImagen: "assets/images/PERSONAS/TIO.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'TÍA', rutaImagen: "assets/images/PERSONAS/TIA.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'PRIMO', rutaImagen: "assets/images/PERSONAS/PRIMO.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'PRIMA', rutaImagen: "assets/images/PERSONAS/PRIMA.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'AMIGO', rutaImagen: "assets/images/PERSONAS/AMIGO.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'AMIGA', rutaImagen: "assets/images/PERSONAS/AMIGA.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'AMIGOS', rutaImagen: "assets/images/PERSONAS/AMIGOS.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'PROFESORA', rutaImagen: "assets/images/PERSONAS/PROFESORA.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'PROFESOR', rutaImagen: "assets/images/PERSONAS/PROFESOR.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'DOCTOR', rutaImagen: "assets/images/PERSONAS/DOCTOR.png", categoria: CategoriaCAA.personas),
          Pictograma(palabra: 'ENFERMERA', rutaImagen: "assets/images/PERSONAS/ENFERMERA.png", categoria: CategoriaCAA.personas),
        ],
      ),

       CarpetaCAA(
        nombre: 'Acciones',
        rutaImagen: "assets/images/ACCIONES/acciones.png",
        colorFondo: const Color.fromARGB(255, 252, 141, 237),
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
          Pictograma(palabra: 'GUARDAR', rutaImagen: "assets/images/ACCIONES/GUARDAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'ESCRIBIR', rutaImagen: "assets/images/ACCIONES/ESCRIBIR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'JUGAR', rutaImagen: "assets/images/ACCIONES/JUGAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'MAS', rutaImagen: "assets/images/ACCIONES/MAS.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'PARARSE', rutaImagen: "assets/images/ACCIONES/PARARSE.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'TRABAJAR', rutaImagen: "assets/images/ACCIONES/TRABAJAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'VER', rutaImagen: "assets/images/ACCIONES/VER.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'VESTIR', rutaImagen: "assets/images/ACCIONES/VESTIR.png", categoria: CategoriaCAA.accion), 
          Pictograma(palabra: 'PINTAR', rutaImagen: "assets/images/ACCIONES/PINTAR.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'SENTARSE', rutaImagen: "assets/images/ACCIONES/SENTARSE.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'VER', rutaImagen: "assets/images/ACCIONES/VER.png", categoria: CategoriaCAA.accion),
               
        ],
      ),

      CarpetaCAA(
        nombre: 'Necesidades',
        rutaImagen: "assets/images/NECESIDAD/NECESIDAD.png",
        colorFondo: const Color(0xFFFEF08A),
        esProOnly: false,
        pictogramas: [
          Pictograma(palabra: 'Ayuda', rutaImagen: "assets/images/NECESIDAD/AYUDA.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Quiero ir al baño', rutaImagen: "assets/images/NECESIDAD/IR_AL_BAÑO.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Tengo hambre', rutaImagen: "assets/images/NECESIDAD/TENGO_HAMBRE.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Tengo sed', rutaImagen: "assets/images/NECESIDAD/TENGO_SED.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Tengo sueño', rutaImagen: "assets/images/NECESIDAD/TENGO_SUEÑO.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Necesito un descanso', rutaImagen: "assets/images/NECESIDAD/NECESITO_UN_DESCANSO.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Más', rutaImagen: "assets/images/NECESIDAD/MÁS.png", categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'Ya está / Terminé', rutaImagen: "assets/images/NECESIDAD/YA_ESTÁ_TERMINÉ.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Pausa', rutaImagen: "assets/images/NECESIDAD/PAUSA.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'No quiero', rutaImagen: "assets/images/NECESIDAD/NO_QUIERO.png", categoria: CategoriaCAA.accion),
        ],
      ),

      CarpetaCAA(
        nombre: 'Emociones',
        rutaImagen: "assets/images/EMOCIONES/EMOCIONES.png",
        colorFondo: const Color.fromARGB(255, 191, 130, 241),
        esProOnly: false,
        pictogramas: [
          Pictograma(palabra: 'Me siento', rutaImagen: "assets/images/EMOCIONES/ME_SIENTO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Feliz', rutaImagen: "assets/images/EMOCIONES/FELIZ.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Triste', rutaImagen: "assets/images/EMOCIONES/TRISTE.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Asustado', rutaImagen: "assets/images/EMOCIONES/ASUSTADO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Enojado', rutaImagen: "assets/images/EMOCIONES/ENOJADO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Cansado', rutaImagen: "assets/images/EMOCIONES/CANSADO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Aburrido', rutaImagen: "assets/images/EMOCIONES/ABURRIDO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Emocionado', rutaImagen: "assets/images/EMOCIONES/EMOCIONADO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Preocupado', rutaImagen: "assets/images/EMOCIONES/PREOCUPADO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Asco', rutaImagen: "assets/images/EMOCIONES/ASCO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Avergonzado', rutaImagen: "assets/images/EMOCIONES/AVERGONZADO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Confuso', rutaImagen: "assets/images/EMOCIONES/CONFUSO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Distraido', rutaImagen: "assets/images/EMOCIONES/DISTRAIDO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Enamorado', rutaImagen: "assets/images/EMOCIONES/ENAMORADO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Enfermo', rutaImagen: "assets/images/EMOCIONES/ENFERMO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Sorprendido', rutaImagen: "assets/images/EMOCIONES/SORPRENDIDO.png", categoria: CategoriaCAA.emocion),
        ],
      ),

      CarpetaCAA(
        nombre: 'Preguntas',
        icono: Icons.question_mark_rounded,
        colorFondo: const Color(0xFFD8B4E2),
        esProOnly: false,
        pictogramas: [
          Pictograma(palabra: '¿Qué?', rutaImagen: "assets/images/PREGUNTAS/QUE.png", categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: '¿Quién?', rutaImagen: "assets/images/PREGUNTAS/QUIEN.png", categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: '¿Dónde?', rutaImagen: "assets/images/PREGUNTAS/DONDE.png", categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: '¿Cuándo?', rutaImagen: "assets/images/PREGUNTAS/CUANDO.png", categoria: CategoriaCAA.descriptivo),
          Pictograma(palabra: 'No entiendo', rutaImagen: "assets/images/PREGUNTAS/NO_ENTIENDO.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Repite, por favor', rutaImagen: "assets/images/PREGUNTAS/REPITE_POR_FAVOR.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Mira esto', rutaImagen: "assets/images/PREGUNTAS/MIRA_ESTO.png", categoria: CategoriaCAA.accion),
          Pictograma(palabra: 'Te toca a ti', rutaImagen: "assets/images/PREGUNTAS/TE_TOCA_A_TI.png", categoria: CategoriaCAA.emocion),
          Pictograma(palabra: 'Me toca a mí', rutaImagen: "assets/images/PREGUNTAS/ME_TOCA_A_MÍ.png", categoria: CategoriaCAA.emocion),
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
          Pictograma(palabra: 'Con mis amigos', icono: Icons.groups, categoria: CategoriaCAA.personas),
        ],
      ),     
    ];
  }
}