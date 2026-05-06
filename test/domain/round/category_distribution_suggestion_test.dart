import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/domain/round/category_distribution_suggestion.dart';

void main() {
  test('distribui 6 brinquedos entre categorias existentes', () {
    final suggestion = buildDistribution(6, const [
      'Montagem',
      'Livros',
      'Faz de conta',
    ]);

    expect(suggestion.total, 6);
    expect(suggestion.distribution, {
      'Montagem': 2,
      'Livros': 2,
      'Faz de conta': 2,
    });
    expect(_sum(suggestion.distribution), 6);
  });

  test('distribui 7 brinquedos de forma equilibrada', () {
    final suggestion = buildDistribution(7, const [
      'Montagem',
      'Livros',
      'Faz de conta',
      'Artes',
    ]);

    expect(suggestion.total, 7);
    expect(suggestion.distribution, {
      'Montagem': 2,
      'Livros': 2,
      'Faz de conta': 2,
      'Artes': 1,
    });
    expect(_sum(suggestion.distribution), 7);
  });

  test('distribui 8 brinquedos sem depender de nomes fixos', () {
    final suggestion = buildDistribution(8, const [
      'Veiculos',
      'Bonecos',
      'Banho',
      'Outros',
    ]);

    expect(suggestion.total, 8);
    expect(suggestion.distribution, {
      'Veiculos': 2,
      'Bonecos': 2,
      'Banho': 2,
      'Outros': 2,
    });
    expect(_sum(suggestion.distribution), 8);
  });

  test('limita sugestao generica a 8 brinquedos', () {
    final suggestion = buildDistribution(12, const [
      'Montagem',
      'Livros',
      'Faz de conta',
      'Artes',
    ]);

    expect(suggestion.total, 8);
    expect(_sum(suggestion.distribution), 8);
  });
}

int _sum(Map<String, int> distribution) {
  return distribution.values.fold<int>(0, (sum, value) => sum + value);
}
