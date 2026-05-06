class CategoryDistributionSuggestion {
  final Map<String, int> distribution;
  final int total;

  const CategoryDistributionSuggestion({
    required this.distribution,
    required this.total,
  });
}

CategoryDistributionSuggestion buildDistribution(int total) {
  final Map<String, int> dist = {
    'Coordena\u00E7\u00E3o': 0,
    'Constru\u00E7\u00E3o': 0,
    'Faz de conta': 0,
    'Livros': 0,
    'Movimento': 0,
    'M\u00FAsica': 0,
    'Artes': 0,
  };

  void add(String key) {
    dist[key] = (dist[key] ?? 0) + 1;
  }

  if (total <= 5) {
    add('Coordena\u00E7\u00E3o');
    add('Constru\u00E7\u00E3o');
    add('Faz de conta');
    add('Livros');
    add('Artes');
  } else if (total == 6) {
    add('Coordena\u00E7\u00E3o');
    add('Coordena\u00E7\u00E3o');
    add('Constru\u00E7\u00E3o');
    add('Faz de conta');
    add('Livros');
    add('Artes');
  } else if (total == 7) {
    add('Coordena\u00E7\u00E3o');
    add('Coordena\u00E7\u00E3o');
    add('Constru\u00E7\u00E3o');
    add('Constru\u00E7\u00E3o');
    add('Faz de conta');
    add('Livros');
    add('Artes');
  } else if (total == 8) {
    add('Coordena\u00E7\u00E3o');
    add('Coordena\u00E7\u00E3o');
    add('Constru\u00E7\u00E3o');
    add('Constru\u00E7\u00E3o');
    add('Faz de conta');
    add('Faz de conta');
    add('Livros');
    add('Artes');
  } else if (total == 9) {
    add('Coordena\u00E7\u00E3o');
    add('Coordena\u00E7\u00E3o');
    add('Constru\u00E7\u00E3o');
    add('Constru\u00E7\u00E3o');
    add('Faz de conta');
    add('Faz de conta');
    add('Livros');
    add('Movimento');
    add('Artes');
  } else {
    add('Coordena\u00E7\u00E3o');
    add('Coordena\u00E7\u00E3o');
    add('Constru\u00E7\u00E3o');
    add('Constru\u00E7\u00E3o');
    add('Faz de conta');
    add('Faz de conta');
    add('Livros');
    add('Movimento');
    add('M\u00FAsica');
    add('Artes');
  }

  return CategoryDistributionSuggestion(
    distribution: dist,
    total: total,
  );
}
