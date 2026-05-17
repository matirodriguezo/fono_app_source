import 'package:flutter_test/flutter_test.dart';
import 'package:fono_app/models/pictograma.dart';

void main() {
  test('CategoriaCAA values are accessible', () {
    expect(CategoriaCAA.values, isNotEmpty);
    expect(CategoriaCAA.accion.colorFondo, isNotNull);
  });

  test('RepositorioVocabulario carga datos sin errores', () {
    final palabras = RepositorioVocabulario.obtenerPalabrasFrecuentes();
    expect(palabras, isNotEmpty);

    final carpetas = RepositorioVocabulario.obtenerCarpetas();
    expect(carpetas, isNotEmpty);
  });

  test('Pictograma se crea correctamente', () {
    final pic = Pictograma(
      palabra: 'Test',
      rutaImagen: 'assets/test.png',
      categoria: CategoriaCAA.emocion,
    );
    expect(pic.palabra, 'Test');
    expect(pic.categoria, CategoriaCAA.emocion);
  });
}
