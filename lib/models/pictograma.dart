import 'package:flutter/material.dart';

// 1. EL ENUMERADOR (La Clave Fitzgerald - Tonos Pastel Modernos)
enum CategoriaCAA {
  persona(Color(0xFFFEF08A)),     // Amarillo suave (Sujetos)
  accion(Color(0xFF86EFAC)),      // Verde menta (Verbos)
  alimento(Color(0xFFFDBA74)),    // Naranja melocotón (Comida/Bebida)
  objeto(Color(0xFFFDBA74)),      // Naranja melocotón (Cosas inertes)
  social(Color(0xFFF9A8D4)),      // Rosa chicle (Interacción social/cortesía)
  descriptivo(Color(0xFF93C5FD)); // Azul cielo (Adjetivos, tiempos, preguntas)

  final Color colorFondo;
  const CategoriaCAA(this.colorFondo);
}

// 2. EL MODELO
class Pictograma {
  final String palabra;
  final IconData icono; 
  final CategoriaCAA categoria;

  Pictograma({
    required this.palabra,
    required this.icono,
    required this.categoria,
  });

  Color get colorFondo => categoria.colorFondo;
}

// 3. LA SÚPER BASE DE DATOS (Las 80 palabras con iconos)
class RepositorioVocabulario {
  static List<Pictograma> obtenerVocabularioBase() {
    return [
      // --- PERSONAS / PRONOMBRES (Amarillo) ---
      Pictograma(palabra: 'Yo', icono: Icons.person, categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Tú', icono: Icons.person_outline, categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Él', icono: Icons.boy, categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Ella', icono: Icons.girl, categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Nosotros', icono: Icons.groups, categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Mamá', icono: Icons.pregnant_woman, categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Papá', icono: Icons.man, categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Amigos', icono: Icons.group, categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Maestra', icono: Icons.school, categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Educadora', icono: Icons.local_library, categoria: CategoriaCAA.persona),
      Pictograma(palabra: 'Monitora', icono: Icons.assignment_ind, categoria: CategoriaCAA.persona),
      
      // --- ACCIONES / VERBOS (Verde) ---
      Pictograma(palabra: 'Quiero', icono: Icons.pan_tool, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'No quiero', icono: Icons.do_not_disturb, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Comer', icono: Icons.restaurant, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Beber', icono: Icons.local_drink, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Jugar', icono: Icons.sports_esports, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Bailar', icono: Icons.music_note, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Dormir', icono: Icons.bed, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Descansar', icono: Icons.weekend, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Ir al baño', icono: Icons.wc, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Hacer pipí', icono: Icons.water_drop, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Hacer', icono: Icons.build, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Dar', icono: Icons.volunteer_activism, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Tomar', icono: Icons.back_hand, categoria: CategoriaCAA.accion), 
      Pictograma(palabra: 'Poner', icono: Icons.move_down, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Parar', icono: Icons.front_hand, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Tener', icono: Icons.inventory_2, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Molestar', icono: Icons.announcement, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Pegar', icono: Icons.sports_martial_arts, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Ir', icono: Icons.directions_walk, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Estar', icono: Icons.place, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Ver', icono: Icons.visibility, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Gustar', icono: Icons.favorite, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Esperar', icono: Icons.hourglass_empty, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Ser', icono: Icons.accessibility, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Escuchar', icono: Icons.hearing, categoria: CategoriaCAA.accion),
      Pictograma(palabra: 'Ayuda', icono: Icons.support, categoria: CategoriaCAA.accion),
      
      // --- ALIMENTOS Y BEBIDAS (Naranja) ---
      Pictograma(palabra: 'Agua', icono: Icons.water_drop, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Leche', icono: Icons.liquor, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Jugo', icono: Icons.emoji_food_beverage, categoria: CategoriaCAA.alimento),      
      Pictograma(palabra: 'Batido', icono: Icons.blender, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Refresco', icono: Icons.local_bar, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Café', icono: Icons.coffee, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Pan', icono: Icons.bakery_dining, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Fruta', icono: Icons.apple, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Manzana', icono: Icons.apple, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Pera', icono: Icons.eco, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Verduras', icono: Icons.grass, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Ensalada', icono: Icons.local_dining, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Carne', icono: Icons.set_meal, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Pollo', icono: Icons.egg, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Pescado', icono: Icons.phishing, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Comida', icono: Icons.restaurant_menu, categoria: CategoriaCAA.alimento),
      Pictograma(palabra: 'Postre', icono: Icons.cake, categoria: CategoriaCAA.alimento),
      
      // --- OBJETOS Y LUGARES (Naranja) ---
      Pictograma(palabra: 'Televisión', icono: Icons.tv, categoria: CategoriaCAA.objeto),
      Pictograma(palabra: 'Pelota', icono: Icons.sports_soccer, categoria: CategoriaCAA.objeto),
      Pictograma(palabra: 'Muñeca', icono: Icons.child_care, categoria: CategoriaCAA.objeto),
      Pictograma(palabra: 'Puzzle', icono: Icons.extension, categoria: CategoriaCAA.objeto),
      Pictograma(palabra: 'Consola', icono: Icons.videogame_asset, categoria: CategoriaCAA.objeto),
      Pictograma(palabra: 'Parque', icono: Icons.park, categoria: CategoriaCAA.objeto),
      Pictograma(palabra: 'Plato', icono: Icons.radio_button_unchecked, categoria: CategoriaCAA.objeto),
      Pictograma(palabra: 'Lavamanos', icono: Icons.wash, categoria: CategoriaCAA.objeto),
      Pictograma(palabra: 'Vaso', icono: Icons.local_drink, categoria: CategoriaCAA.objeto),
      Pictograma(palabra: 'Tenedor', icono: Icons.restaurant, categoria: CategoriaCAA.objeto),
      Pictograma(palabra: 'Cuchara', icono: Icons.soup_kitchen, categoria: CategoriaCAA.objeto),
      Pictograma(palabra: 'Cuchillo', icono: Icons.horizontal_rule, categoria: CategoriaCAA.objeto),
      
      // --- SOCIAL / CORTESÍA (Rosa) ---
      Pictograma(palabra: 'Hola', icono: Icons.waving_hand, categoria: CategoriaCAA.social),
      Pictograma(palabra: 'Adiós', icono: Icons.waving_hand, categoria: CategoriaCAA.social),
      Pictograma(palabra: 'Gracias', icono: Icons.handshake, categoria: CategoriaCAA.social),
      Pictograma(palabra: 'Sí', icono: Icons.check_circle, categoria: CategoriaCAA.social),
      Pictograma(palabra: 'No', icono: Icons.cancel, categoria: CategoriaCAA.social),
      Pictograma(palabra: 'No lo sé', icono: Icons.question_mark, categoria: CategoriaCAA.social),
      Pictograma(palabra: 'Ya está', icono: Icons.done_all, categoria: CategoriaCAA.social),
      
      // --- DESCRIPTIVOS Y OTROS (Azul) ---
      Pictograma(palabra: 'Feliz', icono: Icons.sentiment_very_satisfied, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Triste', icono: Icons.sentiment_very_dissatisfied, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Enfadado', icono: Icons.mood_bad, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Duele', icono: Icons.local_hospital, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Bien', icono: Icons.thumb_up, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Mal', icono: Icons.thumb_down, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Más', icono: Icons.add_circle, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Nada', icono: Icons.block, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Igual a', icono: Icons.drag_handle, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Ahora', icono: Icons.access_time, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Después', icono: Icons.update, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Aquí', icono: Icons.place, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Cuando', icono: Icons.event, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Dónde', icono: Icons.location_on, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Quién', icono: Icons.person_search, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Con', icono: Icons.link, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Un', icono: Icons.looks_one, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Y', icono: Icons.add, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Este', icono: Icons.touch_app, categoria: CategoriaCAA.descriptivo),
      Pictograma(palabra: 'Ese', icono: Icons.arrow_forward, categoria: CategoriaCAA.descriptivo),
    ];
  }
}