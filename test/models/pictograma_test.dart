import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fono_app/models/pictograma.dart';

void main() {
  group('CategoriaCAA', () {
    test('tiene 8 categorías', () {
      expect(CategoriaCAA.values.length, 8);
    });

    test('cada categoría tiene un color de fondo', () {
      for (final cat in CategoriaCAA.values) {
        expect(cat.colorFondo, isA<Color>());
      }
    });
  });

  group('Pictograma', () {
    test('se crea con todos los campos', () {
      final pic = Pictograma(
        palabra: 'Hola',
        rutaImagen: 'assets/images/test.png',
        categoria: CategoriaCAA.saludos,
      );
      expect(pic.palabra, 'Hola');
      expect(pic.rutaImagen, 'assets/images/test.png');
      expect(pic.colorFondo, CategoriaCAA.saludos.colorFondo);
    });

    test('se crea sin rutaImagen usando icono', () {
      final pic = Pictograma(
        palabra: 'Ayuda',
        icono: Icons.support,
        categoria: CategoriaCAA.accion,
      );
      expect(pic.palabra, 'Ayuda');
      expect(pic.icono, Icons.support);
      expect(pic.rutaImagen, isNull);
    });
  });

  group('RepositorioVocabulario', () {
    group('obtenerPalabrasFrecuentes', () {
      test('devuelve 14 pictogramas', () {
        final palabras = RepositorioVocabulario.obtenerPalabrasFrecuentes();
        expect(palabras.length, 14);
      });

      test('incluye pronombres básicos', () {
        final palabras = RepositorioVocabulario.obtenerPalabrasFrecuentes();
        final textos = palabras.map((p) => p.palabra).toSet();
        expect(textos, containsAll(['Yo', 'Tú', 'Él', 'Ella']));
      });

      test('incluye verbos núcleo', () {
        final palabras = RepositorioVocabulario.obtenerPalabrasFrecuentes();
        final textos = palabras.map((p) => p.palabra).toSet();
        expect(textos, containsAll(['QUIERO', 'NO QUIERO']));
      });

      test('incluye afirmación/negación', () {
        final palabras = RepositorioVocabulario.obtenerPalabrasFrecuentes();
        final textos = palabras.map((p) => p.palabra).toSet();
        expect(textos, containsAll(['Sí', 'No']));
      });

      test('cada pictograma tiene palabra no vacía', () {
        final palabras = RepositorioVocabulario.obtenerPalabrasFrecuentes();
        for (final pic in palabras) {
          expect(pic.palabra.trim().isNotEmpty, isTrue);
        }
      });
    });

    group('obtenerCarpetas', () {
      test('devuelve 8 carpetas', () {
        final carpetas = RepositorioVocabulario.obtenerCarpetas();
        expect(carpetas.length, 8);
      });

      test('tiene nombres esperados', () {
        final carpetas = RepositorioVocabulario.obtenerCarpetas();
        final nombres = carpetas.map((c) => c.nombre).toSet();
        expect(nombres, containsAll([
          'Saludos', 'Personas', 'Acciones', 'Necesidades',
          'Salud y Emoción', 'Preguntas', 'Alimentos', 'Lugares y Ocio',
        ]));
      });

      test('cada carpeta tiene pictogramas', () {
        final carpetas = RepositorioVocabulario.obtenerCarpetas();
        for (final carpeta in carpetas) {
          expect(carpeta.pictogramas.isNotEmpty, isTrue,
              reason: 'La carpeta ${carpeta.nombre} no tiene pictogramas');
        }
      });

      test('cada pictograma dentro de carpetas tiene palabra', () {
        final carpetas = RepositorioVocabulario.obtenerCarpetas();
        for (final carpeta in carpetas) {
          for (final pic in carpeta.pictogramas) {
            expect(pic.palabra.trim().isNotEmpty, isTrue,
                reason: 'Pictograma vacío en ${carpeta.nombre}');
          }
        }
      });

      test('cada pictograma tiene rutaImagen o icono', () {
        final carpetas = RepositorioVocabulario.obtenerCarpetas();
        for (final carpeta in carpetas) {
          for (final pic in carpeta.pictogramas) {
            final tieneImagen = pic.rutaImagen != null;
            final tieneIcono = pic.icono != null;
            expect(tieneImagen || tieneIcono, isTrue,
                reason: '${pic.palabra} en ${carpeta.nombre} no tiene ni imagen ni icono');
          }
        }
      });

      test('carpetas PRO están marcadas correctamente', () {
        final carpetas = RepositorioVocabulario.obtenerCarpetas();
        for (final carpeta in carpetas) {
          if (carpeta.nombre == 'Acciones' ||
              carpeta.nombre == 'Alimentos' ||
              carpeta.nombre == 'Lugares y Ocio') {
            expect(carpeta.esProOnly, isTrue,
                reason: '${carpeta.nombre} debería ser PRO');
          }
        }
      });
    });

    group('vocabulario completo', () {
      test('no hay palabras duplicadas entre carpetas', () {
        final carpetas = RepositorioVocabulario.obtenerCarpetas();
        final todas = <String>[];
        for (final c in carpetas) {
          todas.addAll(c.pictogramas.map((p) => p.palabra));
        }
        final duplicados = todas
            .groupBy((w) => w)
            .entries
            .where((e) => e.value.length > 1)
            .map((e) => e.key)
            .toList();
        expect(duplicados, isEmpty,
            reason: 'Palabras duplicadas encontradas: $duplicados');
      });
    });
  });
}

extension _GroupBy<K, V> on Iterable<V> {
  Map<K, List<V>> groupBy(K Function(V) keyFn) {
    final map = <K, List<V>>{};
    for (final v in this) {
      final k = keyFn(v);
      map.putIfAbsent(k, () => []).add(v);
    }
    return map;
  }
}
