import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/domain/round/category_distribution_suggestion.dart';

void main() {
  test('distribui 6 brinquedos entre categorias existentes', () {
    final suggestion = buildDistribution(6, const [
      'Sentidos e Exploração',
      'Comunicação e Histórias',
      'Imaginação e Criatividade',
    ]);

    expect(suggestion.total, 6);
    expect(suggestion.distribution, {
      'Sentidos e Exploração': 2,
      'Comunicação e Histórias': 2,
      'Imaginação e Criatividade': 2,
    });
    expect(_sum(suggestion.distribution), 6);
  });

  test('distribui 7 brinquedos de forma equilibrada', () {
    final suggestion = buildDistribution(7, const [
      'Sentidos e Exploração',
      'Comunicação e Histórias',
      'Imaginação e Criatividade',
      'Mãos e Construção',
    ]);

    expect(suggestion.total, 7);
    expect(suggestion.distribution, {
      'Sentidos e Exploração': 2,
      'Comunicação e Histórias': 2,
      'Imaginação e Criatividade': 2,
      'Mãos e Construção': 1,
    });
    expect(_sum(suggestion.distribution), 7);
  });

  test('distribui 8 brinquedos sem depender de nomes fixos', () {
    final suggestion = buildDistribution(8, const [
      'Sentidos e Exploração',
      'Mãos e Construção',
      'Corpo e Respiração',
      'Comunicação e Histórias',
    ]);

    expect(suggestion.total, 8);
    expect(suggestion.distribution, {
      'Sentidos e Exploração': 2,
      'Mãos e Construção': 2,
      'Corpo e Respiração': 2,
      'Comunicação e Histórias': 2,
    });
    expect(_sum(suggestion.distribution), 8);
  });

  test('preserva presets de 9 e 10 brinquedos', () {
    final suggestion9 = buildDistribution(9, const [
      'Sentidos e Exploração',
      'Comunicação e Histórias',
      'Imaginação e Criatividade',
      'Mãos e Construção',
    ]);
    final suggestion10 = buildDistribution(10, const [
      'Corpo e Respiração',
      'Sentidos e Exploração',
      'Mãos e Construção',
      'Imaginação e Criatividade',
      'Comunicação e Histórias',
    ]);

    expect(suggestion9.total, 9);
    expect(_sum(suggestion9.distribution), 9);
    expect(suggestion10.total, 10);
    expect(_sum(suggestion10.distribution), 10);
  });
}

int _sum(Map<String, int> distribution) {
  return distribution.values.fold<int>(0, (sum, value) => sum + value);
}
