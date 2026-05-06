import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/domain/round/category_distribution_suggestion.dart';

void main() {
  test('distribui 6 brinquedos por categorias principais', () {
    final suggestion = buildDistribution(6);

    expect(suggestion.total, 6);
    expect(suggestion.distribution['Coordena\u00E7\u00E3o'], 2);
    expect(suggestion.distribution['Constru\u00E7\u00E3o'], 1);
    expect(suggestion.distribution['Faz de conta'], 1);
    expect(suggestion.distribution['Livros'], 1);
    expect(suggestion.distribution['Artes'], 1);
  });

  test('distribui 8 brinquedos com reforco em faz de conta', () {
    final suggestion = buildDistribution(8);

    expect(suggestion.total, 8);
    expect(suggestion.distribution['Coordena\u00E7\u00E3o'], 2);
    expect(suggestion.distribution['Constru\u00E7\u00E3o'], 2);
    expect(suggestion.distribution['Faz de conta'], 2);
    expect(suggestion.distribution['Livros'], 1);
    expect(suggestion.distribution['Artes'], 1);
  });

  test('distribui 10 brinquedos incluindo movimento e musica', () {
    final suggestion = buildDistribution(10);

    expect(suggestion.total, 10);
    expect(suggestion.distribution['Coordena\u00E7\u00E3o'], 2);
    expect(suggestion.distribution['Constru\u00E7\u00E3o'], 2);
    expect(suggestion.distribution['Faz de conta'], 2);
    expect(suggestion.distribution['Livros'], 1);
    expect(suggestion.distribution['Movimento'], 1);
    expect(suggestion.distribution['M\u00FAsica'], 1);
    expect(suggestion.distribution['Artes'], 1);
  });
}
